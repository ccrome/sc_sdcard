/*
 * Simple parallel streaming tests
 */

#include <xs1.h>
#include <stdint.h>

// Generate predictable pseudo-random traffic (that we can compare against for proof of testing)
#define CRC32_ETH_REV_POLY 0xEDB88320       // x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + x^0
                                            // See https://github.com/xcore/doc_tips_and_tricks/blob/master/doc/crc.rst

const unsigned seedval = 0xf00dbeef;
/*
 * CRC-32 seed and walk functions - pointer-passing version
 */
void init_the_crc(unsigned *p)
{
    *p = seedval;
}

void walk_the_crc(unsigned *p)
{
    crc32(*p, 0, CRC32_ETH_REV_POLY);
}

void crc_stream_to(streaming chanend c)
{
    unsigned p;
    init_the_crc(&p);
    while(1) {
        c <: p;
        walk_the_crc(&p);
    }
}

extern void disk_write_read_task(streaming chanend c);

int main(void)
{
    streaming chan c;
    par {
        disk_write_read_task(c);
        crc_stream_to(c);
    }
    return 0;
}
