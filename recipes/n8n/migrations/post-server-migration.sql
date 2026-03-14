-- n8n post-server migration
-- Executed after n8n is healthy and has created its schema.

-- 1. Enable MCP (Model Context Protocol) feature
INSERT INTO settings (key, value, "loadOnStartup")
VALUES ('mcp', '{"enabled": true}', true)
ON CONFLICT (key) DO UPDATE SET
  value = '{"enabled": true}',
  "loadOnStartup" = true;

-- 2. Create service account user (Sulla Desktop)
-- Uses a known UUID so the Sulla Desktop seeders can find/update it.
-- Password and API key are managed by Sulla Desktop's TypeScript seeders
-- which handle bcrypt hashing and JWT generation at runtime.
INSERT INTO "user" (
  id,
  email,
  "firstName",
  "lastName",
  "personalizationAnswers",
  settings,
  disabled,
  "mfaEnabled",
  "mfaSecret",
  "mfaRecoveryCodes",
  role,
  password
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '{{sullaEmail}}',
  'Sulla',
  'Desktop',
  '{}',
  '{"userActivated": true}',
  false,
  false,
  '',
  '',
  'global:owner',
  'placeholder-managed-by-sulla-desktop'
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  "firstName" = EXCLUDED."firstName",
  "lastName" = EXCLUDED."lastName",
  settings = EXCLUDED.settings,
  disabled = EXCLUDED.disabled,
  role = EXCLUDED.role;

-- 3. Make all existing workflows available in MCP
UPDATE workflow
SET settings = COALESCE(settings, '{}')::jsonb || '{"availableInMCP": true}'::jsonb
WHERE settings IS NULL
   OR settings::jsonb ->> 'availableInMCP' IS NULL
   OR settings::jsonb ->> 'availableInMCP' != 'true';
