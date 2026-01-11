# GitHub Secrets Configuration

## GitHub App: minicontratos

**Purpose:** Authenticate GitHub Actions to add issues/PRs to Mission Control Project.

**Repository:** https://github.com/danvoulez/lab.voulezvous.tv

**App Details:**
- App Name: `minicontratos`
- App ID: `1460425`
- Client ID: `Iv23lig0W6ehBkwA2PFi`
- Installation ID: `99794544`
- Public Link: https://github.com/apps/minicontratos

---

## Required Secrets

Configure these in: **Repository → Settings → Secrets and variables → Actions**

⚠️ **Important:** Secret names cannot start with `GITHUB_`, so we use `APP_GITHUB_*` prefix.

### 1. APP_GITHUB_ID
```
1460425
```

### 2. APP_GITHUB_PRIVATE_KEY
```
-----BEGIN RSA PRIVATE KEY-----
[PEM content from protected file]
-----END RSA PRIVATE KEY-----
```

**⚠️ CRITICAL:** The private key PEM file is stored securely in the codebase. Do NOT commit it to git.

**How to add:**
1. Go to: https://github.com/danvoulez/lab.voulezvous.tv/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `APP_GITHUB_ID`
4. Value: `1460425`
5. Click **"Add secret"**
6. Repeat for `APP_GITHUB_PRIVATE_KEY` (paste full PEM content including BEGIN/END lines)

---

## Verification

After adding secrets, check:
1. ✅ Secrets appear in: Repo → Settings → Secrets and variables → Actions
2. ✅ GitHub App is installed in: https://github.com/settings/installations (or org settings if applicable)
3. ✅ App has access to: `lab.voulezvous.tv` repository
4. ✅ App has permissions:
   - ✅ Issues: Read & Write
   - ✅ Pull Requests: Read & Write
   - ✅ Projects: Read & Write

---

## Testing the Workflow

1. Create a test issue:
   ```bash
   gh issue create \
     --repo danvoulez/lab.voulezvous.tv \
     --title "Test Mission Control" \
     --body "Testing auto-add workflow" \
     --label "mission-control"
   ```

2. Check Actions tab: https://github.com/danvoulez/lab.voulezvous.tv/actions

3. Expected result:
   - ✅ Workflow runs successfully
   - ✅ Issue appears in Mission Control Project
   - ✅ Issue has default status (Todo or Triage)

---

## Troubleshooting

### "Error: Could not create JWT"
- ✅ Verify `APP_GITHUB_ID` is correct (no quotes, just digits)
- ✅ Verify `APP_GITHUB_PRIVATE_KEY` has full PEM content (with BEGIN/END lines)

### "Error: App not installed"
- ✅ Go to: https://github.com/apps/minicontratos
- ✅ Click **"Install"**
- ✅ Select: Organization `VoulezVous`
- ✅ Grant access to: All repositories (or select `voulezvous.tv`)

### "Error: Insufficient permissions"
- ✅ Go to: https://github.com/apps/minicontratos/installations
- ✅ Click **"Configure"**
- ✅ Repository permissions: Issues (Read & Write), Projects (Read & Write)
- ✅ Organization permissions: Projects (Read & Write)

---

## Security Notes

✅ GitHub App authentication is more secure than PATs:
- Scoped permissions (only what's needed)
- Time-limited tokens (1 hour expiry, auto-renewed)
- Auditable (all actions logged)
- Revocable at org level

⚠️ Never commit:
- Private key PEM file
- Client secret (`59f1a5125084627596704e1acec76c651b691b15`)
- Installation tokens (generated dynamically)

✅ Protected locations:
- Private key: Store in password manager or secure vault
- Secrets: GitHub repository settings only
- Client secret: Environment variables or vault

---

## Alternative: Manual Token (Fallback)

If GitHub App doesn't work, use classic PAT:

1. Create token: https://github.com/settings/tokens/new
2. Permissions:
   - ✅ `repo` (full control)
   - ✅ `project` (full control)
   - ✅ `org:read` (read org data)
3. Add as secret: `ADD_TO_PROJECT_TOKEN`
4. Update workflow to use: `${{ secrets.ADD_TO_PROJECT_TOKEN }}`

---

**Status:** ✅ Secrets documented, ready to configure in GitHub UI.
