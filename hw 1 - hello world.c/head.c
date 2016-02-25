#include "types.h"
#include "stat.h"
#include "user.h"

char buf[512];

void head(int fd, char *name, int lines) {
      int i, n; //n means the size of the chunk read, i keeps track of index of the chunk
      int l, c; // l means line number, c means character count in string

      l = c = 0;
      //int lines = 10;

      char string[512];

      while ((n = read(fd, buf, sizeof(buf))) > 0) {
            for (i = 0; i < n; i++) {
                  if (buf[i] == '\n') {
                        l++; //Increment line upon new line char
                        printf(1, "%s\n", string);
                        memset(string, 0, 512);
                        c = 0;
                  }
                  else {
                        string[c] = buf[i];
                        c++;
                  }
                  if (l == lines) {
                        exit();
                  }
            }
      }
}

int main(int argc, char *argv[]) {
      int fd, i, lines;
      char *name;

      fd = 0; //default, no file specified, so takes user input instead
      name = ""; //default, assuming no file name specified
      lines = 10; //default 10 lines to read

      if (argc <= 1) {
            head(fd, name, lines);
            exit();
      }

      else {
            for (i = 1; i < argc; i++) {
                  if (atoi(argv[i]) == 0 && *argv[i] != '0' && *argv[i] != '-') {//executes if not a number
                        if ((fd = open(argv[i], 0)) < 0) {//executes if can't open the file
                        //If fd == 0, end of file, if fd == -1, error
                        printf(1, "head: cannot open %s\n", argv[i]);
                        exit();
                        }
                        //name = argv[i];
                  }
                  else {//it's a number
			//*argv[i] = 1;
			argv[i]++;
                        lines = atoi(argv[i]++);
                  }
/*
                  head(fd, name, lines);
                  close(fd);
*/
            }
            head(fd, name, lines);
            close(fd);
            exit();
      }
}
