-- Criar tabela de exames
CREATE TABLE IF NOT EXISTS exames (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    disponivel BOOLEAN DEFAULT true,
    profissional_id INT REFERENCES profissionais(id),
    paciente_id INT REFERENCES pacientes(id),
    hospital_id INT REFERENCES hospitais(id),
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'agendado',
    resultado TEXT,
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);