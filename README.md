# Adept GIC Lead Tracker

Standalone Node.js edition with email-and-password sign-in, SQLite, and role-based access. The repository starts with an empty tracker.

## Run locally

Use Node.js 24 or later. From the repository root, build the app and set the initial administrator’s email.

```bash
npm run build
export TRACKER_ADMIN_EMAIL=admin@example.com
export TRACKER_ORIGIN=http://localhost:3000
```

On Bash, create the admin login using a password of at least 15 characters. The prompt hides the password and the command reads it from stdin.

```bash
read -rsp 'New tracker password: ' tracker_password
printf '\n'
printf '%s\n' "$tracker_password" | npm run account -- "$TRACKER_ADMIN_EMAIL"
unset tracker_password
npm start
```

Open http://localhost:3000 and sign in. Changing a password with the account command also revokes that account’s sessions.

## Add employees

1. In User Administration, save the employee’s email and tracker role.
2. On the host, repeat the hidden-password command with the employee’s email in place of "$TRACKER_ADMIN_EMAIL". Run it against the same database as the server.
3. Send the invitation from User Administration and share the initial password through a separate approved channel. The hosting operator handles password resets with the account command.

Removing a tracker role blocks access to tracker records. The app enforces Sales, Ops, Management and Admin permissions on the server.

## Deploy from GitHub

Push this directory to a GitHub repository, then use a Node.js host with a persistent disk. Run `npm run build` before `npm start`. Set these values in the host environment.

| Setting | Value |
| --- | --- |
| TRACKER_ADMIN_EMAIL | Initial administrator’s email |
| TRACKER_ORIGIN | Exact HTTPS URL users visit, with no path |
| TRACKER_DB | Absolute path to the SQLite database on the persistent disk |
| TRACKER_HOST | Bind address, defaults to 127.0.0.1 |
| PORT | Port, defaults to 3000 |

Use one running app instance with this SQLite database and terminate HTTPS at the host or reverse proxy. Some managed hosts require TRACKER_HOST=0.0.0.0 so the proxy can reach the process. Keep the SQLite database and its companion files on the persistent disk. GitHub holds the source code, and the Node.js host runs the app.

To move tracker records, use Export backup in the earlier tracker and Merge browser backup as Admin in this edition. Create employee credentials and roles for the new deployment.

## Import Master Leads

Install Python 3 and run `python3 -m pip install -r requirements.txt` in
the Python environment the server uses. On Windows, use
`py -m pip install -r requirements.txt`. Set TRACKER_PYTHON to the Python
executable path if using a virtual environment.

Sign in as Admin and select **Import Master Leads**, then choose your .xlsx
file. For Google Sheets, download it as Microsoft Excel (.xlsx). Keep the
Master Leads sheet name, headers and data. Setup!G6 supplies the reporting
currency (INR or USD). Calculated columns are skipped. Invalid rows stop
the import and are listed in the status message. Existing tracker values
take priority when both the lead number and company match. The tracker
renumbers ID collisions for different companies. Imported records enter
as existing leads outside the new-lead audit queue.

## Docker deployment

Build with `docker build -t adept-tracker .`. Create a named volume with
`docker volume create adept-tracker-data`. Configure a hosting provider or
reverse proxy to serve HTTPS and forward requests to container port 3000.
Set TRACKER_ORIGIN to the exact HTTPS URL of your tracker.

Start the container, replacing the URL with yours:

```bash
docker run -d --name adept-tracker --restart unless-stopped \
  -p 127.0.0.1:3000:3000 -v adept-tracker-data:/data \
  -e TRACKER_ORIGIN=https://tracker.example.com \
  -e TRACKER_ADMIN_EMAIL=darshan@adeptgic.com adept-tracker
```

The port mapping above assumes your reverse proxy runs on the same host.
On a managed container host, attach persistent storage at /data with
write access for the container user and route HTTPS to port 3000.

Create the initial admin login from Bash on the host:

```bash
read -rsp 'New tracker password: ' tracker_password
printf '\n'
printf '%s\n' "$tracker_password" | docker exec -i adept-tracker node standalone/account.mjs darshan@adeptgic.com
unset tracker_password
```

The app starts with an empty database. Keep the volume for future updates.
