import express from 'express';
import pkg from 'pg';
const { Pool } = pkg;

const router = express.Router();
const pool = new Pool();

// Listar todos os exames
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT e.*, p.nome as paciente_nome, pr.nome as profissional_nome 
      FROM exames e
      LEFT JOIN pacientes p ON e.paciente_id = p.id
      LEFT JOIN profissionais pr ON e.profissional_id = pr.id
      ORDER BY e.data_hora DESC
    `);
    res.json(rows);
  } catch (erro) {
    console.error('Erro ao buscar exames:', erro);
    res.status(500).json({ erro: 'Erro ao buscar exames' });
  }
});

// Criar novo exame
router.post('/', async (req, res) => {
  const { nome, data_hora, paciente_id, hospital_id } = req.body;
  
  try {
    const { rows } = await pool.query(`
      INSERT INTO exames (nome, data_hora, paciente_id, hospital_id, status, disponivel)
      VALUES ($1, $2, $3, $4, 'pendente', true)
      RETURNING *
    `, [nome, data_hora, paciente_id, hospital_id]);
    
    res.status(201).json(rows[0]);
  } catch (erro) {
    console.error('Erro ao criar exame:', erro);
    res.status(500).json({ erro: 'Erro ao criar exame' });
  }
});

// Atualizar status do exame
router.patch('/:id', async (req, res) => {
  const { id } = req.params;
  const { status, profissional_id } = req.body;

  try {
    const { rows } = await pool.query(`
      UPDATE exames 
      SET status = $1, profissional_id = $2
      WHERE id = $3
      RETURNING *
    `, [status, profissional_id, id]);

    if (rows.length === 0) {
      return res.status(404).json({ erro: 'Exame não encontrado' });
    }

    res.json(rows[0]);
  } catch (erro) {
    console.error('Erro ao atualizar exame:', erro);
    res.status(500).json({ erro: 'Erro ao atualizar exame' });
  }
});

// Excluir exame
router.delete('/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const { rows } = await pool.query('DELETE FROM exames WHERE id = $1 RETURNING *', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ erro: 'Exame não encontrado' });
    }

    res.json({ mensagem: 'Exame excluído com sucesso' });
  } catch (erro) {
    console.error('Erro ao excluir exame:', erro);
    res.status(500).json({ erro: 'Erro ao excluir exame' });
  }
});

// Buscar exames do paciente
router.get('/paciente/:pacienteId', async (req, res) => {
  try {
    console.log('Buscando exames para paciente:', req.params.pacienteId); // Debug
    const { pacienteId } = req.params;
    const query = `
      SELECT * FROM exames 
      WHERE paciente_id = $1 
      ORDER BY data_hora DESC
    `;
    const { rows } = await pool.query(query, [pacienteId]);
    console.log('Exames encontrados:', rows); // Debug
    res.json(rows);
  } catch (error) {
    console.error('Erro:', error);
    res.status(500).json({ error: 'Erro ao buscar exames' });
  }
});

export default router;