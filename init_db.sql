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
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- horários de atendimento (consultas e exames separados)
    horarios_atendimento_consultas JSONB DEFAULT '[]'::jsonb,
    horarios_atendimento_exames JSONB DEFAULT '[]'::jsonb
);


-- ==============================
-- Tabela de Pacientes
-- ==============================
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

-- ==============================
-- Tabela de Profissionais
-- ==============================
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

-- ==============================
-- Tabela de Administradores de Hospital
-- ==============================
CREATE TABLE IF NOT EXISTS administradores_hospital (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    foto_url TEXT,
    data_nascimento DATE,
    senha VARCHAR(100) NOT NULL,
    hospital_id INT REFERENCES hospitais(id),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) DEFAULT 'ativo'
);

-- ==============================
-- Tabela de Consultas
-- ==============================
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

-- ==============================
-- Tabela de Exames
-- ==============================
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

-- ==============================
-- Tabela de Administradores do Sistema Moyo
-- ==============================
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


CREATE TABLE IF NOT EXISTS hospital_schedules (
    id SERIAL PRIMARY KEY,
    hospital_id INT NOT NULL REFERENCES hospitais(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('consultation', 'exam')),
    time_slot VARCHAR(50) NOT NULL,
    professionals INT,
    rooms INT,
    patients_per_slot INT NOT NULL,
    UNIQUE(hospital_id, time_slot, type)


);
CREATE TABLE IF NOT EXISTS horarios_hospital (
    id SERIAL PRIMARY KEY,
    hospital_id INT REFERENCES hospitais(id) ON DELETE CASCADE,
    nome_hospital VARCHAR(255),
    dias_semana TEXT[],
    horario_matriz JSONB,
    tipo_servico TEXT[],
    vagas_por_hora INTEGER[],
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS horarios_consulta (
    id SERIAL PRIMARY KEY,
    hospital_id INT REFERENCES hospitais(id) ON DELETE CASCADE,
    dia_semana VARCHAR(20) NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    vagas_por_hora INTEGER DEFAULT 1,
    profissionais_disponiveis INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- Tabela de Horários de Exame
-- ==============================
CREATE TABLE IF NOT EXISTS horarios_exame (
    id SERIAL PRIMARY KEY,
    hospital_id INT REFERENCES hospitais(id) ON DELETE CASCADE,
    dia_semana VARCHAR(20) NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    salas_disponiveis INTEGER DEFAULT 1,
    vagas_por_hora INTEGER DEFAULT 1,
    tipo_exame VARCHAR(100),
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);