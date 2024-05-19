#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command>\n", argv[0]);
        exit(1);
    }

    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } else if (pid == 0) {
        printf("Child process. PID: %d\n", getpid());
        // Execute the command passed as an argument
        execl("/bin/sh", "sh", "-c", argv[1], (char *)NULL);
        perror("execl failed");
        exit(1);
    } else {
        printf("Parent process. PID: %d\n", getpid());
        
    }

    return 0;
}
