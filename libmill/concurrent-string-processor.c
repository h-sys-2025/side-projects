#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libmill.h>

#define string char*

coroutine void worker(chan input, chan output) {
    while (1) {
        string work = chr(input, string);  // Receive work
        if (work == NULL) break;         // NULL signals shutdown
        system(work);
        msleep(now() + 1);
        int len = strlen(work);
        chs(output, int, len);           // Send result
    }
}

int main() {
    string tasks[] = {"ls -la","whoami","lolcat /etc/passwd"};
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
        chs(input, string, (string)tasks[i]);
    }

    // Collect results
    for (int i = 0; i < num_tasks; i++) {
        int len = chr(output, int);
        printf("Result: %d\n", len);
    }

    // Stop all workers
    for (int i = 0; i < num_workers; i++) {
        chs(input, string, NULL);
    }

    // close channel!
    chclose(input);
    chclose(output);

    return 0;
}