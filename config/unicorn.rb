# gives us a bit of concurrency in development too.
worker_processes 2

# Kill workers that hang for over 60 seconds.
timeout 60
