
obj/net/testinput:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 3e 07 00 00       	call   80076f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 b1 11 00 00       	call   8011f2 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 80 	movl   $0x802c80,0x804000
  80004a:	2c 80 00 

	output_envid = fork();
  80004d:	e8 09 15 00 00       	call   80155b <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 8a 2c 80 00       	push   $0x802c8a
  800063:	6a 4d                	push   $0x4d
  800065:	68 98 2c 80 00       	push   $0x802c98
  80006a:	e8 60 07 00 00       	call   8007cf <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 bd 03 00 00       	call   800439 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 d2 14 00 00       	call   80155b <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 8a 2c 80 00       	push   $0x802c8a
  80009a:	6a 55                	push   $0x55
  80009c:	68 98 2c 80 00       	push   $0x802c98
  8000a1:	e8 29 07 00 00       	call   8007cf <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 a8 2c 80 00       	push   $0x802ca8
  8000c3:	e8 e0 07 00 00       	call   8008a8 <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 c5 2c 80 00 	movl   $0x802cc5,(%esp)
  8000e7:	e8 51 06 00 00       	call   80073d <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 cf 2c 80 00 	movl   $0x802ccf,(%esp)
  8000f6:	e8 42 06 00 00       	call   80073d <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 21 11 00 00       	call   801230 <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 d8 2c 80 00       	push   $0x802cd8
  80011c:	6a 19                	push   $0x19
  80011e:	68 98 2c 80 00       	push   $0x802c98
  800123:	e8 a7 06 00 00       	call   8007cf <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 2c 0e 00 00       	call   800f72 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 ce 0e 00 00       	call   801027 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 bf 03 00 00       	call   800524 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 ad 03 00 00       	call   800524 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 9b 03 00 00       	call   800524 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 89 03 00 00       	call   800524 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 77 03 00 00       	call   800524 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 64 0e 00 00       	call   801027 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 51 0e 00 00       	call   801027 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 8b 0d 00 00       	call   800f72 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 2d 0e 00 00       	call   801027 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 6b 15 00 00       	call   801779 <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 98 10 00 00       	call   8012b5 <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 d3 14 00 00       	call   801712 <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 e9 2c 80 00       	push   $0x802ce9
  80024c:	6a 64                	push   $0x64
  80024e:	68 98 2c 80 00       	push   $0x802c98
  800253:	e8 77 05 00 00       	call   8007cf <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 40 2d 80 00       	push   $0x802d40
  800269:	6a 66                	push   $0x66
  80026b:	68 98 2c 80 00       	push   $0x802c98
  800270:	e8 5a 05 00 00       	call   8007cf <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 f6 2c 80 00       	push   $0x802cf6
  800280:	6a 68                	push   $0x68
  800282:	68 98 2c 80 00       	push   $0x802c98
  800287:	e8 43 05 00 00       	call   8007cf <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 08 2d 80 00       	push   $0x802d08
  8002b9:	68 10 2d 80 00       	push   $0x802d10
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 11 0b 00 00       	call   800dda <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 1a 2d 80 00       	push   $0x802d1a
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 ed 0a 00 00       	call   800dda <snprintf>
  8002ed:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002fa:	83 e7 0f             	and    $0xf,%edi
  8002fd:	29 c7                	sub    %eax,%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 ff 0f             	cmp    $0xf,%edi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f0                	mov    %esi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 1f 2d 80 00       	push   $0x802d1f
  800320:	e8 83 05 00 00       	call   8008a8 <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 06 20             	movb   $0x20,(%esi)
  80033d:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  800340:	83 ff 07             	cmp    $0x7,%edi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 06 20             	movb   $0x20,(%esi)
  800348:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 3b 2d 80 00       	push   $0x802d3b
  80035f:	e8 44 05 00 00       	call   8008a8 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 25 2d 80 00       	push   $0x802d25
  800378:	e8 2b 05 00 00       	call   8008a8 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 79 10 00 00       	call   801421 <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 65 	movl   $0x802d65,0x804000
  8003b4:	2d 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 50 0e 00 00       	call   801211 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 5b 10 00 00       	call   801421 <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 6e 2d 80 00       	push   $0x802d6e
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 80 2d 80 00       	push   $0x802d80
  8003e1:	e8 e9 03 00 00       	call   8007cf <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 87 13 00 00       	call   801779 <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 10 13 00 00       	call   801712 <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 8c 2d 80 00       	push   $0x802d8c
  800417:	e8 8c 04 00 00       	call   8008a8 <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 fb 0f 00 00       	call   801421 <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80042d:	c7 05 00 40 80 00 c7 	movl   $0x802dc7,0x804000
  800434:	2d 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <output>:



void
output(envid_t ns_envid)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 10             	sub    $0x10,%esp
	binaryname = "ns_output";
  800441:	c7 05 00 40 80 00 d0 	movl   $0x802dd0,0x804000
  800448:	2d 80 00 
	uint32_t whom;
    int perm;
    int32_t req;

    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
  80044b:	8d 75 f0             	lea    -0x10(%ebp),%esi
  80044e:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	56                   	push   %esi
  800455:	68 00 70 80 00       	push   $0x807000
  80045a:	53                   	push   %ebx
  80045b:	e8 b2 12 00 00       	call   801712 <ipc_recv>
        if (req != NSREQ_OUTPUT) {
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	83 f8 0b             	cmp    $0xb,%eax
  800466:	75 e9                	jne    800451 <output+0x18>
  800468:	eb 05                	jmp    80046f <output+0x36>
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
            sys_yield();
  80046a:	e8 a2 0d 00 00       	call   801211 <sys_yield>
    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
        if (req != NSREQ_OUTPUT) {
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	ff 35 00 70 80 00    	pushl  0x807000
  800478:	68 04 70 80 00       	push   $0x807004
  80047d:	e8 be 0f 00 00       	call   801440 <sys_e1000_try_send>
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 c0                	test   %eax,%eax
  800487:	78 e1                	js     80046a <output+0x31>
  800489:	eb c6                	jmp    800451 <output+0x18>

0080048b <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	57                   	push   %edi
  80048f:	56                   	push   %esi
  800490:	53                   	push   %ebx
  800491:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800494:	8b 45 08             	mov    0x8(%ebp),%eax
  800497:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80049a:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80049d:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  8004a4:	0f b6 0f             	movzbl (%edi),%ecx
  8004a7:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8004ac:	0f b6 d9             	movzbl %cl,%ebx
  8004af:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8004b2:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8004b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b8:	66 c1 e8 0b          	shr    $0xb,%ax
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004c1:	01 c0                	add    %eax,%eax
  8004c3:	29 c1                	sub    %eax,%ecx
  8004c5:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  8004c7:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  8004c9:	8d 72 01             	lea    0x1(%edx),%esi
  8004cc:	0f b6 d2             	movzbl %dl,%edx
  8004cf:	83 c0 30             	add    $0x30,%eax
  8004d2:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  8004d6:	89 f2                	mov    %esi,%edx
    } while(*ap);
  8004d8:	84 db                	test   %bl,%bl
  8004da:	75 d0                	jne    8004ac <inet_ntoa+0x21>
  8004dc:	c6 07 00             	movb   $0x0,(%edi)
  8004df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e2:	eb 0d                	jmp    8004f1 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004e4:	0f b6 c2             	movzbl %dl,%eax
  8004e7:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8004ec:	88 01                	mov    %al,(%ecx)
  8004ee:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8004f1:	83 ea 01             	sub    $0x1,%edx
  8004f4:	80 fa ff             	cmp    $0xff,%dl
  8004f7:	75 eb                	jne    8004e4 <inet_ntoa+0x59>
  8004f9:	89 f0                	mov    %esi,%eax
  8004fb:	0f b6 f0             	movzbl %al,%esi
  8004fe:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800501:	8d 46 01             	lea    0x1(%esi),%eax
  800504:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800507:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80050a:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80050d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800510:	39 c7                	cmp    %eax,%edi
  800512:	75 90                	jne    8004a4 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800514:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800517:	b8 08 50 80 00       	mov    $0x805008,%eax
  80051c:	83 c4 14             	add    $0x14,%esp
  80051f:	5b                   	pop    %ebx
  800520:	5e                   	pop    %esi
  800521:	5f                   	pop    %edi
  800522:	5d                   	pop    %ebp
  800523:	c3                   	ret    

00800524 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800527:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80052b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800534:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800538:	66 c1 c0 08          	rol    $0x8,%ax
}
  80053c:	5d                   	pop    %ebp
  80053d:	c3                   	ret    

0080053e <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800544:	89 d1                	mov    %edx,%ecx
  800546:	c1 e1 18             	shl    $0x18,%ecx
  800549:	89 d0                	mov    %edx,%eax
  80054b:	c1 e8 18             	shr    $0x18,%eax
  80054e:	09 c8                	or     %ecx,%eax
  800550:	89 d1                	mov    %edx,%ecx
  800552:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800558:	c1 e1 08             	shl    $0x8,%ecx
  80055b:	09 c8                	or     %ecx,%eax
  80055d:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800563:	c1 ea 08             	shr    $0x8,%edx
  800566:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	57                   	push   %edi
  80056e:	56                   	push   %esi
  80056f:	53                   	push   %ebx
  800570:	83 ec 20             	sub    $0x20,%esp
  800573:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800576:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800579:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  80057c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80057f:	0f b6 ca             	movzbl %dl,%ecx
  800582:	83 e9 30             	sub    $0x30,%ecx
  800585:	83 f9 09             	cmp    $0x9,%ecx
  800588:	0f 87 94 01 00 00    	ja     800722 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80058e:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800595:	83 fa 30             	cmp    $0x30,%edx
  800598:	75 2b                	jne    8005c5 <inet_aton+0x5b>
      c = *++cp;
  80059a:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80059e:	89 d1                	mov    %edx,%ecx
  8005a0:	83 e1 df             	and    $0xffffffdf,%ecx
  8005a3:	80 f9 58             	cmp    $0x58,%cl
  8005a6:	74 0f                	je     8005b7 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8005a8:	83 c0 01             	add    $0x1,%eax
  8005ab:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8005ae:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8005b5:	eb 0e                	jmp    8005c5 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8005b7:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8005bb:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8005be:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8005c5:	83 c0 01             	add    $0x1,%eax
  8005c8:	be 00 00 00 00       	mov    $0x0,%esi
  8005cd:	eb 03                	jmp    8005d2 <inet_aton+0x68>
  8005cf:	83 c0 01             	add    $0x1,%eax
  8005d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8005d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005d8:	0f b6 fa             	movzbl %dl,%edi
  8005db:	8d 4f d0             	lea    -0x30(%edi),%ecx
  8005de:	83 f9 09             	cmp    $0x9,%ecx
  8005e1:	77 0d                	ja     8005f0 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005e3:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005e7:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8005eb:	0f be 10             	movsbl (%eax),%edx
  8005ee:	eb df                	jmp    8005cf <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8005f0:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8005f4:	75 32                	jne    800628 <inet_aton+0xbe>
  8005f6:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8005f9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ff:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800605:	83 e9 41             	sub    $0x41,%ecx
  800608:	83 f9 05             	cmp    $0x5,%ecx
  80060b:	77 1b                	ja     800628 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80060d:	c1 e6 04             	shl    $0x4,%esi
  800610:	83 c2 0a             	add    $0xa,%edx
  800613:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800617:	19 c9                	sbb    %ecx,%ecx
  800619:	83 e1 20             	and    $0x20,%ecx
  80061c:	83 c1 41             	add    $0x41,%ecx
  80061f:	29 ca                	sub    %ecx,%edx
  800621:	09 d6                	or     %edx,%esi
        c = *++cp;
  800623:	0f be 10             	movsbl (%eax),%edx
  800626:	eb a7                	jmp    8005cf <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800628:	83 fa 2e             	cmp    $0x2e,%edx
  80062b:	75 23                	jne    800650 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80062d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800630:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800633:	39 f8                	cmp    %edi,%eax
  800635:	0f 84 ee 00 00 00    	je     800729 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80063b:	83 c0 04             	add    $0x4,%eax
  80063e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800641:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800644:	8d 43 01             	lea    0x1(%ebx),%eax
  800647:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80064b:	e9 2f ff ff ff       	jmp    80057f <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800650:	85 d2                	test   %edx,%edx
  800652:	74 25                	je     800679 <inet_aton+0x10f>
  800654:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800657:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80065c:	83 f9 5f             	cmp    $0x5f,%ecx
  80065f:	0f 87 d0 00 00 00    	ja     800735 <inet_aton+0x1cb>
  800665:	83 fa 20             	cmp    $0x20,%edx
  800668:	74 0f                	je     800679 <inet_aton+0x10f>
  80066a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80066d:	83 ea 09             	sub    $0x9,%edx
  800670:	83 fa 04             	cmp    $0x4,%edx
  800673:	0f 87 bc 00 00 00    	ja     800735 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800679:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80067c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80067f:	29 c2                	sub    %eax,%edx
  800681:	c1 fa 02             	sar    $0x2,%edx
  800684:	83 c2 01             	add    $0x1,%edx
  800687:	83 fa 02             	cmp    $0x2,%edx
  80068a:	74 20                	je     8006ac <inet_aton+0x142>
  80068c:	83 fa 02             	cmp    $0x2,%edx
  80068f:	7f 0f                	jg     8006a0 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  800691:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800696:	85 d2                	test   %edx,%edx
  800698:	0f 84 97 00 00 00    	je     800735 <inet_aton+0x1cb>
  80069e:	eb 67                	jmp    800707 <inet_aton+0x19d>
  8006a0:	83 fa 03             	cmp    $0x3,%edx
  8006a3:	74 1e                	je     8006c3 <inet_aton+0x159>
  8006a5:	83 fa 04             	cmp    $0x4,%edx
  8006a8:	74 38                	je     8006e2 <inet_aton+0x178>
  8006aa:	eb 5b                	jmp    800707 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8006ac:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8006b1:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8006b7:	77 7c                	ja     800735 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8006b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006bc:	c1 e0 18             	shl    $0x18,%eax
  8006bf:	09 c6                	or     %eax,%esi
    break;
  8006c1:	eb 44                	jmp    800707 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8006c8:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  8006ce:	77 65                	ja     800735 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8006d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d3:	c1 e2 18             	shl    $0x18,%edx
  8006d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006d9:	c1 e0 10             	shl    $0x10,%eax
  8006dc:	09 d0                	or     %edx,%eax
  8006de:	09 c6                	or     %eax,%esi
    break;
  8006e0:	eb 25                	jmp    800707 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006e7:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8006ed:	77 46                	ja     800735 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8006ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f2:	c1 e2 18             	shl    $0x18,%edx
  8006f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f8:	c1 e0 10             	shl    $0x10,%eax
  8006fb:	09 c2                	or     %eax,%edx
  8006fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800700:	c1 e0 08             	shl    $0x8,%eax
  800703:	09 d0                	or     %edx,%eax
  800705:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800707:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80070b:	74 23                	je     800730 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  80070d:	56                   	push   %esi
  80070e:	e8 2b fe ff ff       	call   80053e <htonl>
  800713:	83 c4 04             	add    $0x4,%esp
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800719:	89 03                	mov    %eax,(%ebx)
  return (1);
  80071b:	b8 01 00 00 00       	mov    $0x1,%eax
  800720:	eb 13                	jmp    800735 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800722:	b8 00 00 00 00       	mov    $0x0,%eax
  800727:	eb 0c                	jmp    800735 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	eb 05                	jmp    800735 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800730:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800743:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	ff 75 08             	pushl  0x8(%ebp)
  80074a:	e8 1b fe ff ff       	call   80056a <inet_aton>
  80074f:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  800752:	85 c0                	test   %eax,%eax
  800754:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800759:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  800762:	ff 75 08             	pushl  0x8(%ebp)
  800765:	e8 d4 fd ff ff       	call   80053e <htonl>
  80076a:	83 c4 04             	add    $0x4,%esp
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800777:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80077a:	e8 73 0a 00 00       	call   8011f2 <sys_getenvid>
  80077f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800784:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800787:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80078c:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800791:	85 db                	test   %ebx,%ebx
  800793:	7e 07                	jle    80079c <libmain+0x2d>
		binaryname = argv[0];
  800795:	8b 06                	mov    (%esi),%eax
  800797:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	e8 8d f8 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8007a6:	e8 0a 00 00 00       	call   8007b5 <exit>
}
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8007bb:	e8 11 12 00 00       	call   8019d1 <close_all>
	sys_env_destroy(0);
  8007c0:	83 ec 0c             	sub    $0xc,%esp
  8007c3:	6a 00                	push   $0x0
  8007c5:	e8 e7 09 00 00       	call   8011b1 <sys_env_destroy>
}
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8007d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007d7:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8007dd:	e8 10 0a 00 00       	call   8011f2 <sys_getenvid>
  8007e2:	83 ec 0c             	sub    $0xc,%esp
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	ff 75 08             	pushl  0x8(%ebp)
  8007eb:	56                   	push   %esi
  8007ec:	50                   	push   %eax
  8007ed:	68 e4 2d 80 00       	push   $0x802de4
  8007f2:	e8 b1 00 00 00       	call   8008a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007f7:	83 c4 18             	add    $0x18,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	ff 75 10             	pushl  0x10(%ebp)
  8007fe:	e8 54 00 00 00       	call   800857 <vcprintf>
	cprintf("\n");
  800803:	c7 04 24 3b 2d 80 00 	movl   $0x802d3b,(%esp)
  80080a:	e8 99 00 00 00       	call   8008a8 <cprintf>
  80080f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800812:	cc                   	int3   
  800813:	eb fd                	jmp    800812 <_panic+0x43>

00800815 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	83 ec 04             	sub    $0x4,%esp
  80081c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80081f:	8b 13                	mov    (%ebx),%edx
  800821:	8d 42 01             	lea    0x1(%edx),%eax
  800824:	89 03                	mov    %eax,(%ebx)
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80082d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800832:	75 1a                	jne    80084e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	68 ff 00 00 00       	push   $0xff
  80083c:	8d 43 08             	lea    0x8(%ebx),%eax
  80083f:	50                   	push   %eax
  800840:	e8 2f 09 00 00       	call   801174 <sys_cputs>
		b->idx = 0;
  800845:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80084b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80084e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800860:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800867:	00 00 00 
	b.cnt = 0;
  80086a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800871:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800874:	ff 75 0c             	pushl  0xc(%ebp)
  800877:	ff 75 08             	pushl  0x8(%ebp)
  80087a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800880:	50                   	push   %eax
  800881:	68 15 08 80 00       	push   $0x800815
  800886:	e8 54 01 00 00       	call   8009df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800894:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80089a:	50                   	push   %eax
  80089b:	e8 d4 08 00 00       	call   801174 <sys_cputs>

	return b.cnt;
}
  8008a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008b1:	50                   	push   %eax
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 9d ff ff ff       	call   800857 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	83 ec 1c             	sub    $0x1c,%esp
  8008c5:	89 c7                	mov    %eax,%edi
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8008e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008e3:	39 d3                	cmp    %edx,%ebx
  8008e5:	72 05                	jb     8008ec <printnum+0x30>
  8008e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008ea:	77 45                	ja     800931 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008ec:	83 ec 0c             	sub    $0xc,%esp
  8008ef:	ff 75 18             	pushl  0x18(%ebp)
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8008f8:	53                   	push   %ebx
  8008f9:	ff 75 10             	pushl  0x10(%ebp)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800902:	ff 75 e0             	pushl  -0x20(%ebp)
  800905:	ff 75 dc             	pushl  -0x24(%ebp)
  800908:	ff 75 d8             	pushl  -0x28(%ebp)
  80090b:	e8 e0 20 00 00       	call   8029f0 <__udivdi3>
  800910:	83 c4 18             	add    $0x18,%esp
  800913:	52                   	push   %edx
  800914:	50                   	push   %eax
  800915:	89 f2                	mov    %esi,%edx
  800917:	89 f8                	mov    %edi,%eax
  800919:	e8 9e ff ff ff       	call   8008bc <printnum>
  80091e:	83 c4 20             	add    $0x20,%esp
  800921:	eb 18                	jmp    80093b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	56                   	push   %esi
  800927:	ff 75 18             	pushl  0x18(%ebp)
  80092a:	ff d7                	call   *%edi
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	eb 03                	jmp    800934 <printnum+0x78>
  800931:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800934:	83 eb 01             	sub    $0x1,%ebx
  800937:	85 db                	test   %ebx,%ebx
  800939:	7f e8                	jg     800923 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	56                   	push   %esi
  80093f:	83 ec 04             	sub    $0x4,%esp
  800942:	ff 75 e4             	pushl  -0x1c(%ebp)
  800945:	ff 75 e0             	pushl  -0x20(%ebp)
  800948:	ff 75 dc             	pushl  -0x24(%ebp)
  80094b:	ff 75 d8             	pushl  -0x28(%ebp)
  80094e:	e8 cd 21 00 00       	call   802b20 <__umoddi3>
  800953:	83 c4 14             	add    $0x14,%esp
  800956:	0f be 80 07 2e 80 00 	movsbl 0x802e07(%eax),%eax
  80095d:	50                   	push   %eax
  80095e:	ff d7                	call   *%edi
}
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80096e:	83 fa 01             	cmp    $0x1,%edx
  800971:	7e 0e                	jle    800981 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800973:	8b 10                	mov    (%eax),%edx
  800975:	8d 4a 08             	lea    0x8(%edx),%ecx
  800978:	89 08                	mov    %ecx,(%eax)
  80097a:	8b 02                	mov    (%edx),%eax
  80097c:	8b 52 04             	mov    0x4(%edx),%edx
  80097f:	eb 22                	jmp    8009a3 <getuint+0x38>
	else if (lflag)
  800981:	85 d2                	test   %edx,%edx
  800983:	74 10                	je     800995 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800985:	8b 10                	mov    (%eax),%edx
  800987:	8d 4a 04             	lea    0x4(%edx),%ecx
  80098a:	89 08                	mov    %ecx,(%eax)
  80098c:	8b 02                	mov    (%edx),%eax
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	eb 0e                	jmp    8009a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800995:	8b 10                	mov    (%eax),%edx
  800997:	8d 4a 04             	lea    0x4(%edx),%ecx
  80099a:	89 08                	mov    %ecx,(%eax)
  80099c:	8b 02                	mov    (%edx),%eax
  80099e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8009af:	8b 10                	mov    (%eax),%edx
  8009b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8009b4:	73 0a                	jae    8009c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8009b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009b9:	89 08                	mov    %ecx,(%eax)
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	88 02                	mov    %al,(%edx)
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8009c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8009cb:	50                   	push   %eax
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	ff 75 08             	pushl  0x8(%ebp)
  8009d5:	e8 05 00 00 00       	call   8009df <vprintfmt>
	va_end(ap);
}
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	83 ec 2c             	sub    $0x2c,%esp
  8009e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009f1:	eb 12                	jmp    800a05 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	0f 84 89 03 00 00    	je     800d84 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8009fb:	83 ec 08             	sub    $0x8,%esp
  8009fe:	53                   	push   %ebx
  8009ff:	50                   	push   %eax
  800a00:	ff d6                	call   *%esi
  800a02:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a05:	83 c7 01             	add    $0x1,%edi
  800a08:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a0c:	83 f8 25             	cmp    $0x25,%eax
  800a0f:	75 e2                	jne    8009f3 <vprintfmt+0x14>
  800a11:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800a15:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a1c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a23:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	eb 07                	jmp    800a38 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a31:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a34:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a38:	8d 47 01             	lea    0x1(%edi),%eax
  800a3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a3e:	0f b6 07             	movzbl (%edi),%eax
  800a41:	0f b6 c8             	movzbl %al,%ecx
  800a44:	83 e8 23             	sub    $0x23,%eax
  800a47:	3c 55                	cmp    $0x55,%al
  800a49:	0f 87 1a 03 00 00    	ja     800d69 <vprintfmt+0x38a>
  800a4f:	0f b6 c0             	movzbl %al,%eax
  800a52:	ff 24 85 40 2f 80 00 	jmp    *0x802f40(,%eax,4)
  800a59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a5c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a60:	eb d6                	jmp    800a38 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a6d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a70:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800a74:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800a77:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800a7a:	83 fa 09             	cmp    $0x9,%edx
  800a7d:	77 39                	ja     800ab8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a7f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a82:	eb e9                	jmp    800a6d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 48 04             	lea    0x4(%eax),%ecx
  800a8a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a8d:	8b 00                	mov    (%eax),%eax
  800a8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a95:	eb 27                	jmp    800abe <vprintfmt+0xdf>
  800a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa1:	0f 49 c8             	cmovns %eax,%ecx
  800aa4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aaa:	eb 8c                	jmp    800a38 <vprintfmt+0x59>
  800aac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800aaf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800ab6:	eb 80                	jmp    800a38 <vprintfmt+0x59>
  800ab8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800abb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800abe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ac2:	0f 89 70 ff ff ff    	jns    800a38 <vprintfmt+0x59>
				width = precision, precision = -1;
  800ac8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800acb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ace:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ad5:	e9 5e ff ff ff       	jmp    800a38 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ada:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800add:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ae0:	e9 53 ff ff ff       	jmp    800a38 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae8:	8d 50 04             	lea    0x4(%eax),%edx
  800aeb:	89 55 14             	mov    %edx,0x14(%ebp)
  800aee:	83 ec 08             	sub    $0x8,%esp
  800af1:	53                   	push   %ebx
  800af2:	ff 30                	pushl  (%eax)
  800af4:	ff d6                	call   *%esi
			break;
  800af6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800afc:	e9 04 ff ff ff       	jmp    800a05 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b01:	8b 45 14             	mov    0x14(%ebp),%eax
  800b04:	8d 50 04             	lea    0x4(%eax),%edx
  800b07:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0a:	8b 00                	mov    (%eax),%eax
  800b0c:	99                   	cltd   
  800b0d:	31 d0                	xor    %edx,%eax
  800b0f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b11:	83 f8 0f             	cmp    $0xf,%eax
  800b14:	7f 0b                	jg     800b21 <vprintfmt+0x142>
  800b16:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  800b1d:	85 d2                	test   %edx,%edx
  800b1f:	75 18                	jne    800b39 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800b21:	50                   	push   %eax
  800b22:	68 1f 2e 80 00       	push   $0x802e1f
  800b27:	53                   	push   %ebx
  800b28:	56                   	push   %esi
  800b29:	e8 94 fe ff ff       	call   8009c2 <printfmt>
  800b2e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b34:	e9 cc fe ff ff       	jmp    800a05 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800b39:	52                   	push   %edx
  800b3a:	68 a5 32 80 00       	push   $0x8032a5
  800b3f:	53                   	push   %ebx
  800b40:	56                   	push   %esi
  800b41:	e8 7c fe ff ff       	call   8009c2 <printfmt>
  800b46:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b4c:	e9 b4 fe ff ff       	jmp    800a05 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b51:	8b 45 14             	mov    0x14(%ebp),%eax
  800b54:	8d 50 04             	lea    0x4(%eax),%edx
  800b57:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	b8 18 2e 80 00       	mov    $0x802e18,%eax
  800b63:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b66:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b6a:	0f 8e 94 00 00 00    	jle    800c04 <vprintfmt+0x225>
  800b70:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b74:	0f 84 98 00 00 00    	je     800c12 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	ff 75 d0             	pushl  -0x30(%ebp)
  800b80:	57                   	push   %edi
  800b81:	e8 86 02 00 00       	call   800e0c <strnlen>
  800b86:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b89:	29 c1                	sub    %eax,%ecx
  800b8b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b8e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b91:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b98:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b9b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b9d:	eb 0f                	jmp    800bae <vprintfmt+0x1cf>
					putch(padc, putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	53                   	push   %ebx
  800ba3:	ff 75 e0             	pushl  -0x20(%ebp)
  800ba6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ba8:	83 ef 01             	sub    $0x1,%edi
  800bab:	83 c4 10             	add    $0x10,%esp
  800bae:	85 ff                	test   %edi,%edi
  800bb0:	7f ed                	jg     800b9f <vprintfmt+0x1c0>
  800bb2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800bb5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800bb8:	85 c9                	test   %ecx,%ecx
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	0f 49 c1             	cmovns %ecx,%eax
  800bc2:	29 c1                	sub    %eax,%ecx
  800bc4:	89 75 08             	mov    %esi,0x8(%ebp)
  800bc7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bcd:	89 cb                	mov    %ecx,%ebx
  800bcf:	eb 4d                	jmp    800c1e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800bd1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800bd5:	74 1b                	je     800bf2 <vprintfmt+0x213>
  800bd7:	0f be c0             	movsbl %al,%eax
  800bda:	83 e8 20             	sub    $0x20,%eax
  800bdd:	83 f8 5e             	cmp    $0x5e,%eax
  800be0:	76 10                	jbe    800bf2 <vprintfmt+0x213>
					putch('?', putdat);
  800be2:	83 ec 08             	sub    $0x8,%esp
  800be5:	ff 75 0c             	pushl  0xc(%ebp)
  800be8:	6a 3f                	push   $0x3f
  800bea:	ff 55 08             	call   *0x8(%ebp)
  800bed:	83 c4 10             	add    $0x10,%esp
  800bf0:	eb 0d                	jmp    800bff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800bf2:	83 ec 08             	sub    $0x8,%esp
  800bf5:	ff 75 0c             	pushl  0xc(%ebp)
  800bf8:	52                   	push   %edx
  800bf9:	ff 55 08             	call   *0x8(%ebp)
  800bfc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bff:	83 eb 01             	sub    $0x1,%ebx
  800c02:	eb 1a                	jmp    800c1e <vprintfmt+0x23f>
  800c04:	89 75 08             	mov    %esi,0x8(%ebp)
  800c07:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c0a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c0d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c10:	eb 0c                	jmp    800c1e <vprintfmt+0x23f>
  800c12:	89 75 08             	mov    %esi,0x8(%ebp)
  800c15:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c18:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c1b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c1e:	83 c7 01             	add    $0x1,%edi
  800c21:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c25:	0f be d0             	movsbl %al,%edx
  800c28:	85 d2                	test   %edx,%edx
  800c2a:	74 23                	je     800c4f <vprintfmt+0x270>
  800c2c:	85 f6                	test   %esi,%esi
  800c2e:	78 a1                	js     800bd1 <vprintfmt+0x1f2>
  800c30:	83 ee 01             	sub    $0x1,%esi
  800c33:	79 9c                	jns    800bd1 <vprintfmt+0x1f2>
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3d:	eb 18                	jmp    800c57 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	53                   	push   %ebx
  800c43:	6a 20                	push   $0x20
  800c45:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c47:	83 ef 01             	sub    $0x1,%edi
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb 08                	jmp    800c57 <vprintfmt+0x278>
  800c4f:	89 df                	mov    %ebx,%edi
  800c51:	8b 75 08             	mov    0x8(%ebp),%esi
  800c54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c57:	85 ff                	test   %edi,%edi
  800c59:	7f e4                	jg     800c3f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c5e:	e9 a2 fd ff ff       	jmp    800a05 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c63:	83 fa 01             	cmp    $0x1,%edx
  800c66:	7e 16                	jle    800c7e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800c68:	8b 45 14             	mov    0x14(%ebp),%eax
  800c6b:	8d 50 08             	lea    0x8(%eax),%edx
  800c6e:	89 55 14             	mov    %edx,0x14(%ebp)
  800c71:	8b 50 04             	mov    0x4(%eax),%edx
  800c74:	8b 00                	mov    (%eax),%eax
  800c76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c79:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c7c:	eb 32                	jmp    800cb0 <vprintfmt+0x2d1>
	else if (lflag)
  800c7e:	85 d2                	test   %edx,%edx
  800c80:	74 18                	je     800c9a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800c82:	8b 45 14             	mov    0x14(%ebp),%eax
  800c85:	8d 50 04             	lea    0x4(%eax),%edx
  800c88:	89 55 14             	mov    %edx,0x14(%ebp)
  800c8b:	8b 00                	mov    (%eax),%eax
  800c8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c90:	89 c1                	mov    %eax,%ecx
  800c92:	c1 f9 1f             	sar    $0x1f,%ecx
  800c95:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c98:	eb 16                	jmp    800cb0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800c9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9d:	8d 50 04             	lea    0x4(%eax),%edx
  800ca0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ca3:	8b 00                	mov    (%eax),%eax
  800ca5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ca8:	89 c1                	mov    %eax,%ecx
  800caa:	c1 f9 1f             	sar    $0x1f,%ecx
  800cad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800cb0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cb6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cbb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800cbf:	79 74                	jns    800d35 <vprintfmt+0x356>
				putch('-', putdat);
  800cc1:	83 ec 08             	sub    $0x8,%esp
  800cc4:	53                   	push   %ebx
  800cc5:	6a 2d                	push   $0x2d
  800cc7:	ff d6                	call   *%esi
				num = -(long long) num;
  800cc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ccc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ccf:	f7 d8                	neg    %eax
  800cd1:	83 d2 00             	adc    $0x0,%edx
  800cd4:	f7 da                	neg    %edx
  800cd6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800cd9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800cde:	eb 55                	jmp    800d35 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ce0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce3:	e8 83 fc ff ff       	call   80096b <getuint>
			base = 10;
  800ce8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ced:	eb 46                	jmp    800d35 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf2:	e8 74 fc ff ff       	call   80096b <getuint>
			base = 8;
  800cf7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cfc:	eb 37                	jmp    800d35 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800cfe:	83 ec 08             	sub    $0x8,%esp
  800d01:	53                   	push   %ebx
  800d02:	6a 30                	push   $0x30
  800d04:	ff d6                	call   *%esi
			putch('x', putdat);
  800d06:	83 c4 08             	add    $0x8,%esp
  800d09:	53                   	push   %ebx
  800d0a:	6a 78                	push   $0x78
  800d0c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d11:	8d 50 04             	lea    0x4(%eax),%edx
  800d14:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d17:	8b 00                	mov    (%eax),%eax
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800d1e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d21:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d26:	eb 0d                	jmp    800d35 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d28:	8d 45 14             	lea    0x14(%ebp),%eax
  800d2b:	e8 3b fc ff ff       	call   80096b <getuint>
			base = 16;
  800d30:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800d3c:	57                   	push   %edi
  800d3d:	ff 75 e0             	pushl  -0x20(%ebp)
  800d40:	51                   	push   %ecx
  800d41:	52                   	push   %edx
  800d42:	50                   	push   %eax
  800d43:	89 da                	mov    %ebx,%edx
  800d45:	89 f0                	mov    %esi,%eax
  800d47:	e8 70 fb ff ff       	call   8008bc <printnum>
			break;
  800d4c:	83 c4 20             	add    $0x20,%esp
  800d4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d52:	e9 ae fc ff ff       	jmp    800a05 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d57:	83 ec 08             	sub    $0x8,%esp
  800d5a:	53                   	push   %ebx
  800d5b:	51                   	push   %ecx
  800d5c:	ff d6                	call   *%esi
			break;
  800d5e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d64:	e9 9c fc ff ff       	jmp    800a05 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d69:	83 ec 08             	sub    $0x8,%esp
  800d6c:	53                   	push   %ebx
  800d6d:	6a 25                	push   $0x25
  800d6f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d71:	83 c4 10             	add    $0x10,%esp
  800d74:	eb 03                	jmp    800d79 <vprintfmt+0x39a>
  800d76:	83 ef 01             	sub    $0x1,%edi
  800d79:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800d7d:	75 f7                	jne    800d76 <vprintfmt+0x397>
  800d7f:	e9 81 fc ff ff       	jmp    800a05 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 18             	sub    $0x18,%esp
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d9b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d9f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800da2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	74 26                	je     800dd3 <vsnprintf+0x47>
  800dad:	85 d2                	test   %edx,%edx
  800daf:	7e 22                	jle    800dd3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800db1:	ff 75 14             	pushl  0x14(%ebp)
  800db4:	ff 75 10             	pushl  0x10(%ebp)
  800db7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800dba:	50                   	push   %eax
  800dbb:	68 a5 09 80 00       	push   $0x8009a5
  800dc0:	e8 1a fc ff ff       	call   8009df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	eb 05                	jmp    800dd8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800dd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800de0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800de3:	50                   	push   %eax
  800de4:	ff 75 10             	pushl  0x10(%ebp)
  800de7:	ff 75 0c             	pushl  0xc(%ebp)
  800dea:	ff 75 08             	pushl  0x8(%ebp)
  800ded:	e8 9a ff ff ff       	call   800d8c <vsnprintf>
	va_end(ap);

	return rc;
}
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	eb 03                	jmp    800e04 <strlen+0x10>
		n++;
  800e01:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e04:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e08:	75 f7                	jne    800e01 <strlen+0xd>
		n++;
	return n;
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e15:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1a:	eb 03                	jmp    800e1f <strnlen+0x13>
		n++;
  800e1c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e1f:	39 c2                	cmp    %eax,%edx
  800e21:	74 08                	je     800e2b <strnlen+0x1f>
  800e23:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800e27:	75 f3                	jne    800e1c <strnlen+0x10>
  800e29:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	53                   	push   %ebx
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	83 c2 01             	add    $0x1,%edx
  800e3c:	83 c1 01             	add    $0x1,%ecx
  800e3f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e43:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e46:	84 db                	test   %bl,%bl
  800e48:	75 ef                	jne    800e39 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e54:	53                   	push   %ebx
  800e55:	e8 9a ff ff ff       	call   800df4 <strlen>
  800e5a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e5d:	ff 75 0c             	pushl  0xc(%ebp)
  800e60:	01 d8                	add    %ebx,%eax
  800e62:	50                   	push   %eax
  800e63:	e8 c5 ff ff ff       	call   800e2d <strcpy>
	return dst;
}
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	8b 75 08             	mov    0x8(%ebp),%esi
  800e77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7a:	89 f3                	mov    %esi,%ebx
  800e7c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e7f:	89 f2                	mov    %esi,%edx
  800e81:	eb 0f                	jmp    800e92 <strncpy+0x23>
		*dst++ = *src;
  800e83:	83 c2 01             	add    $0x1,%edx
  800e86:	0f b6 01             	movzbl (%ecx),%eax
  800e89:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e8c:	80 39 01             	cmpb   $0x1,(%ecx)
  800e8f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e92:	39 da                	cmp    %ebx,%edx
  800e94:	75 ed                	jne    800e83 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e96:	89 f0                	mov    %esi,%eax
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	8b 55 10             	mov    0x10(%ebp),%edx
  800eaa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800eac:	85 d2                	test   %edx,%edx
  800eae:	74 21                	je     800ed1 <strlcpy+0x35>
  800eb0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800eb4:	89 f2                	mov    %esi,%edx
  800eb6:	eb 09                	jmp    800ec1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800eb8:	83 c2 01             	add    $0x1,%edx
  800ebb:	83 c1 01             	add    $0x1,%ecx
  800ebe:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ec1:	39 c2                	cmp    %eax,%edx
  800ec3:	74 09                	je     800ece <strlcpy+0x32>
  800ec5:	0f b6 19             	movzbl (%ecx),%ebx
  800ec8:	84 db                	test   %bl,%bl
  800eca:	75 ec                	jne    800eb8 <strlcpy+0x1c>
  800ecc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ece:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ed1:	29 f0                	sub    %esi,%eax
}
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ee0:	eb 06                	jmp    800ee8 <strcmp+0x11>
		p++, q++;
  800ee2:	83 c1 01             	add    $0x1,%ecx
  800ee5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ee8:	0f b6 01             	movzbl (%ecx),%eax
  800eeb:	84 c0                	test   %al,%al
  800eed:	74 04                	je     800ef3 <strcmp+0x1c>
  800eef:	3a 02                	cmp    (%edx),%al
  800ef1:	74 ef                	je     800ee2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ef3:	0f b6 c0             	movzbl %al,%eax
  800ef6:	0f b6 12             	movzbl (%edx),%edx
  800ef9:	29 d0                	sub    %edx,%eax
}
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	53                   	push   %ebx
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f07:	89 c3                	mov    %eax,%ebx
  800f09:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800f0c:	eb 06                	jmp    800f14 <strncmp+0x17>
		n--, p++, q++;
  800f0e:	83 c0 01             	add    $0x1,%eax
  800f11:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f14:	39 d8                	cmp    %ebx,%eax
  800f16:	74 15                	je     800f2d <strncmp+0x30>
  800f18:	0f b6 08             	movzbl (%eax),%ecx
  800f1b:	84 c9                	test   %cl,%cl
  800f1d:	74 04                	je     800f23 <strncmp+0x26>
  800f1f:	3a 0a                	cmp    (%edx),%cl
  800f21:	74 eb                	je     800f0e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f23:	0f b6 00             	movzbl (%eax),%eax
  800f26:	0f b6 12             	movzbl (%edx),%edx
  800f29:	29 d0                	sub    %edx,%eax
  800f2b:	eb 05                	jmp    800f32 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f32:	5b                   	pop    %ebx
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f3f:	eb 07                	jmp    800f48 <strchr+0x13>
		if (*s == c)
  800f41:	38 ca                	cmp    %cl,%dl
  800f43:	74 0f                	je     800f54 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	0f b6 10             	movzbl (%eax),%edx
  800f4b:	84 d2                	test   %dl,%dl
  800f4d:	75 f2                	jne    800f41 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f60:	eb 03                	jmp    800f65 <strfind+0xf>
  800f62:	83 c0 01             	add    $0x1,%eax
  800f65:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f68:	38 ca                	cmp    %cl,%dl
  800f6a:	74 04                	je     800f70 <strfind+0x1a>
  800f6c:	84 d2                	test   %dl,%dl
  800f6e:	75 f2                	jne    800f62 <strfind+0xc>
			break;
	return (char *) s;
}
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f7e:	85 c9                	test   %ecx,%ecx
  800f80:	74 36                	je     800fb8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f82:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f88:	75 28                	jne    800fb2 <memset+0x40>
  800f8a:	f6 c1 03             	test   $0x3,%cl
  800f8d:	75 23                	jne    800fb2 <memset+0x40>
		c &= 0xFF;
  800f8f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f93:	89 d3                	mov    %edx,%ebx
  800f95:	c1 e3 08             	shl    $0x8,%ebx
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	c1 e6 18             	shl    $0x18,%esi
  800f9d:	89 d0                	mov    %edx,%eax
  800f9f:	c1 e0 10             	shl    $0x10,%eax
  800fa2:	09 f0                	or     %esi,%eax
  800fa4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800fa6:	89 d8                	mov    %ebx,%eax
  800fa8:	09 d0                	or     %edx,%eax
  800faa:	c1 e9 02             	shr    $0x2,%ecx
  800fad:	fc                   	cld    
  800fae:	f3 ab                	rep stos %eax,%es:(%edi)
  800fb0:	eb 06                	jmp    800fb8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb5:	fc                   	cld    
  800fb6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fb8:	89 f8                	mov    %edi,%eax
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800fcd:	39 c6                	cmp    %eax,%esi
  800fcf:	73 35                	jae    801006 <memmove+0x47>
  800fd1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fd4:	39 d0                	cmp    %edx,%eax
  800fd6:	73 2e                	jae    801006 <memmove+0x47>
		s += n;
		d += n;
  800fd8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fdb:	89 d6                	mov    %edx,%esi
  800fdd:	09 fe                	or     %edi,%esi
  800fdf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fe5:	75 13                	jne    800ffa <memmove+0x3b>
  800fe7:	f6 c1 03             	test   $0x3,%cl
  800fea:	75 0e                	jne    800ffa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fec:	83 ef 04             	sub    $0x4,%edi
  800fef:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ff2:	c1 e9 02             	shr    $0x2,%ecx
  800ff5:	fd                   	std    
  800ff6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ff8:	eb 09                	jmp    801003 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ffa:	83 ef 01             	sub    $0x1,%edi
  800ffd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801000:	fd                   	std    
  801001:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801003:	fc                   	cld    
  801004:	eb 1d                	jmp    801023 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801006:	89 f2                	mov    %esi,%edx
  801008:	09 c2                	or     %eax,%edx
  80100a:	f6 c2 03             	test   $0x3,%dl
  80100d:	75 0f                	jne    80101e <memmove+0x5f>
  80100f:	f6 c1 03             	test   $0x3,%cl
  801012:	75 0a                	jne    80101e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801014:	c1 e9 02             	shr    $0x2,%ecx
  801017:	89 c7                	mov    %eax,%edi
  801019:	fc                   	cld    
  80101a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80101c:	eb 05                	jmp    801023 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80101e:	89 c7                	mov    %eax,%edi
  801020:	fc                   	cld    
  801021:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80102a:	ff 75 10             	pushl  0x10(%ebp)
  80102d:	ff 75 0c             	pushl  0xc(%ebp)
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 87 ff ff ff       	call   800fbf <memmove>
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	8b 55 0c             	mov    0xc(%ebp),%edx
  801045:	89 c6                	mov    %eax,%esi
  801047:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80104a:	eb 1a                	jmp    801066 <memcmp+0x2c>
		if (*s1 != *s2)
  80104c:	0f b6 08             	movzbl (%eax),%ecx
  80104f:	0f b6 1a             	movzbl (%edx),%ebx
  801052:	38 d9                	cmp    %bl,%cl
  801054:	74 0a                	je     801060 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801056:	0f b6 c1             	movzbl %cl,%eax
  801059:	0f b6 db             	movzbl %bl,%ebx
  80105c:	29 d8                	sub    %ebx,%eax
  80105e:	eb 0f                	jmp    80106f <memcmp+0x35>
		s1++, s2++;
  801060:	83 c0 01             	add    $0x1,%eax
  801063:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801066:	39 f0                	cmp    %esi,%eax
  801068:	75 e2                	jne    80104c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80106a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	53                   	push   %ebx
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80107a:	89 c1                	mov    %eax,%ecx
  80107c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80107f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801083:	eb 0a                	jmp    80108f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801085:	0f b6 10             	movzbl (%eax),%edx
  801088:	39 da                	cmp    %ebx,%edx
  80108a:	74 07                	je     801093 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80108c:	83 c0 01             	add    $0x1,%eax
  80108f:	39 c8                	cmp    %ecx,%eax
  801091:	72 f2                	jb     801085 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801093:	5b                   	pop    %ebx
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	57                   	push   %edi
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010a2:	eb 03                	jmp    8010a7 <strtol+0x11>
		s++;
  8010a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010a7:	0f b6 01             	movzbl (%ecx),%eax
  8010aa:	3c 20                	cmp    $0x20,%al
  8010ac:	74 f6                	je     8010a4 <strtol+0xe>
  8010ae:	3c 09                	cmp    $0x9,%al
  8010b0:	74 f2                	je     8010a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010b2:	3c 2b                	cmp    $0x2b,%al
  8010b4:	75 0a                	jne    8010c0 <strtol+0x2a>
		s++;
  8010b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010be:	eb 11                	jmp    8010d1 <strtol+0x3b>
  8010c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010c5:	3c 2d                	cmp    $0x2d,%al
  8010c7:	75 08                	jne    8010d1 <strtol+0x3b>
		s++, neg = 1;
  8010c9:	83 c1 01             	add    $0x1,%ecx
  8010cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010d7:	75 15                	jne    8010ee <strtol+0x58>
  8010d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8010dc:	75 10                	jne    8010ee <strtol+0x58>
  8010de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010e2:	75 7c                	jne    801160 <strtol+0xca>
		s += 2, base = 16;
  8010e4:	83 c1 02             	add    $0x2,%ecx
  8010e7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010ec:	eb 16                	jmp    801104 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8010ee:	85 db                	test   %ebx,%ebx
  8010f0:	75 12                	jne    801104 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8010fa:	75 08                	jne    801104 <strtol+0x6e>
		s++, base = 8;
  8010fc:	83 c1 01             	add    $0x1,%ecx
  8010ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
  801109:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80110c:	0f b6 11             	movzbl (%ecx),%edx
  80110f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801112:	89 f3                	mov    %esi,%ebx
  801114:	80 fb 09             	cmp    $0x9,%bl
  801117:	77 08                	ja     801121 <strtol+0x8b>
			dig = *s - '0';
  801119:	0f be d2             	movsbl %dl,%edx
  80111c:	83 ea 30             	sub    $0x30,%edx
  80111f:	eb 22                	jmp    801143 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801121:	8d 72 9f             	lea    -0x61(%edx),%esi
  801124:	89 f3                	mov    %esi,%ebx
  801126:	80 fb 19             	cmp    $0x19,%bl
  801129:	77 08                	ja     801133 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80112b:	0f be d2             	movsbl %dl,%edx
  80112e:	83 ea 57             	sub    $0x57,%edx
  801131:	eb 10                	jmp    801143 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801133:	8d 72 bf             	lea    -0x41(%edx),%esi
  801136:	89 f3                	mov    %esi,%ebx
  801138:	80 fb 19             	cmp    $0x19,%bl
  80113b:	77 16                	ja     801153 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80113d:	0f be d2             	movsbl %dl,%edx
  801140:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801143:	3b 55 10             	cmp    0x10(%ebp),%edx
  801146:	7d 0b                	jge    801153 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801148:	83 c1 01             	add    $0x1,%ecx
  80114b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80114f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801151:	eb b9                	jmp    80110c <strtol+0x76>

	if (endptr)
  801153:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801157:	74 0d                	je     801166 <strtol+0xd0>
		*endptr = (char *) s;
  801159:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115c:	89 0e                	mov    %ecx,(%esi)
  80115e:	eb 06                	jmp    801166 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801160:	85 db                	test   %ebx,%ebx
  801162:	74 98                	je     8010fc <strtol+0x66>
  801164:	eb 9e                	jmp    801104 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801166:	89 c2                	mov    %eax,%edx
  801168:	f7 da                	neg    %edx
  80116a:	85 ff                	test   %edi,%edi
  80116c:	0f 45 c2             	cmovne %edx,%eax
}
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801182:	8b 55 08             	mov    0x8(%ebp),%edx
  801185:	89 c3                	mov    %eax,%ebx
  801187:	89 c7                	mov    %eax,%edi
  801189:	89 c6                	mov    %eax,%esi
  80118b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <sys_cgetc>:

int
sys_cgetc(void)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801198:	ba 00 00 00 00       	mov    $0x0,%edx
  80119d:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a2:	89 d1                	mov    %edx,%ecx
  8011a4:	89 d3                	mov    %edx,%ebx
  8011a6:	89 d7                	mov    %edx,%edi
  8011a8:	89 d6                	mov    %edx,%esi
  8011aa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	57                   	push   %edi
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8011c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c7:	89 cb                	mov    %ecx,%ebx
  8011c9:	89 cf                	mov    %ecx,%edi
  8011cb:	89 ce                	mov    %ecx,%esi
  8011cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	7e 17                	jle    8011ea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	50                   	push   %eax
  8011d7:	6a 03                	push   $0x3
  8011d9:	68 ff 30 80 00       	push   $0x8030ff
  8011de:	6a 23                	push   $0x23
  8011e0:	68 1c 31 80 00       	push   $0x80311c
  8011e5:	e8 e5 f5 ff ff       	call   8007cf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fd:	b8 02 00 00 00       	mov    $0x2,%eax
  801202:	89 d1                	mov    %edx,%ecx
  801204:	89 d3                	mov    %edx,%ebx
  801206:	89 d7                	mov    %edx,%edi
  801208:	89 d6                	mov    %edx,%esi
  80120a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sys_yield>:

void
sys_yield(void)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801217:	ba 00 00 00 00       	mov    $0x0,%edx
  80121c:	b8 0b 00 00 00       	mov    $0xb,%eax
  801221:	89 d1                	mov    %edx,%ecx
  801223:	89 d3                	mov    %edx,%ebx
  801225:	89 d7                	mov    %edx,%edi
  801227:	89 d6                	mov    %edx,%esi
  801229:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	be 00 00 00 00       	mov    $0x0,%esi
  80123e:	b8 04 00 00 00       	mov    $0x4,%eax
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
  801249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124c:	89 f7                	mov    %esi,%edi
  80124e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801250:	85 c0                	test   %eax,%eax
  801252:	7e 17                	jle    80126b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	50                   	push   %eax
  801258:	6a 04                	push   $0x4
  80125a:	68 ff 30 80 00       	push   $0x8030ff
  80125f:	6a 23                	push   $0x23
  801261:	68 1c 31 80 00       	push   $0x80311c
  801266:	e8 64 f5 ff ff       	call   8007cf <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80126b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127c:	b8 05 00 00 00       	mov    $0x5,%eax
  801281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801284:	8b 55 08             	mov    0x8(%ebp),%edx
  801287:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80128d:	8b 75 18             	mov    0x18(%ebp),%esi
  801290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801292:	85 c0                	test   %eax,%eax
  801294:	7e 17                	jle    8012ad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	50                   	push   %eax
  80129a:	6a 05                	push   $0x5
  80129c:	68 ff 30 80 00       	push   $0x8030ff
  8012a1:	6a 23                	push   $0x23
  8012a3:	68 1c 31 80 00       	push   $0x80311c
  8012a8:	e8 22 f5 ff ff       	call   8007cf <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8012ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c3:	b8 06 00 00 00       	mov    $0x6,%eax
  8012c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ce:	89 df                	mov    %ebx,%edi
  8012d0:	89 de                	mov    %ebx,%esi
  8012d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	7e 17                	jle    8012ef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	50                   	push   %eax
  8012dc:	6a 06                	push   $0x6
  8012de:	68 ff 30 80 00       	push   $0x8030ff
  8012e3:	6a 23                	push   $0x23
  8012e5:	68 1c 31 80 00       	push   $0x80311c
  8012ea:	e8 e0 f4 ff ff       	call   8007cf <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f2:	5b                   	pop    %ebx
  8012f3:	5e                   	pop    %esi
  8012f4:	5f                   	pop    %edi
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	57                   	push   %edi
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801300:	bb 00 00 00 00       	mov    $0x0,%ebx
  801305:	b8 08 00 00 00       	mov    $0x8,%eax
  80130a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130d:	8b 55 08             	mov    0x8(%ebp),%edx
  801310:	89 df                	mov    %ebx,%edi
  801312:	89 de                	mov    %ebx,%esi
  801314:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801316:	85 c0                	test   %eax,%eax
  801318:	7e 17                	jle    801331 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131a:	83 ec 0c             	sub    $0xc,%esp
  80131d:	50                   	push   %eax
  80131e:	6a 08                	push   $0x8
  801320:	68 ff 30 80 00       	push   $0x8030ff
  801325:	6a 23                	push   $0x23
  801327:	68 1c 31 80 00       	push   $0x80311c
  80132c:	e8 9e f4 ff ff       	call   8007cf <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	57                   	push   %edi
  80133d:	56                   	push   %esi
  80133e:	53                   	push   %ebx
  80133f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801342:	bb 00 00 00 00       	mov    $0x0,%ebx
  801347:	b8 09 00 00 00       	mov    $0x9,%eax
  80134c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134f:	8b 55 08             	mov    0x8(%ebp),%edx
  801352:	89 df                	mov    %ebx,%edi
  801354:	89 de                	mov    %ebx,%esi
  801356:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801358:	85 c0                	test   %eax,%eax
  80135a:	7e 17                	jle    801373 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	50                   	push   %eax
  801360:	6a 09                	push   $0x9
  801362:	68 ff 30 80 00       	push   $0x8030ff
  801367:	6a 23                	push   $0x23
  801369:	68 1c 31 80 00       	push   $0x80311c
  80136e:	e8 5c f4 ff ff       	call   8007cf <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801373:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	57                   	push   %edi
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801384:	bb 00 00 00 00       	mov    $0x0,%ebx
  801389:	b8 0a 00 00 00       	mov    $0xa,%eax
  80138e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801391:	8b 55 08             	mov    0x8(%ebp),%edx
  801394:	89 df                	mov    %ebx,%edi
  801396:	89 de                	mov    %ebx,%esi
  801398:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80139a:	85 c0                	test   %eax,%eax
  80139c:	7e 17                	jle    8013b5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	50                   	push   %eax
  8013a2:	6a 0a                	push   $0xa
  8013a4:	68 ff 30 80 00       	push   $0x8030ff
  8013a9:	6a 23                	push   $0x23
  8013ab:	68 1c 31 80 00       	push   $0x80311c
  8013b0:	e8 1a f4 ff ff       	call   8007cf <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c3:	be 00 00 00 00       	mov    $0x0,%esi
  8013c8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013d9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5f                   	pop    %edi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013ee:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f6:	89 cb                	mov    %ecx,%ebx
  8013f8:	89 cf                	mov    %ecx,%edi
  8013fa:	89 ce                	mov    %ecx,%esi
  8013fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013fe:	85 c0                	test   %eax,%eax
  801400:	7e 17                	jle    801419 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	50                   	push   %eax
  801406:	6a 0d                	push   $0xd
  801408:	68 ff 30 80 00       	push   $0x8030ff
  80140d:	6a 23                	push   $0x23
  80140f:	68 1c 31 80 00       	push   $0x80311c
  801414:	e8 b6 f3 ff ff       	call   8007cf <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801419:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5f                   	pop    %edi
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	57                   	push   %edi
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801427:	ba 00 00 00 00       	mov    $0x0,%edx
  80142c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801431:	89 d1                	mov    %edx,%ecx
  801433:	89 d3                	mov    %edx,%ebx
  801435:	89 d7                	mov    %edx,%edi
  801437:	89 d6                	mov    %edx,%esi
  801439:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801456:	8b 55 08             	mov    0x8(%ebp),%edx
  801459:	89 df                	mov    %ebx,%edi
  80145b:	89 de                	mov    %ebx,%esi
  80145d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80145f:	85 c0                	test   %eax,%eax
  801461:	7e 17                	jle    80147a <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	50                   	push   %eax
  801467:	6a 0f                	push   $0xf
  801469:	68 ff 30 80 00       	push   $0x8030ff
  80146e:	6a 23                	push   $0x23
  801470:	68 1c 31 80 00       	push   $0x80311c
  801475:	e8 55 f3 ff ff       	call   8007cf <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  80147a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5f                   	pop    %edi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	56                   	push   %esi
  801486:	53                   	push   %ebx
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80148a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  80148c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801490:	75 25                	jne    8014b7 <pgfault+0x35>
  801492:	89 d8                	mov    %ebx,%eax
  801494:	c1 e8 0c             	shr    $0xc,%eax
  801497:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149e:	f6 c4 08             	test   $0x8,%ah
  8014a1:	75 14                	jne    8014b7 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	68 2c 31 80 00       	push   $0x80312c
  8014ab:	6a 1e                	push   $0x1e
  8014ad:	68 c0 31 80 00       	push   $0x8031c0
  8014b2:	e8 18 f3 ff ff       	call   8007cf <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  8014b7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8014bd:	e8 30 fd ff ff       	call   8011f2 <sys_getenvid>
  8014c2:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  8014c4:	83 ec 04             	sub    $0x4,%esp
  8014c7:	6a 07                	push   $0x7
  8014c9:	68 00 f0 7f 00       	push   $0x7ff000
  8014ce:	50                   	push   %eax
  8014cf:	e8 5c fd ff ff       	call   801230 <sys_page_alloc>
	if (r < 0)
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	79 12                	jns    8014ed <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  8014db:	50                   	push   %eax
  8014dc:	68 58 31 80 00       	push   $0x803158
  8014e1:	6a 33                	push   $0x33
  8014e3:	68 c0 31 80 00       	push   $0x8031c0
  8014e8:	e8 e2 f2 ff ff       	call   8007cf <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8014ed:	83 ec 04             	sub    $0x4,%esp
  8014f0:	68 00 10 00 00       	push   $0x1000
  8014f5:	53                   	push   %ebx
  8014f6:	68 00 f0 7f 00       	push   $0x7ff000
  8014fb:	e8 27 fb ff ff       	call   801027 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801500:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801507:	53                   	push   %ebx
  801508:	56                   	push   %esi
  801509:	68 00 f0 7f 00       	push   $0x7ff000
  80150e:	56                   	push   %esi
  80150f:	e8 5f fd ff ff       	call   801273 <sys_page_map>
	if (r < 0)
  801514:	83 c4 20             	add    $0x20,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	79 12                	jns    80152d <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  80151b:	50                   	push   %eax
  80151c:	68 7c 31 80 00       	push   $0x80317c
  801521:	6a 3b                	push   $0x3b
  801523:	68 c0 31 80 00       	push   $0x8031c0
  801528:	e8 a2 f2 ff ff       	call   8007cf <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	68 00 f0 7f 00       	push   $0x7ff000
  801535:	56                   	push   %esi
  801536:	e8 7a fd ff ff       	call   8012b5 <sys_page_unmap>
	if (r < 0)
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	79 12                	jns    801554 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801542:	50                   	push   %eax
  801543:	68 a0 31 80 00       	push   $0x8031a0
  801548:	6a 40                	push   $0x40
  80154a:	68 c0 31 80 00       	push   $0x8031c0
  80154f:	e8 7b f2 ff ff       	call   8007cf <_panic>
}
  801554:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801564:	68 82 14 80 00       	push   $0x801482
  801569:	e8 dc 13 00 00       	call   80294a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80156e:	b8 07 00 00 00       	mov    $0x7,%eax
  801573:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	0f 88 64 01 00 00    	js     8016e4 <fork+0x189>
  801580:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801585:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80158a:	85 c0                	test   %eax,%eax
  80158c:	75 21                	jne    8015af <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  80158e:	e8 5f fc ff ff       	call   8011f2 <sys_getenvid>
  801593:	25 ff 03 00 00       	and    $0x3ff,%eax
  801598:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80159b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015a0:	a3 20 50 80 00       	mov    %eax,0x805020
        return 0;
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	e9 3f 01 00 00       	jmp    8016ee <fork+0x193>
  8015af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015b2:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	c1 e8 16             	shr    $0x16,%eax
  8015b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c0:	a8 01                	test   $0x1,%al
  8015c2:	0f 84 bd 00 00 00    	je     801685 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8015c8:	89 d8                	mov    %ebx,%eax
  8015ca:	c1 e8 0c             	shr    $0xc,%eax
  8015cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d4:	f6 c2 01             	test   $0x1,%dl
  8015d7:	0f 84 a8 00 00 00    	je     801685 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8015dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e4:	a8 04                	test   $0x4,%al
  8015e6:	0f 84 99 00 00 00    	je     801685 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8015ec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8015f3:	f6 c4 04             	test   $0x4,%ah
  8015f6:	74 17                	je     80160f <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8015f8:	83 ec 0c             	sub    $0xc,%esp
  8015fb:	68 07 0e 00 00       	push   $0xe07
  801600:	53                   	push   %ebx
  801601:	57                   	push   %edi
  801602:	53                   	push   %ebx
  801603:	6a 00                	push   $0x0
  801605:	e8 69 fc ff ff       	call   801273 <sys_page_map>
  80160a:	83 c4 20             	add    $0x20,%esp
  80160d:	eb 76                	jmp    801685 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80160f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801616:	a8 02                	test   $0x2,%al
  801618:	75 0c                	jne    801626 <fork+0xcb>
  80161a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801621:	f6 c4 08             	test   $0x8,%ah
  801624:	74 3f                	je     801665 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	68 05 08 00 00       	push   $0x805
  80162e:	53                   	push   %ebx
  80162f:	57                   	push   %edi
  801630:	53                   	push   %ebx
  801631:	6a 00                	push   $0x0
  801633:	e8 3b fc ff ff       	call   801273 <sys_page_map>
		if (r < 0)
  801638:	83 c4 20             	add    $0x20,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	0f 88 a5 00 00 00    	js     8016e8 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	68 05 08 00 00       	push   $0x805
  80164b:	53                   	push   %ebx
  80164c:	6a 00                	push   $0x0
  80164e:	53                   	push   %ebx
  80164f:	6a 00                	push   $0x0
  801651:	e8 1d fc ff ff       	call   801273 <sys_page_map>
  801656:	83 c4 20             	add    $0x20,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801660:	0f 4f c1             	cmovg  %ecx,%eax
  801663:	eb 1c                	jmp    801681 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	6a 05                	push   $0x5
  80166a:	53                   	push   %ebx
  80166b:	57                   	push   %edi
  80166c:	53                   	push   %ebx
  80166d:	6a 00                	push   $0x0
  80166f:	e8 ff fb ff ff       	call   801273 <sys_page_map>
  801674:	83 c4 20             	add    $0x20,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80167e:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801681:	85 c0                	test   %eax,%eax
  801683:	78 67                	js     8016ec <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801685:	83 c6 01             	add    $0x1,%esi
  801688:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80168e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801694:	0f 85 1a ff ff ff    	jne    8015b4 <fork+0x59>
  80169a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	6a 07                	push   $0x7
  8016a2:	68 00 f0 bf ee       	push   $0xeebff000
  8016a7:	57                   	push   %edi
  8016a8:	e8 83 fb ff ff       	call   801230 <sys_page_alloc>
	if (r < 0)
  8016ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8016b0:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 38                	js     8016ee <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	68 91 29 80 00       	push   $0x802991
  8016be:	57                   	push   %edi
  8016bf:	e8 b7 fc ff ff       	call   80137b <sys_env_set_pgfault_upcall>
	if (r < 0)
  8016c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8016c7:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 21                	js     8016ee <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	6a 02                	push   $0x2
  8016d2:	57                   	push   %edi
  8016d3:	e8 1f fc ff ff       	call   8012f7 <sys_env_set_status>
	if (r < 0)
  8016d8:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	0f 48 f8             	cmovs  %eax,%edi
  8016e0:	89 fa                	mov    %edi,%edx
  8016e2:	eb 0a                	jmp    8016ee <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	eb 06                	jmp    8016ee <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	eb 02                	jmp    8016ee <fork+0x193>
  8016ec:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8016ee:	89 d0                	mov    %edx,%eax
  8016f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <sfork>:

// Challenge!
int
sfork(void)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8016fe:	68 cb 31 80 00       	push   $0x8031cb
  801703:	68 c9 00 00 00       	push   $0xc9
  801708:	68 c0 31 80 00       	push   $0x8031c0
  80170d:	e8 bd f0 ff ff       	call   8007cf <_panic>

00801712 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	8b 75 08             	mov    0x8(%ebp),%esi
  80171a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801720:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801722:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801727:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	50                   	push   %eax
  80172e:	e8 ad fc ff ff       	call   8013e0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	85 f6                	test   %esi,%esi
  801738:	74 14                	je     80174e <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80173a:	ba 00 00 00 00       	mov    $0x0,%edx
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 09                	js     80174c <ipc_recv+0x3a>
  801743:	8b 15 20 50 80 00    	mov    0x805020,%edx
  801749:	8b 52 74             	mov    0x74(%edx),%edx
  80174c:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80174e:	85 db                	test   %ebx,%ebx
  801750:	74 14                	je     801766 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801752:	ba 00 00 00 00       	mov    $0x0,%edx
  801757:	85 c0                	test   %eax,%eax
  801759:	78 09                	js     801764 <ipc_recv+0x52>
  80175b:	8b 15 20 50 80 00    	mov    0x805020,%edx
  801761:	8b 52 78             	mov    0x78(%edx),%edx
  801764:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801766:	85 c0                	test   %eax,%eax
  801768:	78 08                	js     801772 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80176a:	a1 20 50 80 00       	mov    0x805020,%eax
  80176f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	57                   	push   %edi
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	8b 7d 08             	mov    0x8(%ebp),%edi
  801785:	8b 75 0c             	mov    0xc(%ebp),%esi
  801788:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80178b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80178d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801792:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801795:	ff 75 14             	pushl  0x14(%ebp)
  801798:	53                   	push   %ebx
  801799:	56                   	push   %esi
  80179a:	57                   	push   %edi
  80179b:	e8 1d fc ff ff       	call   8013bd <sys_ipc_try_send>

		if (err < 0) {
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	79 1e                	jns    8017c5 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8017a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017aa:	75 07                	jne    8017b3 <ipc_send+0x3a>
				sys_yield();
  8017ac:	e8 60 fa ff ff       	call   801211 <sys_yield>
  8017b1:	eb e2                	jmp    801795 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8017b3:	50                   	push   %eax
  8017b4:	68 e1 31 80 00       	push   $0x8031e1
  8017b9:	6a 49                	push   $0x49
  8017bb:	68 ee 31 80 00       	push   $0x8031ee
  8017c0:	e8 0a f0 ff ff       	call   8007cf <_panic>
		}

	} while (err < 0);

}
  8017c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5f                   	pop    %edi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8017d8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8017db:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8017e1:	8b 52 50             	mov    0x50(%edx),%edx
  8017e4:	39 ca                	cmp    %ecx,%edx
  8017e6:	75 0d                	jne    8017f5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8017e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8017eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8017f0:	8b 40 48             	mov    0x48(%eax),%eax
  8017f3:	eb 0f                	jmp    801804 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8017f5:	83 c0 01             	add    $0x1,%eax
  8017f8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8017fd:	75 d9                	jne    8017d8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8017ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801809:	8b 45 08             	mov    0x8(%ebp),%eax
  80180c:	05 00 00 00 30       	add    $0x30000000,%eax
  801811:	c1 e8 0c             	shr    $0xc,%eax
}
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	05 00 00 00 30       	add    $0x30000000,%eax
  801821:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801826:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801833:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801838:	89 c2                	mov    %eax,%edx
  80183a:	c1 ea 16             	shr    $0x16,%edx
  80183d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801844:	f6 c2 01             	test   $0x1,%dl
  801847:	74 11                	je     80185a <fd_alloc+0x2d>
  801849:	89 c2                	mov    %eax,%edx
  80184b:	c1 ea 0c             	shr    $0xc,%edx
  80184e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801855:	f6 c2 01             	test   $0x1,%dl
  801858:	75 09                	jne    801863 <fd_alloc+0x36>
			*fd_store = fd;
  80185a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80185c:	b8 00 00 00 00       	mov    $0x0,%eax
  801861:	eb 17                	jmp    80187a <fd_alloc+0x4d>
  801863:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801868:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80186d:	75 c9                	jne    801838 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80186f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801875:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801882:	83 f8 1f             	cmp    $0x1f,%eax
  801885:	77 36                	ja     8018bd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801887:	c1 e0 0c             	shl    $0xc,%eax
  80188a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80188f:	89 c2                	mov    %eax,%edx
  801891:	c1 ea 16             	shr    $0x16,%edx
  801894:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80189b:	f6 c2 01             	test   $0x1,%dl
  80189e:	74 24                	je     8018c4 <fd_lookup+0x48>
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	c1 ea 0c             	shr    $0xc,%edx
  8018a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018ac:	f6 c2 01             	test   $0x1,%dl
  8018af:	74 1a                	je     8018cb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	eb 13                	jmp    8018d0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c2:	eb 0c                	jmp    8018d0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c9:	eb 05                	jmp    8018d0 <fd_lookup+0x54>
  8018cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018db:	ba 78 32 80 00       	mov    $0x803278,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8018e0:	eb 13                	jmp    8018f5 <dev_lookup+0x23>
  8018e2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8018e5:	39 08                	cmp    %ecx,(%eax)
  8018e7:	75 0c                	jne    8018f5 <dev_lookup+0x23>
			*dev = devtab[i];
  8018e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f3:	eb 2e                	jmp    801923 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018f5:	8b 02                	mov    (%edx),%eax
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	75 e7                	jne    8018e2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018fb:	a1 20 50 80 00       	mov    0x805020,%eax
  801900:	8b 40 48             	mov    0x48(%eax),%eax
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	51                   	push   %ecx
  801907:	50                   	push   %eax
  801908:	68 f8 31 80 00       	push   $0x8031f8
  80190d:	e8 96 ef ff ff       	call   8008a8 <cprintf>
	*dev = 0;
  801912:	8b 45 0c             	mov    0xc(%ebp),%eax
  801915:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	83 ec 10             	sub    $0x10,%esp
  80192d:	8b 75 08             	mov    0x8(%ebp),%esi
  801930:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801936:	50                   	push   %eax
  801937:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80193d:	c1 e8 0c             	shr    $0xc,%eax
  801940:	50                   	push   %eax
  801941:	e8 36 ff ff ff       	call   80187c <fd_lookup>
  801946:	83 c4 08             	add    $0x8,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 05                	js     801952 <fd_close+0x2d>
	    || fd != fd2)
  80194d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801950:	74 0c                	je     80195e <fd_close+0x39>
		return (must_exist ? r : 0);
  801952:	84 db                	test   %bl,%bl
  801954:	ba 00 00 00 00       	mov    $0x0,%edx
  801959:	0f 44 c2             	cmove  %edx,%eax
  80195c:	eb 41                	jmp    80199f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	ff 36                	pushl  (%esi)
  801967:	e8 66 ff ff ff       	call   8018d2 <dev_lookup>
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	78 1a                	js     80198f <fd_close+0x6a>
		if (dev->dev_close)
  801975:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801978:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80197b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801980:	85 c0                	test   %eax,%eax
  801982:	74 0b                	je     80198f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	56                   	push   %esi
  801988:	ff d0                	call   *%eax
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	56                   	push   %esi
  801993:	6a 00                	push   $0x0
  801995:	e8 1b f9 ff ff       	call   8012b5 <sys_page_unmap>
	return r;
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	89 d8                	mov    %ebx,%eax
}
  80199f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	ff 75 08             	pushl  0x8(%ebp)
  8019b3:	e8 c4 fe ff ff       	call   80187c <fd_lookup>
  8019b8:	83 c4 08             	add    $0x8,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 10                	js     8019cf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	6a 01                	push   $0x1
  8019c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c7:	e8 59 ff ff ff       	call   801925 <fd_close>
  8019cc:	83 c4 10             	add    $0x10,%esp
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <close_all>:

void
close_all(void)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8019d8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8019dd:	83 ec 0c             	sub    $0xc,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	e8 c0 ff ff ff       	call   8019a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019e6:	83 c3 01             	add    $0x1,%ebx
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	83 fb 20             	cmp    $0x20,%ebx
  8019ef:	75 ec                	jne    8019dd <close_all+0xc>
		close(i);
}
  8019f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	57                   	push   %edi
  8019fa:	56                   	push   %esi
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 2c             	sub    $0x2c,%esp
  8019ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	ff 75 08             	pushl  0x8(%ebp)
  801a09:	e8 6e fe ff ff       	call   80187c <fd_lookup>
  801a0e:	83 c4 08             	add    $0x8,%esp
  801a11:	85 c0                	test   %eax,%eax
  801a13:	0f 88 c1 00 00 00    	js     801ada <dup+0xe4>
		return r;
	close(newfdnum);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	56                   	push   %esi
  801a1d:	e8 84 ff ff ff       	call   8019a6 <close>

	newfd = INDEX2FD(newfdnum);
  801a22:	89 f3                	mov    %esi,%ebx
  801a24:	c1 e3 0c             	shl    $0xc,%ebx
  801a27:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801a2d:	83 c4 04             	add    $0x4,%esp
  801a30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a33:	e8 de fd ff ff       	call   801816 <fd2data>
  801a38:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801a3a:	89 1c 24             	mov    %ebx,(%esp)
  801a3d:	e8 d4 fd ff ff       	call   801816 <fd2data>
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a48:	89 f8                	mov    %edi,%eax
  801a4a:	c1 e8 16             	shr    $0x16,%eax
  801a4d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a54:	a8 01                	test   $0x1,%al
  801a56:	74 37                	je     801a8f <dup+0x99>
  801a58:	89 f8                	mov    %edi,%eax
  801a5a:	c1 e8 0c             	shr    $0xc,%eax
  801a5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a64:	f6 c2 01             	test   $0x1,%dl
  801a67:	74 26                	je     801a8f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	25 07 0e 00 00       	and    $0xe07,%eax
  801a78:	50                   	push   %eax
  801a79:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a7c:	6a 00                	push   $0x0
  801a7e:	57                   	push   %edi
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 ed f7 ff ff       	call   801273 <sys_page_map>
  801a86:	89 c7                	mov    %eax,%edi
  801a88:	83 c4 20             	add    $0x20,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 2e                	js     801abd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a92:	89 d0                	mov    %edx,%eax
  801a94:	c1 e8 0c             	shr    $0xc,%eax
  801a97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	25 07 0e 00 00       	and    $0xe07,%eax
  801aa6:	50                   	push   %eax
  801aa7:	53                   	push   %ebx
  801aa8:	6a 00                	push   $0x0
  801aaa:	52                   	push   %edx
  801aab:	6a 00                	push   $0x0
  801aad:	e8 c1 f7 ff ff       	call   801273 <sys_page_map>
  801ab2:	89 c7                	mov    %eax,%edi
  801ab4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801ab7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ab9:	85 ff                	test   %edi,%edi
  801abb:	79 1d                	jns    801ada <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	53                   	push   %ebx
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 ed f7 ff ff       	call   8012b5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ac8:	83 c4 08             	add    $0x8,%esp
  801acb:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ace:	6a 00                	push   $0x0
  801ad0:	e8 e0 f7 ff ff       	call   8012b5 <sys_page_unmap>
	return r;
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	89 f8                	mov    %edi,%eax
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 14             	sub    $0x14,%esp
  801ae9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	53                   	push   %ebx
  801af1:	e8 86 fd ff ff       	call   80187c <fd_lookup>
  801af6:	83 c4 08             	add    $0x8,%esp
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	85 c0                	test   %eax,%eax
  801afd:	78 6d                	js     801b6c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aff:	83 ec 08             	sub    $0x8,%esp
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b09:	ff 30                	pushl  (%eax)
  801b0b:	e8 c2 fd ff ff       	call   8018d2 <dev_lookup>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 4c                	js     801b63 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b17:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b1a:	8b 42 08             	mov    0x8(%edx),%eax
  801b1d:	83 e0 03             	and    $0x3,%eax
  801b20:	83 f8 01             	cmp    $0x1,%eax
  801b23:	75 21                	jne    801b46 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b25:	a1 20 50 80 00       	mov    0x805020,%eax
  801b2a:	8b 40 48             	mov    0x48(%eax),%eax
  801b2d:	83 ec 04             	sub    $0x4,%esp
  801b30:	53                   	push   %ebx
  801b31:	50                   	push   %eax
  801b32:	68 3c 32 80 00       	push   $0x80323c
  801b37:	e8 6c ed ff ff       	call   8008a8 <cprintf>
		return -E_INVAL;
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b44:	eb 26                	jmp    801b6c <read+0x8a>
	}
	if (!dev->dev_read)
  801b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b49:	8b 40 08             	mov    0x8(%eax),%eax
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	74 17                	je     801b67 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b50:	83 ec 04             	sub    $0x4,%esp
  801b53:	ff 75 10             	pushl  0x10(%ebp)
  801b56:	ff 75 0c             	pushl  0xc(%ebp)
  801b59:	52                   	push   %edx
  801b5a:	ff d0                	call   *%eax
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	eb 09                	jmp    801b6c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b63:	89 c2                	mov    %eax,%edx
  801b65:	eb 05                	jmp    801b6c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b67:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801b6c:	89 d0                	mov    %edx,%eax
  801b6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	57                   	push   %edi
  801b77:	56                   	push   %esi
  801b78:	53                   	push   %ebx
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b87:	eb 21                	jmp    801baa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	29 d8                	sub    %ebx,%eax
  801b90:	50                   	push   %eax
  801b91:	89 d8                	mov    %ebx,%eax
  801b93:	03 45 0c             	add    0xc(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	57                   	push   %edi
  801b98:	e8 45 ff ff ff       	call   801ae2 <read>
		if (m < 0)
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 10                	js     801bb4 <readn+0x41>
			return m;
		if (m == 0)
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	74 0a                	je     801bb2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ba8:	01 c3                	add    %eax,%ebx
  801baa:	39 f3                	cmp    %esi,%ebx
  801bac:	72 db                	jb     801b89 <readn+0x16>
  801bae:	89 d8                	mov    %ebx,%eax
  801bb0:	eb 02                	jmp    801bb4 <readn+0x41>
  801bb2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5f                   	pop    %edi
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 14             	sub    $0x14,%esp
  801bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc9:	50                   	push   %eax
  801bca:	53                   	push   %ebx
  801bcb:	e8 ac fc ff ff       	call   80187c <fd_lookup>
  801bd0:	83 c4 08             	add    $0x8,%esp
  801bd3:	89 c2                	mov    %eax,%edx
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 68                	js     801c41 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bd9:	83 ec 08             	sub    $0x8,%esp
  801bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be3:	ff 30                	pushl  (%eax)
  801be5:	e8 e8 fc ff ff       	call   8018d2 <dev_lookup>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 47                	js     801c38 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bf8:	75 21                	jne    801c1b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801bfa:	a1 20 50 80 00       	mov    0x805020,%eax
  801bff:	8b 40 48             	mov    0x48(%eax),%eax
  801c02:	83 ec 04             	sub    $0x4,%esp
  801c05:	53                   	push   %ebx
  801c06:	50                   	push   %eax
  801c07:	68 58 32 80 00       	push   $0x803258
  801c0c:	e8 97 ec ff ff       	call   8008a8 <cprintf>
		return -E_INVAL;
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c19:	eb 26                	jmp    801c41 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1e:	8b 52 0c             	mov    0xc(%edx),%edx
  801c21:	85 d2                	test   %edx,%edx
  801c23:	74 17                	je     801c3c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	ff 75 10             	pushl  0x10(%ebp)
  801c2b:	ff 75 0c             	pushl  0xc(%ebp)
  801c2e:	50                   	push   %eax
  801c2f:	ff d2                	call   *%edx
  801c31:	89 c2                	mov    %eax,%edx
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	eb 09                	jmp    801c41 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	eb 05                	jmp    801c41 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c3c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801c41:	89 d0                	mov    %edx,%eax
  801c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <seek>:

int
seek(int fdnum, off_t offset)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c51:	50                   	push   %eax
  801c52:	ff 75 08             	pushl  0x8(%ebp)
  801c55:	e8 22 fc ff ff       	call   80187c <fd_lookup>
  801c5a:	83 c4 08             	add    $0x8,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 0e                	js     801c6f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801c61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c67:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	53                   	push   %ebx
  801c75:	83 ec 14             	sub    $0x14,%esp
  801c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	53                   	push   %ebx
  801c80:	e8 f7 fb ff ff       	call   80187c <fd_lookup>
  801c85:	83 c4 08             	add    $0x8,%esp
  801c88:	89 c2                	mov    %eax,%edx
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 65                	js     801cf3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c98:	ff 30                	pushl  (%eax)
  801c9a:	e8 33 fc ff ff       	call   8018d2 <dev_lookup>
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	78 44                	js     801cea <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cad:	75 21                	jne    801cd0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801caf:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801cb4:	8b 40 48             	mov    0x48(%eax),%eax
  801cb7:	83 ec 04             	sub    $0x4,%esp
  801cba:	53                   	push   %ebx
  801cbb:	50                   	push   %eax
  801cbc:	68 18 32 80 00       	push   $0x803218
  801cc1:	e8 e2 eb ff ff       	call   8008a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801cce:	eb 23                	jmp    801cf3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801cd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd3:	8b 52 18             	mov    0x18(%edx),%edx
  801cd6:	85 d2                	test   %edx,%edx
  801cd8:	74 14                	je     801cee <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	ff 75 0c             	pushl  0xc(%ebp)
  801ce0:	50                   	push   %eax
  801ce1:	ff d2                	call   *%edx
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	eb 09                	jmp    801cf3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	eb 05                	jmp    801cf3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801cee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801cf3:	89 d0                	mov    %edx,%eax
  801cf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 14             	sub    $0x14,%esp
  801d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d07:	50                   	push   %eax
  801d08:	ff 75 08             	pushl  0x8(%ebp)
  801d0b:	e8 6c fb ff ff       	call   80187c <fd_lookup>
  801d10:	83 c4 08             	add    $0x8,%esp
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 58                	js     801d71 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d19:	83 ec 08             	sub    $0x8,%esp
  801d1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1f:	50                   	push   %eax
  801d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d23:	ff 30                	pushl  (%eax)
  801d25:	e8 a8 fb ff ff       	call   8018d2 <dev_lookup>
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 37                	js     801d68 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d34:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d38:	74 32                	je     801d6c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d3a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d3d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d44:	00 00 00 
	stat->st_isdir = 0;
  801d47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d4e:	00 00 00 
	stat->st_dev = dev;
  801d51:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d57:	83 ec 08             	sub    $0x8,%esp
  801d5a:	53                   	push   %ebx
  801d5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5e:	ff 50 14             	call   *0x14(%eax)
  801d61:	89 c2                	mov    %eax,%edx
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	eb 09                	jmp    801d71 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d68:	89 c2                	mov    %eax,%edx
  801d6a:	eb 05                	jmp    801d71 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d6c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d71:	89 d0                	mov    %edx,%eax
  801d73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	6a 00                	push   $0x0
  801d82:	ff 75 08             	pushl  0x8(%ebp)
  801d85:	e8 d6 01 00 00       	call   801f60 <open>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 1b                	js     801dae <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	ff 75 0c             	pushl  0xc(%ebp)
  801d99:	50                   	push   %eax
  801d9a:	e8 5b ff ff ff       	call   801cfa <fstat>
  801d9f:	89 c6                	mov    %eax,%esi
	close(fd);
  801da1:	89 1c 24             	mov    %ebx,(%esp)
  801da4:	e8 fd fb ff ff       	call   8019a6 <close>
	return r;
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	89 f0                	mov    %esi,%eax
}
  801dae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	89 c6                	mov    %eax,%esi
  801dbc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801dbe:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801dc5:	75 12                	jne    801dd9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	6a 01                	push   $0x1
  801dcc:	e8 fc f9 ff ff       	call   8017cd <ipc_find_env>
  801dd1:	a3 18 50 80 00       	mov    %eax,0x805018
  801dd6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801dd9:	6a 07                	push   $0x7
  801ddb:	68 00 60 80 00       	push   $0x806000
  801de0:	56                   	push   %esi
  801de1:	ff 35 18 50 80 00    	pushl  0x805018
  801de7:	e8 8d f9 ff ff       	call   801779 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801dec:	83 c4 0c             	add    $0xc,%esp
  801def:	6a 00                	push   $0x0
  801df1:	53                   	push   %ebx
  801df2:	6a 00                	push   $0x0
  801df4:	e8 19 f9 ff ff       	call   801712 <ipc_recv>
}
  801df9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	8b 40 0c             	mov    0xc(%eax),%eax
  801e0c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e14:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e19:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1e:	b8 02 00 00 00       	mov    $0x2,%eax
  801e23:	e8 8d ff ff ff       	call   801db5 <fsipc>
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	8b 40 0c             	mov    0xc(%eax),%eax
  801e36:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e40:	b8 06 00 00 00       	mov    $0x6,%eax
  801e45:	e8 6b ff ff ff       	call   801db5 <fsipc>
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 04             	sub    $0x4,%esp
  801e53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e56:	8b 45 08             	mov    0x8(%ebp),%eax
  801e59:	8b 40 0c             	mov    0xc(%eax),%eax
  801e5c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e61:	ba 00 00 00 00       	mov    $0x0,%edx
  801e66:	b8 05 00 00 00       	mov    $0x5,%eax
  801e6b:	e8 45 ff ff ff       	call   801db5 <fsipc>
  801e70:	85 c0                	test   %eax,%eax
  801e72:	78 2c                	js     801ea0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e74:	83 ec 08             	sub    $0x8,%esp
  801e77:	68 00 60 80 00       	push   $0x806000
  801e7c:	53                   	push   %ebx
  801e7d:	e8 ab ef ff ff       	call   800e2d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e82:	a1 80 60 80 00       	mov    0x806080,%eax
  801e87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e8d:	a1 84 60 80 00       	mov    0x806084,%eax
  801e92:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801eae:	8b 55 08             	mov    0x8(%ebp),%edx
  801eb1:	8b 52 0c             	mov    0xc(%edx),%edx
  801eb4:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801eba:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ebf:	50                   	push   %eax
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	68 08 60 80 00       	push   $0x806008
  801ec8:	e8 f2 f0 ff ff       	call   800fbf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ed7:	e8 d9 fe ff ff       	call   801db5 <fsipc>

}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	56                   	push   %esi
  801ee2:	53                   	push   %ebx
  801ee3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	8b 40 0c             	mov    0xc(%eax),%eax
  801eec:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ef1:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  801efc:	b8 03 00 00 00       	mov    $0x3,%eax
  801f01:	e8 af fe ff ff       	call   801db5 <fsipc>
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 4b                	js     801f57 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801f0c:	39 c6                	cmp    %eax,%esi
  801f0e:	73 16                	jae    801f26 <devfile_read+0x48>
  801f10:	68 8c 32 80 00       	push   $0x80328c
  801f15:	68 93 32 80 00       	push   $0x803293
  801f1a:	6a 7c                	push   $0x7c
  801f1c:	68 a8 32 80 00       	push   $0x8032a8
  801f21:	e8 a9 e8 ff ff       	call   8007cf <_panic>
	assert(r <= PGSIZE);
  801f26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f2b:	7e 16                	jle    801f43 <devfile_read+0x65>
  801f2d:	68 b3 32 80 00       	push   $0x8032b3
  801f32:	68 93 32 80 00       	push   $0x803293
  801f37:	6a 7d                	push   $0x7d
  801f39:	68 a8 32 80 00       	push   $0x8032a8
  801f3e:	e8 8c e8 ff ff       	call   8007cf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	50                   	push   %eax
  801f47:	68 00 60 80 00       	push   $0x806000
  801f4c:	ff 75 0c             	pushl  0xc(%ebp)
  801f4f:	e8 6b f0 ff ff       	call   800fbf <memmove>
	return r;
  801f54:	83 c4 10             	add    $0x10,%esp
}
  801f57:	89 d8                	mov    %ebx,%eax
  801f59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	53                   	push   %ebx
  801f64:	83 ec 20             	sub    $0x20,%esp
  801f67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f6a:	53                   	push   %ebx
  801f6b:	e8 84 ee ff ff       	call   800df4 <strlen>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f78:	7f 67                	jg     801fe1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	e8 a7 f8 ff ff       	call   80182d <fd_alloc>
  801f86:	83 c4 10             	add    $0x10,%esp
		return r;
  801f89:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	78 57                	js     801fe6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f8f:	83 ec 08             	sub    $0x8,%esp
  801f92:	53                   	push   %ebx
  801f93:	68 00 60 80 00       	push   $0x806000
  801f98:	e8 90 ee ff ff       	call   800e2d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fad:	e8 03 fe ff ff       	call   801db5 <fsipc>
  801fb2:	89 c3                	mov    %eax,%ebx
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	79 14                	jns    801fcf <open+0x6f>
		fd_close(fd, 0);
  801fbb:	83 ec 08             	sub    $0x8,%esp
  801fbe:	6a 00                	push   $0x0
  801fc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc3:	e8 5d f9 ff ff       	call   801925 <fd_close>
		return r;
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	89 da                	mov    %ebx,%edx
  801fcd:	eb 17                	jmp    801fe6 <open+0x86>
	}

	return fd2num(fd);
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd5:	e8 2c f8 ff ff       	call   801806 <fd2num>
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	83 c4 10             	add    $0x10,%esp
  801fdf:	eb 05                	jmp    801fe6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801fe1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801feb:	c9                   	leave  
  801fec:	c3                   	ret    

00801fed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ff3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff8:	b8 08 00 00 00       	mov    $0x8,%eax
  801ffd:	e8 b3 fd ff ff       	call   801db5 <fsipc>
}
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80200a:	68 bf 32 80 00       	push   $0x8032bf
  80200f:	ff 75 0c             	pushl  0xc(%ebp)
  802012:	e8 16 ee ff ff       	call   800e2d <strcpy>
	return 0;
}
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	53                   	push   %ebx
  802022:	83 ec 10             	sub    $0x10,%esp
  802025:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802028:	53                   	push   %ebx
  802029:	e8 87 09 00 00       	call   8029b5 <pageref>
  80202e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802031:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802036:	83 f8 01             	cmp    $0x1,%eax
  802039:	75 10                	jne    80204b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80203b:	83 ec 0c             	sub    $0xc,%esp
  80203e:	ff 73 0c             	pushl  0xc(%ebx)
  802041:	e8 c0 02 00 00       	call   802306 <nsipc_close>
  802046:	89 c2                	mov    %eax,%edx
  802048:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802050:	c9                   	leave  
  802051:	c3                   	ret    

00802052 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802058:	6a 00                	push   $0x0
  80205a:	ff 75 10             	pushl  0x10(%ebp)
  80205d:	ff 75 0c             	pushl  0xc(%ebp)
  802060:	8b 45 08             	mov    0x8(%ebp),%eax
  802063:	ff 70 0c             	pushl  0xc(%eax)
  802066:	e8 78 03 00 00       	call   8023e3 <nsipc_send>
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802073:	6a 00                	push   $0x0
  802075:	ff 75 10             	pushl  0x10(%ebp)
  802078:	ff 75 0c             	pushl  0xc(%ebp)
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	ff 70 0c             	pushl  0xc(%eax)
  802081:	e8 f1 02 00 00       	call   802377 <nsipc_recv>
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80208e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802091:	52                   	push   %edx
  802092:	50                   	push   %eax
  802093:	e8 e4 f7 ff ff       	call   80187c <fd_lookup>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	78 17                	js     8020b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a2:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  8020a8:	39 08                	cmp    %ecx,(%eax)
  8020aa:	75 05                	jne    8020b1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8020ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8020af:	eb 05                	jmp    8020b6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8020b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8020b6:	c9                   	leave  
  8020b7:	c3                   	ret    

008020b8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	83 ec 1c             	sub    $0x1c,%esp
  8020c0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c5:	50                   	push   %eax
  8020c6:	e8 62 f7 ff ff       	call   80182d <fd_alloc>
  8020cb:	89 c3                	mov    %eax,%ebx
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 1b                	js     8020ef <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8020d4:	83 ec 04             	sub    $0x4,%esp
  8020d7:	68 07 04 00 00       	push   $0x407
  8020dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 4a f1 ff ff       	call   801230 <sys_page_alloc>
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	79 10                	jns    8020ff <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8020ef:	83 ec 0c             	sub    $0xc,%esp
  8020f2:	56                   	push   %esi
  8020f3:	e8 0e 02 00 00       	call   802306 <nsipc_close>
		return r;
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	eb 24                	jmp    802123 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8020ff:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802108:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802114:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802117:	83 ec 0c             	sub    $0xc,%esp
  80211a:	50                   	push   %eax
  80211b:	e8 e6 f6 ff ff       	call   801806 <fd2num>
  802120:	83 c4 10             	add    $0x10,%esp
}
  802123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802126:	5b                   	pop    %ebx
  802127:	5e                   	pop    %esi
  802128:	5d                   	pop    %ebp
  802129:	c3                   	ret    

0080212a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802130:	8b 45 08             	mov    0x8(%ebp),%eax
  802133:	e8 50 ff ff ff       	call   802088 <fd2sockid>
		return r;
  802138:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80213a:	85 c0                	test   %eax,%eax
  80213c:	78 1f                	js     80215d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80213e:	83 ec 04             	sub    $0x4,%esp
  802141:	ff 75 10             	pushl  0x10(%ebp)
  802144:	ff 75 0c             	pushl  0xc(%ebp)
  802147:	50                   	push   %eax
  802148:	e8 12 01 00 00       	call   80225f <nsipc_accept>
  80214d:	83 c4 10             	add    $0x10,%esp
		return r;
  802150:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802152:	85 c0                	test   %eax,%eax
  802154:	78 07                	js     80215d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802156:	e8 5d ff ff ff       	call   8020b8 <alloc_sockfd>
  80215b:	89 c1                	mov    %eax,%ecx
}
  80215d:	89 c8                	mov    %ecx,%eax
  80215f:	c9                   	leave  
  802160:	c3                   	ret    

00802161 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802167:	8b 45 08             	mov    0x8(%ebp),%eax
  80216a:	e8 19 ff ff ff       	call   802088 <fd2sockid>
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 12                	js     802185 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802173:	83 ec 04             	sub    $0x4,%esp
  802176:	ff 75 10             	pushl  0x10(%ebp)
  802179:	ff 75 0c             	pushl  0xc(%ebp)
  80217c:	50                   	push   %eax
  80217d:	e8 2d 01 00 00       	call   8022af <nsipc_bind>
  802182:	83 c4 10             	add    $0x10,%esp
}
  802185:	c9                   	leave  
  802186:	c3                   	ret    

00802187 <shutdown>:

int
shutdown(int s, int how)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80218d:	8b 45 08             	mov    0x8(%ebp),%eax
  802190:	e8 f3 fe ff ff       	call   802088 <fd2sockid>
  802195:	85 c0                	test   %eax,%eax
  802197:	78 0f                	js     8021a8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802199:	83 ec 08             	sub    $0x8,%esp
  80219c:	ff 75 0c             	pushl  0xc(%ebp)
  80219f:	50                   	push   %eax
  8021a0:	e8 3f 01 00 00       	call   8022e4 <nsipc_shutdown>
  8021a5:	83 c4 10             	add    $0x10,%esp
}
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b3:	e8 d0 fe ff ff       	call   802088 <fd2sockid>
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	78 12                	js     8021ce <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8021bc:	83 ec 04             	sub    $0x4,%esp
  8021bf:	ff 75 10             	pushl  0x10(%ebp)
  8021c2:	ff 75 0c             	pushl  0xc(%ebp)
  8021c5:	50                   	push   %eax
  8021c6:	e8 55 01 00 00       	call   802320 <nsipc_connect>
  8021cb:	83 c4 10             	add    $0x10,%esp
}
  8021ce:	c9                   	leave  
  8021cf:	c3                   	ret    

008021d0 <listen>:

int
listen(int s, int backlog)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d9:	e8 aa fe ff ff       	call   802088 <fd2sockid>
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 0f                	js     8021f1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021e2:	83 ec 08             	sub    $0x8,%esp
  8021e5:	ff 75 0c             	pushl  0xc(%ebp)
  8021e8:	50                   	push   %eax
  8021e9:	e8 67 01 00 00       	call   802355 <nsipc_listen>
  8021ee:	83 c4 10             	add    $0x10,%esp
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8021f9:	ff 75 10             	pushl  0x10(%ebp)
  8021fc:	ff 75 0c             	pushl  0xc(%ebp)
  8021ff:	ff 75 08             	pushl  0x8(%ebp)
  802202:	e8 3a 02 00 00       	call   802441 <nsipc_socket>
  802207:	83 c4 10             	add    $0x10,%esp
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 05                	js     802213 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80220e:	e8 a5 fe ff ff       	call   8020b8 <alloc_sockfd>
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	53                   	push   %ebx
  802219:	83 ec 04             	sub    $0x4,%esp
  80221c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80221e:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  802225:	75 12                	jne    802239 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802227:	83 ec 0c             	sub    $0xc,%esp
  80222a:	6a 02                	push   $0x2
  80222c:	e8 9c f5 ff ff       	call   8017cd <ipc_find_env>
  802231:	a3 1c 50 80 00       	mov    %eax,0x80501c
  802236:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802239:	6a 07                	push   $0x7
  80223b:	68 00 70 80 00       	push   $0x807000
  802240:	53                   	push   %ebx
  802241:	ff 35 1c 50 80 00    	pushl  0x80501c
  802247:	e8 2d f5 ff ff       	call   801779 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80224c:	83 c4 0c             	add    $0xc,%esp
  80224f:	6a 00                	push   $0x0
  802251:	6a 00                	push   $0x0
  802253:	6a 00                	push   $0x0
  802255:	e8 b8 f4 ff ff       	call   801712 <ipc_recv>
}
  80225a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    

0080225f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802267:	8b 45 08             	mov    0x8(%ebp),%eax
  80226a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80226f:	8b 06                	mov    (%esi),%eax
  802271:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	e8 95 ff ff ff       	call   802215 <nsipc>
  802280:	89 c3                	mov    %eax,%ebx
  802282:	85 c0                	test   %eax,%eax
  802284:	78 20                	js     8022a6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802286:	83 ec 04             	sub    $0x4,%esp
  802289:	ff 35 10 70 80 00    	pushl  0x807010
  80228f:	68 00 70 80 00       	push   $0x807000
  802294:	ff 75 0c             	pushl  0xc(%ebp)
  802297:	e8 23 ed ff ff       	call   800fbf <memmove>
		*addrlen = ret->ret_addrlen;
  80229c:	a1 10 70 80 00       	mov    0x807010,%eax
  8022a1:	89 06                	mov    %eax,(%esi)
  8022a3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ab:	5b                   	pop    %ebx
  8022ac:	5e                   	pop    %esi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	53                   	push   %ebx
  8022b3:	83 ec 08             	sub    $0x8,%esp
  8022b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022c1:	53                   	push   %ebx
  8022c2:	ff 75 0c             	pushl  0xc(%ebp)
  8022c5:	68 04 70 80 00       	push   $0x807004
  8022ca:	e8 f0 ec ff ff       	call   800fbf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022cf:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8022d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8022da:	e8 36 ff ff ff       	call   802215 <nsipc>
}
  8022df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e2:	c9                   	leave  
  8022e3:	c3                   	ret    

008022e4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ed:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8022f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f5:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8022fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8022ff:	e8 11 ff ff ff       	call   802215 <nsipc>
}
  802304:	c9                   	leave  
  802305:	c3                   	ret    

00802306 <nsipc_close>:

int
nsipc_close(int s)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802314:	b8 04 00 00 00       	mov    $0x4,%eax
  802319:	e8 f7 fe ff ff       	call   802215 <nsipc>
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	53                   	push   %ebx
  802324:	83 ec 08             	sub    $0x8,%esp
  802327:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80232a:	8b 45 08             	mov    0x8(%ebp),%eax
  80232d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802332:	53                   	push   %ebx
  802333:	ff 75 0c             	pushl  0xc(%ebp)
  802336:	68 04 70 80 00       	push   $0x807004
  80233b:	e8 7f ec ff ff       	call   800fbf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802340:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802346:	b8 05 00 00 00       	mov    $0x5,%eax
  80234b:	e8 c5 fe ff ff       	call   802215 <nsipc>
}
  802350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802353:	c9                   	leave  
  802354:	c3                   	ret    

00802355 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80235b:	8b 45 08             	mov    0x8(%ebp),%eax
  80235e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802363:	8b 45 0c             	mov    0xc(%ebp),%eax
  802366:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80236b:	b8 06 00 00 00       	mov    $0x6,%eax
  802370:	e8 a0 fe ff ff       	call   802215 <nsipc>
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	56                   	push   %esi
  80237b:	53                   	push   %ebx
  80237c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80237f:	8b 45 08             	mov    0x8(%ebp),%eax
  802382:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802387:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80238d:	8b 45 14             	mov    0x14(%ebp),%eax
  802390:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802395:	b8 07 00 00 00       	mov    $0x7,%eax
  80239a:	e8 76 fe ff ff       	call   802215 <nsipc>
  80239f:	89 c3                	mov    %eax,%ebx
  8023a1:	85 c0                	test   %eax,%eax
  8023a3:	78 35                	js     8023da <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8023a5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023aa:	7f 04                	jg     8023b0 <nsipc_recv+0x39>
  8023ac:	39 c6                	cmp    %eax,%esi
  8023ae:	7d 16                	jge    8023c6 <nsipc_recv+0x4f>
  8023b0:	68 cb 32 80 00       	push   $0x8032cb
  8023b5:	68 93 32 80 00       	push   $0x803293
  8023ba:	6a 62                	push   $0x62
  8023bc:	68 e0 32 80 00       	push   $0x8032e0
  8023c1:	e8 09 e4 ff ff       	call   8007cf <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023c6:	83 ec 04             	sub    $0x4,%esp
  8023c9:	50                   	push   %eax
  8023ca:	68 00 70 80 00       	push   $0x807000
  8023cf:	ff 75 0c             	pushl  0xc(%ebp)
  8023d2:	e8 e8 eb ff ff       	call   800fbf <memmove>
  8023d7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8023da:	89 d8                	mov    %ebx,%eax
  8023dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023df:	5b                   	pop    %ebx
  8023e0:	5e                   	pop    %esi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    

008023e3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8023e3:	55                   	push   %ebp
  8023e4:	89 e5                	mov    %esp,%ebp
  8023e6:	53                   	push   %ebx
  8023e7:	83 ec 04             	sub    $0x4,%esp
  8023ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8023ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f0:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8023f5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8023fb:	7e 16                	jle    802413 <nsipc_send+0x30>
  8023fd:	68 ec 32 80 00       	push   $0x8032ec
  802402:	68 93 32 80 00       	push   $0x803293
  802407:	6a 6d                	push   $0x6d
  802409:	68 e0 32 80 00       	push   $0x8032e0
  80240e:	e8 bc e3 ff ff       	call   8007cf <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802413:	83 ec 04             	sub    $0x4,%esp
  802416:	53                   	push   %ebx
  802417:	ff 75 0c             	pushl  0xc(%ebp)
  80241a:	68 0c 70 80 00       	push   $0x80700c
  80241f:	e8 9b eb ff ff       	call   800fbf <memmove>
	nsipcbuf.send.req_size = size;
  802424:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80242a:	8b 45 14             	mov    0x14(%ebp),%eax
  80242d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802432:	b8 08 00 00 00       	mov    $0x8,%eax
  802437:	e8 d9 fd ff ff       	call   802215 <nsipc>
}
  80243c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80243f:	c9                   	leave  
  802440:	c3                   	ret    

00802441 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802447:	8b 45 08             	mov    0x8(%ebp),%eax
  80244a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80244f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802452:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802457:	8b 45 10             	mov    0x10(%ebp),%eax
  80245a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80245f:	b8 09 00 00 00       	mov    $0x9,%eax
  802464:	e8 ac fd ff ff       	call   802215 <nsipc>
}
  802469:	c9                   	leave  
  80246a:	c3                   	ret    

0080246b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	56                   	push   %esi
  80246f:	53                   	push   %ebx
  802470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802473:	83 ec 0c             	sub    $0xc,%esp
  802476:	ff 75 08             	pushl  0x8(%ebp)
  802479:	e8 98 f3 ff ff       	call   801816 <fd2data>
  80247e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802480:	83 c4 08             	add    $0x8,%esp
  802483:	68 f8 32 80 00       	push   $0x8032f8
  802488:	53                   	push   %ebx
  802489:	e8 9f e9 ff ff       	call   800e2d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80248e:	8b 46 04             	mov    0x4(%esi),%eax
  802491:	2b 06                	sub    (%esi),%eax
  802493:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802499:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8024a0:	00 00 00 
	stat->st_dev = &devpipe;
  8024a3:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8024aa:	40 80 00 
	return 0;
}
  8024ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5e                   	pop    %esi
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    

008024b9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	53                   	push   %ebx
  8024bd:	83 ec 0c             	sub    $0xc,%esp
  8024c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024c3:	53                   	push   %ebx
  8024c4:	6a 00                	push   $0x0
  8024c6:	e8 ea ed ff ff       	call   8012b5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024cb:	89 1c 24             	mov    %ebx,(%esp)
  8024ce:	e8 43 f3 ff ff       	call   801816 <fd2data>
  8024d3:	83 c4 08             	add    $0x8,%esp
  8024d6:	50                   	push   %eax
  8024d7:	6a 00                	push   $0x0
  8024d9:	e8 d7 ed ff ff       	call   8012b5 <sys_page_unmap>
}
  8024de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024e1:	c9                   	leave  
  8024e2:	c3                   	ret    

008024e3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	57                   	push   %edi
  8024e7:	56                   	push   %esi
  8024e8:	53                   	push   %ebx
  8024e9:	83 ec 1c             	sub    $0x1c,%esp
  8024ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8024ef:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024f1:	a1 20 50 80 00       	mov    0x805020,%eax
  8024f6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8024f9:	83 ec 0c             	sub    $0xc,%esp
  8024fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8024ff:	e8 b1 04 00 00       	call   8029b5 <pageref>
  802504:	89 c3                	mov    %eax,%ebx
  802506:	89 3c 24             	mov    %edi,(%esp)
  802509:	e8 a7 04 00 00       	call   8029b5 <pageref>
  80250e:	83 c4 10             	add    $0x10,%esp
  802511:	39 c3                	cmp    %eax,%ebx
  802513:	0f 94 c1             	sete   %cl
  802516:	0f b6 c9             	movzbl %cl,%ecx
  802519:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80251c:	8b 15 20 50 80 00    	mov    0x805020,%edx
  802522:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802525:	39 ce                	cmp    %ecx,%esi
  802527:	74 1b                	je     802544 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802529:	39 c3                	cmp    %eax,%ebx
  80252b:	75 c4                	jne    8024f1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80252d:	8b 42 58             	mov    0x58(%edx),%eax
  802530:	ff 75 e4             	pushl  -0x1c(%ebp)
  802533:	50                   	push   %eax
  802534:	56                   	push   %esi
  802535:	68 ff 32 80 00       	push   $0x8032ff
  80253a:	e8 69 e3 ff ff       	call   8008a8 <cprintf>
  80253f:	83 c4 10             	add    $0x10,%esp
  802542:	eb ad                	jmp    8024f1 <_pipeisclosed+0xe>
	}
}
  802544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802547:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80254a:	5b                   	pop    %ebx
  80254b:	5e                   	pop    %esi
  80254c:	5f                   	pop    %edi
  80254d:	5d                   	pop    %ebp
  80254e:	c3                   	ret    

0080254f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	57                   	push   %edi
  802553:	56                   	push   %esi
  802554:	53                   	push   %ebx
  802555:	83 ec 28             	sub    $0x28,%esp
  802558:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80255b:	56                   	push   %esi
  80255c:	e8 b5 f2 ff ff       	call   801816 <fd2data>
  802561:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802563:	83 c4 10             	add    $0x10,%esp
  802566:	bf 00 00 00 00       	mov    $0x0,%edi
  80256b:	eb 4b                	jmp    8025b8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80256d:	89 da                	mov    %ebx,%edx
  80256f:	89 f0                	mov    %esi,%eax
  802571:	e8 6d ff ff ff       	call   8024e3 <_pipeisclosed>
  802576:	85 c0                	test   %eax,%eax
  802578:	75 48                	jne    8025c2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80257a:	e8 92 ec ff ff       	call   801211 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80257f:	8b 43 04             	mov    0x4(%ebx),%eax
  802582:	8b 0b                	mov    (%ebx),%ecx
  802584:	8d 51 20             	lea    0x20(%ecx),%edx
  802587:	39 d0                	cmp    %edx,%eax
  802589:	73 e2                	jae    80256d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80258b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80258e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802592:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802595:	89 c2                	mov    %eax,%edx
  802597:	c1 fa 1f             	sar    $0x1f,%edx
  80259a:	89 d1                	mov    %edx,%ecx
  80259c:	c1 e9 1b             	shr    $0x1b,%ecx
  80259f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8025a2:	83 e2 1f             	and    $0x1f,%edx
  8025a5:	29 ca                	sub    %ecx,%edx
  8025a7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8025ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8025af:	83 c0 01             	add    $0x1,%eax
  8025b2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025b5:	83 c7 01             	add    $0x1,%edi
  8025b8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025bb:	75 c2                	jne    80257f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8025bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8025c0:	eb 05                	jmp    8025c7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025c2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8025c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ca:	5b                   	pop    %ebx
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    

008025cf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025cf:	55                   	push   %ebp
  8025d0:	89 e5                	mov    %esp,%ebp
  8025d2:	57                   	push   %edi
  8025d3:	56                   	push   %esi
  8025d4:	53                   	push   %ebx
  8025d5:	83 ec 18             	sub    $0x18,%esp
  8025d8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025db:	57                   	push   %edi
  8025dc:	e8 35 f2 ff ff       	call   801816 <fd2data>
  8025e1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025e3:	83 c4 10             	add    $0x10,%esp
  8025e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025eb:	eb 3d                	jmp    80262a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025ed:	85 db                	test   %ebx,%ebx
  8025ef:	74 04                	je     8025f5 <devpipe_read+0x26>
				return i;
  8025f1:	89 d8                	mov    %ebx,%eax
  8025f3:	eb 44                	jmp    802639 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025f5:	89 f2                	mov    %esi,%edx
  8025f7:	89 f8                	mov    %edi,%eax
  8025f9:	e8 e5 fe ff ff       	call   8024e3 <_pipeisclosed>
  8025fe:	85 c0                	test   %eax,%eax
  802600:	75 32                	jne    802634 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802602:	e8 0a ec ff ff       	call   801211 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802607:	8b 06                	mov    (%esi),%eax
  802609:	3b 46 04             	cmp    0x4(%esi),%eax
  80260c:	74 df                	je     8025ed <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80260e:	99                   	cltd   
  80260f:	c1 ea 1b             	shr    $0x1b,%edx
  802612:	01 d0                	add    %edx,%eax
  802614:	83 e0 1f             	and    $0x1f,%eax
  802617:	29 d0                	sub    %edx,%eax
  802619:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80261e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802621:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802624:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802627:	83 c3 01             	add    $0x1,%ebx
  80262a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80262d:	75 d8                	jne    802607 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80262f:	8b 45 10             	mov    0x10(%ebp),%eax
  802632:	eb 05                	jmp    802639 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802634:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80263c:	5b                   	pop    %ebx
  80263d:	5e                   	pop    %esi
  80263e:	5f                   	pop    %edi
  80263f:	5d                   	pop    %ebp
  802640:	c3                   	ret    

00802641 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802641:	55                   	push   %ebp
  802642:	89 e5                	mov    %esp,%ebp
  802644:	56                   	push   %esi
  802645:	53                   	push   %ebx
  802646:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802649:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80264c:	50                   	push   %eax
  80264d:	e8 db f1 ff ff       	call   80182d <fd_alloc>
  802652:	83 c4 10             	add    $0x10,%esp
  802655:	89 c2                	mov    %eax,%edx
  802657:	85 c0                	test   %eax,%eax
  802659:	0f 88 2c 01 00 00    	js     80278b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80265f:	83 ec 04             	sub    $0x4,%esp
  802662:	68 07 04 00 00       	push   $0x407
  802667:	ff 75 f4             	pushl  -0xc(%ebp)
  80266a:	6a 00                	push   $0x0
  80266c:	e8 bf eb ff ff       	call   801230 <sys_page_alloc>
  802671:	83 c4 10             	add    $0x10,%esp
  802674:	89 c2                	mov    %eax,%edx
  802676:	85 c0                	test   %eax,%eax
  802678:	0f 88 0d 01 00 00    	js     80278b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80267e:	83 ec 0c             	sub    $0xc,%esp
  802681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802684:	50                   	push   %eax
  802685:	e8 a3 f1 ff ff       	call   80182d <fd_alloc>
  80268a:	89 c3                	mov    %eax,%ebx
  80268c:	83 c4 10             	add    $0x10,%esp
  80268f:	85 c0                	test   %eax,%eax
  802691:	0f 88 e2 00 00 00    	js     802779 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802697:	83 ec 04             	sub    $0x4,%esp
  80269a:	68 07 04 00 00       	push   $0x407
  80269f:	ff 75 f0             	pushl  -0x10(%ebp)
  8026a2:	6a 00                	push   $0x0
  8026a4:	e8 87 eb ff ff       	call   801230 <sys_page_alloc>
  8026a9:	89 c3                	mov    %eax,%ebx
  8026ab:	83 c4 10             	add    $0x10,%esp
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	0f 88 c3 00 00 00    	js     802779 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8026b6:	83 ec 0c             	sub    $0xc,%esp
  8026b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8026bc:	e8 55 f1 ff ff       	call   801816 <fd2data>
  8026c1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026c3:	83 c4 0c             	add    $0xc,%esp
  8026c6:	68 07 04 00 00       	push   $0x407
  8026cb:	50                   	push   %eax
  8026cc:	6a 00                	push   $0x0
  8026ce:	e8 5d eb ff ff       	call   801230 <sys_page_alloc>
  8026d3:	89 c3                	mov    %eax,%ebx
  8026d5:	83 c4 10             	add    $0x10,%esp
  8026d8:	85 c0                	test   %eax,%eax
  8026da:	0f 88 89 00 00 00    	js     802769 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026e0:	83 ec 0c             	sub    $0xc,%esp
  8026e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8026e6:	e8 2b f1 ff ff       	call   801816 <fd2data>
  8026eb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026f2:	50                   	push   %eax
  8026f3:	6a 00                	push   $0x0
  8026f5:	56                   	push   %esi
  8026f6:	6a 00                	push   $0x0
  8026f8:	e8 76 eb ff ff       	call   801273 <sys_page_map>
  8026fd:	89 c3                	mov    %eax,%ebx
  8026ff:	83 c4 20             	add    $0x20,%esp
  802702:	85 c0                	test   %eax,%eax
  802704:	78 55                	js     80275b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802706:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80270c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802714:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80271b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802724:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802729:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802730:	83 ec 0c             	sub    $0xc,%esp
  802733:	ff 75 f4             	pushl  -0xc(%ebp)
  802736:	e8 cb f0 ff ff       	call   801806 <fd2num>
  80273b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80273e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802740:	83 c4 04             	add    $0x4,%esp
  802743:	ff 75 f0             	pushl  -0x10(%ebp)
  802746:	e8 bb f0 ff ff       	call   801806 <fd2num>
  80274b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80274e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802751:	83 c4 10             	add    $0x10,%esp
  802754:	ba 00 00 00 00       	mov    $0x0,%edx
  802759:	eb 30                	jmp    80278b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80275b:	83 ec 08             	sub    $0x8,%esp
  80275e:	56                   	push   %esi
  80275f:	6a 00                	push   $0x0
  802761:	e8 4f eb ff ff       	call   8012b5 <sys_page_unmap>
  802766:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802769:	83 ec 08             	sub    $0x8,%esp
  80276c:	ff 75 f0             	pushl  -0x10(%ebp)
  80276f:	6a 00                	push   $0x0
  802771:	e8 3f eb ff ff       	call   8012b5 <sys_page_unmap>
  802776:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802779:	83 ec 08             	sub    $0x8,%esp
  80277c:	ff 75 f4             	pushl  -0xc(%ebp)
  80277f:	6a 00                	push   $0x0
  802781:	e8 2f eb ff ff       	call   8012b5 <sys_page_unmap>
  802786:	83 c4 10             	add    $0x10,%esp
  802789:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80278b:	89 d0                	mov    %edx,%eax
  80278d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802790:	5b                   	pop    %ebx
  802791:	5e                   	pop    %esi
  802792:	5d                   	pop    %ebp
  802793:	c3                   	ret    

00802794 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802794:	55                   	push   %ebp
  802795:	89 e5                	mov    %esp,%ebp
  802797:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80279a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80279d:	50                   	push   %eax
  80279e:	ff 75 08             	pushl  0x8(%ebp)
  8027a1:	e8 d6 f0 ff ff       	call   80187c <fd_lookup>
  8027a6:	83 c4 10             	add    $0x10,%esp
  8027a9:	85 c0                	test   %eax,%eax
  8027ab:	78 18                	js     8027c5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8027ad:	83 ec 0c             	sub    $0xc,%esp
  8027b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8027b3:	e8 5e f0 ff ff       	call   801816 <fd2data>
	return _pipeisclosed(fd, p);
  8027b8:	89 c2                	mov    %eax,%edx
  8027ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027bd:	e8 21 fd ff ff       	call   8024e3 <_pipeisclosed>
  8027c2:	83 c4 10             	add    $0x10,%esp
}
  8027c5:	c9                   	leave  
  8027c6:	c3                   	ret    

008027c7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8027c7:	55                   	push   %ebp
  8027c8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8027ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8027cf:	5d                   	pop    %ebp
  8027d0:	c3                   	ret    

008027d1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8027d1:	55                   	push   %ebp
  8027d2:	89 e5                	mov    %esp,%ebp
  8027d4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8027d7:	68 17 33 80 00       	push   $0x803317
  8027dc:	ff 75 0c             	pushl  0xc(%ebp)
  8027df:	e8 49 e6 ff ff       	call   800e2d <strcpy>
	return 0;
}
  8027e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8027e9:	c9                   	leave  
  8027ea:	c3                   	ret    

008027eb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027eb:	55                   	push   %ebp
  8027ec:	89 e5                	mov    %esp,%ebp
  8027ee:	57                   	push   %edi
  8027ef:	56                   	push   %esi
  8027f0:	53                   	push   %ebx
  8027f1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027f7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027fc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802802:	eb 2d                	jmp    802831 <devcons_write+0x46>
		m = n - tot;
  802804:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802807:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802809:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80280c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802811:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802814:	83 ec 04             	sub    $0x4,%esp
  802817:	53                   	push   %ebx
  802818:	03 45 0c             	add    0xc(%ebp),%eax
  80281b:	50                   	push   %eax
  80281c:	57                   	push   %edi
  80281d:	e8 9d e7 ff ff       	call   800fbf <memmove>
		sys_cputs(buf, m);
  802822:	83 c4 08             	add    $0x8,%esp
  802825:	53                   	push   %ebx
  802826:	57                   	push   %edi
  802827:	e8 48 e9 ff ff       	call   801174 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80282c:	01 de                	add    %ebx,%esi
  80282e:	83 c4 10             	add    $0x10,%esp
  802831:	89 f0                	mov    %esi,%eax
  802833:	3b 75 10             	cmp    0x10(%ebp),%esi
  802836:	72 cc                	jb     802804 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802838:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80283b:	5b                   	pop    %ebx
  80283c:	5e                   	pop    %esi
  80283d:	5f                   	pop    %edi
  80283e:	5d                   	pop    %ebp
  80283f:	c3                   	ret    

00802840 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802840:	55                   	push   %ebp
  802841:	89 e5                	mov    %esp,%ebp
  802843:	83 ec 08             	sub    $0x8,%esp
  802846:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80284b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80284f:	74 2a                	je     80287b <devcons_read+0x3b>
  802851:	eb 05                	jmp    802858 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802853:	e8 b9 e9 ff ff       	call   801211 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802858:	e8 35 e9 ff ff       	call   801192 <sys_cgetc>
  80285d:	85 c0                	test   %eax,%eax
  80285f:	74 f2                	je     802853 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802861:	85 c0                	test   %eax,%eax
  802863:	78 16                	js     80287b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802865:	83 f8 04             	cmp    $0x4,%eax
  802868:	74 0c                	je     802876 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80286a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80286d:	88 02                	mov    %al,(%edx)
	return 1;
  80286f:	b8 01 00 00 00       	mov    $0x1,%eax
  802874:	eb 05                	jmp    80287b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802876:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80287b:	c9                   	leave  
  80287c:	c3                   	ret    

0080287d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80287d:	55                   	push   %ebp
  80287e:	89 e5                	mov    %esp,%ebp
  802880:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802883:	8b 45 08             	mov    0x8(%ebp),%eax
  802886:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802889:	6a 01                	push   $0x1
  80288b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80288e:	50                   	push   %eax
  80288f:	e8 e0 e8 ff ff       	call   801174 <sys_cputs>
}
  802894:	83 c4 10             	add    $0x10,%esp
  802897:	c9                   	leave  
  802898:	c3                   	ret    

00802899 <getchar>:

int
getchar(void)
{
  802899:	55                   	push   %ebp
  80289a:	89 e5                	mov    %esp,%ebp
  80289c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80289f:	6a 01                	push   $0x1
  8028a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028a4:	50                   	push   %eax
  8028a5:	6a 00                	push   $0x0
  8028a7:	e8 36 f2 ff ff       	call   801ae2 <read>
	if (r < 0)
  8028ac:	83 c4 10             	add    $0x10,%esp
  8028af:	85 c0                	test   %eax,%eax
  8028b1:	78 0f                	js     8028c2 <getchar+0x29>
		return r;
	if (r < 1)
  8028b3:	85 c0                	test   %eax,%eax
  8028b5:	7e 06                	jle    8028bd <getchar+0x24>
		return -E_EOF;
	return c;
  8028b7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028bb:	eb 05                	jmp    8028c2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028bd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028c2:	c9                   	leave  
  8028c3:	c3                   	ret    

008028c4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8028c4:	55                   	push   %ebp
  8028c5:	89 e5                	mov    %esp,%ebp
  8028c7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028cd:	50                   	push   %eax
  8028ce:	ff 75 08             	pushl  0x8(%ebp)
  8028d1:	e8 a6 ef ff ff       	call   80187c <fd_lookup>
  8028d6:	83 c4 10             	add    $0x10,%esp
  8028d9:	85 c0                	test   %eax,%eax
  8028db:	78 11                	js     8028ee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028e6:	39 10                	cmp    %edx,(%eax)
  8028e8:	0f 94 c0             	sete   %al
  8028eb:	0f b6 c0             	movzbl %al,%eax
}
  8028ee:	c9                   	leave  
  8028ef:	c3                   	ret    

008028f0 <opencons>:

int
opencons(void)
{
  8028f0:	55                   	push   %ebp
  8028f1:	89 e5                	mov    %esp,%ebp
  8028f3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028f9:	50                   	push   %eax
  8028fa:	e8 2e ef ff ff       	call   80182d <fd_alloc>
  8028ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802902:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802904:	85 c0                	test   %eax,%eax
  802906:	78 3e                	js     802946 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802908:	83 ec 04             	sub    $0x4,%esp
  80290b:	68 07 04 00 00       	push   $0x407
  802910:	ff 75 f4             	pushl  -0xc(%ebp)
  802913:	6a 00                	push   $0x0
  802915:	e8 16 e9 ff ff       	call   801230 <sys_page_alloc>
  80291a:	83 c4 10             	add    $0x10,%esp
		return r;
  80291d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80291f:	85 c0                	test   %eax,%eax
  802921:	78 23                	js     802946 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802923:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80292c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80292e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802931:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802938:	83 ec 0c             	sub    $0xc,%esp
  80293b:	50                   	push   %eax
  80293c:	e8 c5 ee ff ff       	call   801806 <fd2num>
  802941:	89 c2                	mov    %eax,%edx
  802943:	83 c4 10             	add    $0x10,%esp
}
  802946:	89 d0                	mov    %edx,%eax
  802948:	c9                   	leave  
  802949:	c3                   	ret    

0080294a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80294a:	55                   	push   %ebp
  80294b:	89 e5                	mov    %esp,%ebp
  80294d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802950:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802957:	75 2e                	jne    802987 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802959:	e8 94 e8 ff ff       	call   8011f2 <sys_getenvid>
  80295e:	83 ec 04             	sub    $0x4,%esp
  802961:	68 07 0e 00 00       	push   $0xe07
  802966:	68 00 f0 bf ee       	push   $0xeebff000
  80296b:	50                   	push   %eax
  80296c:	e8 bf e8 ff ff       	call   801230 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802971:	e8 7c e8 ff ff       	call   8011f2 <sys_getenvid>
  802976:	83 c4 08             	add    $0x8,%esp
  802979:	68 91 29 80 00       	push   $0x802991
  80297e:	50                   	push   %eax
  80297f:	e8 f7 e9 ff ff       	call   80137b <sys_env_set_pgfault_upcall>
  802984:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802987:	8b 45 08             	mov    0x8(%ebp),%eax
  80298a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80298f:	c9                   	leave  
  802990:	c3                   	ret    

00802991 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802991:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802992:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802997:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802999:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80299c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8029a0:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8029a4:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8029a7:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8029aa:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8029ab:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8029ae:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8029af:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8029b0:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8029b4:	c3                   	ret    

008029b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029b5:	55                   	push   %ebp
  8029b6:	89 e5                	mov    %esp,%ebp
  8029b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029bb:	89 d0                	mov    %edx,%eax
  8029bd:	c1 e8 16             	shr    $0x16,%eax
  8029c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029c7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029cc:	f6 c1 01             	test   $0x1,%cl
  8029cf:	74 1d                	je     8029ee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029d1:	c1 ea 0c             	shr    $0xc,%edx
  8029d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029db:	f6 c2 01             	test   $0x1,%dl
  8029de:	74 0e                	je     8029ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029e0:	c1 ea 0c             	shr    $0xc,%edx
  8029e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029ea:	ef 
  8029eb:	0f b7 c0             	movzwl %ax,%eax
}
  8029ee:	5d                   	pop    %ebp
  8029ef:	c3                   	ret    

008029f0 <__udivdi3>:
  8029f0:	55                   	push   %ebp
  8029f1:	57                   	push   %edi
  8029f2:	56                   	push   %esi
  8029f3:	53                   	push   %ebx
  8029f4:	83 ec 1c             	sub    $0x1c,%esp
  8029f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8029fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8029ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a07:	85 f6                	test   %esi,%esi
  802a09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a0d:	89 ca                	mov    %ecx,%edx
  802a0f:	89 f8                	mov    %edi,%eax
  802a11:	75 3d                	jne    802a50 <__udivdi3+0x60>
  802a13:	39 cf                	cmp    %ecx,%edi
  802a15:	0f 87 c5 00 00 00    	ja     802ae0 <__udivdi3+0xf0>
  802a1b:	85 ff                	test   %edi,%edi
  802a1d:	89 fd                	mov    %edi,%ebp
  802a1f:	75 0b                	jne    802a2c <__udivdi3+0x3c>
  802a21:	b8 01 00 00 00       	mov    $0x1,%eax
  802a26:	31 d2                	xor    %edx,%edx
  802a28:	f7 f7                	div    %edi
  802a2a:	89 c5                	mov    %eax,%ebp
  802a2c:	89 c8                	mov    %ecx,%eax
  802a2e:	31 d2                	xor    %edx,%edx
  802a30:	f7 f5                	div    %ebp
  802a32:	89 c1                	mov    %eax,%ecx
  802a34:	89 d8                	mov    %ebx,%eax
  802a36:	89 cf                	mov    %ecx,%edi
  802a38:	f7 f5                	div    %ebp
  802a3a:	89 c3                	mov    %eax,%ebx
  802a3c:	89 d8                	mov    %ebx,%eax
  802a3e:	89 fa                	mov    %edi,%edx
  802a40:	83 c4 1c             	add    $0x1c,%esp
  802a43:	5b                   	pop    %ebx
  802a44:	5e                   	pop    %esi
  802a45:	5f                   	pop    %edi
  802a46:	5d                   	pop    %ebp
  802a47:	c3                   	ret    
  802a48:	90                   	nop
  802a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a50:	39 ce                	cmp    %ecx,%esi
  802a52:	77 74                	ja     802ac8 <__udivdi3+0xd8>
  802a54:	0f bd fe             	bsr    %esi,%edi
  802a57:	83 f7 1f             	xor    $0x1f,%edi
  802a5a:	0f 84 98 00 00 00    	je     802af8 <__udivdi3+0x108>
  802a60:	bb 20 00 00 00       	mov    $0x20,%ebx
  802a65:	89 f9                	mov    %edi,%ecx
  802a67:	89 c5                	mov    %eax,%ebp
  802a69:	29 fb                	sub    %edi,%ebx
  802a6b:	d3 e6                	shl    %cl,%esi
  802a6d:	89 d9                	mov    %ebx,%ecx
  802a6f:	d3 ed                	shr    %cl,%ebp
  802a71:	89 f9                	mov    %edi,%ecx
  802a73:	d3 e0                	shl    %cl,%eax
  802a75:	09 ee                	or     %ebp,%esi
  802a77:	89 d9                	mov    %ebx,%ecx
  802a79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a7d:	89 d5                	mov    %edx,%ebp
  802a7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a83:	d3 ed                	shr    %cl,%ebp
  802a85:	89 f9                	mov    %edi,%ecx
  802a87:	d3 e2                	shl    %cl,%edx
  802a89:	89 d9                	mov    %ebx,%ecx
  802a8b:	d3 e8                	shr    %cl,%eax
  802a8d:	09 c2                	or     %eax,%edx
  802a8f:	89 d0                	mov    %edx,%eax
  802a91:	89 ea                	mov    %ebp,%edx
  802a93:	f7 f6                	div    %esi
  802a95:	89 d5                	mov    %edx,%ebp
  802a97:	89 c3                	mov    %eax,%ebx
  802a99:	f7 64 24 0c          	mull   0xc(%esp)
  802a9d:	39 d5                	cmp    %edx,%ebp
  802a9f:	72 10                	jb     802ab1 <__udivdi3+0xc1>
  802aa1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802aa5:	89 f9                	mov    %edi,%ecx
  802aa7:	d3 e6                	shl    %cl,%esi
  802aa9:	39 c6                	cmp    %eax,%esi
  802aab:	73 07                	jae    802ab4 <__udivdi3+0xc4>
  802aad:	39 d5                	cmp    %edx,%ebp
  802aaf:	75 03                	jne    802ab4 <__udivdi3+0xc4>
  802ab1:	83 eb 01             	sub    $0x1,%ebx
  802ab4:	31 ff                	xor    %edi,%edi
  802ab6:	89 d8                	mov    %ebx,%eax
  802ab8:	89 fa                	mov    %edi,%edx
  802aba:	83 c4 1c             	add    $0x1c,%esp
  802abd:	5b                   	pop    %ebx
  802abe:	5e                   	pop    %esi
  802abf:	5f                   	pop    %edi
  802ac0:	5d                   	pop    %ebp
  802ac1:	c3                   	ret    
  802ac2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ac8:	31 ff                	xor    %edi,%edi
  802aca:	31 db                	xor    %ebx,%ebx
  802acc:	89 d8                	mov    %ebx,%eax
  802ace:	89 fa                	mov    %edi,%edx
  802ad0:	83 c4 1c             	add    $0x1c,%esp
  802ad3:	5b                   	pop    %ebx
  802ad4:	5e                   	pop    %esi
  802ad5:	5f                   	pop    %edi
  802ad6:	5d                   	pop    %ebp
  802ad7:	c3                   	ret    
  802ad8:	90                   	nop
  802ad9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ae0:	89 d8                	mov    %ebx,%eax
  802ae2:	f7 f7                	div    %edi
  802ae4:	31 ff                	xor    %edi,%edi
  802ae6:	89 c3                	mov    %eax,%ebx
  802ae8:	89 d8                	mov    %ebx,%eax
  802aea:	89 fa                	mov    %edi,%edx
  802aec:	83 c4 1c             	add    $0x1c,%esp
  802aef:	5b                   	pop    %ebx
  802af0:	5e                   	pop    %esi
  802af1:	5f                   	pop    %edi
  802af2:	5d                   	pop    %ebp
  802af3:	c3                   	ret    
  802af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802af8:	39 ce                	cmp    %ecx,%esi
  802afa:	72 0c                	jb     802b08 <__udivdi3+0x118>
  802afc:	31 db                	xor    %ebx,%ebx
  802afe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b02:	0f 87 34 ff ff ff    	ja     802a3c <__udivdi3+0x4c>
  802b08:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b0d:	e9 2a ff ff ff       	jmp    802a3c <__udivdi3+0x4c>
  802b12:	66 90                	xchg   %ax,%ax
  802b14:	66 90                	xchg   %ax,%ax
  802b16:	66 90                	xchg   %ax,%ax
  802b18:	66 90                	xchg   %ax,%ax
  802b1a:	66 90                	xchg   %ax,%ax
  802b1c:	66 90                	xchg   %ax,%ax
  802b1e:	66 90                	xchg   %ax,%ax

00802b20 <__umoddi3>:
  802b20:	55                   	push   %ebp
  802b21:	57                   	push   %edi
  802b22:	56                   	push   %esi
  802b23:	53                   	push   %ebx
  802b24:	83 ec 1c             	sub    $0x1c,%esp
  802b27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b37:	85 d2                	test   %edx,%edx
  802b39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b41:	89 f3                	mov    %esi,%ebx
  802b43:	89 3c 24             	mov    %edi,(%esp)
  802b46:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b4a:	75 1c                	jne    802b68 <__umoddi3+0x48>
  802b4c:	39 f7                	cmp    %esi,%edi
  802b4e:	76 50                	jbe    802ba0 <__umoddi3+0x80>
  802b50:	89 c8                	mov    %ecx,%eax
  802b52:	89 f2                	mov    %esi,%edx
  802b54:	f7 f7                	div    %edi
  802b56:	89 d0                	mov    %edx,%eax
  802b58:	31 d2                	xor    %edx,%edx
  802b5a:	83 c4 1c             	add    $0x1c,%esp
  802b5d:	5b                   	pop    %ebx
  802b5e:	5e                   	pop    %esi
  802b5f:	5f                   	pop    %edi
  802b60:	5d                   	pop    %ebp
  802b61:	c3                   	ret    
  802b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b68:	39 f2                	cmp    %esi,%edx
  802b6a:	89 d0                	mov    %edx,%eax
  802b6c:	77 52                	ja     802bc0 <__umoddi3+0xa0>
  802b6e:	0f bd ea             	bsr    %edx,%ebp
  802b71:	83 f5 1f             	xor    $0x1f,%ebp
  802b74:	75 5a                	jne    802bd0 <__umoddi3+0xb0>
  802b76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802b7a:	0f 82 e0 00 00 00    	jb     802c60 <__umoddi3+0x140>
  802b80:	39 0c 24             	cmp    %ecx,(%esp)
  802b83:	0f 86 d7 00 00 00    	jbe    802c60 <__umoddi3+0x140>
  802b89:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b91:	83 c4 1c             	add    $0x1c,%esp
  802b94:	5b                   	pop    %ebx
  802b95:	5e                   	pop    %esi
  802b96:	5f                   	pop    %edi
  802b97:	5d                   	pop    %ebp
  802b98:	c3                   	ret    
  802b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ba0:	85 ff                	test   %edi,%edi
  802ba2:	89 fd                	mov    %edi,%ebp
  802ba4:	75 0b                	jne    802bb1 <__umoddi3+0x91>
  802ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bab:	31 d2                	xor    %edx,%edx
  802bad:	f7 f7                	div    %edi
  802baf:	89 c5                	mov    %eax,%ebp
  802bb1:	89 f0                	mov    %esi,%eax
  802bb3:	31 d2                	xor    %edx,%edx
  802bb5:	f7 f5                	div    %ebp
  802bb7:	89 c8                	mov    %ecx,%eax
  802bb9:	f7 f5                	div    %ebp
  802bbb:	89 d0                	mov    %edx,%eax
  802bbd:	eb 99                	jmp    802b58 <__umoddi3+0x38>
  802bbf:	90                   	nop
  802bc0:	89 c8                	mov    %ecx,%eax
  802bc2:	89 f2                	mov    %esi,%edx
  802bc4:	83 c4 1c             	add    $0x1c,%esp
  802bc7:	5b                   	pop    %ebx
  802bc8:	5e                   	pop    %esi
  802bc9:	5f                   	pop    %edi
  802bca:	5d                   	pop    %ebp
  802bcb:	c3                   	ret    
  802bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bd0:	8b 34 24             	mov    (%esp),%esi
  802bd3:	bf 20 00 00 00       	mov    $0x20,%edi
  802bd8:	89 e9                	mov    %ebp,%ecx
  802bda:	29 ef                	sub    %ebp,%edi
  802bdc:	d3 e0                	shl    %cl,%eax
  802bde:	89 f9                	mov    %edi,%ecx
  802be0:	89 f2                	mov    %esi,%edx
  802be2:	d3 ea                	shr    %cl,%edx
  802be4:	89 e9                	mov    %ebp,%ecx
  802be6:	09 c2                	or     %eax,%edx
  802be8:	89 d8                	mov    %ebx,%eax
  802bea:	89 14 24             	mov    %edx,(%esp)
  802bed:	89 f2                	mov    %esi,%edx
  802bef:	d3 e2                	shl    %cl,%edx
  802bf1:	89 f9                	mov    %edi,%ecx
  802bf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802bf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802bfb:	d3 e8                	shr    %cl,%eax
  802bfd:	89 e9                	mov    %ebp,%ecx
  802bff:	89 c6                	mov    %eax,%esi
  802c01:	d3 e3                	shl    %cl,%ebx
  802c03:	89 f9                	mov    %edi,%ecx
  802c05:	89 d0                	mov    %edx,%eax
  802c07:	d3 e8                	shr    %cl,%eax
  802c09:	89 e9                	mov    %ebp,%ecx
  802c0b:	09 d8                	or     %ebx,%eax
  802c0d:	89 d3                	mov    %edx,%ebx
  802c0f:	89 f2                	mov    %esi,%edx
  802c11:	f7 34 24             	divl   (%esp)
  802c14:	89 d6                	mov    %edx,%esi
  802c16:	d3 e3                	shl    %cl,%ebx
  802c18:	f7 64 24 04          	mull   0x4(%esp)
  802c1c:	39 d6                	cmp    %edx,%esi
  802c1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c22:	89 d1                	mov    %edx,%ecx
  802c24:	89 c3                	mov    %eax,%ebx
  802c26:	72 08                	jb     802c30 <__umoddi3+0x110>
  802c28:	75 11                	jne    802c3b <__umoddi3+0x11b>
  802c2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c2e:	73 0b                	jae    802c3b <__umoddi3+0x11b>
  802c30:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c34:	1b 14 24             	sbb    (%esp),%edx
  802c37:	89 d1                	mov    %edx,%ecx
  802c39:	89 c3                	mov    %eax,%ebx
  802c3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c3f:	29 da                	sub    %ebx,%edx
  802c41:	19 ce                	sbb    %ecx,%esi
  802c43:	89 f9                	mov    %edi,%ecx
  802c45:	89 f0                	mov    %esi,%eax
  802c47:	d3 e0                	shl    %cl,%eax
  802c49:	89 e9                	mov    %ebp,%ecx
  802c4b:	d3 ea                	shr    %cl,%edx
  802c4d:	89 e9                	mov    %ebp,%ecx
  802c4f:	d3 ee                	shr    %cl,%esi
  802c51:	09 d0                	or     %edx,%eax
  802c53:	89 f2                	mov    %esi,%edx
  802c55:	83 c4 1c             	add    $0x1c,%esp
  802c58:	5b                   	pop    %ebx
  802c59:	5e                   	pop    %esi
  802c5a:	5f                   	pop    %edi
  802c5b:	5d                   	pop    %ebp
  802c5c:	c3                   	ret    
  802c5d:	8d 76 00             	lea    0x0(%esi),%esi
  802c60:	29 f9                	sub    %edi,%ecx
  802c62:	19 d6                	sbb    %edx,%esi
  802c64:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c6c:	e9 18 ff ff ff       	jmp    802b89 <__umoddi3+0x69>
