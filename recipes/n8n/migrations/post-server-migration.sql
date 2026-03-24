-- n8n post-server migration
-- Executed after n8n is healthy and has created its schema.
-- All template variables ({{...}}) are resolved by Sulla's recipe installer
-- at install time, including bcrypt password hashing and JWT API key generation.

-- 1. Enable MCP (Model Context Protocol) feature
INSERT INTO settings (key, value, "loadOnStartup")
VALUES ('mcp', '{"enabled": true}', true)
ON CONFLICT (key) DO UPDATE SET
  value = '{"enabled": true}',
  "loadOnStartup" = true;

-- 2. Create service account user (Sulla Desktop)
-- Password is bcrypt-hashed at install time via the {{...|bcrypt}} modifier.
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
  '{{sullaServicePassword|bcrypt}}'
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  "firstName" = EXCLUDED."firstName",
  "lastName" = EXCLUDED."lastName",
  settings = EXCLUDED.settings,
  disabled = EXCLUDED.disabled,
  role = EXCLUDED.role,
  password = EXCLUDED.password;

-- 3. Create API key for the service account
-- JWT token is pre-generated at first-run and stored as sullaN8nApiKey.
INSERT INTO user_api_keys (
  id,
  "userId",
  label,
  "apiKey",
  scopes,
  audience,
  "createdAt",
  "updatedAt"
)
VALUES (
  '{{sullaN8nApiKeyId}}',
  '00000000-0000-0000-0000-000000000001',
  'Sulla Integration',
  '{{sullaN8nApiKey}}',
  '["credential:list","credential:read","credential:move","credential:create","credential:update","credential:delete","project:create","project:update","project:delete","project:list","securityAudit:generate","sourceControl:pull","tag:create","tag:read","tag:update","tag:delete","tag:list","user:changeRole","user:enforceMfa","user:create","user:read","user:delete","user:list","workflow:execute","workflow:read","workflow:create","workflow:update","workflow:delete","workflow:list","workflow:share","workflow:share:read","workflow:share:create","workflow:share:update","workflow:share:delete","workflow:share:list","variable:read","variable:create","variable:update","variable:delete","execution:read","execution:create","execution:delete","dataTable:read","dataTable:create","dataTable:update","dataTable:delete"]',
  'public-api',
  NOW(),
  NOW()
)
ON CONFLICT (id)
DO UPDATE SET
  "apiKey" = EXCLUDED."apiKey",
  "updatedAt" = NOW();

-- 4. Make all existing workflows available in MCP
UPDATE workflow
SET settings = COALESCE(settings, '{}')::jsonb || '{"availableInMCP": true}'::jsonb
WHERE settings IS NULL
   OR settings::jsonb ->> 'availableInMCP' IS NULL
   OR settings::jsonb ->> 'availableInMCP' != 'true';
