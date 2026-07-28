#include <stdio.h>

int main() {
    int a, b, cin, sum, cout;
    FILE *fp = fopen("expected_outputs.txt", "w");

    printf("a  b  cin | sum  cout\n");
    printf("----------------------\n");

    for (a = 0; a <= 1; a++) {
        for (b = 0; b <= 1; b++) {
            for (cin = 0; cin <= 1; cin++) {
                sum  = a ^ b ^ cin;
                cout = (a & b) | (b & cin) | (a & cin);

                printf("%d  %d   %d  |  %d    %d\n", a, b, cin, sum, cout);

                if (fp)
                    fprintf(fp, "%d %d %d %d %d\n", a, b, cin, sum, cout);
            }
        }
    }

    if (fp) fclose(fp);
    printf("\nGolden reference written to expected_outputs.txt\n");
    return 0;
}
