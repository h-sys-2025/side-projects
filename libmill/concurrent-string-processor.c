#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libmill.h>

coroutine void worker(chan input, chan output) {
    while (1) {
        char *work = chr(input, char*);  // Receive work
        if (work == NULL) break;         // NULL signals shutdown
        FILE *fp;
        char buffer[256];

        fp = popen("whoami", "r");
        if (fp == NULL) {
            perror("popen failed");
            return;
        }

        if (fgets(buffer, sizeof(buffer), fp) != NULL) {
            printf("Processed-string:\n\t%s", buffer);
        }

        pclose(fp);
        int len = strlen(work);
        chs(output, int, len);           // Send result
    }
}

int main() {
    const char *tasks[] = {"hello", "libmill", "concurrency", "C", "coroutine"};
    int num_tasks = sizeof(tasks) / sizeof(tasks[0]);
    int num_workers = 3;

    chan input = chmake(char*, 0);
    chan output = chmake(int, 0);

    // Start worker coroutines
    for (int i = 0; i < num_workers; i++) {
        go(worker(input, output));
    }

    // Send tasks
    for (int i = 0; i < num_tasks; i++) {
        chs(input, char*, (char*)tasks[i]);
    }

    // Collect results
    for (int i = 0; i < num_tasks; i++) {
        int len = chr(output, int);
        printf("Result: %d\n", len);
    }

    // Stop all workers
    for (int i = 0; i < num_workers; i++) {
        chs(input, char*, NULL);
    }

    // close channel!
    chclose(input);
    chclose(output);

    return 0;
}