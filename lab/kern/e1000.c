#include <kern/e1000.h>
#include <kern/pmap.h>
#include <kern/pci.h>
#include <inc/string.h>

// LAB 6: Your driver code here

volatile uint32_t *e1000;

struct e1000_tx_desc transmit_desc_array[32];
char transmit_buffer[32][1520];
struct e1000_tdh *tdh;
struct e1000_tdt *tdt;

struct e1000_rx_desc receive_desc_array[128];
char receive_buffer[128][1520];
struct e1000_rdh *rdh;
struct e1000_rdt *rdt;

uint32_t E1000_MAC[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};

void e1000_transmit_init();
void e1000_receive_init();


int 
pci_e1000_attach(struct pci_func *f)
{
    pci_func_enable(f);

    if (!f->reg_base[0])
		return -1;

    e1000 = mmio_map_region(f->reg_base[0], f->reg_size[0]);

    // status offest is 8
    uint32_t status = *(uint32_t *)E1000_ADDR(8);

    if (status != 0x80080783)
        return -1;
    
    e1000_transmit_init();
    e1000_receive_init();

    return 0;
}

void 
e1000_transmit_init()
{
    for (int i = 0; i < 32; i++) {
        transmit_desc_array[i].addr = PADDR(transmit_buffer[i]);
        transmit_desc_array[i].cmd = 0;
        transmit_desc_array[i].status |= E1000_TXD_STAT_DD;
    }

    struct e1000_tdlen *tdlen = (struct e1000_tdlen *)E1000_ADDR(E1000_TDLEN);
    tdlen->len = 32;

    uint32_t *tdbal = (uint32_t *)E1000_ADDR(E1000_TDBAL);
    *tdbal = PADDR(transmit_desc_array);

    uint32_t *tdbah = (uint32_t *)E1000_ADDR(E1000_TDBAH);
    *tdbah = 0;

    tdh = (struct e1000_tdh *)E1000_ADDR(E1000_TDH);
    tdh->tdh = 0;

    tdt = (struct e1000_tdt *)E1000_ADDR(E1000_TDT);
    tdt->tdt = 0;

    struct e1000_tctl *tctl = (struct e1000_tctl *)E1000_ADDR(E1000_TCTL);
    tctl->en = 1;
    tctl->psp = 1;
    tctl->ct = 0x10;
    tctl->cold = 0x40;

    struct e1000_tipg *tipg = (struct e1000_tipg *)E1000_ADDR(E1000_TIPG);
    tipg->ipgt = 10;
    tipg->ipgr1 = 4;
    tipg->ipgr2 = 6;

}


int
e1000_transmit(char *data, uint32_t len)
{
    uint32_t current = tdt->tdt;

    if(!(transmit_desc_array[current].status & E1000_TXD_STAT_DD)) {
        return -1;
    }

    transmit_desc_array[current].length = len;
    transmit_desc_array[current].status &= ~E1000_TXD_STAT_DD;
    transmit_desc_array[current].cmd |= (E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS);

    memcpy(transmit_buffer[current], data, len);
    uint32_t next = (current + 1) % 32;
    tdt->tdt = next;

    return 0;
}

void
get_ra_address(uint32_t mac[], uint32_t *ral, uint32_t *rah)
{
    uint32_t low = 0, high = 0;
    int i;

    for (i = 0; i < 4; i++) {
            low |= mac[i] << (8 * i);
    }

    for (i = 4; i < 6; i++) {
            high |= mac[i] << (8 * i);
    }

    *ral = low;
    *rah = high | E1000_RAH_AV;
}

void
e1000_receive_init()
{
    uint32_t *rdbal = (uint32_t *)E1000_ADDR(E1000_RDBAL);
    uint32_t *rdbah = (uint32_t *)E1000_ADDR(E1000_RDBAH);
    *rdbal = PADDR(receive_desc_array);
    *rdbah = 0;

    int i;
    for (i = 0; i < 128; i++) {
            receive_desc_array[i].addr = PADDR(receive_buffer[i]);
    }

    struct e1000_rdlen *rdlen = (struct e1000_rdlen *)E1000_ADDR(E1000_RDLEN);
    rdlen->len = 128;

    rdh = (struct e1000_rdh *)E1000_ADDR(E1000_RDH);
    rdt = (struct e1000_rdt *)E1000_ADDR(E1000_RDT);
    rdh->rdh = 0;
    rdt->rdt = 128-1;

    uint32_t *rctl = (uint32_t *)E1000_ADDR(E1000_RCTL);
    *rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SECRC;

    uint32_t *ra = (uint32_t *)E1000_ADDR(E1000_RA);
    uint32_t ral, rah;
    get_ra_address(E1000_MAC, &ral, &rah);
    ra[0] = ral;
    ra[1] = rah;
}

int
e1000_receive(char *addr, uint32_t *len)
{
    static int32_t next = 0;
    if(!(receive_desc_array[next].status & E1000_RXD_STAT_DD)) {	//simply tell client to retry
        return -2;
    }
    if(receive_desc_array[next].errors) {
        cprintf("receive errors\n");
        return -2;
    }

    *len = receive_desc_array[next].length;
    memcpy(addr, receive_buffer[next], *len);

    rdt->rdt = (rdt->rdt + 1) % 128;
    next = (next + 1) % 128;
    return 0;
}