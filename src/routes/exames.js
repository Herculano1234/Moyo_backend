import express from 'express';
import pkg from 'pg';
const { Pool } = pkg;

const router = express.Router();

const pool = new Pool({
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  host: process.env.PGHOST,
  port: process.env.PGPORT
});

// Buscar exames por hospital
router.get('/hospital/:hospitalId', async (req, res) => {
  try {
    const { hospitalId } = req.params;
    const query = `
      SELECT e.*, p.nome as profissional_nome, p.especialidade
      FROM exames e
      LEFT JOIN profissionais p ON e.profissional_id = p.id
      WHERE e.hospital_id = $1
      ORDER BY e.criado_em DESC
    `;
    const { rows } = await pool.query(query, [hospitalId]);
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao buscar exames' });
  }
});

// Criar novo exame
router.post('/', async (req, res) => {
  try {
    const { nome, hospital_id, data_hora, status } = req.body;
    const query = `
      INSERT INTO exames (nome, hospital_id, data_hora, status)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [nome, hospital_id, data_hora, status]);
    res.status(201).json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao criar exame' });
  }
});

// Atualizar disponibilidade do exame
router.patch('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { disponivel } = req.body;
    const query = `
      UPDATE exames 
      SET disponivel = $1
      WHERE id = $2
      RETURNING *
    `;
    const { rows } = await pool.query(query, [disponivel, id]);
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao atualizar exame' });
  }
});

// Atribuir exame a médico
router.patch('/:id/assign', async (req, res) => {
  try {
    const { id } = req.params;
    const { profissional_id } = req.body;
    const query = `
      UPDATE exames 
      SET profissional_id = $1
      WHERE id = $2
      RETURNING *
    `;
    const { rows } = await pool.query(query, [profissional_id, id]);
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao atribuir exame' });
  }
});

// Deletar exame
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'DELETE FROM exames WHERE id = $1 RETURNING *';
    const { rows } = await pool.query(query, [id]);
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao deletar exame' });
  }
});

export default router;