function backup_dotfiles
    set timestamp (date +%Y%m%d_%H%M%S)
    set log_file ~/.log/dotfiles_backup_$timestamp.log
    set symlink ~/.log/current_log

    # Create tarball and upload it using rclone
    tar -czvf ~/dotfiles_$timestamp.tar.gz ~/.* >$log_file 2>&1
    and rclone copy ~/dotfiles_$timestamp.tar.gz remote:path/to/directory >>$log_file 2>&1

    # Check if the commands were successful
    if test $status -ne 0
        # If there was an error, send a macOS notification
        terminal-notifier -message "Backup failed. Check the log for details." -title "Backup Notification"
    end

    # Remove the old symlink and create a new one to the current log
    if test -e $symlink
        rm $symlink
    end
    ln -s $log_file $symlink

    # Remove tarball
    rm ~/dotfiles_$timestamp.tar.gz

    # Rotate logs (keep only the 7 most recent)
    ls -t1 ~/.log/dotfiles_backup_*.log | tail -n +8 | xargs rm
end
