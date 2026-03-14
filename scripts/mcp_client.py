"""
MCP API client for Telvar game project.
Lets the Claude session here call back to the Master Control Program.

Usage:
    python scripts/mcp_client.py status          # phase status for spec 189
    python scripts/mcp_client.py submit_conductor # fire conductor
    python scripts/mcp_client.py jobs            # recent TELVAR jobs
"""
import json, os, sys, urllib.request, urllib.error

MCP_URL = os.getenv("MCP_URL", "http://localhost:8765")
API_KEY = os.getenv("EFN_API_KEY", "w3vVEK-1PdIXAukUMyJwpLM2k2Hi62aaD-UZeEl5XwM")
SPEC_ID = 189


def _get(path):
    req = urllib.request.Request(f"{MCP_URL}{path}", headers={"X-API-Key": API_KEY})
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.load(r)


def _post(path, body):
    data = json.dumps(body).encode()
    req = urllib.request.Request(f"{MCP_URL}{path}", data=data,
        headers={"X-API-Key": API_KEY, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.load(r)


def phase_status():
    phases = _get(f"/coding/specs/{SPEC_ID}/phases").get("phases", [])
    print(f"Spec {SPEC_ID} — {len(phases)} phases:")
    for p in phases:
        print(f"  {p['seq']:2} [{p['status']:14}] {p['title']}")


def recent_jobs(limit=10):
    data = _get(f"/batch/jobs?limit={limit}").get("data", [])
    print(f"Recent {limit} jobs:")
    for j in data:
        print(f"  #{j['id']:5} [{j['status']:10}] {j['job_type']:30} {j.get('title','')[:50]}")


def submit_conductor():
    r = _post("/batch/submit", {
        "job_type": "coding_conductor",
        "title": f"Conductor: Telvar spec {SPEC_ID}",
        "program": "TELVAR",
        "params": {"spec_id": SPEC_ID},
        "priority": 5,
        "created_by": "telvar_mcp_client",
    })
    print(f"Conductor submitted: job #{r.get('job_id')}")


def send_nexus(message: str, to_program: str = "MCP"):
    """Send a Nexus message to another agent (e.g. back to Mark via MCP)."""
    r = _post("/nexus/messages", {
        "from_program": "TELVAR",
        "to_program": to_program,
        "message": message,
        "message_type": "info",
    })
    print(f"Nexus message sent: {r}")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "status":
        phase_status()
    elif cmd == "jobs":
        recent_jobs()
    elif cmd == "submit_conductor":
        submit_conductor()
    elif cmd == "nexus":
        msg = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else "ping from Telvar session"
        send_nexus(msg)
    else:
        print(f"Unknown command: {cmd}")
        print("Commands: status, jobs, submit_conductor, nexus <message>")
