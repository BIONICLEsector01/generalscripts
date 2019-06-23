#!/bin/bash

items_to_update=(
	'/home/swert/biosector01.com'
	'/home/swert/biosector01.com/errors'
)

unneeded_updates=()
successful_updates=()
failed_updates=()

# adapted from https://stackoverflow.com/a/3278427
# Determines whether or not the branch currently at the argument's path has
# upstream changes.
# Echos:
# 1: local copy needs to be updated
# 0: local copy doesn't need to be updated
# -1: local copy needs to be pushed
# -2: local copy and upstream have diverged
# -3: local copy has uncommitted changes
needs_update () {
	# if files in version control have local changes
	if [ -n "$(git ls-files -m)" ]; then
		echo -3
	fi

	local upstream='@{u}'
	local local_id=$(git rev-parse @)
	local remote_id=$(git rev-parse "$upstream")
	local base_id=$(git merge-base @ "$upstream") # last common ancestor of local and remote

	if [ $local_id = $remote_id ]; then # don't need to do anything
		echo 0
	elif [ $local_id = $base_id ]; then # need pull
		echo 1
	elif [ $remote_id = $base_id ]; then # need push
		echo -1
	else # diverged
		echo -2
	fi
}

# if possible, update the argument with git pull
update_item_if_needed () {
	cd $1
	git fetch -q
	case $(needs_update $1) in
		0)
			echo -e "\t$1: already up-to-date"
			unneeded_updates+="$1"
			;;
		1)
			echo -e "\t$1: updating from remote..."
			git pull
			successful_updates+="$1"
			;;
		-1)
			echo -e "\t$1: can't update (local is ahead of remote, need to push)"
			failed_updates+="$1: local is ahead of remote"
			;;
		-2)
			echo -e "\t$1: can't update (local and remote diverged)"
			failed_updates+="$1: local and remote diverged"
			;;
		-3)
			echo -e "\t$1: can't update (local has uncommitted changes)"
			failed_updates+="$1: local has uncommitted changes"
			;;
	esac
}

update () {
	echo 'Attempting updates from git...'

	# perform updates
	for i in "${items_to_update[@]}"
	do
		update_item_if_needed $i
	done

	# echo '#################################################'
	# echo

	echo 'Finished updating!'
	echo

	echo "Summary:"

	if ! [ ${#unneeded_updates[@]} -eq 0 ]; then
		echo -e "\t${#unneeded_updates[@]} directories were already up-to-date"
		for i in "${unneeded_updates[@]}"
		do
			echo -e "\t\t$i"
		done
	fi

	# if updates succeeded, print which ones
	if ! [ ${#succeeded_updates[@]} -eq 0 ]; then
		echo -e "\t${#succeeded_updates[@]} directories successfully updated"
		for i in "${succeeded_updates[@]}"
		do
			echo -e "\t\t$i"
		done
	fi

	# if updates failed, print which ones and why
	if ! [ ${#failed_updates[@]} -eq 0 ]; then
		echo -e "\t${#failed_updates[@]} directories failed to update"
		for i in "${failed_updates[@]}"
		do
			echo -e "\t\t$i"
		done
	fi
}

update
