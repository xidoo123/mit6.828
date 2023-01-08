
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
  80002c:	e8 fb 06 00 00       	call   80072c <libmain>
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
  80003c:	e8 6e 11 00 00       	call   8011af <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 00 	movl   $0x802c00,0x804000
  80004a:	2c 80 00 

	output_envid = fork();
  80004d:	e8 84 14 00 00       	call   8014d6 <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 0a 2c 80 00       	push   $0x802c0a
  800063:	6a 4d                	push   $0x4d
  800065:	68 18 2c 80 00       	push   $0x802c18
  80006a:	e8 1d 07 00 00       	call   80078c <_panic>
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
  800084:	e8 4d 14 00 00       	call   8014d6 <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 0a 2c 80 00       	push   $0x802c0a
  80009a:	6a 55                	push   $0x55
  80009c:	68 18 2c 80 00       	push   $0x802c18
  8000a1:	e8 e6 06 00 00       	call   80078c <_panic>
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
  8000be:	68 28 2c 80 00       	push   $0x802c28
  8000c3:	e8 9d 07 00 00       	call   800865 <cprintf>
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
  8000e0:	c7 04 24 45 2c 80 00 	movl   $0x802c45,(%esp)
  8000e7:	e8 0e 06 00 00       	call   8006fa <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 4f 2c 80 00 	movl   $0x802c4f,(%esp)
  8000f6:	e8 ff 05 00 00       	call   8006fa <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 de 10 00 00       	call   8011ed <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 58 2c 80 00       	push   $0x802c58
  80011c:	6a 19                	push   $0x19
  80011e:	68 18 2c 80 00       	push   $0x802c18
  800123:	e8 64 06 00 00       	call   80078c <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 e9 0d 00 00       	call   800f2f <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 8b 0e 00 00       	call   800fe4 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 7c 03 00 00       	call   8004e1 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 6a 03 00 00       	call   8004e1 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 58 03 00 00       	call   8004e1 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 46 03 00 00       	call   8004e1 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 34 03 00 00       	call   8004e1 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 21 0e 00 00       	call   800fe4 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 0e 0e 00 00       	call   800fe4 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 48 0d 00 00       	call   800f2f <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 ea 0d 00 00       	call   800fe4 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 e6 14 00 00       	call   8016f4 <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 55 10 00 00       	call   801272 <sys_page_unmap>
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
  80023a:	e8 4e 14 00 00       	call   80168d <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 69 2c 80 00       	push   $0x802c69
  80024c:	6a 64                	push   $0x64
  80024e:	68 18 2c 80 00       	push   $0x802c18
  800253:	e8 34 05 00 00       	call   80078c <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 c0 2c 80 00       	push   $0x802cc0
  800269:	6a 66                	push   $0x66
  80026b:	68 18 2c 80 00       	push   $0x802c18
  800270:	e8 17 05 00 00       	call   80078c <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 76 2c 80 00       	push   $0x802c76
  800280:	6a 68                	push   $0x68
  800282:	68 18 2c 80 00       	push   $0x802c18
  800287:	e8 00 05 00 00       	call   80078c <_panic>

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
  8002b4:	68 88 2c 80 00       	push   $0x802c88
  8002b9:	68 90 2c 80 00       	push   $0x802c90
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 ce 0a 00 00       	call   800d97 <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 9a 2c 80 00       	push   $0x802c9a
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 aa 0a 00 00       	call   800d97 <snprintf>
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
  80031b:	68 9f 2c 80 00       	push   $0x802c9f
  800320:	e8 40 05 00 00       	call   800865 <cprintf>
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
  80035a:	68 bb 2c 80 00       	push   $0x802cbb
  80035f:	e8 01 05 00 00       	call   800865 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 a5 2c 80 00       	push   $0x802ca5
  800378:	e8 e8 04 00 00       	call   800865 <cprintf>
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
  8003a3:	e8 36 10 00 00       	call   8013de <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 e5 	movl   $0x802ce5,0x804000
  8003b4:	2c 80 00 

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
  8003bc:	e8 0d 0e 00 00       	call   8011ce <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 18 10 00 00       	call   8013de <sys_time_msec>
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
  8003d5:	68 ee 2c 80 00       	push   $0x802cee
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 00 2d 80 00       	push   $0x802d00
  8003e1:	e8 a6 03 00 00       	call   80078c <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 02 13 00 00       	call   8016f4 <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 8b 12 00 00       	call   80168d <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 0c 2d 80 00       	push   $0x802d0c
  800417:	e8 49 04 00 00       	call   800865 <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 b8 0f 00 00       	call   8013de <sys_time_msec>
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
  80042d:	c7 05 00 40 80 00 47 	movl   $0x802d47,0x804000
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

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  80043c:	c7 05 00 40 80 00 50 	movl   $0x802d50,0x804000
  800443:	2d 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800457:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80045a:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  800461:	0f b6 0f             	movzbl (%edi),%ecx
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800469:	0f b6 d9             	movzbl %cl,%ebx
  80046c:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80046f:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800472:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800475:	66 c1 e8 0b          	shr    $0xb,%ax
  800479:	89 c3                	mov    %eax,%ebx
  80047b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047e:	01 c0                	add    %eax,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800484:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800486:	8d 72 01             	lea    0x1(%edx),%esi
  800489:	0f b6 d2             	movzbl %dl,%edx
  80048c:	83 c0 30             	add    $0x30,%eax
  80048f:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800493:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800495:	84 db                	test   %bl,%bl
  800497:	75 d0                	jne    800469 <inet_ntoa+0x21>
  800499:	c6 07 00             	movb   $0x0,(%edi)
  80049c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049f:	eb 0d                	jmp    8004ae <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004a1:	0f b6 c2             	movzbl %dl,%eax
  8004a4:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8004a9:	88 01                	mov    %al,(%ecx)
  8004ab:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8004ae:	83 ea 01             	sub    $0x1,%edx
  8004b1:	80 fa ff             	cmp    $0xff,%dl
  8004b4:	75 eb                	jne    8004a1 <inet_ntoa+0x59>
  8004b6:	89 f0                	mov    %esi,%eax
  8004b8:	0f b6 f0             	movzbl %al,%esi
  8004bb:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8004be:	8d 46 01             	lea    0x1(%esi),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8004c7:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cd:	39 c7                	cmp    %eax,%edi
  8004cf:	75 90                	jne    800461 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8004d1:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8004d4:	b8 08 50 80 00       	mov    $0x805008,%eax
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8004e4:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004e8:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8004f1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004f5:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800501:	89 d1                	mov    %edx,%ecx
  800503:	c1 e1 18             	shl    $0x18,%ecx
  800506:	89 d0                	mov    %edx,%eax
  800508:	c1 e8 18             	shr    $0x18,%eax
  80050b:	09 c8                	or     %ecx,%eax
  80050d:	89 d1                	mov    %edx,%ecx
  80050f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800515:	c1 e1 08             	shl    $0x8,%ecx
  800518:	09 c8                	or     %ecx,%eax
  80051a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800520:	c1 ea 08             	shr    $0x8,%edx
  800523:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 20             	sub    $0x20,%esp
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800533:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800536:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800539:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80053c:	0f b6 ca             	movzbl %dl,%ecx
  80053f:	83 e9 30             	sub    $0x30,%ecx
  800542:	83 f9 09             	cmp    $0x9,%ecx
  800545:	0f 87 94 01 00 00    	ja     8006df <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80054b:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800552:	83 fa 30             	cmp    $0x30,%edx
  800555:	75 2b                	jne    800582 <inet_aton+0x5b>
      c = *++cp;
  800557:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80055b:	89 d1                	mov    %edx,%ecx
  80055d:	83 e1 df             	and    $0xffffffdf,%ecx
  800560:	80 f9 58             	cmp    $0x58,%cl
  800563:	74 0f                	je     800574 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800565:	83 c0 01             	add    $0x1,%eax
  800568:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80056b:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800572:	eb 0e                	jmp    800582 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800574:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800578:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80057b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800582:	83 c0 01             	add    $0x1,%eax
  800585:	be 00 00 00 00       	mov    $0x0,%esi
  80058a:	eb 03                	jmp    80058f <inet_aton+0x68>
  80058c:	83 c0 01             	add    $0x1,%eax
  80058f:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800592:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800595:	0f b6 fa             	movzbl %dl,%edi
  800598:	8d 4f d0             	lea    -0x30(%edi),%ecx
  80059b:	83 f9 09             	cmp    $0x9,%ecx
  80059e:	77 0d                	ja     8005ad <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005a0:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005a4:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8005a8:	0f be 10             	movsbl (%eax),%edx
  8005ab:	eb df                	jmp    80058c <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8005ad:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8005b1:	75 32                	jne    8005e5 <inet_aton+0xbe>
  8005b3:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8005b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bc:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8005c2:	83 e9 41             	sub    $0x41,%ecx
  8005c5:	83 f9 05             	cmp    $0x5,%ecx
  8005c8:	77 1b                	ja     8005e5 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8005ca:	c1 e6 04             	shl    $0x4,%esi
  8005cd:	83 c2 0a             	add    $0xa,%edx
  8005d0:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8005d4:	19 c9                	sbb    %ecx,%ecx
  8005d6:	83 e1 20             	and    $0x20,%ecx
  8005d9:	83 c1 41             	add    $0x41,%ecx
  8005dc:	29 ca                	sub    %ecx,%edx
  8005de:	09 d6                	or     %edx,%esi
        c = *++cp;
  8005e0:	0f be 10             	movsbl (%eax),%edx
  8005e3:	eb a7                	jmp    80058c <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8005e5:	83 fa 2e             	cmp    $0x2e,%edx
  8005e8:	75 23                	jne    80060d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8005ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8005f0:	39 f8                	cmp    %edi,%eax
  8005f2:	0f 84 ee 00 00 00    	je     8006e6 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8005f8:	83 c0 04             	add    $0x4,%eax
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005fe:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800601:	8d 43 01             	lea    0x1(%ebx),%eax
  800604:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800608:	e9 2f ff ff ff       	jmp    80053c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 25                	je     800636 <inet_aton+0x10f>
  800611:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800614:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800619:	83 f9 5f             	cmp    $0x5f,%ecx
  80061c:	0f 87 d0 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  800622:	83 fa 20             	cmp    $0x20,%edx
  800625:	74 0f                	je     800636 <inet_aton+0x10f>
  800627:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062a:	83 ea 09             	sub    $0x9,%edx
  80062d:	83 fa 04             	cmp    $0x4,%edx
  800630:	0f 87 bc 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800636:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800639:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	c1 fa 02             	sar    $0x2,%edx
  800641:	83 c2 01             	add    $0x1,%edx
  800644:	83 fa 02             	cmp    $0x2,%edx
  800647:	74 20                	je     800669 <inet_aton+0x142>
  800649:	83 fa 02             	cmp    $0x2,%edx
  80064c:	7f 0f                	jg     80065d <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  80064e:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800653:	85 d2                	test   %edx,%edx
  800655:	0f 84 97 00 00 00    	je     8006f2 <inet_aton+0x1cb>
  80065b:	eb 67                	jmp    8006c4 <inet_aton+0x19d>
  80065d:	83 fa 03             	cmp    $0x3,%edx
  800660:	74 1e                	je     800680 <inet_aton+0x159>
  800662:	83 fa 04             	cmp    $0x4,%edx
  800665:	74 38                	je     80069f <inet_aton+0x178>
  800667:	eb 5b                	jmp    8006c4 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800669:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80066e:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  800674:	77 7c                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  800676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800679:	c1 e0 18             	shl    $0x18,%eax
  80067c:	09 c6                	or     %eax,%esi
    break;
  80067e:	eb 44                	jmp    8006c4 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800685:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  80068b:	77 65                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80068d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800690:	c1 e2 18             	shl    $0x18,%edx
  800693:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800696:	c1 e0 10             	shl    $0x10,%eax
  800699:	09 d0                	or     %edx,%eax
  80069b:	09 c6                	or     %eax,%esi
    break;
  80069d:	eb 25                	jmp    8006c4 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006a4:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8006aa:	77 46                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8006ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006af:	c1 e2 18             	shl    $0x18,%edx
  8006b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b5:	c1 e0 10             	shl    $0x10,%eax
  8006b8:	09 c2                	or     %eax,%edx
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c1 e0 08             	shl    $0x8,%eax
  8006c0:	09 d0                	or     %edx,%eax
  8006c2:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8006c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c8:	74 23                	je     8006ed <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8006ca:	56                   	push   %esi
  8006cb:	e8 2b fe ff ff       	call   8004fb <htonl>
  8006d0:	83 c4 04             	add    $0x4,%esp
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	89 03                	mov    %eax,(%ebx)
  return (1);
  8006d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8006dd:	eb 13                	jmp    8006f2 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 0c                	jmp    8006f2 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 05                	jmp    8006f2 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8006ed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800700:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 1b fe ff ff       	call   800527 <inet_aton>
  80070c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80070f:	85 c0                	test   %eax,%eax
  800711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800716:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 d4 fd ff ff       	call   8004fb <htonl>
  800727:	83 c4 04             	add    $0x4,%esp
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800734:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800737:	e8 73 0a 00 00       	call   8011af <sys_getenvid>
  80073c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800741:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800744:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800749:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80074e:	85 db                	test   %ebx,%ebx
  800750:	7e 07                	jle    800759 <libmain+0x2d>
		binaryname = argv[0];
  800752:	8b 06                	mov    (%esi),%eax
  800754:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	e8 d0 f8 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800763:	e8 0a 00 00 00       	call   800772 <exit>
}
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800778:	e8 cf 11 00 00       	call   80194c <close_all>
	sys_env_destroy(0);
  80077d:	83 ec 0c             	sub    $0xc,%esp
  800780:	6a 00                	push   $0x0
  800782:	e8 e7 09 00 00       	call   80116e <sys_env_destroy>
}
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800791:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800794:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80079a:	e8 10 0a 00 00       	call   8011af <sys_getenvid>
  80079f:	83 ec 0c             	sub    $0xc,%esp
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	ff 75 08             	pushl  0x8(%ebp)
  8007a8:	56                   	push   %esi
  8007a9:	50                   	push   %eax
  8007aa:	68 64 2d 80 00       	push   $0x802d64
  8007af:	e8 b1 00 00 00       	call   800865 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007b4:	83 c4 18             	add    $0x18,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	e8 54 00 00 00       	call   800814 <vcprintf>
	cprintf("\n");
  8007c0:	c7 04 24 bb 2c 80 00 	movl   $0x802cbb,(%esp)
  8007c7:	e8 99 00 00 00       	call   800865 <cprintf>
  8007cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007cf:	cc                   	int3   
  8007d0:	eb fd                	jmp    8007cf <_panic+0x43>

008007d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 04             	sub    $0x4,%esp
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007dc:	8b 13                	mov    (%ebx),%edx
  8007de:	8d 42 01             	lea    0x1(%edx),%eax
  8007e1:	89 03                	mov    %eax,(%ebx)
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007ef:	75 1a                	jne    80080b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	68 ff 00 00 00       	push   $0xff
  8007f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8007fc:	50                   	push   %eax
  8007fd:	e8 2f 09 00 00       	call   801131 <sys_cputs>
		b->idx = 0;
  800802:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800808:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80080b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80080f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80081d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800824:	00 00 00 
	b.cnt = 0;
  800827:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80082e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800831:	ff 75 0c             	pushl  0xc(%ebp)
  800834:	ff 75 08             	pushl  0x8(%ebp)
  800837:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	68 d2 07 80 00       	push   $0x8007d2
  800843:	e8 54 01 00 00       	call   80099c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800851:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	e8 d4 08 00 00       	call   801131 <sys_cputs>

	return b.cnt;
}
  80085d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80086b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80086e:	50                   	push   %eax
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 9d ff ff ff       	call   800814 <vcprintf>
	va_end(ap);

	return cnt;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	57                   	push   %edi
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	83 ec 1c             	sub    $0x1c,%esp
  800882:	89 c7                	mov    %eax,%edi
  800884:	89 d6                	mov    %edx,%esi
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800895:	bb 00 00 00 00       	mov    $0x0,%ebx
  80089a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80089d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008a0:	39 d3                	cmp    %edx,%ebx
  8008a2:	72 05                	jb     8008a9 <printnum+0x30>
  8008a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008a7:	77 45                	ja     8008ee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008a9:	83 ec 0c             	sub    $0xc,%esp
  8008ac:	ff 75 18             	pushl  0x18(%ebp)
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8008b5:	53                   	push   %ebx
  8008b6:	ff 75 10             	pushl  0x10(%ebp)
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c8:	e8 a3 20 00 00       	call   802970 <__udivdi3>
  8008cd:	83 c4 18             	add    $0x18,%esp
  8008d0:	52                   	push   %edx
  8008d1:	50                   	push   %eax
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	89 f8                	mov    %edi,%eax
  8008d6:	e8 9e ff ff ff       	call   800879 <printnum>
  8008db:	83 c4 20             	add    $0x20,%esp
  8008de:	eb 18                	jmp    8008f8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	56                   	push   %esi
  8008e4:	ff 75 18             	pushl  0x18(%ebp)
  8008e7:	ff d7                	call   *%edi
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 03                	jmp    8008f1 <printnum+0x78>
  8008ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008f1:	83 eb 01             	sub    $0x1,%ebx
  8008f4:	85 db                	test   %ebx,%ebx
  8008f6:	7f e8                	jg     8008e0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	56                   	push   %esi
  8008fc:	83 ec 04             	sub    $0x4,%esp
  8008ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800902:	ff 75 e0             	pushl  -0x20(%ebp)
  800905:	ff 75 dc             	pushl  -0x24(%ebp)
  800908:	ff 75 d8             	pushl  -0x28(%ebp)
  80090b:	e8 90 21 00 00       	call   802aa0 <__umoddi3>
  800910:	83 c4 14             	add    $0x14,%esp
  800913:	0f be 80 87 2d 80 00 	movsbl 0x802d87(%eax),%eax
  80091a:	50                   	push   %eax
  80091b:	ff d7                	call   *%edi
}
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80092b:	83 fa 01             	cmp    $0x1,%edx
  80092e:	7e 0e                	jle    80093e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800930:	8b 10                	mov    (%eax),%edx
  800932:	8d 4a 08             	lea    0x8(%edx),%ecx
  800935:	89 08                	mov    %ecx,(%eax)
  800937:	8b 02                	mov    (%edx),%eax
  800939:	8b 52 04             	mov    0x4(%edx),%edx
  80093c:	eb 22                	jmp    800960 <getuint+0x38>
	else if (lflag)
  80093e:	85 d2                	test   %edx,%edx
  800940:	74 10                	je     800952 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800942:	8b 10                	mov    (%eax),%edx
  800944:	8d 4a 04             	lea    0x4(%edx),%ecx
  800947:	89 08                	mov    %ecx,(%eax)
  800949:	8b 02                	mov    (%edx),%eax
  80094b:	ba 00 00 00 00       	mov    $0x0,%edx
  800950:	eb 0e                	jmp    800960 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8d 4a 04             	lea    0x4(%edx),%ecx
  800957:	89 08                	mov    %ecx,(%eax)
  800959:	8b 02                	mov    (%edx),%eax
  80095b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800968:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80096c:	8b 10                	mov    (%eax),%edx
  80096e:	3b 50 04             	cmp    0x4(%eax),%edx
  800971:	73 0a                	jae    80097d <sprintputch+0x1b>
		*b->buf++ = ch;
  800973:	8d 4a 01             	lea    0x1(%edx),%ecx
  800976:	89 08                	mov    %ecx,(%eax)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	88 02                	mov    %al,(%edx)
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800988:	50                   	push   %eax
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 05 00 00 00       	call   80099c <vprintfmt>
	va_end(ap);
}
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 2c             	sub    $0x2c,%esp
  8009a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009ae:	eb 12                	jmp    8009c2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	0f 84 89 03 00 00    	je     800d41 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8009b8:	83 ec 08             	sub    $0x8,%esp
  8009bb:	53                   	push   %ebx
  8009bc:	50                   	push   %eax
  8009bd:	ff d6                	call   *%esi
  8009bf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009c2:	83 c7 01             	add    $0x1,%edi
  8009c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c9:	83 f8 25             	cmp    $0x25,%eax
  8009cc:	75 e2                	jne    8009b0 <vprintfmt+0x14>
  8009ce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	eb 07                	jmp    8009f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009f1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f5:	8d 47 01             	lea    0x1(%edi),%eax
  8009f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009fb:	0f b6 07             	movzbl (%edi),%eax
  8009fe:	0f b6 c8             	movzbl %al,%ecx
  800a01:	83 e8 23             	sub    $0x23,%eax
  800a04:	3c 55                	cmp    $0x55,%al
  800a06:	0f 87 1a 03 00 00    	ja     800d26 <vprintfmt+0x38a>
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	ff 24 85 c0 2e 80 00 	jmp    *0x802ec0(,%eax,4)
  800a16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a19:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a1d:	eb d6                	jmp    8009f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a2a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a2d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800a31:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800a34:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800a37:	83 fa 09             	cmp    $0x9,%edx
  800a3a:	77 39                	ja     800a75 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a3c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a3f:	eb e9                	jmp    800a2a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a41:	8b 45 14             	mov    0x14(%ebp),%eax
  800a44:	8d 48 04             	lea    0x4(%eax),%ecx
  800a47:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a4a:	8b 00                	mov    (%eax),%eax
  800a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a52:	eb 27                	jmp    800a7b <vprintfmt+0xdf>
  800a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a57:	85 c0                	test   %eax,%eax
  800a59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5e:	0f 49 c8             	cmovns %eax,%ecx
  800a61:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	eb 8c                	jmp    8009f5 <vprintfmt+0x59>
  800a69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a73:	eb 80                	jmp    8009f5 <vprintfmt+0x59>
  800a75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a78:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a7f:	0f 89 70 ff ff ff    	jns    8009f5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800a85:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a8b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a92:	e9 5e ff ff ff       	jmp    8009f5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a97:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a9d:	e9 53 ff ff ff       	jmp    8009f5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	53                   	push   %ebx
  800aaf:	ff 30                	pushl  (%eax)
  800ab1:	ff d6                	call   *%esi
			break;
  800ab3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ab9:	e9 04 ff ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 00                	mov    (%eax),%eax
  800ac9:	99                   	cltd   
  800aca:	31 d0                	xor    %edx,%eax
  800acc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ace:	83 f8 0f             	cmp    $0xf,%eax
  800ad1:	7f 0b                	jg     800ade <vprintfmt+0x142>
  800ad3:	8b 14 85 20 30 80 00 	mov    0x803020(,%eax,4),%edx
  800ada:	85 d2                	test   %edx,%edx
  800adc:	75 18                	jne    800af6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800ade:	50                   	push   %eax
  800adf:	68 9f 2d 80 00       	push   $0x802d9f
  800ae4:	53                   	push   %ebx
  800ae5:	56                   	push   %esi
  800ae6:	e8 94 fe ff ff       	call   80097f <printfmt>
  800aeb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800af1:	e9 cc fe ff ff       	jmp    8009c2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800af6:	52                   	push   %edx
  800af7:	68 25 32 80 00       	push   $0x803225
  800afc:	53                   	push   %ebx
  800afd:	56                   	push   %esi
  800afe:	e8 7c fe ff ff       	call   80097f <printfmt>
  800b03:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b09:	e9 b4 fe ff ff       	jmp    8009c2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b11:	8d 50 04             	lea    0x4(%eax),%edx
  800b14:	89 55 14             	mov    %edx,0x14(%ebp)
  800b17:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	b8 98 2d 80 00       	mov    $0x802d98,%eax
  800b20:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b23:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b27:	0f 8e 94 00 00 00    	jle    800bc1 <vprintfmt+0x225>
  800b2d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b31:	0f 84 98 00 00 00    	je     800bcf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b37:	83 ec 08             	sub    $0x8,%esp
  800b3a:	ff 75 d0             	pushl  -0x30(%ebp)
  800b3d:	57                   	push   %edi
  800b3e:	e8 86 02 00 00       	call   800dc9 <strnlen>
  800b43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b46:	29 c1                	sub    %eax,%ecx
  800b48:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b4b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b4e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b55:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b58:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5a:	eb 0f                	jmp    800b6b <vprintfmt+0x1cf>
					putch(padc, putdat);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	ff 75 e0             	pushl  -0x20(%ebp)
  800b63:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b65:	83 ef 01             	sub    $0x1,%edi
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	7f ed                	jg     800b5c <vprintfmt+0x1c0>
  800b6f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b72:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	0f 49 c1             	cmovns %ecx,%eax
  800b7f:	29 c1                	sub    %eax,%ecx
  800b81:	89 75 08             	mov    %esi,0x8(%ebp)
  800b84:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b8a:	89 cb                	mov    %ecx,%ebx
  800b8c:	eb 4d                	jmp    800bdb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b92:	74 1b                	je     800baf <vprintfmt+0x213>
  800b94:	0f be c0             	movsbl %al,%eax
  800b97:	83 e8 20             	sub    $0x20,%eax
  800b9a:	83 f8 5e             	cmp    $0x5e,%eax
  800b9d:	76 10                	jbe    800baf <vprintfmt+0x213>
					putch('?', putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	6a 3f                	push   $0x3f
  800ba7:	ff 55 08             	call   *0x8(%ebp)
  800baa:	83 c4 10             	add    $0x10,%esp
  800bad:	eb 0d                	jmp    800bbc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	52                   	push   %edx
  800bb6:	ff 55 08             	call   *0x8(%ebp)
  800bb9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bbc:	83 eb 01             	sub    $0x1,%ebx
  800bbf:	eb 1a                	jmp    800bdb <vprintfmt+0x23f>
  800bc1:	89 75 08             	mov    %esi,0x8(%ebp)
  800bc4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bc7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bcd:	eb 0c                	jmp    800bdb <vprintfmt+0x23f>
  800bcf:	89 75 08             	mov    %esi,0x8(%ebp)
  800bd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bdb:	83 c7 01             	add    $0x1,%edi
  800bde:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800be2:	0f be d0             	movsbl %al,%edx
  800be5:	85 d2                	test   %edx,%edx
  800be7:	74 23                	je     800c0c <vprintfmt+0x270>
  800be9:	85 f6                	test   %esi,%esi
  800beb:	78 a1                	js     800b8e <vprintfmt+0x1f2>
  800bed:	83 ee 01             	sub    $0x1,%esi
  800bf0:	79 9c                	jns    800b8e <vprintfmt+0x1f2>
  800bf2:	89 df                	mov    %ebx,%edi
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfa:	eb 18                	jmp    800c14 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bfc:	83 ec 08             	sub    $0x8,%esp
  800bff:	53                   	push   %ebx
  800c00:	6a 20                	push   $0x20
  800c02:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c04:	83 ef 01             	sub    $0x1,%edi
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb 08                	jmp    800c14 <vprintfmt+0x278>
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c14:	85 ff                	test   %edi,%edi
  800c16:	7f e4                	jg     800bfc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c1b:	e9 a2 fd ff ff       	jmp    8009c2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c20:	83 fa 01             	cmp    $0x1,%edx
  800c23:	7e 16                	jle    800c3b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800c25:	8b 45 14             	mov    0x14(%ebp),%eax
  800c28:	8d 50 08             	lea    0x8(%eax),%edx
  800c2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2e:	8b 50 04             	mov    0x4(%eax),%edx
  800c31:	8b 00                	mov    (%eax),%eax
  800c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c36:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c39:	eb 32                	jmp    800c6d <vprintfmt+0x2d1>
	else if (lflag)
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 18                	je     800c57 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800c3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c42:	8d 50 04             	lea    0x4(%eax),%edx
  800c45:	89 55 14             	mov    %edx,0x14(%ebp)
  800c48:	8b 00                	mov    (%eax),%eax
  800c4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c4d:	89 c1                	mov    %eax,%ecx
  800c4f:	c1 f9 1f             	sar    $0x1f,%ecx
  800c52:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c55:	eb 16                	jmp    800c6d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800c57:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5a:	8d 50 04             	lea    0x4(%eax),%edx
  800c5d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c60:	8b 00                	mov    (%eax),%eax
  800c62:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c65:	89 c1                	mov    %eax,%ecx
  800c67:	c1 f9 1f             	sar    $0x1f,%ecx
  800c6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c70:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c73:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c7c:	79 74                	jns    800cf2 <vprintfmt+0x356>
				putch('-', putdat);
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	53                   	push   %ebx
  800c82:	6a 2d                	push   $0x2d
  800c84:	ff d6                	call   *%esi
				num = -(long long) num;
  800c86:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c89:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c8c:	f7 d8                	neg    %eax
  800c8e:	83 d2 00             	adc    $0x0,%edx
  800c91:	f7 da                	neg    %edx
  800c93:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800c96:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c9b:	eb 55                	jmp    800cf2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c9d:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca0:	e8 83 fc ff ff       	call   800928 <getuint>
			base = 10;
  800ca5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800caa:	eb 46                	jmp    800cf2 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800cac:	8d 45 14             	lea    0x14(%ebp),%eax
  800caf:	e8 74 fc ff ff       	call   800928 <getuint>
			base = 8;
  800cb4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cb9:	eb 37                	jmp    800cf2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800cbb:	83 ec 08             	sub    $0x8,%esp
  800cbe:	53                   	push   %ebx
  800cbf:	6a 30                	push   $0x30
  800cc1:	ff d6                	call   *%esi
			putch('x', putdat);
  800cc3:	83 c4 08             	add    $0x8,%esp
  800cc6:	53                   	push   %ebx
  800cc7:	6a 78                	push   $0x78
  800cc9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ccb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cce:	8d 50 04             	lea    0x4(%eax),%edx
  800cd1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cd4:	8b 00                	mov    (%eax),%eax
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800cdb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cde:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ce3:	eb 0d                	jmp    800cf2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ce5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce8:	e8 3b fc ff ff       	call   800928 <getuint>
			base = 16;
  800ced:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800cf9:	57                   	push   %edi
  800cfa:	ff 75 e0             	pushl  -0x20(%ebp)
  800cfd:	51                   	push   %ecx
  800cfe:	52                   	push   %edx
  800cff:	50                   	push   %eax
  800d00:	89 da                	mov    %ebx,%edx
  800d02:	89 f0                	mov    %esi,%eax
  800d04:	e8 70 fb ff ff       	call   800879 <printnum>
			break;
  800d09:	83 c4 20             	add    $0x20,%esp
  800d0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d0f:	e9 ae fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d14:	83 ec 08             	sub    $0x8,%esp
  800d17:	53                   	push   %ebx
  800d18:	51                   	push   %ecx
  800d19:	ff d6                	call   *%esi
			break;
  800d1b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d21:	e9 9c fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d26:	83 ec 08             	sub    $0x8,%esp
  800d29:	53                   	push   %ebx
  800d2a:	6a 25                	push   $0x25
  800d2c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	eb 03                	jmp    800d36 <vprintfmt+0x39a>
  800d33:	83 ef 01             	sub    $0x1,%edi
  800d36:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800d3a:	75 f7                	jne    800d33 <vprintfmt+0x397>
  800d3c:	e9 81 fc ff ff       	jmp    8009c2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 18             	sub    $0x18,%esp
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d55:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d58:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d5c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	74 26                	je     800d90 <vsnprintf+0x47>
  800d6a:	85 d2                	test   %edx,%edx
  800d6c:	7e 22                	jle    800d90 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d6e:	ff 75 14             	pushl  0x14(%ebp)
  800d71:	ff 75 10             	pushl  0x10(%ebp)
  800d74:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d77:	50                   	push   %eax
  800d78:	68 62 09 80 00       	push   $0x800962
  800d7d:	e8 1a fc ff ff       	call   80099c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d85:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	eb 05                	jmp    800d95 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d9d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800da0:	50                   	push   %eax
  800da1:	ff 75 10             	pushl  0x10(%ebp)
  800da4:	ff 75 0c             	pushl  0xc(%ebp)
  800da7:	ff 75 08             	pushl  0x8(%ebp)
  800daa:	e8 9a ff ff ff       	call   800d49 <vsnprintf>
	va_end(ap);

	return rc;
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800db7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbc:	eb 03                	jmp    800dc1 <strlen+0x10>
		n++;
  800dbe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dc5:	75 f7                	jne    800dbe <strlen+0xd>
		n++;
	return n;
}
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	eb 03                	jmp    800ddc <strnlen+0x13>
		n++;
  800dd9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ddc:	39 c2                	cmp    %eax,%edx
  800dde:	74 08                	je     800de8 <strnlen+0x1f>
  800de0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800de4:	75 f3                	jne    800dd9 <strnlen+0x10>
  800de6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	53                   	push   %ebx
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800df4:	89 c2                	mov    %eax,%edx
  800df6:	83 c2 01             	add    $0x1,%edx
  800df9:	83 c1 01             	add    $0x1,%ecx
  800dfc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e00:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e03:	84 db                	test   %bl,%bl
  800e05:	75 ef                	jne    800df6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e11:	53                   	push   %ebx
  800e12:	e8 9a ff ff ff       	call   800db1 <strlen>
  800e17:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e1a:	ff 75 0c             	pushl  0xc(%ebp)
  800e1d:	01 d8                	add    %ebx,%eax
  800e1f:	50                   	push   %eax
  800e20:	e8 c5 ff ff ff       	call   800dea <strcpy>
	return dst;
}
  800e25:	89 d8                	mov    %ebx,%eax
  800e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 75 08             	mov    0x8(%ebp),%esi
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	89 f3                	mov    %esi,%ebx
  800e39:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e3c:	89 f2                	mov    %esi,%edx
  800e3e:	eb 0f                	jmp    800e4f <strncpy+0x23>
		*dst++ = *src;
  800e40:	83 c2 01             	add    $0x1,%edx
  800e43:	0f b6 01             	movzbl (%ecx),%eax
  800e46:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e49:	80 39 01             	cmpb   $0x1,(%ecx)
  800e4c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e4f:	39 da                	cmp    %ebx,%edx
  800e51:	75 ed                	jne    800e40 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	8b 55 10             	mov    0x10(%ebp),%edx
  800e67:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e69:	85 d2                	test   %edx,%edx
  800e6b:	74 21                	je     800e8e <strlcpy+0x35>
  800e6d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e71:	89 f2                	mov    %esi,%edx
  800e73:	eb 09                	jmp    800e7e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e75:	83 c2 01             	add    $0x1,%edx
  800e78:	83 c1 01             	add    $0x1,%ecx
  800e7b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e7e:	39 c2                	cmp    %eax,%edx
  800e80:	74 09                	je     800e8b <strlcpy+0x32>
  800e82:	0f b6 19             	movzbl (%ecx),%ebx
  800e85:	84 db                	test   %bl,%bl
  800e87:	75 ec                	jne    800e75 <strlcpy+0x1c>
  800e89:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e8b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e8e:	29 f0                	sub    %esi,%eax
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e9d:	eb 06                	jmp    800ea5 <strcmp+0x11>
		p++, q++;
  800e9f:	83 c1 01             	add    $0x1,%ecx
  800ea2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ea5:	0f b6 01             	movzbl (%ecx),%eax
  800ea8:	84 c0                	test   %al,%al
  800eaa:	74 04                	je     800eb0 <strcmp+0x1c>
  800eac:	3a 02                	cmp    (%edx),%al
  800eae:	74 ef                	je     800e9f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb0:	0f b6 c0             	movzbl %al,%eax
  800eb3:	0f b6 12             	movzbl (%edx),%edx
  800eb6:	29 d0                	sub    %edx,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec4:	89 c3                	mov    %eax,%ebx
  800ec6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ec9:	eb 06                	jmp    800ed1 <strncmp+0x17>
		n--, p++, q++;
  800ecb:	83 c0 01             	add    $0x1,%eax
  800ece:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ed1:	39 d8                	cmp    %ebx,%eax
  800ed3:	74 15                	je     800eea <strncmp+0x30>
  800ed5:	0f b6 08             	movzbl (%eax),%ecx
  800ed8:	84 c9                	test   %cl,%cl
  800eda:	74 04                	je     800ee0 <strncmp+0x26>
  800edc:	3a 0a                	cmp    (%edx),%cl
  800ede:	74 eb                	je     800ecb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ee0:	0f b6 00             	movzbl (%eax),%eax
  800ee3:	0f b6 12             	movzbl (%edx),%edx
  800ee6:	29 d0                	sub    %edx,%eax
  800ee8:	eb 05                	jmp    800eef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800efc:	eb 07                	jmp    800f05 <strchr+0x13>
		if (*s == c)
  800efe:	38 ca                	cmp    %cl,%dl
  800f00:	74 0f                	je     800f11 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f02:	83 c0 01             	add    $0x1,%eax
  800f05:	0f b6 10             	movzbl (%eax),%edx
  800f08:	84 d2                	test   %dl,%dl
  800f0a:	75 f2                	jne    800efe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f1d:	eb 03                	jmp    800f22 <strfind+0xf>
  800f1f:	83 c0 01             	add    $0x1,%eax
  800f22:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f25:	38 ca                	cmp    %cl,%dl
  800f27:	74 04                	je     800f2d <strfind+0x1a>
  800f29:	84 d2                	test   %dl,%dl
  800f2b:	75 f2                	jne    800f1f <strfind+0xc>
			break;
	return (char *) s;
}
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f3b:	85 c9                	test   %ecx,%ecx
  800f3d:	74 36                	je     800f75 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f45:	75 28                	jne    800f6f <memset+0x40>
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 23                	jne    800f6f <memset+0x40>
		c &= 0xFF;
  800f4c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f50:	89 d3                	mov    %edx,%ebx
  800f52:	c1 e3 08             	shl    $0x8,%ebx
  800f55:	89 d6                	mov    %edx,%esi
  800f57:	c1 e6 18             	shl    $0x18,%esi
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	c1 e0 10             	shl    $0x10,%eax
  800f5f:	09 f0                	or     %esi,%eax
  800f61:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	09 d0                	or     %edx,%eax
  800f67:	c1 e9 02             	shr    $0x2,%ecx
  800f6a:	fc                   	cld    
  800f6b:	f3 ab                	rep stos %eax,%es:(%edi)
  800f6d:	eb 06                	jmp    800f75 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f72:	fc                   	cld    
  800f73:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f75:	89 f8                	mov    %edi,%eax
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f8a:	39 c6                	cmp    %eax,%esi
  800f8c:	73 35                	jae    800fc3 <memmove+0x47>
  800f8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f91:	39 d0                	cmp    %edx,%eax
  800f93:	73 2e                	jae    800fc3 <memmove+0x47>
		s += n;
		d += n;
  800f95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	09 fe                	or     %edi,%esi
  800f9c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fa2:	75 13                	jne    800fb7 <memmove+0x3b>
  800fa4:	f6 c1 03             	test   $0x3,%cl
  800fa7:	75 0e                	jne    800fb7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fa9:	83 ef 04             	sub    $0x4,%edi
  800fac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800faf:	c1 e9 02             	shr    $0x2,%ecx
  800fb2:	fd                   	std    
  800fb3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fb5:	eb 09                	jmp    800fc0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fb7:	83 ef 01             	sub    $0x1,%edi
  800fba:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fbd:	fd                   	std    
  800fbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fc0:	fc                   	cld    
  800fc1:	eb 1d                	jmp    800fe0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	09 c2                	or     %eax,%edx
  800fc7:	f6 c2 03             	test   $0x3,%dl
  800fca:	75 0f                	jne    800fdb <memmove+0x5f>
  800fcc:	f6 c1 03             	test   $0x3,%cl
  800fcf:	75 0a                	jne    800fdb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fd1:	c1 e9 02             	shr    $0x2,%ecx
  800fd4:	89 c7                	mov    %eax,%edi
  800fd6:	fc                   	cld    
  800fd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd9:	eb 05                	jmp    800fe0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fdb:	89 c7                	mov    %eax,%edi
  800fdd:	fc                   	cld    
  800fde:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fe7:	ff 75 10             	pushl  0x10(%ebp)
  800fea:	ff 75 0c             	pushl  0xc(%ebp)
  800fed:	ff 75 08             	pushl  0x8(%ebp)
  800ff0:	e8 87 ff ff ff       	call   800f7c <memmove>
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	89 c6                	mov    %eax,%esi
  801004:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801007:	eb 1a                	jmp    801023 <memcmp+0x2c>
		if (*s1 != *s2)
  801009:	0f b6 08             	movzbl (%eax),%ecx
  80100c:	0f b6 1a             	movzbl (%edx),%ebx
  80100f:	38 d9                	cmp    %bl,%cl
  801011:	74 0a                	je     80101d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801013:	0f b6 c1             	movzbl %cl,%eax
  801016:	0f b6 db             	movzbl %bl,%ebx
  801019:	29 d8                	sub    %ebx,%eax
  80101b:	eb 0f                	jmp    80102c <memcmp+0x35>
		s1++, s2++;
  80101d:	83 c0 01             	add    $0x1,%eax
  801020:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801023:	39 f0                	cmp    %esi,%eax
  801025:	75 e2                	jne    801009 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801027:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801037:	89 c1                	mov    %eax,%ecx
  801039:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80103c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801040:	eb 0a                	jmp    80104c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801042:	0f b6 10             	movzbl (%eax),%edx
  801045:	39 da                	cmp    %ebx,%edx
  801047:	74 07                	je     801050 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801049:	83 c0 01             	add    $0x1,%eax
  80104c:	39 c8                	cmp    %ecx,%eax
  80104e:	72 f2                	jb     801042 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801050:	5b                   	pop    %ebx
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105f:	eb 03                	jmp    801064 <strtol+0x11>
		s++;
  801061:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801064:	0f b6 01             	movzbl (%ecx),%eax
  801067:	3c 20                	cmp    $0x20,%al
  801069:	74 f6                	je     801061 <strtol+0xe>
  80106b:	3c 09                	cmp    $0x9,%al
  80106d:	74 f2                	je     801061 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80106f:	3c 2b                	cmp    $0x2b,%al
  801071:	75 0a                	jne    80107d <strtol+0x2a>
		s++;
  801073:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801076:	bf 00 00 00 00       	mov    $0x0,%edi
  80107b:	eb 11                	jmp    80108e <strtol+0x3b>
  80107d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801082:	3c 2d                	cmp    $0x2d,%al
  801084:	75 08                	jne    80108e <strtol+0x3b>
		s++, neg = 1;
  801086:	83 c1 01             	add    $0x1,%ecx
  801089:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80108e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801094:	75 15                	jne    8010ab <strtol+0x58>
  801096:	80 39 30             	cmpb   $0x30,(%ecx)
  801099:	75 10                	jne    8010ab <strtol+0x58>
  80109b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80109f:	75 7c                	jne    80111d <strtol+0xca>
		s += 2, base = 16;
  8010a1:	83 c1 02             	add    $0x2,%ecx
  8010a4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010a9:	eb 16                	jmp    8010c1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8010ab:	85 db                	test   %ebx,%ebx
  8010ad:	75 12                	jne    8010c1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010af:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010b4:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b7:	75 08                	jne    8010c1 <strtol+0x6e>
		s++, base = 8;
  8010b9:	83 c1 01             	add    $0x1,%ecx
  8010bc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010c9:	0f b6 11             	movzbl (%ecx),%edx
  8010cc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010cf:	89 f3                	mov    %esi,%ebx
  8010d1:	80 fb 09             	cmp    $0x9,%bl
  8010d4:	77 08                	ja     8010de <strtol+0x8b>
			dig = *s - '0';
  8010d6:	0f be d2             	movsbl %dl,%edx
  8010d9:	83 ea 30             	sub    $0x30,%edx
  8010dc:	eb 22                	jmp    801100 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8010de:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010e1:	89 f3                	mov    %esi,%ebx
  8010e3:	80 fb 19             	cmp    $0x19,%bl
  8010e6:	77 08                	ja     8010f0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8010e8:	0f be d2             	movsbl %dl,%edx
  8010eb:	83 ea 57             	sub    $0x57,%edx
  8010ee:	eb 10                	jmp    801100 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8010f0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010f3:	89 f3                	mov    %esi,%ebx
  8010f5:	80 fb 19             	cmp    $0x19,%bl
  8010f8:	77 16                	ja     801110 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8010fa:	0f be d2             	movsbl %dl,%edx
  8010fd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801100:	3b 55 10             	cmp    0x10(%ebp),%edx
  801103:	7d 0b                	jge    801110 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801105:	83 c1 01             	add    $0x1,%ecx
  801108:	0f af 45 10          	imul   0x10(%ebp),%eax
  80110c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80110e:	eb b9                	jmp    8010c9 <strtol+0x76>

	if (endptr)
  801110:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801114:	74 0d                	je     801123 <strtol+0xd0>
		*endptr = (char *) s;
  801116:	8b 75 0c             	mov    0xc(%ebp),%esi
  801119:	89 0e                	mov    %ecx,(%esi)
  80111b:	eb 06                	jmp    801123 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80111d:	85 db                	test   %ebx,%ebx
  80111f:	74 98                	je     8010b9 <strtol+0x66>
  801121:	eb 9e                	jmp    8010c1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801123:	89 c2                	mov    %eax,%edx
  801125:	f7 da                	neg    %edx
  801127:	85 ff                	test   %edi,%edi
  801129:	0f 45 c2             	cmovne %edx,%eax
}
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	8b 55 08             	mov    0x8(%ebp),%edx
  801142:	89 c3                	mov    %eax,%ebx
  801144:	89 c7                	mov    %eax,%edi
  801146:	89 c6                	mov    %eax,%esi
  801148:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80114a:	5b                   	pop    %ebx
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <sys_cgetc>:

int
sys_cgetc(void)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801155:	ba 00 00 00 00       	mov    $0x0,%edx
  80115a:	b8 01 00 00 00       	mov    $0x1,%eax
  80115f:	89 d1                	mov    %edx,%ecx
  801161:	89 d3                	mov    %edx,%ebx
  801163:	89 d7                	mov    %edx,%edi
  801165:	89 d6                	mov    %edx,%esi
  801167:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117c:	b8 03 00 00 00       	mov    $0x3,%eax
  801181:	8b 55 08             	mov    0x8(%ebp),%edx
  801184:	89 cb                	mov    %ecx,%ebx
  801186:	89 cf                	mov    %ecx,%edi
  801188:	89 ce                	mov    %ecx,%esi
  80118a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	7e 17                	jle    8011a7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	50                   	push   %eax
  801194:	6a 03                	push   $0x3
  801196:	68 7f 30 80 00       	push   $0x80307f
  80119b:	6a 23                	push   $0x23
  80119d:	68 9c 30 80 00       	push   $0x80309c
  8011a2:	e8 e5 f5 ff ff       	call   80078c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8011bf:	89 d1                	mov    %edx,%ecx
  8011c1:	89 d3                	mov    %edx,%ebx
  8011c3:	89 d7                	mov    %edx,%edi
  8011c5:	89 d6                	mov    %edx,%esi
  8011c7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <sys_yield>:

void
sys_yield(void)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011de:	89 d1                	mov    %edx,%ecx
  8011e0:	89 d3                	mov    %edx,%ebx
  8011e2:	89 d7                	mov    %edx,%edi
  8011e4:	89 d6                	mov    %edx,%esi
  8011e6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	be 00 00 00 00       	mov    $0x0,%esi
  8011fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801209:	89 f7                	mov    %esi,%edi
  80120b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80120d:	85 c0                	test   %eax,%eax
  80120f:	7e 17                	jle    801228 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801211:	83 ec 0c             	sub    $0xc,%esp
  801214:	50                   	push   %eax
  801215:	6a 04                	push   $0x4
  801217:	68 7f 30 80 00       	push   $0x80307f
  80121c:	6a 23                	push   $0x23
  80121e:	68 9c 30 80 00       	push   $0x80309c
  801223:	e8 64 f5 ff ff       	call   80078c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  801239:	b8 05 00 00 00       	mov    $0x5,%eax
  80123e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801241:	8b 55 08             	mov    0x8(%ebp),%edx
  801244:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801247:	8b 7d 14             	mov    0x14(%ebp),%edi
  80124a:	8b 75 18             	mov    0x18(%ebp),%esi
  80124d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	7e 17                	jle    80126a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	50                   	push   %eax
  801257:	6a 05                	push   $0x5
  801259:	68 7f 30 80 00       	push   $0x80307f
  80125e:	6a 23                	push   $0x23
  801260:	68 9c 30 80 00       	push   $0x80309c
  801265:	e8 22 f5 ff ff       	call   80078c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80126a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801280:	b8 06 00 00 00       	mov    $0x6,%eax
  801285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
  80128b:	89 df                	mov    %ebx,%edi
  80128d:	89 de                	mov    %ebx,%esi
  80128f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801291:	85 c0                	test   %eax,%eax
  801293:	7e 17                	jle    8012ac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	50                   	push   %eax
  801299:	6a 06                	push   $0x6
  80129b:	68 7f 30 80 00       	push   $0x80307f
  8012a0:	6a 23                	push   $0x23
  8012a2:	68 9c 30 80 00       	push   $0x80309c
  8012a7:	e8 e0 f4 ff ff       	call   80078c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5e                   	pop    %esi
  8012b1:	5f                   	pop    %edi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8012c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cd:	89 df                	mov    %ebx,%edi
  8012cf:	89 de                	mov    %ebx,%esi
  8012d1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	7e 17                	jle    8012ee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	50                   	push   %eax
  8012db:	6a 08                	push   $0x8
  8012dd:	68 7f 30 80 00       	push   $0x80307f
  8012e2:	6a 23                	push   $0x23
  8012e4:	68 9c 30 80 00       	push   $0x80309c
  8012e9:	e8 9e f4 ff ff       	call   80078c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801304:	b8 09 00 00 00       	mov    $0x9,%eax
  801309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130c:	8b 55 08             	mov    0x8(%ebp),%edx
  80130f:	89 df                	mov    %ebx,%edi
  801311:	89 de                	mov    %ebx,%esi
  801313:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801315:	85 c0                	test   %eax,%eax
  801317:	7e 17                	jle    801330 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	50                   	push   %eax
  80131d:	6a 09                	push   $0x9
  80131f:	68 7f 30 80 00       	push   $0x80307f
  801324:	6a 23                	push   $0x23
  801326:	68 9c 30 80 00       	push   $0x80309c
  80132b:	e8 5c f4 ff ff       	call   80078c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801341:	bb 00 00 00 00       	mov    $0x0,%ebx
  801346:	b8 0a 00 00 00       	mov    $0xa,%eax
  80134b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134e:	8b 55 08             	mov    0x8(%ebp),%edx
  801351:	89 df                	mov    %ebx,%edi
  801353:	89 de                	mov    %ebx,%esi
  801355:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801357:	85 c0                	test   %eax,%eax
  801359:	7e 17                	jle    801372 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	50                   	push   %eax
  80135f:	6a 0a                	push   $0xa
  801361:	68 7f 30 80 00       	push   $0x80307f
  801366:	6a 23                	push   $0x23
  801368:	68 9c 30 80 00       	push   $0x80309c
  80136d:	e8 1a f4 ff ff       	call   80078c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5f                   	pop    %edi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	57                   	push   %edi
  80137e:	56                   	push   %esi
  80137f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801380:	be 00 00 00 00       	mov    $0x0,%esi
  801385:	b8 0c 00 00 00       	mov    $0xc,%eax
  80138a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138d:	8b 55 08             	mov    0x8(%ebp),%edx
  801390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801393:	8b 7d 14             	mov    0x14(%ebp),%edi
  801396:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013ab:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b3:	89 cb                	mov    %ecx,%ebx
  8013b5:	89 cf                	mov    %ecx,%edi
  8013b7:	89 ce                	mov    %ecx,%esi
  8013b9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	7e 17                	jle    8013d6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	50                   	push   %eax
  8013c3:	6a 0d                	push   $0xd
  8013c5:	68 7f 30 80 00       	push   $0x80307f
  8013ca:	6a 23                	push   $0x23
  8013cc:	68 9c 30 80 00       	push   $0x80309c
  8013d1:	e8 b6 f3 ff ff       	call   80078c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013ee:	89 d1                	mov    %edx,%ecx
  8013f0:	89 d3                	mov    %edx,%ebx
  8013f2:	89 d7                	mov    %edx,%edi
  8013f4:	89 d6                	mov    %edx,%esi
  8013f6:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801405:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  801407:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80140b:	75 25                	jne    801432 <pgfault+0x35>
  80140d:	89 d8                	mov    %ebx,%eax
  80140f:	c1 e8 0c             	shr    $0xc,%eax
  801412:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801419:	f6 c4 08             	test   $0x8,%ah
  80141c:	75 14                	jne    801432 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	68 ac 30 80 00       	push   $0x8030ac
  801426:	6a 1e                	push   $0x1e
  801428:	68 40 31 80 00       	push   $0x803140
  80142d:	e8 5a f3 ff ff       	call   80078c <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  801432:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801438:	e8 72 fd ff ff       	call   8011af <sys_getenvid>
  80143d:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  80143f:	83 ec 04             	sub    $0x4,%esp
  801442:	6a 07                	push   $0x7
  801444:	68 00 f0 7f 00       	push   $0x7ff000
  801449:	50                   	push   %eax
  80144a:	e8 9e fd ff ff       	call   8011ed <sys_page_alloc>
	if (r < 0)
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	79 12                	jns    801468 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  801456:	50                   	push   %eax
  801457:	68 d8 30 80 00       	push   $0x8030d8
  80145c:	6a 33                	push   $0x33
  80145e:	68 40 31 80 00       	push   $0x803140
  801463:	e8 24 f3 ff ff       	call   80078c <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	68 00 10 00 00       	push   $0x1000
  801470:	53                   	push   %ebx
  801471:	68 00 f0 7f 00       	push   $0x7ff000
  801476:	e8 69 fb ff ff       	call   800fe4 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  80147b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801482:	53                   	push   %ebx
  801483:	56                   	push   %esi
  801484:	68 00 f0 7f 00       	push   $0x7ff000
  801489:	56                   	push   %esi
  80148a:	e8 a1 fd ff ff       	call   801230 <sys_page_map>
	if (r < 0)
  80148f:	83 c4 20             	add    $0x20,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	79 12                	jns    8014a8 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  801496:	50                   	push   %eax
  801497:	68 fc 30 80 00       	push   $0x8030fc
  80149c:	6a 3b                	push   $0x3b
  80149e:	68 40 31 80 00       	push   $0x803140
  8014a3:	e8 e4 f2 ff ff       	call   80078c <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	68 00 f0 7f 00       	push   $0x7ff000
  8014b0:	56                   	push   %esi
  8014b1:	e8 bc fd ff ff       	call   801272 <sys_page_unmap>
	if (r < 0)
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	79 12                	jns    8014cf <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  8014bd:	50                   	push   %eax
  8014be:	68 20 31 80 00       	push   $0x803120
  8014c3:	6a 40                	push   $0x40
  8014c5:	68 40 31 80 00       	push   $0x803140
  8014ca:	e8 bd f2 ff ff       	call   80078c <_panic>
}
  8014cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d2:	5b                   	pop    %ebx
  8014d3:	5e                   	pop    %esi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	57                   	push   %edi
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
  8014dc:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  8014df:	68 fd 13 80 00       	push   $0x8013fd
  8014e4:	e8 dc 13 00 00       	call   8028c5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8014e9:	b8 07 00 00 00       	mov    $0x7,%eax
  8014ee:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	0f 88 64 01 00 00    	js     80165f <fork+0x189>
  8014fb:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801500:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801505:	85 c0                	test   %eax,%eax
  801507:	75 21                	jne    80152a <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801509:	e8 a1 fc ff ff       	call   8011af <sys_getenvid>
  80150e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801513:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801516:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80151b:	a3 20 50 80 00       	mov    %eax,0x805020
        return 0;
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	e9 3f 01 00 00       	jmp    801669 <fork+0x193>
  80152a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80152d:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	c1 e8 16             	shr    $0x16,%eax
  801534:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80153b:	a8 01                	test   $0x1,%al
  80153d:	0f 84 bd 00 00 00    	je     801600 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801543:	89 d8                	mov    %ebx,%eax
  801545:	c1 e8 0c             	shr    $0xc,%eax
  801548:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80154f:	f6 c2 01             	test   $0x1,%dl
  801552:	0f 84 a8 00 00 00    	je     801600 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801558:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80155f:	a8 04                	test   $0x4,%al
  801561:	0f 84 99 00 00 00    	je     801600 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801567:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80156e:	f6 c4 04             	test   $0x4,%ah
  801571:	74 17                	je     80158a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	68 07 0e 00 00       	push   $0xe07
  80157b:	53                   	push   %ebx
  80157c:	57                   	push   %edi
  80157d:	53                   	push   %ebx
  80157e:	6a 00                	push   $0x0
  801580:	e8 ab fc ff ff       	call   801230 <sys_page_map>
  801585:	83 c4 20             	add    $0x20,%esp
  801588:	eb 76                	jmp    801600 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80158a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801591:	a8 02                	test   $0x2,%al
  801593:	75 0c                	jne    8015a1 <fork+0xcb>
  801595:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80159c:	f6 c4 08             	test   $0x8,%ah
  80159f:	74 3f                	je     8015e0 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8015a1:	83 ec 0c             	sub    $0xc,%esp
  8015a4:	68 05 08 00 00       	push   $0x805
  8015a9:	53                   	push   %ebx
  8015aa:	57                   	push   %edi
  8015ab:	53                   	push   %ebx
  8015ac:	6a 00                	push   $0x0
  8015ae:	e8 7d fc ff ff       	call   801230 <sys_page_map>
		if (r < 0)
  8015b3:	83 c4 20             	add    $0x20,%esp
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	0f 88 a5 00 00 00    	js     801663 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	68 05 08 00 00       	push   $0x805
  8015c6:	53                   	push   %ebx
  8015c7:	6a 00                	push   $0x0
  8015c9:	53                   	push   %ebx
  8015ca:	6a 00                	push   $0x0
  8015cc:	e8 5f fc ff ff       	call   801230 <sys_page_map>
  8015d1:	83 c4 20             	add    $0x20,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015db:	0f 4f c1             	cmovg  %ecx,%eax
  8015de:	eb 1c                	jmp    8015fc <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	6a 05                	push   $0x5
  8015e5:	53                   	push   %ebx
  8015e6:	57                   	push   %edi
  8015e7:	53                   	push   %ebx
  8015e8:	6a 00                	push   $0x0
  8015ea:	e8 41 fc ff ff       	call   801230 <sys_page_map>
  8015ef:	83 c4 20             	add    $0x20,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f9:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 67                	js     801667 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801600:	83 c6 01             	add    $0x1,%esi
  801603:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801609:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80160f:	0f 85 1a ff ff ff    	jne    80152f <fork+0x59>
  801615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801618:	83 ec 04             	sub    $0x4,%esp
  80161b:	6a 07                	push   $0x7
  80161d:	68 00 f0 bf ee       	push   $0xeebff000
  801622:	57                   	push   %edi
  801623:	e8 c5 fb ff ff       	call   8011ed <sys_page_alloc>
	if (r < 0)
  801628:	83 c4 10             	add    $0x10,%esp
		return r;
  80162b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 38                	js     801669 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	68 0c 29 80 00       	push   $0x80290c
  801639:	57                   	push   %edi
  80163a:	e8 f9 fc ff ff       	call   801338 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80163f:	83 c4 10             	add    $0x10,%esp
		return r;
  801642:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801644:	85 c0                	test   %eax,%eax
  801646:	78 21                	js     801669 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	6a 02                	push   $0x2
  80164d:	57                   	push   %edi
  80164e:	e8 61 fc ff ff       	call   8012b4 <sys_env_set_status>
	if (r < 0)
  801653:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801656:	85 c0                	test   %eax,%eax
  801658:	0f 48 f8             	cmovs  %eax,%edi
  80165b:	89 fa                	mov    %edi,%edx
  80165d:	eb 0a                	jmp    801669 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80165f:	89 c2                	mov    %eax,%edx
  801661:	eb 06                	jmp    801669 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801663:	89 c2                	mov    %eax,%edx
  801665:	eb 02                	jmp    801669 <fork+0x193>
  801667:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801669:	89 d0                	mov    %edx,%eax
  80166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <sfork>:

// Challenge!
int
sfork(void)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801679:	68 4b 31 80 00       	push   $0x80314b
  80167e:	68 c9 00 00 00       	push   $0xc9
  801683:	68 40 31 80 00       	push   $0x803140
  801688:	e8 ff f0 ff ff       	call   80078c <_panic>

0080168d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
  801692:	8b 75 08             	mov    0x8(%ebp),%esi
  801695:	8b 45 0c             	mov    0xc(%ebp),%eax
  801698:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80169b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80169d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8016a2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	50                   	push   %eax
  8016a9:	e8 ef fc ff ff       	call   80139d <sys_ipc_recv>

	if (from_env_store != NULL)
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 f6                	test   %esi,%esi
  8016b3:	74 14                	je     8016c9 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8016b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 09                	js     8016c7 <ipc_recv+0x3a>
  8016be:	8b 15 20 50 80 00    	mov    0x805020,%edx
  8016c4:	8b 52 74             	mov    0x74(%edx),%edx
  8016c7:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8016c9:	85 db                	test   %ebx,%ebx
  8016cb:	74 14                	je     8016e1 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 09                	js     8016df <ipc_recv+0x52>
  8016d6:	8b 15 20 50 80 00    	mov    0x805020,%edx
  8016dc:	8b 52 78             	mov    0x78(%edx),%edx
  8016df:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 08                	js     8016ed <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8016e5:	a1 20 50 80 00       	mov    0x805020,%eax
  8016ea:	8b 40 70             	mov    0x70(%eax),%eax
}
  8016ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	57                   	push   %edi
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801700:	8b 75 0c             	mov    0xc(%ebp),%esi
  801703:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801706:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801708:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80170d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801710:	ff 75 14             	pushl  0x14(%ebp)
  801713:	53                   	push   %ebx
  801714:	56                   	push   %esi
  801715:	57                   	push   %edi
  801716:	e8 5f fc ff ff       	call   80137a <sys_ipc_try_send>

		if (err < 0) {
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	85 c0                	test   %eax,%eax
  801720:	79 1e                	jns    801740 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801722:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801725:	75 07                	jne    80172e <ipc_send+0x3a>
				sys_yield();
  801727:	e8 a2 fa ff ff       	call   8011ce <sys_yield>
  80172c:	eb e2                	jmp    801710 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80172e:	50                   	push   %eax
  80172f:	68 61 31 80 00       	push   $0x803161
  801734:	6a 49                	push   $0x49
  801736:	68 6e 31 80 00       	push   $0x80316e
  80173b:	e8 4c f0 ff ff       	call   80078c <_panic>
		}

	} while (err < 0);

}
  801740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5f                   	pop    %edi
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80174e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801753:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801756:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80175c:	8b 52 50             	mov    0x50(%edx),%edx
  80175f:	39 ca                	cmp    %ecx,%edx
  801761:	75 0d                	jne    801770 <ipc_find_env+0x28>
			return envs[i].env_id;
  801763:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801766:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80176b:	8b 40 48             	mov    0x48(%eax),%eax
  80176e:	eb 0f                	jmp    80177f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801770:	83 c0 01             	add    $0x1,%eax
  801773:	3d 00 04 00 00       	cmp    $0x400,%eax
  801778:	75 d9                	jne    801753 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	05 00 00 00 30       	add    $0x30000000,%eax
  80178c:	c1 e8 0c             	shr    $0xc,%eax
}
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	05 00 00 00 30       	add    $0x30000000,%eax
  80179c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017a1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	c1 ea 16             	shr    $0x16,%edx
  8017b8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017bf:	f6 c2 01             	test   $0x1,%dl
  8017c2:	74 11                	je     8017d5 <fd_alloc+0x2d>
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	c1 ea 0c             	shr    $0xc,%edx
  8017c9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017d0:	f6 c2 01             	test   $0x1,%dl
  8017d3:	75 09                	jne    8017de <fd_alloc+0x36>
			*fd_store = fd;
  8017d5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dc:	eb 17                	jmp    8017f5 <fd_alloc+0x4d>
  8017de:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017e3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017e8:	75 c9                	jne    8017b3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017ea:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8017f0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017fd:	83 f8 1f             	cmp    $0x1f,%eax
  801800:	77 36                	ja     801838 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801802:	c1 e0 0c             	shl    $0xc,%eax
  801805:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	c1 ea 16             	shr    $0x16,%edx
  80180f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801816:	f6 c2 01             	test   $0x1,%dl
  801819:	74 24                	je     80183f <fd_lookup+0x48>
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	c1 ea 0c             	shr    $0xc,%edx
  801820:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801827:	f6 c2 01             	test   $0x1,%dl
  80182a:	74 1a                	je     801846 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80182c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182f:	89 02                	mov    %eax,(%edx)
	return 0;
  801831:	b8 00 00 00 00       	mov    $0x0,%eax
  801836:	eb 13                	jmp    80184b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801838:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183d:	eb 0c                	jmp    80184b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801844:	eb 05                	jmp    80184b <fd_lookup+0x54>
  801846:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801856:	ba f8 31 80 00       	mov    $0x8031f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80185b:	eb 13                	jmp    801870 <dev_lookup+0x23>
  80185d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801860:	39 08                	cmp    %ecx,(%eax)
  801862:	75 0c                	jne    801870 <dev_lookup+0x23>
			*dev = devtab[i];
  801864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801867:	89 01                	mov    %eax,(%ecx)
			return 0;
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
  80186e:	eb 2e                	jmp    80189e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801870:	8b 02                	mov    (%edx),%eax
  801872:	85 c0                	test   %eax,%eax
  801874:	75 e7                	jne    80185d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801876:	a1 20 50 80 00       	mov    0x805020,%eax
  80187b:	8b 40 48             	mov    0x48(%eax),%eax
  80187e:	83 ec 04             	sub    $0x4,%esp
  801881:	51                   	push   %ecx
  801882:	50                   	push   %eax
  801883:	68 78 31 80 00       	push   $0x803178
  801888:	e8 d8 ef ff ff       	call   800865 <cprintf>
	*dev = 0;
  80188d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801890:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 10             	sub    $0x10,%esp
  8018a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b1:	50                   	push   %eax
  8018b2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8018b8:	c1 e8 0c             	shr    $0xc,%eax
  8018bb:	50                   	push   %eax
  8018bc:	e8 36 ff ff ff       	call   8017f7 <fd_lookup>
  8018c1:	83 c4 08             	add    $0x8,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 05                	js     8018cd <fd_close+0x2d>
	    || fd != fd2)
  8018c8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018cb:	74 0c                	je     8018d9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8018cd:	84 db                	test   %bl,%bl
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	0f 44 c2             	cmove  %edx,%eax
  8018d7:	eb 41                	jmp    80191a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	ff 36                	pushl  (%esi)
  8018e2:	e8 66 ff ff ff       	call   80184d <dev_lookup>
  8018e7:	89 c3                	mov    %eax,%ebx
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 1a                	js     80190a <fd_close+0x6a>
		if (dev->dev_close)
  8018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018f6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	74 0b                	je     80190a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	56                   	push   %esi
  801903:	ff d0                	call   *%eax
  801905:	89 c3                	mov    %eax,%ebx
  801907:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80190a:	83 ec 08             	sub    $0x8,%esp
  80190d:	56                   	push   %esi
  80190e:	6a 00                	push   $0x0
  801910:	e8 5d f9 ff ff       	call   801272 <sys_page_unmap>
	return r;
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	89 d8                	mov    %ebx,%eax
}
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801927:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192a:	50                   	push   %eax
  80192b:	ff 75 08             	pushl  0x8(%ebp)
  80192e:	e8 c4 fe ff ff       	call   8017f7 <fd_lookup>
  801933:	83 c4 08             	add    $0x8,%esp
  801936:	85 c0                	test   %eax,%eax
  801938:	78 10                	js     80194a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	6a 01                	push   $0x1
  80193f:	ff 75 f4             	pushl  -0xc(%ebp)
  801942:	e8 59 ff ff ff       	call   8018a0 <fd_close>
  801947:	83 c4 10             	add    $0x10,%esp
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <close_all>:

void
close_all(void)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801953:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	53                   	push   %ebx
  80195c:	e8 c0 ff ff ff       	call   801921 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801961:	83 c3 01             	add    $0x1,%ebx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	83 fb 20             	cmp    $0x20,%ebx
  80196a:	75 ec                	jne    801958 <close_all+0xc>
		close(i);
}
  80196c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	57                   	push   %edi
  801975:	56                   	push   %esi
  801976:	53                   	push   %ebx
  801977:	83 ec 2c             	sub    $0x2c,%esp
  80197a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80197d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801980:	50                   	push   %eax
  801981:	ff 75 08             	pushl  0x8(%ebp)
  801984:	e8 6e fe ff ff       	call   8017f7 <fd_lookup>
  801989:	83 c4 08             	add    $0x8,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	0f 88 c1 00 00 00    	js     801a55 <dup+0xe4>
		return r;
	close(newfdnum);
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	56                   	push   %esi
  801998:	e8 84 ff ff ff       	call   801921 <close>

	newfd = INDEX2FD(newfdnum);
  80199d:	89 f3                	mov    %esi,%ebx
  80199f:	c1 e3 0c             	shl    $0xc,%ebx
  8019a2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8019a8:	83 c4 04             	add    $0x4,%esp
  8019ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019ae:	e8 de fd ff ff       	call   801791 <fd2data>
  8019b3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8019b5:	89 1c 24             	mov    %ebx,(%esp)
  8019b8:	e8 d4 fd ff ff       	call   801791 <fd2data>
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8019c3:	89 f8                	mov    %edi,%eax
  8019c5:	c1 e8 16             	shr    $0x16,%eax
  8019c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019cf:	a8 01                	test   $0x1,%al
  8019d1:	74 37                	je     801a0a <dup+0x99>
  8019d3:	89 f8                	mov    %edi,%eax
  8019d5:	c1 e8 0c             	shr    $0xc,%eax
  8019d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019df:	f6 c2 01             	test   $0x1,%dl
  8019e2:	74 26                	je     801a0a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019eb:	83 ec 0c             	sub    $0xc,%esp
  8019ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8019f3:	50                   	push   %eax
  8019f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8019f7:	6a 00                	push   $0x0
  8019f9:	57                   	push   %edi
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 2f f8 ff ff       	call   801230 <sys_page_map>
  801a01:	89 c7                	mov    %eax,%edi
  801a03:	83 c4 20             	add    $0x20,%esp
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 2e                	js     801a38 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a0d:	89 d0                	mov    %edx,%eax
  801a0f:	c1 e8 0c             	shr    $0xc,%eax
  801a12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	25 07 0e 00 00       	and    $0xe07,%eax
  801a21:	50                   	push   %eax
  801a22:	53                   	push   %ebx
  801a23:	6a 00                	push   $0x0
  801a25:	52                   	push   %edx
  801a26:	6a 00                	push   $0x0
  801a28:	e8 03 f8 ff ff       	call   801230 <sys_page_map>
  801a2d:	89 c7                	mov    %eax,%edi
  801a2f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801a32:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a34:	85 ff                	test   %edi,%edi
  801a36:	79 1d                	jns    801a55 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	6a 00                	push   $0x0
  801a3e:	e8 2f f8 ff ff       	call   801272 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a43:	83 c4 08             	add    $0x8,%esp
  801a46:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a49:	6a 00                	push   $0x0
  801a4b:	e8 22 f8 ff ff       	call   801272 <sys_page_unmap>
	return r;
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	89 f8                	mov    %edi,%eax
}
  801a55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	53                   	push   %ebx
  801a61:	83 ec 14             	sub    $0x14,%esp
  801a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a6a:	50                   	push   %eax
  801a6b:	53                   	push   %ebx
  801a6c:	e8 86 fd ff ff       	call   8017f7 <fd_lookup>
  801a71:	83 c4 08             	add    $0x8,%esp
  801a74:	89 c2                	mov    %eax,%edx
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 6d                	js     801ae7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a80:	50                   	push   %eax
  801a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a84:	ff 30                	pushl  (%eax)
  801a86:	e8 c2 fd ff ff       	call   80184d <dev_lookup>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 4c                	js     801ade <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a92:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a95:	8b 42 08             	mov    0x8(%edx),%eax
  801a98:	83 e0 03             	and    $0x3,%eax
  801a9b:	83 f8 01             	cmp    $0x1,%eax
  801a9e:	75 21                	jne    801ac1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801aa0:	a1 20 50 80 00       	mov    0x805020,%eax
  801aa5:	8b 40 48             	mov    0x48(%eax),%eax
  801aa8:	83 ec 04             	sub    $0x4,%esp
  801aab:	53                   	push   %ebx
  801aac:	50                   	push   %eax
  801aad:	68 bc 31 80 00       	push   $0x8031bc
  801ab2:	e8 ae ed ff ff       	call   800865 <cprintf>
		return -E_INVAL;
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801abf:	eb 26                	jmp    801ae7 <read+0x8a>
	}
	if (!dev->dev_read)
  801ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac4:	8b 40 08             	mov    0x8(%eax),%eax
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	74 17                	je     801ae2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	ff 75 10             	pushl  0x10(%ebp)
  801ad1:	ff 75 0c             	pushl  0xc(%ebp)
  801ad4:	52                   	push   %edx
  801ad5:	ff d0                	call   *%eax
  801ad7:	89 c2                	mov    %eax,%edx
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	eb 09                	jmp    801ae7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ade:	89 c2                	mov    %eax,%edx
  801ae0:	eb 05                	jmp    801ae7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ae2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801ae7:	89 d0                	mov    %edx,%eax
  801ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801afd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b02:	eb 21                	jmp    801b25 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	89 f0                	mov    %esi,%eax
  801b09:	29 d8                	sub    %ebx,%eax
  801b0b:	50                   	push   %eax
  801b0c:	89 d8                	mov    %ebx,%eax
  801b0e:	03 45 0c             	add    0xc(%ebp),%eax
  801b11:	50                   	push   %eax
  801b12:	57                   	push   %edi
  801b13:	e8 45 ff ff ff       	call   801a5d <read>
		if (m < 0)
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	78 10                	js     801b2f <readn+0x41>
			return m;
		if (m == 0)
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	74 0a                	je     801b2d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b23:	01 c3                	add    %eax,%ebx
  801b25:	39 f3                	cmp    %esi,%ebx
  801b27:	72 db                	jb     801b04 <readn+0x16>
  801b29:	89 d8                	mov    %ebx,%eax
  801b2b:	eb 02                	jmp    801b2f <readn+0x41>
  801b2d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5f                   	pop    %edi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 14             	sub    $0x14,%esp
  801b3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b44:	50                   	push   %eax
  801b45:	53                   	push   %ebx
  801b46:	e8 ac fc ff ff       	call   8017f7 <fd_lookup>
  801b4b:	83 c4 08             	add    $0x8,%esp
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 68                	js     801bbc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b54:	83 ec 08             	sub    $0x8,%esp
  801b57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5a:	50                   	push   %eax
  801b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5e:	ff 30                	pushl  (%eax)
  801b60:	e8 e8 fc ff ff       	call   80184d <dev_lookup>
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 47                	js     801bb3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b73:	75 21                	jne    801b96 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b75:	a1 20 50 80 00       	mov    0x805020,%eax
  801b7a:	8b 40 48             	mov    0x48(%eax),%eax
  801b7d:	83 ec 04             	sub    $0x4,%esp
  801b80:	53                   	push   %ebx
  801b81:	50                   	push   %eax
  801b82:	68 d8 31 80 00       	push   $0x8031d8
  801b87:	e8 d9 ec ff ff       	call   800865 <cprintf>
		return -E_INVAL;
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b94:	eb 26                	jmp    801bbc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b99:	8b 52 0c             	mov    0xc(%edx),%edx
  801b9c:	85 d2                	test   %edx,%edx
  801b9e:	74 17                	je     801bb7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	ff 75 10             	pushl  0x10(%ebp)
  801ba6:	ff 75 0c             	pushl  0xc(%ebp)
  801ba9:	50                   	push   %eax
  801baa:	ff d2                	call   *%edx
  801bac:	89 c2                	mov    %eax,%edx
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	eb 09                	jmp    801bbc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb3:	89 c2                	mov    %eax,%edx
  801bb5:	eb 05                	jmp    801bbc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801bb7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801bbc:	89 d0                	mov    %edx,%eax
  801bbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <seek>:

int
seek(int fdnum, off_t offset)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bcc:	50                   	push   %eax
  801bcd:	ff 75 08             	pushl  0x8(%ebp)
  801bd0:	e8 22 fc ff ff       	call   8017f7 <fd_lookup>
  801bd5:	83 c4 08             	add    $0x8,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 0e                	js     801bea <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801bdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801be5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 14             	sub    $0x14,%esp
  801bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bf6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	53                   	push   %ebx
  801bfb:	e8 f7 fb ff ff       	call   8017f7 <fd_lookup>
  801c00:	83 c4 08             	add    $0x8,%esp
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 65                	js     801c6e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0f:	50                   	push   %eax
  801c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c13:	ff 30                	pushl  (%eax)
  801c15:	e8 33 fc ff ff       	call   80184d <dev_lookup>
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 44                	js     801c65 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c24:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c28:	75 21                	jne    801c4b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c2a:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c2f:	8b 40 48             	mov    0x48(%eax),%eax
  801c32:	83 ec 04             	sub    $0x4,%esp
  801c35:	53                   	push   %ebx
  801c36:	50                   	push   %eax
  801c37:	68 98 31 80 00       	push   $0x803198
  801c3c:	e8 24 ec ff ff       	call   800865 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c49:	eb 23                	jmp    801c6e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4e:	8b 52 18             	mov    0x18(%edx),%edx
  801c51:	85 d2                	test   %edx,%edx
  801c53:	74 14                	je     801c69 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 0c             	pushl  0xc(%ebp)
  801c5b:	50                   	push   %eax
  801c5c:	ff d2                	call   *%edx
  801c5e:	89 c2                	mov    %eax,%edx
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	eb 09                	jmp    801c6e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c65:	89 c2                	mov    %eax,%edx
  801c67:	eb 05                	jmp    801c6e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c69:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801c6e:	89 d0                	mov    %edx,%eax
  801c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 14             	sub    $0x14,%esp
  801c7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c82:	50                   	push   %eax
  801c83:	ff 75 08             	pushl  0x8(%ebp)
  801c86:	e8 6c fb ff ff       	call   8017f7 <fd_lookup>
  801c8b:	83 c4 08             	add    $0x8,%esp
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	85 c0                	test   %eax,%eax
  801c92:	78 58                	js     801cec <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c94:	83 ec 08             	sub    $0x8,%esp
  801c97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9a:	50                   	push   %eax
  801c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9e:	ff 30                	pushl  (%eax)
  801ca0:	e8 a8 fb ff ff       	call   80184d <dev_lookup>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	78 37                	js     801ce3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801cb3:	74 32                	je     801ce7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cb5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cb8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cbf:	00 00 00 
	stat->st_isdir = 0;
  801cc2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cc9:	00 00 00 
	stat->st_dev = dev;
  801ccc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801cd2:	83 ec 08             	sub    $0x8,%esp
  801cd5:	53                   	push   %ebx
  801cd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd9:	ff 50 14             	call   *0x14(%eax)
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	eb 09                	jmp    801cec <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	eb 05                	jmp    801cec <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ce7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801cec:	89 d0                	mov    %edx,%eax
  801cee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	56                   	push   %esi
  801cf7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	6a 00                	push   $0x0
  801cfd:	ff 75 08             	pushl  0x8(%ebp)
  801d00:	e8 d6 01 00 00       	call   801edb <open>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 1b                	js     801d29 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801d0e:	83 ec 08             	sub    $0x8,%esp
  801d11:	ff 75 0c             	pushl  0xc(%ebp)
  801d14:	50                   	push   %eax
  801d15:	e8 5b ff ff ff       	call   801c75 <fstat>
  801d1a:	89 c6                	mov    %eax,%esi
	close(fd);
  801d1c:	89 1c 24             	mov    %ebx,(%esp)
  801d1f:	e8 fd fb ff ff       	call   801921 <close>
	return r;
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	89 f0                	mov    %esi,%eax
}
  801d29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2c:	5b                   	pop    %ebx
  801d2d:	5e                   	pop    %esi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	56                   	push   %esi
  801d34:	53                   	push   %ebx
  801d35:	89 c6                	mov    %eax,%esi
  801d37:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d39:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801d40:	75 12                	jne    801d54 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	6a 01                	push   $0x1
  801d47:	e8 fc f9 ff ff       	call   801748 <ipc_find_env>
  801d4c:	a3 18 50 80 00       	mov    %eax,0x805018
  801d51:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d54:	6a 07                	push   $0x7
  801d56:	68 00 60 80 00       	push   $0x806000
  801d5b:	56                   	push   %esi
  801d5c:	ff 35 18 50 80 00    	pushl  0x805018
  801d62:	e8 8d f9 ff ff       	call   8016f4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d67:	83 c4 0c             	add    $0xc,%esp
  801d6a:	6a 00                	push   $0x0
  801d6c:	53                   	push   %ebx
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 19 f9 ff ff       	call   80168d <ipc_recv>
}
  801d74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	8b 40 0c             	mov    0xc(%eax),%eax
  801d87:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8f:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d94:	ba 00 00 00 00       	mov    $0x0,%edx
  801d99:	b8 02 00 00 00       	mov    $0x2,%eax
  801d9e:	e8 8d ff ff ff       	call   801d30 <fsipc>
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	8b 40 0c             	mov    0xc(%eax),%eax
  801db1:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801db6:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbb:	b8 06 00 00 00       	mov    $0x6,%eax
  801dc0:	e8 6b ff ff ff       	call   801d30 <fsipc>
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 04             	sub    $0x4,%esp
  801dce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ddc:	ba 00 00 00 00       	mov    $0x0,%edx
  801de1:	b8 05 00 00 00       	mov    $0x5,%eax
  801de6:	e8 45 ff ff ff       	call   801d30 <fsipc>
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 2c                	js     801e1b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801def:	83 ec 08             	sub    $0x8,%esp
  801df2:	68 00 60 80 00       	push   $0x806000
  801df7:	53                   	push   %ebx
  801df8:	e8 ed ef ff ff       	call   800dea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801dfd:	a1 80 60 80 00       	mov    0x806080,%eax
  801e02:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e08:	a1 84 60 80 00       	mov    0x806084,%eax
  801e0d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e29:	8b 55 08             	mov    0x8(%ebp),%edx
  801e2c:	8b 52 0c             	mov    0xc(%edx),%edx
  801e2f:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801e35:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801e3a:	50                   	push   %eax
  801e3b:	ff 75 0c             	pushl  0xc(%ebp)
  801e3e:	68 08 60 80 00       	push   $0x806008
  801e43:	e8 34 f1 ff ff       	call   800f7c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801e48:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4d:	b8 04 00 00 00       	mov    $0x4,%eax
  801e52:	e8 d9 fe ff ff       	call   801d30 <fsipc>

}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e61:	8b 45 08             	mov    0x8(%ebp),%eax
  801e64:	8b 40 0c             	mov    0xc(%eax),%eax
  801e67:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e6c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e72:	ba 00 00 00 00       	mov    $0x0,%edx
  801e77:	b8 03 00 00 00       	mov    $0x3,%eax
  801e7c:	e8 af fe ff ff       	call   801d30 <fsipc>
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 4b                	js     801ed2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801e87:	39 c6                	cmp    %eax,%esi
  801e89:	73 16                	jae    801ea1 <devfile_read+0x48>
  801e8b:	68 0c 32 80 00       	push   $0x80320c
  801e90:	68 13 32 80 00       	push   $0x803213
  801e95:	6a 7c                	push   $0x7c
  801e97:	68 28 32 80 00       	push   $0x803228
  801e9c:	e8 eb e8 ff ff       	call   80078c <_panic>
	assert(r <= PGSIZE);
  801ea1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ea6:	7e 16                	jle    801ebe <devfile_read+0x65>
  801ea8:	68 33 32 80 00       	push   $0x803233
  801ead:	68 13 32 80 00       	push   $0x803213
  801eb2:	6a 7d                	push   $0x7d
  801eb4:	68 28 32 80 00       	push   $0x803228
  801eb9:	e8 ce e8 ff ff       	call   80078c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ebe:	83 ec 04             	sub    $0x4,%esp
  801ec1:	50                   	push   %eax
  801ec2:	68 00 60 80 00       	push   $0x806000
  801ec7:	ff 75 0c             	pushl  0xc(%ebp)
  801eca:	e8 ad f0 ff ff       	call   800f7c <memmove>
	return r;
  801ecf:	83 c4 10             	add    $0x10,%esp
}
  801ed2:	89 d8                	mov    %ebx,%eax
  801ed4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed7:	5b                   	pop    %ebx
  801ed8:	5e                   	pop    %esi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	53                   	push   %ebx
  801edf:	83 ec 20             	sub    $0x20,%esp
  801ee2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ee5:	53                   	push   %ebx
  801ee6:	e8 c6 ee ff ff       	call   800db1 <strlen>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ef3:	7f 67                	jg     801f5c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ef5:	83 ec 0c             	sub    $0xc,%esp
  801ef8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efb:	50                   	push   %eax
  801efc:	e8 a7 f8 ff ff       	call   8017a8 <fd_alloc>
  801f01:	83 c4 10             	add    $0x10,%esp
		return r;
  801f04:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 57                	js     801f61 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f0a:	83 ec 08             	sub    $0x8,%esp
  801f0d:	53                   	push   %ebx
  801f0e:	68 00 60 80 00       	push   $0x806000
  801f13:	e8 d2 ee ff ff       	call   800dea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f23:	b8 01 00 00 00       	mov    $0x1,%eax
  801f28:	e8 03 fe ff ff       	call   801d30 <fsipc>
  801f2d:	89 c3                	mov    %eax,%ebx
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	79 14                	jns    801f4a <open+0x6f>
		fd_close(fd, 0);
  801f36:	83 ec 08             	sub    $0x8,%esp
  801f39:	6a 00                	push   $0x0
  801f3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3e:	e8 5d f9 ff ff       	call   8018a0 <fd_close>
		return r;
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	89 da                	mov    %ebx,%edx
  801f48:	eb 17                	jmp    801f61 <open+0x86>
	}

	return fd2num(fd);
  801f4a:	83 ec 0c             	sub    $0xc,%esp
  801f4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f50:	e8 2c f8 ff ff       	call   801781 <fd2num>
  801f55:	89 c2                	mov    %eax,%edx
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	eb 05                	jmp    801f61 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f5c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f61:	89 d0                	mov    %edx,%eax
  801f63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f66:	c9                   	leave  
  801f67:	c3                   	ret    

00801f68 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f73:	b8 08 00 00 00       	mov    $0x8,%eax
  801f78:	e8 b3 fd ff ff       	call   801d30 <fsipc>
}
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	ff 75 08             	pushl  0x8(%ebp)
  801f8d:	e8 ff f7 ff ff       	call   801791 <fd2data>
  801f92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f94:	83 c4 08             	add    $0x8,%esp
  801f97:	68 3f 32 80 00       	push   $0x80323f
  801f9c:	53                   	push   %ebx
  801f9d:	e8 48 ee ff ff       	call   800dea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fa2:	8b 46 04             	mov    0x4(%esi),%eax
  801fa5:	2b 06                	sub    (%esi),%eax
  801fa7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fb4:	00 00 00 
	stat->st_dev = &devpipe;
  801fb7:	c7 83 88 00 00 00 20 	movl   $0x804020,0x88(%ebx)
  801fbe:	40 80 00 
	return 0;
}
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc9:	5b                   	pop    %ebx
  801fca:	5e                   	pop    %esi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 0c             	sub    $0xc,%esp
  801fd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fd7:	53                   	push   %ebx
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 93 f2 ff ff       	call   801272 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fdf:	89 1c 24             	mov    %ebx,(%esp)
  801fe2:	e8 aa f7 ff ff       	call   801791 <fd2data>
  801fe7:	83 c4 08             	add    $0x8,%esp
  801fea:	50                   	push   %eax
  801feb:	6a 00                	push   $0x0
  801fed:	e8 80 f2 ff ff       	call   801272 <sys_page_unmap>
}
  801ff2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	57                   	push   %edi
  801ffb:	56                   	push   %esi
  801ffc:	53                   	push   %ebx
  801ffd:	83 ec 1c             	sub    $0x1c,%esp
  802000:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802003:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802005:	a1 20 50 80 00       	mov    0x805020,%eax
  80200a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80200d:	83 ec 0c             	sub    $0xc,%esp
  802010:	ff 75 e0             	pushl  -0x20(%ebp)
  802013:	e8 18 09 00 00       	call   802930 <pageref>
  802018:	89 c3                	mov    %eax,%ebx
  80201a:	89 3c 24             	mov    %edi,(%esp)
  80201d:	e8 0e 09 00 00       	call   802930 <pageref>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	39 c3                	cmp    %eax,%ebx
  802027:	0f 94 c1             	sete   %cl
  80202a:	0f b6 c9             	movzbl %cl,%ecx
  80202d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802030:	8b 15 20 50 80 00    	mov    0x805020,%edx
  802036:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802039:	39 ce                	cmp    %ecx,%esi
  80203b:	74 1b                	je     802058 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80203d:	39 c3                	cmp    %eax,%ebx
  80203f:	75 c4                	jne    802005 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802041:	8b 42 58             	mov    0x58(%edx),%eax
  802044:	ff 75 e4             	pushl  -0x1c(%ebp)
  802047:	50                   	push   %eax
  802048:	56                   	push   %esi
  802049:	68 46 32 80 00       	push   $0x803246
  80204e:	e8 12 e8 ff ff       	call   800865 <cprintf>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	eb ad                	jmp    802005 <_pipeisclosed+0xe>
	}
}
  802058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80205b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    

00802063 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	57                   	push   %edi
  802067:	56                   	push   %esi
  802068:	53                   	push   %ebx
  802069:	83 ec 28             	sub    $0x28,%esp
  80206c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80206f:	56                   	push   %esi
  802070:	e8 1c f7 ff ff       	call   801791 <fd2data>
  802075:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	bf 00 00 00 00       	mov    $0x0,%edi
  80207f:	eb 4b                	jmp    8020cc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802081:	89 da                	mov    %ebx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	e8 6d ff ff ff       	call   801ff7 <_pipeisclosed>
  80208a:	85 c0                	test   %eax,%eax
  80208c:	75 48                	jne    8020d6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80208e:	e8 3b f1 ff ff       	call   8011ce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802093:	8b 43 04             	mov    0x4(%ebx),%eax
  802096:	8b 0b                	mov    (%ebx),%ecx
  802098:	8d 51 20             	lea    0x20(%ecx),%edx
  80209b:	39 d0                	cmp    %edx,%eax
  80209d:	73 e2                	jae    802081 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80209f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020a6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a9:	89 c2                	mov    %eax,%edx
  8020ab:	c1 fa 1f             	sar    $0x1f,%edx
  8020ae:	89 d1                	mov    %edx,%ecx
  8020b0:	c1 e9 1b             	shr    $0x1b,%ecx
  8020b3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020b6:	83 e2 1f             	and    $0x1f,%edx
  8020b9:	29 ca                	sub    %ecx,%edx
  8020bb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020c3:	83 c0 01             	add    $0x1,%eax
  8020c6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c9:	83 c7 01             	add    $0x1,%edi
  8020cc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cf:	75 c2                	jne    802093 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d4:	eb 05                	jmp    8020db <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	57                   	push   %edi
  8020e7:	56                   	push   %esi
  8020e8:	53                   	push   %ebx
  8020e9:	83 ec 18             	sub    $0x18,%esp
  8020ec:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ef:	57                   	push   %edi
  8020f0:	e8 9c f6 ff ff       	call   801791 <fd2data>
  8020f5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ff:	eb 3d                	jmp    80213e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802101:	85 db                	test   %ebx,%ebx
  802103:	74 04                	je     802109 <devpipe_read+0x26>
				return i;
  802105:	89 d8                	mov    %ebx,%eax
  802107:	eb 44                	jmp    80214d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802109:	89 f2                	mov    %esi,%edx
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	e8 e5 fe ff ff       	call   801ff7 <_pipeisclosed>
  802112:	85 c0                	test   %eax,%eax
  802114:	75 32                	jne    802148 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802116:	e8 b3 f0 ff ff       	call   8011ce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80211b:	8b 06                	mov    (%esi),%eax
  80211d:	3b 46 04             	cmp    0x4(%esi),%eax
  802120:	74 df                	je     802101 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802122:	99                   	cltd   
  802123:	c1 ea 1b             	shr    $0x1b,%edx
  802126:	01 d0                	add    %edx,%eax
  802128:	83 e0 1f             	and    $0x1f,%eax
  80212b:	29 d0                	sub    %edx,%eax
  80212d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802135:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802138:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80213b:	83 c3 01             	add    $0x1,%ebx
  80213e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802141:	75 d8                	jne    80211b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802143:	8b 45 10             	mov    0x10(%ebp),%eax
  802146:	eb 05                	jmp    80214d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80214d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	56                   	push   %esi
  802159:	53                   	push   %ebx
  80215a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80215d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	e8 42 f6 ff ff       	call   8017a8 <fd_alloc>
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	89 c2                	mov    %eax,%edx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	0f 88 2c 01 00 00    	js     80229f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802173:	83 ec 04             	sub    $0x4,%esp
  802176:	68 07 04 00 00       	push   $0x407
  80217b:	ff 75 f4             	pushl  -0xc(%ebp)
  80217e:	6a 00                	push   $0x0
  802180:	e8 68 f0 ff ff       	call   8011ed <sys_page_alloc>
  802185:	83 c4 10             	add    $0x10,%esp
  802188:	89 c2                	mov    %eax,%edx
  80218a:	85 c0                	test   %eax,%eax
  80218c:	0f 88 0d 01 00 00    	js     80229f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802192:	83 ec 0c             	sub    $0xc,%esp
  802195:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	e8 0a f6 ff ff       	call   8017a8 <fd_alloc>
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	0f 88 e2 00 00 00    	js     80228d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ab:	83 ec 04             	sub    $0x4,%esp
  8021ae:	68 07 04 00 00       	push   $0x407
  8021b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b6:	6a 00                	push   $0x0
  8021b8:	e8 30 f0 ff ff       	call   8011ed <sys_page_alloc>
  8021bd:	89 c3                	mov    %eax,%ebx
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	85 c0                	test   %eax,%eax
  8021c4:	0f 88 c3 00 00 00    	js     80228d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021ca:	83 ec 0c             	sub    $0xc,%esp
  8021cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d0:	e8 bc f5 ff ff       	call   801791 <fd2data>
  8021d5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d7:	83 c4 0c             	add    $0xc,%esp
  8021da:	68 07 04 00 00       	push   $0x407
  8021df:	50                   	push   %eax
  8021e0:	6a 00                	push   $0x0
  8021e2:	e8 06 f0 ff ff       	call   8011ed <sys_page_alloc>
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 88 89 00 00 00    	js     80227d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f4:	83 ec 0c             	sub    $0xc,%esp
  8021f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021fa:	e8 92 f5 ff ff       	call   801791 <fd2data>
  8021ff:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802206:	50                   	push   %eax
  802207:	6a 00                	push   $0x0
  802209:	56                   	push   %esi
  80220a:	6a 00                	push   $0x0
  80220c:	e8 1f f0 ff ff       	call   801230 <sys_page_map>
  802211:	89 c3                	mov    %eax,%ebx
  802213:	83 c4 20             	add    $0x20,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	78 55                	js     80226f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80221a:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802228:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80222f:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802238:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80223a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80223d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802244:	83 ec 0c             	sub    $0xc,%esp
  802247:	ff 75 f4             	pushl  -0xc(%ebp)
  80224a:	e8 32 f5 ff ff       	call   801781 <fd2num>
  80224f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802252:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802254:	83 c4 04             	add    $0x4,%esp
  802257:	ff 75 f0             	pushl  -0x10(%ebp)
  80225a:	e8 22 f5 ff ff       	call   801781 <fd2num>
  80225f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802262:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	ba 00 00 00 00       	mov    $0x0,%edx
  80226d:	eb 30                	jmp    80229f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80226f:	83 ec 08             	sub    $0x8,%esp
  802272:	56                   	push   %esi
  802273:	6a 00                	push   $0x0
  802275:	e8 f8 ef ff ff       	call   801272 <sys_page_unmap>
  80227a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80227d:	83 ec 08             	sub    $0x8,%esp
  802280:	ff 75 f0             	pushl  -0x10(%ebp)
  802283:	6a 00                	push   $0x0
  802285:	e8 e8 ef ff ff       	call   801272 <sys_page_unmap>
  80228a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80228d:	83 ec 08             	sub    $0x8,%esp
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 d8 ef ff ff       	call   801272 <sys_page_unmap>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b1:	50                   	push   %eax
  8022b2:	ff 75 08             	pushl  0x8(%ebp)
  8022b5:	e8 3d f5 ff ff       	call   8017f7 <fd_lookup>
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	78 18                	js     8022d9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022c1:	83 ec 0c             	sub    $0xc,%esp
  8022c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c7:	e8 c5 f4 ff ff       	call   801791 <fd2data>
	return _pipeisclosed(fd, p);
  8022cc:	89 c2                	mov    %eax,%edx
  8022ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d1:	e8 21 fd ff ff       	call   801ff7 <_pipeisclosed>
  8022d6:	83 c4 10             	add    $0x10,%esp
}
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8022e1:	68 5e 32 80 00       	push   $0x80325e
  8022e6:	ff 75 0c             	pushl  0xc(%ebp)
  8022e9:	e8 fc ea ff ff       	call   800dea <strcpy>
	return 0;
}
  8022ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	53                   	push   %ebx
  8022f9:	83 ec 10             	sub    $0x10,%esp
  8022fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8022ff:	53                   	push   %ebx
  802300:	e8 2b 06 00 00       	call   802930 <pageref>
  802305:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802308:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80230d:	83 f8 01             	cmp    $0x1,%eax
  802310:	75 10                	jne    802322 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802312:	83 ec 0c             	sub    $0xc,%esp
  802315:	ff 73 0c             	pushl  0xc(%ebx)
  802318:	e8 c0 02 00 00       	call   8025dd <nsipc_close>
  80231d:	89 c2                	mov    %eax,%edx
  80231f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802322:	89 d0                	mov    %edx,%eax
  802324:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802327:	c9                   	leave  
  802328:	c3                   	ret    

00802329 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80232f:	6a 00                	push   $0x0
  802331:	ff 75 10             	pushl  0x10(%ebp)
  802334:	ff 75 0c             	pushl  0xc(%ebp)
  802337:	8b 45 08             	mov    0x8(%ebp),%eax
  80233a:	ff 70 0c             	pushl  0xc(%eax)
  80233d:	e8 78 03 00 00       	call   8026ba <nsipc_send>
}
  802342:	c9                   	leave  
  802343:	c3                   	ret    

00802344 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80234a:	6a 00                	push   $0x0
  80234c:	ff 75 10             	pushl  0x10(%ebp)
  80234f:	ff 75 0c             	pushl  0xc(%ebp)
  802352:	8b 45 08             	mov    0x8(%ebp),%eax
  802355:	ff 70 0c             	pushl  0xc(%eax)
  802358:	e8 f1 02 00 00       	call   80264e <nsipc_recv>
}
  80235d:	c9                   	leave  
  80235e:	c3                   	ret    

0080235f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802365:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802368:	52                   	push   %edx
  802369:	50                   	push   %eax
  80236a:	e8 88 f4 ff ff       	call   8017f7 <fd_lookup>
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	85 c0                	test   %eax,%eax
  802374:	78 17                	js     80238d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802379:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  80237f:	39 08                	cmp    %ecx,(%eax)
  802381:	75 05                	jne    802388 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802383:	8b 40 0c             	mov    0xc(%eax),%eax
  802386:	eb 05                	jmp    80238d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802388:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802399:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239c:	50                   	push   %eax
  80239d:	e8 06 f4 ff ff       	call   8017a8 <fd_alloc>
  8023a2:	89 c3                	mov    %eax,%ebx
  8023a4:	83 c4 10             	add    $0x10,%esp
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	78 1b                	js     8023c6 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8023ab:	83 ec 04             	sub    $0x4,%esp
  8023ae:	68 07 04 00 00       	push   $0x407
  8023b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b6:	6a 00                	push   $0x0
  8023b8:	e8 30 ee ff ff       	call   8011ed <sys_page_alloc>
  8023bd:	89 c3                	mov    %eax,%ebx
  8023bf:	83 c4 10             	add    $0x10,%esp
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	79 10                	jns    8023d6 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8023c6:	83 ec 0c             	sub    $0xc,%esp
  8023c9:	56                   	push   %esi
  8023ca:	e8 0e 02 00 00       	call   8025dd <nsipc_close>
		return r;
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	89 d8                	mov    %ebx,%eax
  8023d4:	eb 24                	jmp    8023fa <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8023d6:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023df:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8023e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8023eb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8023ee:	83 ec 0c             	sub    $0xc,%esp
  8023f1:	50                   	push   %eax
  8023f2:	e8 8a f3 ff ff       	call   801781 <fd2num>
  8023f7:	83 c4 10             	add    $0x10,%esp
}
  8023fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    

00802401 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802407:	8b 45 08             	mov    0x8(%ebp),%eax
  80240a:	e8 50 ff ff ff       	call   80235f <fd2sockid>
		return r;
  80240f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802411:	85 c0                	test   %eax,%eax
  802413:	78 1f                	js     802434 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802415:	83 ec 04             	sub    $0x4,%esp
  802418:	ff 75 10             	pushl  0x10(%ebp)
  80241b:	ff 75 0c             	pushl  0xc(%ebp)
  80241e:	50                   	push   %eax
  80241f:	e8 12 01 00 00       	call   802536 <nsipc_accept>
  802424:	83 c4 10             	add    $0x10,%esp
		return r;
  802427:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802429:	85 c0                	test   %eax,%eax
  80242b:	78 07                	js     802434 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80242d:	e8 5d ff ff ff       	call   80238f <alloc_sockfd>
  802432:	89 c1                	mov    %eax,%ecx
}
  802434:	89 c8                	mov    %ecx,%eax
  802436:	c9                   	leave  
  802437:	c3                   	ret    

00802438 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80243e:	8b 45 08             	mov    0x8(%ebp),%eax
  802441:	e8 19 ff ff ff       	call   80235f <fd2sockid>
  802446:	85 c0                	test   %eax,%eax
  802448:	78 12                	js     80245c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80244a:	83 ec 04             	sub    $0x4,%esp
  80244d:	ff 75 10             	pushl  0x10(%ebp)
  802450:	ff 75 0c             	pushl  0xc(%ebp)
  802453:	50                   	push   %eax
  802454:	e8 2d 01 00 00       	call   802586 <nsipc_bind>
  802459:	83 c4 10             	add    $0x10,%esp
}
  80245c:	c9                   	leave  
  80245d:	c3                   	ret    

0080245e <shutdown>:

int
shutdown(int s, int how)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802464:	8b 45 08             	mov    0x8(%ebp),%eax
  802467:	e8 f3 fe ff ff       	call   80235f <fd2sockid>
  80246c:	85 c0                	test   %eax,%eax
  80246e:	78 0f                	js     80247f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802470:	83 ec 08             	sub    $0x8,%esp
  802473:	ff 75 0c             	pushl  0xc(%ebp)
  802476:	50                   	push   %eax
  802477:	e8 3f 01 00 00       	call   8025bb <nsipc_shutdown>
  80247c:	83 c4 10             	add    $0x10,%esp
}
  80247f:	c9                   	leave  
  802480:	c3                   	ret    

00802481 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802487:	8b 45 08             	mov    0x8(%ebp),%eax
  80248a:	e8 d0 fe ff ff       	call   80235f <fd2sockid>
  80248f:	85 c0                	test   %eax,%eax
  802491:	78 12                	js     8024a5 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802493:	83 ec 04             	sub    $0x4,%esp
  802496:	ff 75 10             	pushl  0x10(%ebp)
  802499:	ff 75 0c             	pushl  0xc(%ebp)
  80249c:	50                   	push   %eax
  80249d:	e8 55 01 00 00       	call   8025f7 <nsipc_connect>
  8024a2:	83 c4 10             	add    $0x10,%esp
}
  8024a5:	c9                   	leave  
  8024a6:	c3                   	ret    

008024a7 <listen>:

int
listen(int s, int backlog)
{
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b0:	e8 aa fe ff ff       	call   80235f <fd2sockid>
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	78 0f                	js     8024c8 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8024b9:	83 ec 08             	sub    $0x8,%esp
  8024bc:	ff 75 0c             	pushl  0xc(%ebp)
  8024bf:	50                   	push   %eax
  8024c0:	e8 67 01 00 00       	call   80262c <nsipc_listen>
  8024c5:	83 c4 10             	add    $0x10,%esp
}
  8024c8:	c9                   	leave  
  8024c9:	c3                   	ret    

008024ca <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8024ca:	55                   	push   %ebp
  8024cb:	89 e5                	mov    %esp,%ebp
  8024cd:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8024d0:	ff 75 10             	pushl  0x10(%ebp)
  8024d3:	ff 75 0c             	pushl  0xc(%ebp)
  8024d6:	ff 75 08             	pushl  0x8(%ebp)
  8024d9:	e8 3a 02 00 00       	call   802718 <nsipc_socket>
  8024de:	83 c4 10             	add    $0x10,%esp
  8024e1:	85 c0                	test   %eax,%eax
  8024e3:	78 05                	js     8024ea <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8024e5:	e8 a5 fe ff ff       	call   80238f <alloc_sockfd>
}
  8024ea:	c9                   	leave  
  8024eb:	c3                   	ret    

008024ec <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	53                   	push   %ebx
  8024f0:	83 ec 04             	sub    $0x4,%esp
  8024f3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8024f5:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  8024fc:	75 12                	jne    802510 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8024fe:	83 ec 0c             	sub    $0xc,%esp
  802501:	6a 02                	push   $0x2
  802503:	e8 40 f2 ff ff       	call   801748 <ipc_find_env>
  802508:	a3 1c 50 80 00       	mov    %eax,0x80501c
  80250d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802510:	6a 07                	push   $0x7
  802512:	68 00 70 80 00       	push   $0x807000
  802517:	53                   	push   %ebx
  802518:	ff 35 1c 50 80 00    	pushl  0x80501c
  80251e:	e8 d1 f1 ff ff       	call   8016f4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802523:	83 c4 0c             	add    $0xc,%esp
  802526:	6a 00                	push   $0x0
  802528:	6a 00                	push   $0x0
  80252a:	6a 00                	push   $0x0
  80252c:	e8 5c f1 ff ff       	call   80168d <ipc_recv>
}
  802531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802534:	c9                   	leave  
  802535:	c3                   	ret    

00802536 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802536:	55                   	push   %ebp
  802537:	89 e5                	mov    %esp,%ebp
  802539:	56                   	push   %esi
  80253a:	53                   	push   %ebx
  80253b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80253e:	8b 45 08             	mov    0x8(%ebp),%eax
  802541:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802546:	8b 06                	mov    (%esi),%eax
  802548:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80254d:	b8 01 00 00 00       	mov    $0x1,%eax
  802552:	e8 95 ff ff ff       	call   8024ec <nsipc>
  802557:	89 c3                	mov    %eax,%ebx
  802559:	85 c0                	test   %eax,%eax
  80255b:	78 20                	js     80257d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80255d:	83 ec 04             	sub    $0x4,%esp
  802560:	ff 35 10 70 80 00    	pushl  0x807010
  802566:	68 00 70 80 00       	push   $0x807000
  80256b:	ff 75 0c             	pushl  0xc(%ebp)
  80256e:	e8 09 ea ff ff       	call   800f7c <memmove>
		*addrlen = ret->ret_addrlen;
  802573:	a1 10 70 80 00       	mov    0x807010,%eax
  802578:	89 06                	mov    %eax,(%esi)
  80257a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80257d:	89 d8                	mov    %ebx,%eax
  80257f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802582:	5b                   	pop    %ebx
  802583:	5e                   	pop    %esi
  802584:	5d                   	pop    %ebp
  802585:	c3                   	ret    

00802586 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	53                   	push   %ebx
  80258a:	83 ec 08             	sub    $0x8,%esp
  80258d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802590:	8b 45 08             	mov    0x8(%ebp),%eax
  802593:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802598:	53                   	push   %ebx
  802599:	ff 75 0c             	pushl  0xc(%ebp)
  80259c:	68 04 70 80 00       	push   $0x807004
  8025a1:	e8 d6 e9 ff ff       	call   800f7c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8025a6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8025ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8025b1:	e8 36 ff ff ff       	call   8024ec <nsipc>
}
  8025b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025b9:	c9                   	leave  
  8025ba:	c3                   	ret    

008025bb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8025bb:	55                   	push   %ebp
  8025bc:	89 e5                	mov    %esp,%ebp
  8025be:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8025c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8025c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025cc:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8025d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8025d6:	e8 11 ff ff ff       	call   8024ec <nsipc>
}
  8025db:	c9                   	leave  
  8025dc:	c3                   	ret    

008025dd <nsipc_close>:

int
nsipc_close(int s)
{
  8025dd:	55                   	push   %ebp
  8025de:	89 e5                	mov    %esp,%ebp
  8025e0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8025e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e6:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8025eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8025f0:	e8 f7 fe ff ff       	call   8024ec <nsipc>
}
  8025f5:	c9                   	leave  
  8025f6:	c3                   	ret    

008025f7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025f7:	55                   	push   %ebp
  8025f8:	89 e5                	mov    %esp,%ebp
  8025fa:	53                   	push   %ebx
  8025fb:	83 ec 08             	sub    $0x8,%esp
  8025fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802601:	8b 45 08             	mov    0x8(%ebp),%eax
  802604:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802609:	53                   	push   %ebx
  80260a:	ff 75 0c             	pushl  0xc(%ebp)
  80260d:	68 04 70 80 00       	push   $0x807004
  802612:	e8 65 e9 ff ff       	call   800f7c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802617:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80261d:	b8 05 00 00 00       	mov    $0x5,%eax
  802622:	e8 c5 fe ff ff       	call   8024ec <nsipc>
}
  802627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80262a:	c9                   	leave  
  80262b:	c3                   	ret    

0080262c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80262c:	55                   	push   %ebp
  80262d:	89 e5                	mov    %esp,%ebp
  80262f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802632:	8b 45 08             	mov    0x8(%ebp),%eax
  802635:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80263a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80263d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802642:	b8 06 00 00 00       	mov    $0x6,%eax
  802647:	e8 a0 fe ff ff       	call   8024ec <nsipc>
}
  80264c:	c9                   	leave  
  80264d:	c3                   	ret    

0080264e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80264e:	55                   	push   %ebp
  80264f:	89 e5                	mov    %esp,%ebp
  802651:	56                   	push   %esi
  802652:	53                   	push   %ebx
  802653:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802656:	8b 45 08             	mov    0x8(%ebp),%eax
  802659:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80265e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802664:	8b 45 14             	mov    0x14(%ebp),%eax
  802667:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80266c:	b8 07 00 00 00       	mov    $0x7,%eax
  802671:	e8 76 fe ff ff       	call   8024ec <nsipc>
  802676:	89 c3                	mov    %eax,%ebx
  802678:	85 c0                	test   %eax,%eax
  80267a:	78 35                	js     8026b1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80267c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802681:	7f 04                	jg     802687 <nsipc_recv+0x39>
  802683:	39 c6                	cmp    %eax,%esi
  802685:	7d 16                	jge    80269d <nsipc_recv+0x4f>
  802687:	68 6a 32 80 00       	push   $0x80326a
  80268c:	68 13 32 80 00       	push   $0x803213
  802691:	6a 62                	push   $0x62
  802693:	68 7f 32 80 00       	push   $0x80327f
  802698:	e8 ef e0 ff ff       	call   80078c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80269d:	83 ec 04             	sub    $0x4,%esp
  8026a0:	50                   	push   %eax
  8026a1:	68 00 70 80 00       	push   $0x807000
  8026a6:	ff 75 0c             	pushl  0xc(%ebp)
  8026a9:	e8 ce e8 ff ff       	call   800f7c <memmove>
  8026ae:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8026b1:	89 d8                	mov    %ebx,%eax
  8026b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026b6:	5b                   	pop    %ebx
  8026b7:	5e                   	pop    %esi
  8026b8:	5d                   	pop    %ebp
  8026b9:	c3                   	ret    

008026ba <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8026ba:	55                   	push   %ebp
  8026bb:	89 e5                	mov    %esp,%ebp
  8026bd:	53                   	push   %ebx
  8026be:	83 ec 04             	sub    $0x4,%esp
  8026c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8026c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c7:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8026cc:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8026d2:	7e 16                	jle    8026ea <nsipc_send+0x30>
  8026d4:	68 8b 32 80 00       	push   $0x80328b
  8026d9:	68 13 32 80 00       	push   $0x803213
  8026de:	6a 6d                	push   $0x6d
  8026e0:	68 7f 32 80 00       	push   $0x80327f
  8026e5:	e8 a2 e0 ff ff       	call   80078c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8026ea:	83 ec 04             	sub    $0x4,%esp
  8026ed:	53                   	push   %ebx
  8026ee:	ff 75 0c             	pushl  0xc(%ebp)
  8026f1:	68 0c 70 80 00       	push   $0x80700c
  8026f6:	e8 81 e8 ff ff       	call   800f7c <memmove>
	nsipcbuf.send.req_size = size;
  8026fb:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802701:	8b 45 14             	mov    0x14(%ebp),%eax
  802704:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802709:	b8 08 00 00 00       	mov    $0x8,%eax
  80270e:	e8 d9 fd ff ff       	call   8024ec <nsipc>
}
  802713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802716:	c9                   	leave  
  802717:	c3                   	ret    

00802718 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802718:	55                   	push   %ebp
  802719:	89 e5                	mov    %esp,%ebp
  80271b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80271e:	8b 45 08             	mov    0x8(%ebp),%eax
  802721:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802726:	8b 45 0c             	mov    0xc(%ebp),%eax
  802729:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80272e:	8b 45 10             	mov    0x10(%ebp),%eax
  802731:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802736:	b8 09 00 00 00       	mov    $0x9,%eax
  80273b:	e8 ac fd ff ff       	call   8024ec <nsipc>
}
  802740:	c9                   	leave  
  802741:	c3                   	ret    

00802742 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802742:	55                   	push   %ebp
  802743:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802745:	b8 00 00 00 00       	mov    $0x0,%eax
  80274a:	5d                   	pop    %ebp
  80274b:	c3                   	ret    

0080274c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80274c:	55                   	push   %ebp
  80274d:	89 e5                	mov    %esp,%ebp
  80274f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802752:	68 97 32 80 00       	push   $0x803297
  802757:	ff 75 0c             	pushl  0xc(%ebp)
  80275a:	e8 8b e6 ff ff       	call   800dea <strcpy>
	return 0;
}
  80275f:	b8 00 00 00 00       	mov    $0x0,%eax
  802764:	c9                   	leave  
  802765:	c3                   	ret    

00802766 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802766:	55                   	push   %ebp
  802767:	89 e5                	mov    %esp,%ebp
  802769:	57                   	push   %edi
  80276a:	56                   	push   %esi
  80276b:	53                   	push   %ebx
  80276c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802772:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802777:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80277d:	eb 2d                	jmp    8027ac <devcons_write+0x46>
		m = n - tot;
  80277f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802782:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802784:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802787:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80278c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80278f:	83 ec 04             	sub    $0x4,%esp
  802792:	53                   	push   %ebx
  802793:	03 45 0c             	add    0xc(%ebp),%eax
  802796:	50                   	push   %eax
  802797:	57                   	push   %edi
  802798:	e8 df e7 ff ff       	call   800f7c <memmove>
		sys_cputs(buf, m);
  80279d:	83 c4 08             	add    $0x8,%esp
  8027a0:	53                   	push   %ebx
  8027a1:	57                   	push   %edi
  8027a2:	e8 8a e9 ff ff       	call   801131 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027a7:	01 de                	add    %ebx,%esi
  8027a9:	83 c4 10             	add    $0x10,%esp
  8027ac:	89 f0                	mov    %esi,%eax
  8027ae:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027b1:	72 cc                	jb     80277f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b6:	5b                   	pop    %ebx
  8027b7:	5e                   	pop    %esi
  8027b8:	5f                   	pop    %edi
  8027b9:	5d                   	pop    %ebp
  8027ba:	c3                   	ret    

008027bb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027bb:	55                   	push   %ebp
  8027bc:	89 e5                	mov    %esp,%ebp
  8027be:	83 ec 08             	sub    $0x8,%esp
  8027c1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8027c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027ca:	74 2a                	je     8027f6 <devcons_read+0x3b>
  8027cc:	eb 05                	jmp    8027d3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027ce:	e8 fb e9 ff ff       	call   8011ce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027d3:	e8 77 e9 ff ff       	call   80114f <sys_cgetc>
  8027d8:	85 c0                	test   %eax,%eax
  8027da:	74 f2                	je     8027ce <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8027dc:	85 c0                	test   %eax,%eax
  8027de:	78 16                	js     8027f6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027e0:	83 f8 04             	cmp    $0x4,%eax
  8027e3:	74 0c                	je     8027f1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8027e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027e8:	88 02                	mov    %al,(%edx)
	return 1;
  8027ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ef:	eb 05                	jmp    8027f6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8027f1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8027f6:	c9                   	leave  
  8027f7:	c3                   	ret    

008027f8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8027f8:	55                   	push   %ebp
  8027f9:	89 e5                	mov    %esp,%ebp
  8027fb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8027fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802801:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802804:	6a 01                	push   $0x1
  802806:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802809:	50                   	push   %eax
  80280a:	e8 22 e9 ff ff       	call   801131 <sys_cputs>
}
  80280f:	83 c4 10             	add    $0x10,%esp
  802812:	c9                   	leave  
  802813:	c3                   	ret    

00802814 <getchar>:

int
getchar(void)
{
  802814:	55                   	push   %ebp
  802815:	89 e5                	mov    %esp,%ebp
  802817:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80281a:	6a 01                	push   $0x1
  80281c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80281f:	50                   	push   %eax
  802820:	6a 00                	push   $0x0
  802822:	e8 36 f2 ff ff       	call   801a5d <read>
	if (r < 0)
  802827:	83 c4 10             	add    $0x10,%esp
  80282a:	85 c0                	test   %eax,%eax
  80282c:	78 0f                	js     80283d <getchar+0x29>
		return r;
	if (r < 1)
  80282e:	85 c0                	test   %eax,%eax
  802830:	7e 06                	jle    802838 <getchar+0x24>
		return -E_EOF;
	return c;
  802832:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802836:	eb 05                	jmp    80283d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802838:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80283d:	c9                   	leave  
  80283e:	c3                   	ret    

0080283f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80283f:	55                   	push   %ebp
  802840:	89 e5                	mov    %esp,%ebp
  802842:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802848:	50                   	push   %eax
  802849:	ff 75 08             	pushl  0x8(%ebp)
  80284c:	e8 a6 ef ff ff       	call   8017f7 <fd_lookup>
  802851:	83 c4 10             	add    $0x10,%esp
  802854:	85 c0                	test   %eax,%eax
  802856:	78 11                	js     802869 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80285b:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802861:	39 10                	cmp    %edx,(%eax)
  802863:	0f 94 c0             	sete   %al
  802866:	0f b6 c0             	movzbl %al,%eax
}
  802869:	c9                   	leave  
  80286a:	c3                   	ret    

0080286b <opencons>:

int
opencons(void)
{
  80286b:	55                   	push   %ebp
  80286c:	89 e5                	mov    %esp,%ebp
  80286e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802874:	50                   	push   %eax
  802875:	e8 2e ef ff ff       	call   8017a8 <fd_alloc>
  80287a:	83 c4 10             	add    $0x10,%esp
		return r;
  80287d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80287f:	85 c0                	test   %eax,%eax
  802881:	78 3e                	js     8028c1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802883:	83 ec 04             	sub    $0x4,%esp
  802886:	68 07 04 00 00       	push   $0x407
  80288b:	ff 75 f4             	pushl  -0xc(%ebp)
  80288e:	6a 00                	push   $0x0
  802890:	e8 58 e9 ff ff       	call   8011ed <sys_page_alloc>
  802895:	83 c4 10             	add    $0x10,%esp
		return r;
  802898:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80289a:	85 c0                	test   %eax,%eax
  80289c:	78 23                	js     8028c1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80289e:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ac:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028b3:	83 ec 0c             	sub    $0xc,%esp
  8028b6:	50                   	push   %eax
  8028b7:	e8 c5 ee ff ff       	call   801781 <fd2num>
  8028bc:	89 c2                	mov    %eax,%edx
  8028be:	83 c4 10             	add    $0x10,%esp
}
  8028c1:	89 d0                	mov    %edx,%eax
  8028c3:	c9                   	leave  
  8028c4:	c3                   	ret    

008028c5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028c5:	55                   	push   %ebp
  8028c6:	89 e5                	mov    %esp,%ebp
  8028c8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028cb:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8028d2:	75 2e                	jne    802902 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8028d4:	e8 d6 e8 ff ff       	call   8011af <sys_getenvid>
  8028d9:	83 ec 04             	sub    $0x4,%esp
  8028dc:	68 07 0e 00 00       	push   $0xe07
  8028e1:	68 00 f0 bf ee       	push   $0xeebff000
  8028e6:	50                   	push   %eax
  8028e7:	e8 01 e9 ff ff       	call   8011ed <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8028ec:	e8 be e8 ff ff       	call   8011af <sys_getenvid>
  8028f1:	83 c4 08             	add    $0x8,%esp
  8028f4:	68 0c 29 80 00       	push   $0x80290c
  8028f9:	50                   	push   %eax
  8028fa:	e8 39 ea ff ff       	call   801338 <sys_env_set_pgfault_upcall>
  8028ff:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802902:	8b 45 08             	mov    0x8(%ebp),%eax
  802905:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80290a:	c9                   	leave  
  80290b:	c3                   	ret    

0080290c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80290c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80290d:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802912:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802914:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802917:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80291b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80291f:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802922:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802925:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802926:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802929:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80292a:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80292b:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80292f:	c3                   	ret    

00802930 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
  802933:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802936:	89 d0                	mov    %edx,%eax
  802938:	c1 e8 16             	shr    $0x16,%eax
  80293b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802942:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802947:	f6 c1 01             	test   $0x1,%cl
  80294a:	74 1d                	je     802969 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80294c:	c1 ea 0c             	shr    $0xc,%edx
  80294f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802956:	f6 c2 01             	test   $0x1,%dl
  802959:	74 0e                	je     802969 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80295b:	c1 ea 0c             	shr    $0xc,%edx
  80295e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802965:	ef 
  802966:	0f b7 c0             	movzwl %ax,%eax
}
  802969:	5d                   	pop    %ebp
  80296a:	c3                   	ret    
  80296b:	66 90                	xchg   %ax,%ax
  80296d:	66 90                	xchg   %ax,%ax
  80296f:	90                   	nop

00802970 <__udivdi3>:
  802970:	55                   	push   %ebp
  802971:	57                   	push   %edi
  802972:	56                   	push   %esi
  802973:	53                   	push   %ebx
  802974:	83 ec 1c             	sub    $0x1c,%esp
  802977:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80297b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80297f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802983:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802987:	85 f6                	test   %esi,%esi
  802989:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80298d:	89 ca                	mov    %ecx,%edx
  80298f:	89 f8                	mov    %edi,%eax
  802991:	75 3d                	jne    8029d0 <__udivdi3+0x60>
  802993:	39 cf                	cmp    %ecx,%edi
  802995:	0f 87 c5 00 00 00    	ja     802a60 <__udivdi3+0xf0>
  80299b:	85 ff                	test   %edi,%edi
  80299d:	89 fd                	mov    %edi,%ebp
  80299f:	75 0b                	jne    8029ac <__udivdi3+0x3c>
  8029a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8029a6:	31 d2                	xor    %edx,%edx
  8029a8:	f7 f7                	div    %edi
  8029aa:	89 c5                	mov    %eax,%ebp
  8029ac:	89 c8                	mov    %ecx,%eax
  8029ae:	31 d2                	xor    %edx,%edx
  8029b0:	f7 f5                	div    %ebp
  8029b2:	89 c1                	mov    %eax,%ecx
  8029b4:	89 d8                	mov    %ebx,%eax
  8029b6:	89 cf                	mov    %ecx,%edi
  8029b8:	f7 f5                	div    %ebp
  8029ba:	89 c3                	mov    %eax,%ebx
  8029bc:	89 d8                	mov    %ebx,%eax
  8029be:	89 fa                	mov    %edi,%edx
  8029c0:	83 c4 1c             	add    $0x1c,%esp
  8029c3:	5b                   	pop    %ebx
  8029c4:	5e                   	pop    %esi
  8029c5:	5f                   	pop    %edi
  8029c6:	5d                   	pop    %ebp
  8029c7:	c3                   	ret    
  8029c8:	90                   	nop
  8029c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029d0:	39 ce                	cmp    %ecx,%esi
  8029d2:	77 74                	ja     802a48 <__udivdi3+0xd8>
  8029d4:	0f bd fe             	bsr    %esi,%edi
  8029d7:	83 f7 1f             	xor    $0x1f,%edi
  8029da:	0f 84 98 00 00 00    	je     802a78 <__udivdi3+0x108>
  8029e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8029e5:	89 f9                	mov    %edi,%ecx
  8029e7:	89 c5                	mov    %eax,%ebp
  8029e9:	29 fb                	sub    %edi,%ebx
  8029eb:	d3 e6                	shl    %cl,%esi
  8029ed:	89 d9                	mov    %ebx,%ecx
  8029ef:	d3 ed                	shr    %cl,%ebp
  8029f1:	89 f9                	mov    %edi,%ecx
  8029f3:	d3 e0                	shl    %cl,%eax
  8029f5:	09 ee                	or     %ebp,%esi
  8029f7:	89 d9                	mov    %ebx,%ecx
  8029f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029fd:	89 d5                	mov    %edx,%ebp
  8029ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a03:	d3 ed                	shr    %cl,%ebp
  802a05:	89 f9                	mov    %edi,%ecx
  802a07:	d3 e2                	shl    %cl,%edx
  802a09:	89 d9                	mov    %ebx,%ecx
  802a0b:	d3 e8                	shr    %cl,%eax
  802a0d:	09 c2                	or     %eax,%edx
  802a0f:	89 d0                	mov    %edx,%eax
  802a11:	89 ea                	mov    %ebp,%edx
  802a13:	f7 f6                	div    %esi
  802a15:	89 d5                	mov    %edx,%ebp
  802a17:	89 c3                	mov    %eax,%ebx
  802a19:	f7 64 24 0c          	mull   0xc(%esp)
  802a1d:	39 d5                	cmp    %edx,%ebp
  802a1f:	72 10                	jb     802a31 <__udivdi3+0xc1>
  802a21:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a25:	89 f9                	mov    %edi,%ecx
  802a27:	d3 e6                	shl    %cl,%esi
  802a29:	39 c6                	cmp    %eax,%esi
  802a2b:	73 07                	jae    802a34 <__udivdi3+0xc4>
  802a2d:	39 d5                	cmp    %edx,%ebp
  802a2f:	75 03                	jne    802a34 <__udivdi3+0xc4>
  802a31:	83 eb 01             	sub    $0x1,%ebx
  802a34:	31 ff                	xor    %edi,%edi
  802a36:	89 d8                	mov    %ebx,%eax
  802a38:	89 fa                	mov    %edi,%edx
  802a3a:	83 c4 1c             	add    $0x1c,%esp
  802a3d:	5b                   	pop    %ebx
  802a3e:	5e                   	pop    %esi
  802a3f:	5f                   	pop    %edi
  802a40:	5d                   	pop    %ebp
  802a41:	c3                   	ret    
  802a42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a48:	31 ff                	xor    %edi,%edi
  802a4a:	31 db                	xor    %ebx,%ebx
  802a4c:	89 d8                	mov    %ebx,%eax
  802a4e:	89 fa                	mov    %edi,%edx
  802a50:	83 c4 1c             	add    $0x1c,%esp
  802a53:	5b                   	pop    %ebx
  802a54:	5e                   	pop    %esi
  802a55:	5f                   	pop    %edi
  802a56:	5d                   	pop    %ebp
  802a57:	c3                   	ret    
  802a58:	90                   	nop
  802a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a60:	89 d8                	mov    %ebx,%eax
  802a62:	f7 f7                	div    %edi
  802a64:	31 ff                	xor    %edi,%edi
  802a66:	89 c3                	mov    %eax,%ebx
  802a68:	89 d8                	mov    %ebx,%eax
  802a6a:	89 fa                	mov    %edi,%edx
  802a6c:	83 c4 1c             	add    $0x1c,%esp
  802a6f:	5b                   	pop    %ebx
  802a70:	5e                   	pop    %esi
  802a71:	5f                   	pop    %edi
  802a72:	5d                   	pop    %ebp
  802a73:	c3                   	ret    
  802a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a78:	39 ce                	cmp    %ecx,%esi
  802a7a:	72 0c                	jb     802a88 <__udivdi3+0x118>
  802a7c:	31 db                	xor    %ebx,%ebx
  802a7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802a82:	0f 87 34 ff ff ff    	ja     8029bc <__udivdi3+0x4c>
  802a88:	bb 01 00 00 00       	mov    $0x1,%ebx
  802a8d:	e9 2a ff ff ff       	jmp    8029bc <__udivdi3+0x4c>
  802a92:	66 90                	xchg   %ax,%ax
  802a94:	66 90                	xchg   %ax,%ax
  802a96:	66 90                	xchg   %ax,%ax
  802a98:	66 90                	xchg   %ax,%ax
  802a9a:	66 90                	xchg   %ax,%ax
  802a9c:	66 90                	xchg   %ax,%ax
  802a9e:	66 90                	xchg   %ax,%ax

00802aa0 <__umoddi3>:
  802aa0:	55                   	push   %ebp
  802aa1:	57                   	push   %edi
  802aa2:	56                   	push   %esi
  802aa3:	53                   	push   %ebx
  802aa4:	83 ec 1c             	sub    $0x1c,%esp
  802aa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802aab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802aaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ab3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ab7:	85 d2                	test   %edx,%edx
  802ab9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802abd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ac1:	89 f3                	mov    %esi,%ebx
  802ac3:	89 3c 24             	mov    %edi,(%esp)
  802ac6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802aca:	75 1c                	jne    802ae8 <__umoddi3+0x48>
  802acc:	39 f7                	cmp    %esi,%edi
  802ace:	76 50                	jbe    802b20 <__umoddi3+0x80>
  802ad0:	89 c8                	mov    %ecx,%eax
  802ad2:	89 f2                	mov    %esi,%edx
  802ad4:	f7 f7                	div    %edi
  802ad6:	89 d0                	mov    %edx,%eax
  802ad8:	31 d2                	xor    %edx,%edx
  802ada:	83 c4 1c             	add    $0x1c,%esp
  802add:	5b                   	pop    %ebx
  802ade:	5e                   	pop    %esi
  802adf:	5f                   	pop    %edi
  802ae0:	5d                   	pop    %ebp
  802ae1:	c3                   	ret    
  802ae2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ae8:	39 f2                	cmp    %esi,%edx
  802aea:	89 d0                	mov    %edx,%eax
  802aec:	77 52                	ja     802b40 <__umoddi3+0xa0>
  802aee:	0f bd ea             	bsr    %edx,%ebp
  802af1:	83 f5 1f             	xor    $0x1f,%ebp
  802af4:	75 5a                	jne    802b50 <__umoddi3+0xb0>
  802af6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802afa:	0f 82 e0 00 00 00    	jb     802be0 <__umoddi3+0x140>
  802b00:	39 0c 24             	cmp    %ecx,(%esp)
  802b03:	0f 86 d7 00 00 00    	jbe    802be0 <__umoddi3+0x140>
  802b09:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b11:	83 c4 1c             	add    $0x1c,%esp
  802b14:	5b                   	pop    %ebx
  802b15:	5e                   	pop    %esi
  802b16:	5f                   	pop    %edi
  802b17:	5d                   	pop    %ebp
  802b18:	c3                   	ret    
  802b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b20:	85 ff                	test   %edi,%edi
  802b22:	89 fd                	mov    %edi,%ebp
  802b24:	75 0b                	jne    802b31 <__umoddi3+0x91>
  802b26:	b8 01 00 00 00       	mov    $0x1,%eax
  802b2b:	31 d2                	xor    %edx,%edx
  802b2d:	f7 f7                	div    %edi
  802b2f:	89 c5                	mov    %eax,%ebp
  802b31:	89 f0                	mov    %esi,%eax
  802b33:	31 d2                	xor    %edx,%edx
  802b35:	f7 f5                	div    %ebp
  802b37:	89 c8                	mov    %ecx,%eax
  802b39:	f7 f5                	div    %ebp
  802b3b:	89 d0                	mov    %edx,%eax
  802b3d:	eb 99                	jmp    802ad8 <__umoddi3+0x38>
  802b3f:	90                   	nop
  802b40:	89 c8                	mov    %ecx,%eax
  802b42:	89 f2                	mov    %esi,%edx
  802b44:	83 c4 1c             	add    $0x1c,%esp
  802b47:	5b                   	pop    %ebx
  802b48:	5e                   	pop    %esi
  802b49:	5f                   	pop    %edi
  802b4a:	5d                   	pop    %ebp
  802b4b:	c3                   	ret    
  802b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b50:	8b 34 24             	mov    (%esp),%esi
  802b53:	bf 20 00 00 00       	mov    $0x20,%edi
  802b58:	89 e9                	mov    %ebp,%ecx
  802b5a:	29 ef                	sub    %ebp,%edi
  802b5c:	d3 e0                	shl    %cl,%eax
  802b5e:	89 f9                	mov    %edi,%ecx
  802b60:	89 f2                	mov    %esi,%edx
  802b62:	d3 ea                	shr    %cl,%edx
  802b64:	89 e9                	mov    %ebp,%ecx
  802b66:	09 c2                	or     %eax,%edx
  802b68:	89 d8                	mov    %ebx,%eax
  802b6a:	89 14 24             	mov    %edx,(%esp)
  802b6d:	89 f2                	mov    %esi,%edx
  802b6f:	d3 e2                	shl    %cl,%edx
  802b71:	89 f9                	mov    %edi,%ecx
  802b73:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b7b:	d3 e8                	shr    %cl,%eax
  802b7d:	89 e9                	mov    %ebp,%ecx
  802b7f:	89 c6                	mov    %eax,%esi
  802b81:	d3 e3                	shl    %cl,%ebx
  802b83:	89 f9                	mov    %edi,%ecx
  802b85:	89 d0                	mov    %edx,%eax
  802b87:	d3 e8                	shr    %cl,%eax
  802b89:	89 e9                	mov    %ebp,%ecx
  802b8b:	09 d8                	or     %ebx,%eax
  802b8d:	89 d3                	mov    %edx,%ebx
  802b8f:	89 f2                	mov    %esi,%edx
  802b91:	f7 34 24             	divl   (%esp)
  802b94:	89 d6                	mov    %edx,%esi
  802b96:	d3 e3                	shl    %cl,%ebx
  802b98:	f7 64 24 04          	mull   0x4(%esp)
  802b9c:	39 d6                	cmp    %edx,%esi
  802b9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ba2:	89 d1                	mov    %edx,%ecx
  802ba4:	89 c3                	mov    %eax,%ebx
  802ba6:	72 08                	jb     802bb0 <__umoddi3+0x110>
  802ba8:	75 11                	jne    802bbb <__umoddi3+0x11b>
  802baa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802bae:	73 0b                	jae    802bbb <__umoddi3+0x11b>
  802bb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802bb4:	1b 14 24             	sbb    (%esp),%edx
  802bb7:	89 d1                	mov    %edx,%ecx
  802bb9:	89 c3                	mov    %eax,%ebx
  802bbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802bbf:	29 da                	sub    %ebx,%edx
  802bc1:	19 ce                	sbb    %ecx,%esi
  802bc3:	89 f9                	mov    %edi,%ecx
  802bc5:	89 f0                	mov    %esi,%eax
  802bc7:	d3 e0                	shl    %cl,%eax
  802bc9:	89 e9                	mov    %ebp,%ecx
  802bcb:	d3 ea                	shr    %cl,%edx
  802bcd:	89 e9                	mov    %ebp,%ecx
  802bcf:	d3 ee                	shr    %cl,%esi
  802bd1:	09 d0                	or     %edx,%eax
  802bd3:	89 f2                	mov    %esi,%edx
  802bd5:	83 c4 1c             	add    $0x1c,%esp
  802bd8:	5b                   	pop    %ebx
  802bd9:	5e                   	pop    %esi
  802bda:	5f                   	pop    %edi
  802bdb:	5d                   	pop    %ebp
  802bdc:	c3                   	ret    
  802bdd:	8d 76 00             	lea    0x0(%esi),%esi
  802be0:	29 f9                	sub    %edi,%ecx
  802be2:	19 d6                	sbb    %edx,%esi
  802be4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802be8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bec:	e9 18 ff ff ff       	jmp    802b09 <__umoddi3+0x69>
