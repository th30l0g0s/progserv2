-- Exécuté uniquement à la première création de la BDD
CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  contenu VARCHAR(255) NOT NULL,
  cree_le TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO messages (contenu) VALUES ('Connexion à MariaDB OK');
