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

void e1000_transmit_init();


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
    // e1000_receive_init();

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