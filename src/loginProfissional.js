import { Router } from 'express';
import * as bcrypt from 'bcryptjs';
import { Pool } from 'pg';

const router = Router();
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

router.post('/login-profissional', async (req, res) => {
  const { email, senha } = req.body;
  if (!email || !senha) return res.status(400).json({ error: 'Campos obrigatórios' });
  try {
    const result = await pool.query('SELECT * FROM profissionais WHERE email = $1', [email]);
    if (result.rows.length === 0) return res.status(401).json({ error: 'Usuário não encontrado' });
    const profissional = result.rows[0];
    if (profissional.status !== 'aprovado') {
      return res.status(403).json({ error: 'Conta pendente de aprovação pelo admin do hospital.' });
    }
    const match = await bcrypt.compare(senha, profissional.senha_hash);
    if (!match) return res.status(401).json({ error: 'Senha incorreta' });
    res.json({ id: profissional.id, nome: profissional.nome, email: profissional.email, status: profissional.status });
  } catch (err) {
    res.status(500).json({ error: 'Erro ao autenticar profissional', detalhes: err.message });
  }
});

export default router;
