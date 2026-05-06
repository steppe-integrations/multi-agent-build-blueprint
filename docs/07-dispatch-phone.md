# Stage 6 — Dispatch Phone-Pairing

**Goal:** pair your phone to a Cowork desktop session via QR code. The phone becomes a remote control for that session.

**Time:** ~5 minutes.

**Depends on:** Stage 3 (Cowork desktop running).

---

## Why Dispatch (and why last)

Dispatch turns your phone into:
- A remote that kicks off jobs.
- A status reader without sitting at the desk.
- A prompt-paste surface (the phone keyboard is slower, but voice input is fine for short prompts).
- A log/output viewer.

It's *last* in this guide because it's an accelerant for an already-mature workflow, not the entry point. If you're not regularly away from your keyboard while builds are in flight, skip Stage 6.

---

## Steps

### 1. Install the Claude phone app

iOS or Android. Sign in with the same account you use for Cowork desktop.

### 2. Open the Cowork session you want to pair

In Cowork desktop, open the session. Find the **Pair Phone** menu item (typically `Session menu → Pair phone via QR`). A QR code appears.

### 3. Scan the QR

In the phone app, navigate to **Dispatch** (typically a tab or sidebar item). Tap **Pair Session** and scan the QR code from your desktop.

### 4. Verify the pairing

The phone should now show the session's chat history and an input box. Type a message; it appears on the desktop session.

### 5. Test ambient interaction

- From the phone: paste a status-digest request, send. The session responds.
- From the desktop: continue working. The phone updates in real-time.
- Walk away from the desk. Watch the build progress on your phone.

---

## Patterns that work well

### Pattern A — Phone + 3-PC + Routines

The phone pairs to **PC 3** (the always-on machine). PC 3 has a Cowork session whose only job is reading state. The phone polls digests from this session. PC 1 and PC 2 are doing the actual work; the phone never directly touches them.

### Pattern B — Phone + orchestrator session

The phone pairs to **PC 1's orchestrator session**. You ack design proposals, paste short directives, and read status from the field. PC 1 must be awake.

### Pattern C — Voice-input prompts

The phone keyboard is slow. Voice-input is fast. Speak a short prompt; the session takes over from there. Long-form prompts still go from the desktop.

---

## Verification command

There isn't a useful programmatic verify for Stage 6. The verify is: does scanning the QR pair the session? Does typing a message show up on both devices?

If yes → Stage 6 done.

---

## Common pitfalls

- **QR doesn't scan.** Make sure the phone has camera permission for the Claude app. Try increasing brightness on the desktop.
- **Pairing succeeds but phone shows empty session.** Cowork hasn't pushed history yet. Wait 5–10s, then refresh.
- **Phone goes to sleep mid-build.** OS-level sleep can drop the connection. Reopen the app to reconnect; conversation history is preserved.
- **Phone updates lag.** Check your network. Both devices need internet (the pairing routes through Anthropic's servers, not direct LAN).
- **Multiple phones, one session.** Pair multiple phones to the same session. Useful for team standups.

---

## Security note

The QR code is short-lived but acts as an auth credential while valid. Don't:
- Screenshot the QR and post it anywhere.
- Pair untrusted devices to your sessions.
- Leave a QR visible on a streaming/recorded screen.

The pairing handshake is encrypted, but possession of the QR during its valid window = ability to pair.

---

## What you have now

A phone paired to a Cowork session. Ambient awareness without sitting at the desk. The full Dispatch + MAF + OTel stack is operational.

---

## Where to go next

You've completed all six stages. Now:

- **Iterate on prompts.** The [`prompts/`](../prompts/) directory has starting points. Tune them for your project's voice.
- **Add ADRs.** As you make load-bearing decisions, capture them. Templates in [`adr-templates/`](../adr-templates/).
- **Seed your memory directory.** Use [`memory-templates/`](../memory-templates/) to set up `feedback_*.md` and `reference_*.md` files for the cross-session continuity the methodology assumes.

The deepest leverage isn't in any one stage — it's in the discipline that keeps the substrate clean across many sessions over many months. See the [Five Layers methodology article](https://steppeintegrations.com/articles/five-layer-build-blueprint/) for that part of the story.
