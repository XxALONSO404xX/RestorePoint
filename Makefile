# === RestorePoint Makefile ===

backup:
	bash scripts/backup.sh

restore:
	bash scripts/restore.sh

save:
	bash scripts/saving.sh

logs:
	tail -n 30 logs/*.log

monitor:
	sensible-browser http://localhost:3000 &

help:
	@echo "Usage:"
	@echo "  make backup   - Run backup script"
	@echo "  make restore  - Run restore script"
	@echo "  make save     - Save system state"
	@echo "  make logs     - Tail the latest logs"
	@echo "  make monitor  - Open Grafana in browser"
