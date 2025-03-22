.DEFAULT_GOAL := backup-dotfiles

backup-dotfiles: 
	./backup_dotfiles.sh
	echo "backup done.."
	python _utils/remove_data.py


mj-backup: 
	./backup_dotfiles_mj.sh
	echo "backup done.."

help: ## Show all Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
