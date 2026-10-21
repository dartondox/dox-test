-- up
CREATE TABLE IF NOT EXISTS profiles (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    bio TEXT NULL,
    website VARCHAR(255) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
)

-- down
DROP TABLE IF EXISTS profiles
