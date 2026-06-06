# BestMedia Booking System

Local development workspace for the booking system.

## Development notes

- To enable password reset emails, copy `.env.example` to `.env` in `booking-system-backend` and set SMTP vars.
- Basic test commands (from project root):

```bash
# start backend
cd booking-system-backend
npm run start

# build frontend
cd ../booking-system-frontend
npm run build
```

If SMTP isn't configured, the backend will log reset codes to the console for development testing.

