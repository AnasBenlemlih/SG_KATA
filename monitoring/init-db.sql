-- Script d'initialisation de la base de données PostgreSQL
-- pour l'application Foo Bar Quix

-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS foobarquix;

-- Utiliser la base de données
\c foobarquix;

-- Créer les extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Créer la table pour les métriques de batch (optionnel)
CREATE TABLE IF NOT EXISTS batch_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    records_processed INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer un index sur la table des métriques
CREATE INDEX IF NOT EXISTS idx_batch_metrics_job_name ON batch_metrics(job_name);
CREATE INDEX IF NOT EXISTS idx_batch_metrics_start_time ON batch_metrics(start_time);

-- Insérer des données de test (optionnel)
INSERT INTO batch_metrics (job_name, start_time, end_time, status, records_processed, records_failed)
VALUES 
    ('numberTransformationJob', NOW() - INTERVAL '1 hour', NOW() - INTERVAL '55 minutes', 'COMPLETED', 100, 0),
    ('numberTransformationJob', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour 55 minutes', 'COMPLETED', 150, 2)
ON CONFLICT DO NOTHING;
