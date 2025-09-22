-- Script de inicialização do banco de dados PostgreSQL para o projeto Moyo
CREATE TABLE IF NOT EXISTS hospitais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    provincia VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    areas_trabalho TEXT,
    exames_disponiveis TEXT,
    telefone VARCHAR(50),
    email VARCHAR(100),
    site VARCHAR(255),
    tipo_unidade VARCHAR(100),
    categoria VARCHAR(100),
    nivel VARCHAR(100),
    data_fundacao DATE,
    redes_sociais TEXT,
    diretor VARCHAR(100),
    cargo_diretor VARCHAR(100),
    nif VARCHAR(50),
    horario VARCHAR(100),
    capacidade INTEGER DEFAULT 0,
    num_medicos INTEGER,
    num_enfermeiros INTEGER,
    capacidade_internamento VARCHAR(100),
    urgencia VARCHAR(10),
    salas_cirurgia VARCHAR(100),
    especialidades TEXT,
    laboratorio VARCHAR(10),
    farmacia VARCHAR(10),
    banco_sangue VARCHAR(10),
    servicos_imagem TEXT,
    ambulancia VARCHAR(10),
    seguradoras TEXT,
    acessibilidade VARCHAR(10),
    estacionamento VARCHAR(100),
    status VARCHAR(30),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Criar tabela de pacientes
CREATE TABLE IF NOT EXISTS pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    data_nascimento DATE  NOT NULL,
    sexo VARCHAR(10) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    endereco TEXT NOT NULL,
    bi VARCHAR(50),
    foto_perfil TEXT NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de profissionais
CREATE TABLE IF NOT EXISTS profissionais (
    id SERIAL PRIMARY KEY,
    hospital_id INT REFERENCES hospitais(id),
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE  NOT NULL,
    bi VARCHAR(50) NOT NULL,
    sexo VARCHAR(10) NOT NULL,
    morada TEXT NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    unidade VARCHAR(100) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    registro_profissional VARCHAR(50) NOT NULL,
    foto_perfil TEXT NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS administradores_hospital (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  telefone VARCHAR(20),
  foto_url TEXT,
  data_nascimento DATE,
  senha VARCHAR(100) NOT NULL,
  hospital_id INT REFERENCES hospitais(id),
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
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
-- Criar tabela de consultas
CREATE TABLE IF NOT EXISTS consultas (
    id SERIAL PRIMARY KEY,
    paciente_id INT REFERENCES pacientes(id) ON DELETE CASCADE,
    profissional_id INT REFERENCES profissionais(id) ON DELETE CASCADE,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'agendada',
    prioridade VARCHAR(10),
    local VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS administradores_moyo (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  telefone VARCHAR(20),
  foto_url TEXT,
  data_nascimento DATE,
  senha VARCHAR(100) NOT NULL,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Atualizar tabela de exames
CREATE TABLE IF NOT EXISTS exames (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    disponivel BOOLEAN DEFAULT true,
    profissional_id INTEGER REFERENCES profissionais(id),
    paciente_id INTEGER REFERENCES pacientes(id),
    hospital_id INTEGER REFERENCES hospitais(id),
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    resultado TEXT,
    observacoes TEXT,
    done_count INTEGER DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES hospitais(id),
    CONSTRAINT fk_profissional FOREIGN KEY (profissional_id) REFERENCES profissionais(id),
    CONSTRAINT fk_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
);
-- Adicionar coluna 'status' na tabela de administradores_hospital

-- Criar tabela de configuração de horários
CREATE TABLE IF NOT EXISTS horarios_config (
    id SERIAL PRIMARY KEY,
    hospital_id INTEGER REFERENCES hospitais(id),
    tipo VARCHAR(20) NOT NULL, -- 'consulta' ou 'exame'
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    num_profissionais INTEGER NOT NULL,
    atendimentos_por_hora INTEGER NOT NULL,
    dias_semana TEXT[], -- array com dias da semana ['segunda', 'terca', 'quarta', 'quinta', 'sexta']
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES hospitais(id)
);

-- Criar tabela de slots de horário
CREATE TABLE IF NOT EXISTS horarios_slots (
    id SERIAL PRIMARY KEY,
    hospital_id INTEGER REFERENCES hospitais(id),
    tipo VARCHAR(20) NOT NULL, -- 'consulta' ou 'exame'
    data_hora TIMESTAMP NOT NULL,
    vagas_totais INTEGER NOT NULL,
    vagas_ocupadas INTEGER DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES hospitais(id)
);

-- Criar tabela de horários dos hospitais
CREATE TABLE IF NOT EXISTS horario_hospitais (
    id SERIAL PRIMARY KEY,
    hospital_id INTEGER REFERENCES hospitais(id),
    nome_hospital VARCHAR(255) NOT NULL,
    dias_semana TEXT[] NOT NULL, -- ['segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo']
    horario_matriz JSONB NOT NULL, -- Matriz de horários em formato JSON
    tipo_servico VARCHAR(50)[], -- ['consulta', 'exame', 'urgencia', etc]
    vagas_por_hora INTEGER[], -- [20, 15, 30] etc
    observacoes TEXT,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hospital FOREIGN KEY (hospital_id) REFERENCES hospitais(id)
);

-- Inserir exemplo de configuração
INSERT INTO horarios_config (
    hospital_id,
    tipo,
    hora_inicio,
    hora_fim,
    num_profissionais,
    atendimentos_por_hora,
    dias_semana
) VALUES 
-- Configuração para consultas (10 médicos, 2 consultas por hora cada = 20 consultas/hora)
(1, 'consulta', '08:00', '17:00', 10, 2, ARRAY['segunda', 'terca', 'quarta', 'quinta', 'sexta']),
-- Configuração para exames (5 técnicos, 4 exames por hora cada = 20 exames/hora)
(1, 'exame', '08:00', '17:00', 5, 4, ARRAY['segunda', 'terca', 'quarta', 'quinta', 'sexta']);

-- Inserir exemplo de horário
INSERT INTO horario_hospitais (
    hospital_id,
    nome_hospital,
    dias_semana,
    horario_matriz,
    tipo_servico,
    vagas_por_hora,
    observacoes
) VALUES (
    1,
    'Hospital Exemplo',
    ARRAY['segunda', 'terca', 'quarta', 'quinta', 'sexta'],
    '{
        "consultas": {
            "manha": {
                "inicio": "08:00",
                "fim": "12:00",
                "vagas_por_hora": 20
            },
            "tarde": {
                "inicio": "14:00",
                "fim": "17:00",
                "vagas_por_hora": 15
            }
        },
        "exames": {
            "manha": {
                "inicio": "07:00",
                "fim": "11:00",
                "vagas_por_hora": 10
            },
            "tarde": {
                "inicio": "13:00",
                "fim": "16:00",
                "vagas_por_hora": 8
            }
        }
    }'::jsonb,
    ARRAY['consulta', 'exame'],
    ARRAY[20, 10],
    'Horários normais de funcionamento. Urgência 24h.'
);
