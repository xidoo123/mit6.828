
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
  80002c:	e8 fc 07 00 00       	call   80082d <libmain>
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
  80003c:	e8 6f 12 00 00       	call   8012b0 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 80 	movl   $0x802d80,0x804000
  80004a:	2d 80 00 

	output_envid = fork();
  80004d:	e8 09 16 00 00       	call   80165b <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 8a 2d 80 00       	push   $0x802d8a
  800063:	6a 4d                	push   $0x4d
  800065:	68 98 2d 80 00       	push   $0x802d98
  80006a:	e8 1e 08 00 00       	call   80088d <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 7b 04 00 00       	call   8004f7 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 d2 15 00 00       	call   80165b <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 8a 2d 80 00       	push   $0x802d8a
  80009a:	6a 55                	push   $0x55
  80009c:	68 98 2d 80 00       	push   $0x802d98
  8000a1:	e8 e7 07 00 00       	call   80088d <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 d3 03 00 00       	call   800486 <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 a8 2d 80 00       	push   $0x802da8
  8000c3:	e8 9e 08 00 00       	call   800966 <cprintf>
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
  8000e0:	c7 04 24 c5 2d 80 00 	movl   $0x802dc5,(%esp)
  8000e7:	e8 0f 07 00 00       	call   8007fb <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 cf 2d 80 00 	movl   $0x802dcf,(%esp)
  8000f6:	e8 00 07 00 00       	call   8007fb <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 df 11 00 00       	call   8012ee <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 d8 2d 80 00       	push   $0x802dd8
  80011c:	6a 19                	push   $0x19
  80011e:	68 98 2d 80 00       	push   $0x802d98
  800123:	e8 65 07 00 00       	call   80088d <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 ea 0e 00 00       	call   801030 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 8c 0f 00 00       	call   8010e5 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 7d 04 00 00       	call   8005e2 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 6b 04 00 00       	call   8005e2 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 59 04 00 00       	call   8005e2 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 47 04 00 00       	call   8005e2 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 35 04 00 00       	call   8005e2 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 22 0f 00 00       	call   8010e5 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 0f 0f 00 00       	call   8010e5 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 49 0e 00 00       	call   801030 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 eb 0e 00 00       	call   8010e5 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 6b 16 00 00       	call   801879 <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 56 11 00 00       	call   801373 <sys_page_unmap>
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
  80023a:	e8 d3 15 00 00       	call   801812 <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 e9 2d 80 00       	push   $0x802de9
  80024c:	6a 64                	push   $0x64
  80024e:	68 98 2d 80 00       	push   $0x802d98
  800253:	e8 35 06 00 00       	call   80088d <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 40 2e 80 00       	push   $0x802e40
  800269:	6a 66                	push   $0x66
  80026b:	68 98 2d 80 00       	push   $0x802d98
  800270:	e8 18 06 00 00       	call   80088d <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 f6 2d 80 00       	push   $0x802df6
  800280:	6a 68                	push   $0x68
  800282:	68 98 2d 80 00       	push   $0x802d98
  800287:	e8 01 06 00 00       	call   80088d <_panic>

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
  8002b4:	68 08 2e 80 00       	push   $0x802e08
  8002b9:	68 10 2e 80 00       	push   $0x802e10
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 cf 0b 00 00       	call   800e98 <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 1a 2e 80 00       	push   $0x802e1a
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 ab 0b 00 00       	call   800e98 <snprintf>
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
  80031b:	68 1f 2e 80 00       	push   $0x802e1f
  800320:	e8 41 06 00 00       	call   800966 <cprintf>
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
  80035a:	68 3b 2e 80 00       	push   $0x802e3b
  80035f:	e8 02 06 00 00       	call   800966 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 25 2e 80 00       	push   $0x802e25
  800378:	e8 e9 05 00 00       	call   800966 <cprintf>
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
  8003a3:	e8 37 11 00 00       	call   8014df <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 65 	movl   $0x802e65,0x804000
  8003b4:	2e 80 00 

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
  8003bc:	e8 0e 0f 00 00       	call   8012cf <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 19 11 00 00       	call   8014df <sys_time_msec>
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
  8003d5:	68 6e 2e 80 00       	push   $0x802e6e
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 80 2e 80 00       	push   $0x802e80
  8003e1:	e8 a7 04 00 00       	call   80088d <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 87 14 00 00       	call   801879 <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 10 14 00 00       	call   801812 <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 8c 2e 80 00       	push   $0x802e8c
  800417:	e8 4a 05 00 00       	call   800966 <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 b9 10 00 00       	call   8014df <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <sleep>:
extern union Nsipc nsipcbuf;


void
sleep(int msec)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	53                   	push   %ebx
  80042e:	83 ec 04             	sub    $0x4,%esp
    unsigned now = sys_time_msec();
  800431:	e8 a9 10 00 00       	call   8014df <sys_time_msec>
    unsigned end = now + msec;
  800436:	89 c3                	mov    %eax,%ebx
  800438:	03 5d 08             	add    0x8(%ebp),%ebx

    if ((int)now < 0 && (int)now > -MAXERROR)
  80043b:	89 c2                	mov    %eax,%edx
  80043d:	c1 ea 1f             	shr    $0x1f,%edx
  800440:	84 d2                	test   %dl,%dl
  800442:	74 17                	je     80045b <sleep+0x31>
  800444:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800447:	7c 12                	jl     80045b <sleep+0x31>
        panic("sys_time_msec: %e", (int)now);
  800449:	50                   	push   %eax
  80044a:	68 6e 2e 80 00       	push   $0x802e6e
  80044f:	6a 0d                	push   $0xd
  800451:	68 c7 2e 80 00       	push   $0x802ec7
  800456:	e8 32 04 00 00       	call   80088d <_panic>
    if (end < now)
  80045b:	39 d8                	cmp    %ebx,%eax
  80045d:	76 19                	jbe    800478 <sleep+0x4e>
        panic("sleep: wrap");
  80045f:	83 ec 04             	sub    $0x4,%esp
  800462:	68 d3 2e 80 00       	push   $0x802ed3
  800467:	6a 0f                	push   $0xf
  800469:	68 c7 2e 80 00       	push   $0x802ec7
  80046e:	e8 1a 04 00 00       	call   80088d <_panic>

    while (sys_time_msec() < end)
        sys_yield();
  800473:	e8 57 0e 00 00       	call   8012cf <sys_yield>
    if ((int)now < 0 && (int)now > -MAXERROR)
        panic("sys_time_msec: %e", (int)now);
    if (end < now)
        panic("sleep: wrap");

    while (sys_time_msec() < end)
  800478:	e8 62 10 00 00       	call   8014df <sys_time_msec>
  80047d:	39 c3                	cmp    %eax,%ebx
  80047f:	77 f2                	ja     800473 <sleep+0x49>
        sys_yield();
}
  800481:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <input>:

void
input(envid_t ns_envid)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	57                   	push   %edi
  80048a:	56                   	push   %esi
  80048b:	53                   	push   %ebx
  80048c:	81 ec 0c 06 00 00    	sub    $0x60c,%esp
  800492:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800495:	c7 05 00 40 80 00 df 	movl   $0x802edf,0x804000
  80049c:	2e 80 00 
	size_t len;
    char rev_buf[1520];
    size_t i = 0;
    while(1) {

        while (sys_e1000_try_recv(rev_buf, &len) < 0) {
  80049f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8004a2:	8d 9d f4 f9 ff ff    	lea    -0x60c(%ebp),%ebx
  8004a8:	eb 05                	jmp    8004af <input+0x29>
            sys_yield();    
  8004aa:	e8 20 0e 00 00       	call   8012cf <sys_yield>
	size_t len;
    char rev_buf[1520];
    size_t i = 0;
    while(1) {

        while (sys_e1000_try_recv(rev_buf, &len) < 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	53                   	push   %ebx
  8004b4:	e8 87 10 00 00       	call   801540 <sys_e1000_try_recv>
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	78 ea                	js     8004aa <input+0x24>
            sys_yield();    
        }

        memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
  8004c0:	83 ec 04             	sub    $0x4,%esp
  8004c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c6:	53                   	push   %ebx
  8004c7:	68 04 70 80 00       	push   $0x807004
  8004cc:	e8 14 0c 00 00       	call   8010e5 <memcpy>
        nsipcbuf.pkt.jp_len = len;
  8004d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d4:	a3 00 70 80 00       	mov    %eax,0x807000
        
        ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
  8004d9:	6a 05                	push   $0x5
  8004db:	68 00 70 80 00       	push   $0x807000
  8004e0:	6a 0a                	push   $0xa
  8004e2:	57                   	push   %edi
  8004e3:	e8 91 13 00 00       	call   801879 <ipc_send>
        sleep(50);
  8004e8:	83 c4 14             	add    $0x14,%esp
  8004eb:	6a 32                	push   $0x32
  8004ed:	e8 38 ff ff ff       	call   80042a <sleep>
    }
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	eb b8                	jmp    8004af <input+0x29>

008004f7 <output>:



void
output(envid_t ns_envid)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	56                   	push   %esi
  8004fb:	53                   	push   %ebx
  8004fc:	83 ec 10             	sub    $0x10,%esp
	binaryname = "ns_output";
  8004ff:	c7 05 00 40 80 00 e8 	movl   $0x802ee8,0x804000
  800506:	2e 80 00 
	uint32_t whom;
    int perm;
    int32_t req;

    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
  800509:	8d 75 f0             	lea    -0x10(%ebp),%esi
  80050c:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  80050f:	83 ec 04             	sub    $0x4,%esp
  800512:	56                   	push   %esi
  800513:	68 00 70 80 00       	push   $0x807000
  800518:	53                   	push   %ebx
  800519:	e8 f4 12 00 00       	call   801812 <ipc_recv>
        if (req != NSREQ_OUTPUT) {
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	83 f8 0b             	cmp    $0xb,%eax
  800524:	75 e9                	jne    80050f <output+0x18>
  800526:	eb 05                	jmp    80052d <output+0x36>
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
            sys_yield();
  800528:	e8 a2 0d 00 00       	call   8012cf <sys_yield>
    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
        if (req != NSREQ_OUTPUT) {
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 35 00 70 80 00    	pushl  0x807000
  800536:	68 04 70 80 00       	push   $0x807004
  80053b:	e8 be 0f 00 00       	call   8014fe <sys_e1000_try_send>
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	85 c0                	test   %eax,%eax
  800545:	78 e1                	js     800528 <output+0x31>
  800547:	eb c6                	jmp    80050f <output+0x18>

00800549 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	57                   	push   %edi
  80054d:	56                   	push   %esi
  80054e:	53                   	push   %ebx
  80054f:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800552:	8b 45 08             	mov    0x8(%ebp),%eax
  800555:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800558:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80055b:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  800562:	0f b6 0f             	movzbl (%edi),%ecx
  800565:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80056a:	0f b6 d9             	movzbl %cl,%ebx
  80056d:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800570:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800573:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800576:	66 c1 e8 0b          	shr    $0xb,%ax
  80057a:	89 c3                	mov    %eax,%ebx
  80057c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057f:	01 c0                	add    %eax,%eax
  800581:	29 c1                	sub    %eax,%ecx
  800583:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800585:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800587:	8d 72 01             	lea    0x1(%edx),%esi
  80058a:	0f b6 d2             	movzbl %dl,%edx
  80058d:	83 c0 30             	add    $0x30,%eax
  800590:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800594:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800596:	84 db                	test   %bl,%bl
  800598:	75 d0                	jne    80056a <inet_ntoa+0x21>
  80059a:	c6 07 00             	movb   $0x0,(%edi)
  80059d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a0:	eb 0d                	jmp    8005af <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8005a2:	0f b6 c2             	movzbl %dl,%eax
  8005a5:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8005aa:	88 01                	mov    %al,(%ecx)
  8005ac:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8005af:	83 ea 01             	sub    $0x1,%edx
  8005b2:	80 fa ff             	cmp    $0xff,%dl
  8005b5:	75 eb                	jne    8005a2 <inet_ntoa+0x59>
  8005b7:	89 f0                	mov    %esi,%eax
  8005b9:	0f b6 f0             	movzbl %al,%esi
  8005bc:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8005bf:	8d 46 01             	lea    0x1(%esi),%eax
  8005c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c5:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8005c8:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8005cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005ce:	39 c7                	cmp    %eax,%edi
  8005d0:	75 90                	jne    800562 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8005d2:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8005d5:	b8 08 50 80 00       	mov    $0x805008,%eax
  8005da:	83 c4 14             	add    $0x14,%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5f                   	pop    %edi
  8005e0:	5d                   	pop    %ebp
  8005e1:	c3                   	ret    

008005e2 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005e5:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005e9:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    

008005ef <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8005f2:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005f6:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800602:	89 d1                	mov    %edx,%ecx
  800604:	c1 e1 18             	shl    $0x18,%ecx
  800607:	89 d0                	mov    %edx,%eax
  800609:	c1 e8 18             	shr    $0x18,%eax
  80060c:	09 c8                	or     %ecx,%eax
  80060e:	89 d1                	mov    %edx,%ecx
  800610:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800616:	c1 e1 08             	shl    $0x8,%ecx
  800619:	09 c8                	or     %ecx,%eax
  80061b:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800621:	c1 ea 08             	shr    $0x8,%edx
  800624:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	57                   	push   %edi
  80062c:	56                   	push   %esi
  80062d:	53                   	push   %ebx
  80062e:	83 ec 20             	sub    $0x20,%esp
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800634:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800637:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  80063a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80063d:	0f b6 ca             	movzbl %dl,%ecx
  800640:	83 e9 30             	sub    $0x30,%ecx
  800643:	83 f9 09             	cmp    $0x9,%ecx
  800646:	0f 87 94 01 00 00    	ja     8007e0 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80064c:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800653:	83 fa 30             	cmp    $0x30,%edx
  800656:	75 2b                	jne    800683 <inet_aton+0x5b>
      c = *++cp;
  800658:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80065c:	89 d1                	mov    %edx,%ecx
  80065e:	83 e1 df             	and    $0xffffffdf,%ecx
  800661:	80 f9 58             	cmp    $0x58,%cl
  800664:	74 0f                	je     800675 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800666:	83 c0 01             	add    $0x1,%eax
  800669:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80066c:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800673:	eb 0e                	jmp    800683 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800675:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800679:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80067c:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800683:	83 c0 01             	add    $0x1,%eax
  800686:	be 00 00 00 00       	mov    $0x0,%esi
  80068b:	eb 03                	jmp    800690 <inet_aton+0x68>
  80068d:	83 c0 01             	add    $0x1,%eax
  800690:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800693:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800696:	0f b6 fa             	movzbl %dl,%edi
  800699:	8d 4f d0             	lea    -0x30(%edi),%ecx
  80069c:	83 f9 09             	cmp    $0x9,%ecx
  80069f:	77 0d                	ja     8006ae <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8006a1:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8006a5:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8006a9:	0f be 10             	movsbl (%eax),%edx
  8006ac:	eb df                	jmp    80068d <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8006ae:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8006b2:	75 32                	jne    8006e6 <inet_aton+0xbe>
  8006b4:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8006b7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006bd:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8006c3:	83 e9 41             	sub    $0x41,%ecx
  8006c6:	83 f9 05             	cmp    $0x5,%ecx
  8006c9:	77 1b                	ja     8006e6 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8006cb:	c1 e6 04             	shl    $0x4,%esi
  8006ce:	83 c2 0a             	add    $0xa,%edx
  8006d1:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8006d5:	19 c9                	sbb    %ecx,%ecx
  8006d7:	83 e1 20             	and    $0x20,%ecx
  8006da:	83 c1 41             	add    $0x41,%ecx
  8006dd:	29 ca                	sub    %ecx,%edx
  8006df:	09 d6                	or     %edx,%esi
        c = *++cp;
  8006e1:	0f be 10             	movsbl (%eax),%edx
  8006e4:	eb a7                	jmp    80068d <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8006e6:	83 fa 2e             	cmp    $0x2e,%edx
  8006e9:	75 23                	jne    80070e <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8006eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ee:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8006f1:	39 f8                	cmp    %edi,%eax
  8006f3:	0f 84 ee 00 00 00    	je     8007e7 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8006f9:	83 c0 04             	add    $0x4,%eax
  8006fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006ff:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800702:	8d 43 01             	lea    0x1(%ebx),%eax
  800705:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800709:	e9 2f ff ff ff       	jmp    80063d <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80070e:	85 d2                	test   %edx,%edx
  800710:	74 25                	je     800737 <inet_aton+0x10f>
  800712:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800715:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80071a:	83 f9 5f             	cmp    $0x5f,%ecx
  80071d:	0f 87 d0 00 00 00    	ja     8007f3 <inet_aton+0x1cb>
  800723:	83 fa 20             	cmp    $0x20,%edx
  800726:	74 0f                	je     800737 <inet_aton+0x10f>
  800728:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80072b:	83 ea 09             	sub    $0x9,%edx
  80072e:	83 fa 04             	cmp    $0x4,%edx
  800731:	0f 87 bc 00 00 00    	ja     8007f3 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800737:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80073a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80073d:	29 c2                	sub    %eax,%edx
  80073f:	c1 fa 02             	sar    $0x2,%edx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	83 fa 02             	cmp    $0x2,%edx
  800748:	74 20                	je     80076a <inet_aton+0x142>
  80074a:	83 fa 02             	cmp    $0x2,%edx
  80074d:	7f 0f                	jg     80075e <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800754:	85 d2                	test   %edx,%edx
  800756:	0f 84 97 00 00 00    	je     8007f3 <inet_aton+0x1cb>
  80075c:	eb 67                	jmp    8007c5 <inet_aton+0x19d>
  80075e:	83 fa 03             	cmp    $0x3,%edx
  800761:	74 1e                	je     800781 <inet_aton+0x159>
  800763:	83 fa 04             	cmp    $0x4,%edx
  800766:	74 38                	je     8007a0 <inet_aton+0x178>
  800768:	eb 5b                	jmp    8007c5 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80076f:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  800775:	77 7c                	ja     8007f3 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  800777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80077a:	c1 e0 18             	shl    $0x18,%eax
  80077d:	09 c6                	or     %eax,%esi
    break;
  80077f:	eb 44                	jmp    8007c5 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800786:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  80078c:	77 65                	ja     8007f3 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80078e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800791:	c1 e2 18             	shl    $0x18,%edx
  800794:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800797:	c1 e0 10             	shl    $0x10,%eax
  80079a:	09 d0                	or     %edx,%eax
  80079c:	09 c6                	or     %eax,%esi
    break;
  80079e:	eb 25                	jmp    8007c5 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8007a5:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8007ab:	77 46                	ja     8007f3 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8007ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b0:	c1 e2 18             	shl    $0x18,%edx
  8007b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007b6:	c1 e0 10             	shl    $0x10,%eax
  8007b9:	09 c2                	or     %eax,%edx
  8007bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007be:	c1 e0 08             	shl    $0x8,%eax
  8007c1:	09 d0                	or     %edx,%eax
  8007c3:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8007c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007c9:	74 23                	je     8007ee <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8007cb:	56                   	push   %esi
  8007cc:	e8 2b fe ff ff       	call   8005fc <htonl>
  8007d1:	83 c4 04             	add    $0x4,%esp
  8007d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d7:	89 03                	mov    %eax,(%ebx)
  return (1);
  8007d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8007de:	eb 13                	jmp    8007f3 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 0c                	jmp    8007f3 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 05                	jmp    8007f3 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8007ee:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8007f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5f                   	pop    %edi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800801:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	ff 75 08             	pushl  0x8(%ebp)
  800808:	e8 1b fe ff ff       	call   800628 <inet_aton>
  80080d:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  800810:	85 c0                	test   %eax,%eax
  800812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800817:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  800820:	ff 75 08             	pushl  0x8(%ebp)
  800823:	e8 d4 fd ff ff       	call   8005fc <htonl>
  800828:	83 c4 04             	add    $0x4,%esp
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800835:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800838:	e8 73 0a 00 00       	call   8012b0 <sys_getenvid>
  80083d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800842:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800845:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80084a:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80084f:	85 db                	test   %ebx,%ebx
  800851:	7e 07                	jle    80085a <libmain+0x2d>
		binaryname = argv[0];
  800853:	8b 06                	mov    (%esi),%eax
  800855:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	e8 cf f7 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800864:	e8 0a 00 00 00       	call   800873 <exit>
}
  800869:	83 c4 10             	add    $0x10,%esp
  80086c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800879:	e8 53 12 00 00       	call   801ad1 <close_all>
	sys_env_destroy(0);
  80087e:	83 ec 0c             	sub    $0xc,%esp
  800881:	6a 00                	push   $0x0
  800883:	e8 e7 09 00 00       	call   80126f <sys_env_destroy>
}
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800892:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800895:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80089b:	e8 10 0a 00 00       	call   8012b0 <sys_getenvid>
  8008a0:	83 ec 0c             	sub    $0xc,%esp
  8008a3:	ff 75 0c             	pushl  0xc(%ebp)
  8008a6:	ff 75 08             	pushl  0x8(%ebp)
  8008a9:	56                   	push   %esi
  8008aa:	50                   	push   %eax
  8008ab:	68 fc 2e 80 00       	push   $0x802efc
  8008b0:	e8 b1 00 00 00       	call   800966 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8008b5:	83 c4 18             	add    $0x18,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	ff 75 10             	pushl  0x10(%ebp)
  8008bc:	e8 54 00 00 00       	call   800915 <vcprintf>
	cprintf("\n");
  8008c1:	c7 04 24 3b 2e 80 00 	movl   $0x802e3b,(%esp)
  8008c8:	e8 99 00 00 00       	call   800966 <cprintf>
  8008cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8008d0:	cc                   	int3   
  8008d1:	eb fd                	jmp    8008d0 <_panic+0x43>

008008d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	83 ec 04             	sub    $0x4,%esp
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008dd:	8b 13                	mov    (%ebx),%edx
  8008df:	8d 42 01             	lea    0x1(%edx),%eax
  8008e2:	89 03                	mov    %eax,(%ebx)
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8008eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008f0:	75 1a                	jne    80090c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	68 ff 00 00 00       	push   $0xff
  8008fa:	8d 43 08             	lea    0x8(%ebx),%eax
  8008fd:	50                   	push   %eax
  8008fe:	e8 2f 09 00 00       	call   801232 <sys_cputs>
		b->idx = 0;
  800903:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800909:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80090c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80091e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800925:	00 00 00 
	b.cnt = 0;
  800928:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80092f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800932:	ff 75 0c             	pushl  0xc(%ebp)
  800935:	ff 75 08             	pushl  0x8(%ebp)
  800938:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80093e:	50                   	push   %eax
  80093f:	68 d3 08 80 00       	push   $0x8008d3
  800944:	e8 54 01 00 00       	call   800a9d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800949:	83 c4 08             	add    $0x8,%esp
  80094c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800952:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800958:	50                   	push   %eax
  800959:	e8 d4 08 00 00       	call   801232 <sys_cputs>

	return b.cnt;
}
  80095e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80096c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80096f:	50                   	push   %eax
  800970:	ff 75 08             	pushl  0x8(%ebp)
  800973:	e8 9d ff ff ff       	call   800915 <vcprintf>
	va_end(ap);

	return cnt;
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	83 ec 1c             	sub    $0x1c,%esp
  800983:	89 c7                	mov    %eax,%edi
  800985:	89 d6                	mov    %edx,%esi
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800990:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800996:	bb 00 00 00 00       	mov    $0x0,%ebx
  80099b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80099e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009a1:	39 d3                	cmp    %edx,%ebx
  8009a3:	72 05                	jb     8009aa <printnum+0x30>
  8009a5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8009a8:	77 45                	ja     8009ef <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8009aa:	83 ec 0c             	sub    $0xc,%esp
  8009ad:	ff 75 18             	pushl  0x18(%ebp)
  8009b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8009b6:	53                   	push   %ebx
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	83 ec 08             	sub    $0x8,%esp
  8009bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8009c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8009c9:	e8 22 21 00 00       	call   802af0 <__udivdi3>
  8009ce:	83 c4 18             	add    $0x18,%esp
  8009d1:	52                   	push   %edx
  8009d2:	50                   	push   %eax
  8009d3:	89 f2                	mov    %esi,%edx
  8009d5:	89 f8                	mov    %edi,%eax
  8009d7:	e8 9e ff ff ff       	call   80097a <printnum>
  8009dc:	83 c4 20             	add    $0x20,%esp
  8009df:	eb 18                	jmp    8009f9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	56                   	push   %esi
  8009e5:	ff 75 18             	pushl  0x18(%ebp)
  8009e8:	ff d7                	call   *%edi
  8009ea:	83 c4 10             	add    $0x10,%esp
  8009ed:	eb 03                	jmp    8009f2 <printnum+0x78>
  8009ef:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009f2:	83 eb 01             	sub    $0x1,%ebx
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	7f e8                	jg     8009e1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009f9:	83 ec 08             	sub    $0x8,%esp
  8009fc:	56                   	push   %esi
  8009fd:	83 ec 04             	sub    $0x4,%esp
  800a00:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a03:	ff 75 e0             	pushl  -0x20(%ebp)
  800a06:	ff 75 dc             	pushl  -0x24(%ebp)
  800a09:	ff 75 d8             	pushl  -0x28(%ebp)
  800a0c:	e8 0f 22 00 00       	call   802c20 <__umoddi3>
  800a11:	83 c4 14             	add    $0x14,%esp
  800a14:	0f be 80 1f 2f 80 00 	movsbl 0x802f1f(%eax),%eax
  800a1b:	50                   	push   %eax
  800a1c:	ff d7                	call   *%edi
}
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800a2c:	83 fa 01             	cmp    $0x1,%edx
  800a2f:	7e 0e                	jle    800a3f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800a31:	8b 10                	mov    (%eax),%edx
  800a33:	8d 4a 08             	lea    0x8(%edx),%ecx
  800a36:	89 08                	mov    %ecx,(%eax)
  800a38:	8b 02                	mov    (%edx),%eax
  800a3a:	8b 52 04             	mov    0x4(%edx),%edx
  800a3d:	eb 22                	jmp    800a61 <getuint+0x38>
	else if (lflag)
  800a3f:	85 d2                	test   %edx,%edx
  800a41:	74 10                	je     800a53 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a43:	8b 10                	mov    (%eax),%edx
  800a45:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a48:	89 08                	mov    %ecx,(%eax)
  800a4a:	8b 02                	mov    (%edx),%eax
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	eb 0e                	jmp    800a61 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a53:	8b 10                	mov    (%eax),%edx
  800a55:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a58:	89 08                	mov    %ecx,(%eax)
  800a5a:	8b 02                	mov    (%edx),%eax
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a69:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a6d:	8b 10                	mov    (%eax),%edx
  800a6f:	3b 50 04             	cmp    0x4(%eax),%edx
  800a72:	73 0a                	jae    800a7e <sprintputch+0x1b>
		*b->buf++ = ch;
  800a74:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a77:	89 08                	mov    %ecx,(%eax)
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	88 02                	mov    %al,(%edx)
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800a86:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a89:	50                   	push   %eax
  800a8a:	ff 75 10             	pushl  0x10(%ebp)
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	ff 75 08             	pushl  0x8(%ebp)
  800a93:	e8 05 00 00 00       	call   800a9d <vprintfmt>
	va_end(ap);
}
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 2c             	sub    $0x2c,%esp
  800aa6:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aac:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aaf:	eb 12                	jmp    800ac3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	0f 84 89 03 00 00    	je     800e42 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800ab9:	83 ec 08             	sub    $0x8,%esp
  800abc:	53                   	push   %ebx
  800abd:	50                   	push   %eax
  800abe:	ff d6                	call   *%esi
  800ac0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ac3:	83 c7 01             	add    $0x1,%edi
  800ac6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800aca:	83 f8 25             	cmp    $0x25,%eax
  800acd:	75 e2                	jne    800ab1 <vprintfmt+0x14>
  800acf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800ad3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800ada:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ae1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	eb 07                	jmp    800af6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aef:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800af2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af6:	8d 47 01             	lea    0x1(%edi),%eax
  800af9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800afc:	0f b6 07             	movzbl (%edi),%eax
  800aff:	0f b6 c8             	movzbl %al,%ecx
  800b02:	83 e8 23             	sub    $0x23,%eax
  800b05:	3c 55                	cmp    $0x55,%al
  800b07:	0f 87 1a 03 00 00    	ja     800e27 <vprintfmt+0x38a>
  800b0d:	0f b6 c0             	movzbl %al,%eax
  800b10:	ff 24 85 60 30 80 00 	jmp    *0x803060(,%eax,4)
  800b17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b1a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800b1e:	eb d6                	jmp    800af6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800b2b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800b2e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800b32:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800b35:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800b38:	83 fa 09             	cmp    $0x9,%edx
  800b3b:	77 39                	ja     800b76 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b3d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800b40:	eb e9                	jmp    800b2b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b42:	8b 45 14             	mov    0x14(%ebp),%eax
  800b45:	8d 48 04             	lea    0x4(%eax),%ecx
  800b48:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b4b:	8b 00                	mov    (%eax),%eax
  800b4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800b53:	eb 27                	jmp    800b7c <vprintfmt+0xdf>
  800b55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	0f 49 c8             	cmovns %eax,%ecx
  800b62:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b68:	eb 8c                	jmp    800af6 <vprintfmt+0x59>
  800b6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b6d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800b74:	eb 80                	jmp    800af6 <vprintfmt+0x59>
  800b76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b79:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800b7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b80:	0f 89 70 ff ff ff    	jns    800af6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800b86:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b89:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b8c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800b93:	e9 5e ff ff ff       	jmp    800af6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b98:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b9e:	e9 53 ff ff ff       	jmp    800af6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba6:	8d 50 04             	lea    0x4(%eax),%edx
  800ba9:	89 55 14             	mov    %edx,0x14(%ebp)
  800bac:	83 ec 08             	sub    $0x8,%esp
  800baf:	53                   	push   %ebx
  800bb0:	ff 30                	pushl  (%eax)
  800bb2:	ff d6                	call   *%esi
			break;
  800bb4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800bba:	e9 04 ff ff ff       	jmp    800ac3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc2:	8d 50 04             	lea    0x4(%eax),%edx
  800bc5:	89 55 14             	mov    %edx,0x14(%ebp)
  800bc8:	8b 00                	mov    (%eax),%eax
  800bca:	99                   	cltd   
  800bcb:	31 d0                	xor    %edx,%eax
  800bcd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800bcf:	83 f8 0f             	cmp    $0xf,%eax
  800bd2:	7f 0b                	jg     800bdf <vprintfmt+0x142>
  800bd4:	8b 14 85 c0 31 80 00 	mov    0x8031c0(,%eax,4),%edx
  800bdb:	85 d2                	test   %edx,%edx
  800bdd:	75 18                	jne    800bf7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800bdf:	50                   	push   %eax
  800be0:	68 37 2f 80 00       	push   $0x802f37
  800be5:	53                   	push   %ebx
  800be6:	56                   	push   %esi
  800be7:	e8 94 fe ff ff       	call   800a80 <printfmt>
  800bec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800bf2:	e9 cc fe ff ff       	jmp    800ac3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800bf7:	52                   	push   %edx
  800bf8:	68 c5 33 80 00       	push   $0x8033c5
  800bfd:	53                   	push   %ebx
  800bfe:	56                   	push   %esi
  800bff:	e8 7c fe ff ff       	call   800a80 <printfmt>
  800c04:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0a:	e9 b4 fe ff ff       	jmp    800ac3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800c0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c12:	8d 50 04             	lea    0x4(%eax),%edx
  800c15:	89 55 14             	mov    %edx,0x14(%ebp)
  800c18:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800c1a:	85 ff                	test   %edi,%edi
  800c1c:	b8 30 2f 80 00       	mov    $0x802f30,%eax
  800c21:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800c24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c28:	0f 8e 94 00 00 00    	jle    800cc2 <vprintfmt+0x225>
  800c2e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800c32:	0f 84 98 00 00 00    	je     800cd0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c38:	83 ec 08             	sub    $0x8,%esp
  800c3b:	ff 75 d0             	pushl  -0x30(%ebp)
  800c3e:	57                   	push   %edi
  800c3f:	e8 86 02 00 00       	call   800eca <strnlen>
  800c44:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c47:	29 c1                	sub    %eax,%ecx
  800c49:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800c4c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800c4f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c56:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800c59:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c5b:	eb 0f                	jmp    800c6c <vprintfmt+0x1cf>
					putch(padc, putdat);
  800c5d:	83 ec 08             	sub    $0x8,%esp
  800c60:	53                   	push   %ebx
  800c61:	ff 75 e0             	pushl  -0x20(%ebp)
  800c64:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c66:	83 ef 01             	sub    $0x1,%edi
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	85 ff                	test   %edi,%edi
  800c6e:	7f ed                	jg     800c5d <vprintfmt+0x1c0>
  800c70:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800c73:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c76:	85 c9                	test   %ecx,%ecx
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7d:	0f 49 c1             	cmovns %ecx,%eax
  800c80:	29 c1                	sub    %eax,%ecx
  800c82:	89 75 08             	mov    %esi,0x8(%ebp)
  800c85:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c88:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c8b:	89 cb                	mov    %ecx,%ebx
  800c8d:	eb 4d                	jmp    800cdc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c8f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c93:	74 1b                	je     800cb0 <vprintfmt+0x213>
  800c95:	0f be c0             	movsbl %al,%eax
  800c98:	83 e8 20             	sub    $0x20,%eax
  800c9b:	83 f8 5e             	cmp    $0x5e,%eax
  800c9e:	76 10                	jbe    800cb0 <vprintfmt+0x213>
					putch('?', putdat);
  800ca0:	83 ec 08             	sub    $0x8,%esp
  800ca3:	ff 75 0c             	pushl  0xc(%ebp)
  800ca6:	6a 3f                	push   $0x3f
  800ca8:	ff 55 08             	call   *0x8(%ebp)
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	eb 0d                	jmp    800cbd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800cb0:	83 ec 08             	sub    $0x8,%esp
  800cb3:	ff 75 0c             	pushl  0xc(%ebp)
  800cb6:	52                   	push   %edx
  800cb7:	ff 55 08             	call   *0x8(%ebp)
  800cba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cbd:	83 eb 01             	sub    $0x1,%ebx
  800cc0:	eb 1a                	jmp    800cdc <vprintfmt+0x23f>
  800cc2:	89 75 08             	mov    %esi,0x8(%ebp)
  800cc5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800cc8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ccb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800cce:	eb 0c                	jmp    800cdc <vprintfmt+0x23f>
  800cd0:	89 75 08             	mov    %esi,0x8(%ebp)
  800cd3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800cd6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800cd9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800cdc:	83 c7 01             	add    $0x1,%edi
  800cdf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ce3:	0f be d0             	movsbl %al,%edx
  800ce6:	85 d2                	test   %edx,%edx
  800ce8:	74 23                	je     800d0d <vprintfmt+0x270>
  800cea:	85 f6                	test   %esi,%esi
  800cec:	78 a1                	js     800c8f <vprintfmt+0x1f2>
  800cee:	83 ee 01             	sub    $0x1,%esi
  800cf1:	79 9c                	jns    800c8f <vprintfmt+0x1f2>
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cfb:	eb 18                	jmp    800d15 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800cfd:	83 ec 08             	sub    $0x8,%esp
  800d00:	53                   	push   %ebx
  800d01:	6a 20                	push   $0x20
  800d03:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800d05:	83 ef 01             	sub    $0x1,%edi
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	eb 08                	jmp    800d15 <vprintfmt+0x278>
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800d12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d15:	85 ff                	test   %edi,%edi
  800d17:	7f e4                	jg     800cfd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d1c:	e9 a2 fd ff ff       	jmp    800ac3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d21:	83 fa 01             	cmp    $0x1,%edx
  800d24:	7e 16                	jle    800d3c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800d26:	8b 45 14             	mov    0x14(%ebp),%eax
  800d29:	8d 50 08             	lea    0x8(%eax),%edx
  800d2c:	89 55 14             	mov    %edx,0x14(%ebp)
  800d2f:	8b 50 04             	mov    0x4(%eax),%edx
  800d32:	8b 00                	mov    (%eax),%eax
  800d34:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d37:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d3a:	eb 32                	jmp    800d6e <vprintfmt+0x2d1>
	else if (lflag)
  800d3c:	85 d2                	test   %edx,%edx
  800d3e:	74 18                	je     800d58 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800d40:	8b 45 14             	mov    0x14(%ebp),%eax
  800d43:	8d 50 04             	lea    0x4(%eax),%edx
  800d46:	89 55 14             	mov    %edx,0x14(%ebp)
  800d49:	8b 00                	mov    (%eax),%eax
  800d4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d4e:	89 c1                	mov    %eax,%ecx
  800d50:	c1 f9 1f             	sar    $0x1f,%ecx
  800d53:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d56:	eb 16                	jmp    800d6e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800d58:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5b:	8d 50 04             	lea    0x4(%eax),%edx
  800d5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800d61:	8b 00                	mov    (%eax),%eax
  800d63:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d66:	89 c1                	mov    %eax,%ecx
  800d68:	c1 f9 1f             	sar    $0x1f,%ecx
  800d6b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d71:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d74:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d79:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d7d:	79 74                	jns    800df3 <vprintfmt+0x356>
				putch('-', putdat);
  800d7f:	83 ec 08             	sub    $0x8,%esp
  800d82:	53                   	push   %ebx
  800d83:	6a 2d                	push   $0x2d
  800d85:	ff d6                	call   *%esi
				num = -(long long) num;
  800d87:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d8d:	f7 d8                	neg    %eax
  800d8f:	83 d2 00             	adc    $0x0,%edx
  800d92:	f7 da                	neg    %edx
  800d94:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800d97:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d9c:	eb 55                	jmp    800df3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800d9e:	8d 45 14             	lea    0x14(%ebp),%eax
  800da1:	e8 83 fc ff ff       	call   800a29 <getuint>
			base = 10;
  800da6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800dab:	eb 46                	jmp    800df3 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800dad:	8d 45 14             	lea    0x14(%ebp),%eax
  800db0:	e8 74 fc ff ff       	call   800a29 <getuint>
			base = 8;
  800db5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800dba:	eb 37                	jmp    800df3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800dbc:	83 ec 08             	sub    $0x8,%esp
  800dbf:	53                   	push   %ebx
  800dc0:	6a 30                	push   $0x30
  800dc2:	ff d6                	call   *%esi
			putch('x', putdat);
  800dc4:	83 c4 08             	add    $0x8,%esp
  800dc7:	53                   	push   %ebx
  800dc8:	6a 78                	push   $0x78
  800dca:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800dcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800dcf:	8d 50 04             	lea    0x4(%eax),%edx
  800dd2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800dd5:	8b 00                	mov    (%eax),%eax
  800dd7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ddc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ddf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800de4:	eb 0d                	jmp    800df3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800de6:	8d 45 14             	lea    0x14(%ebp),%eax
  800de9:	e8 3b fc ff ff       	call   800a29 <getuint>
			base = 16;
  800dee:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800dfa:	57                   	push   %edi
  800dfb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dfe:	51                   	push   %ecx
  800dff:	52                   	push   %edx
  800e00:	50                   	push   %eax
  800e01:	89 da                	mov    %ebx,%edx
  800e03:	89 f0                	mov    %esi,%eax
  800e05:	e8 70 fb ff ff       	call   80097a <printnum>
			break;
  800e0a:	83 c4 20             	add    $0x20,%esp
  800e0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e10:	e9 ae fc ff ff       	jmp    800ac3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e15:	83 ec 08             	sub    $0x8,%esp
  800e18:	53                   	push   %ebx
  800e19:	51                   	push   %ecx
  800e1a:	ff d6                	call   *%esi
			break;
  800e1c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800e22:	e9 9c fc ff ff       	jmp    800ac3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	53                   	push   %ebx
  800e2b:	6a 25                	push   $0x25
  800e2d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	eb 03                	jmp    800e37 <vprintfmt+0x39a>
  800e34:	83 ef 01             	sub    $0x1,%edi
  800e37:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e3b:	75 f7                	jne    800e34 <vprintfmt+0x397>
  800e3d:	e9 81 fc ff ff       	jmp    800ac3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 18             	sub    $0x18,%esp
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e59:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e5d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	74 26                	je     800e91 <vsnprintf+0x47>
  800e6b:	85 d2                	test   %edx,%edx
  800e6d:	7e 22                	jle    800e91 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e6f:	ff 75 14             	pushl  0x14(%ebp)
  800e72:	ff 75 10             	pushl  0x10(%ebp)
  800e75:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e78:	50                   	push   %eax
  800e79:	68 63 0a 80 00       	push   $0x800a63
  800e7e:	e8 1a fc ff ff       	call   800a9d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e86:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	eb 05                	jmp    800e96 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e9e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ea1:	50                   	push   %eax
  800ea2:	ff 75 10             	pushl  0x10(%ebp)
  800ea5:	ff 75 0c             	pushl  0xc(%ebp)
  800ea8:	ff 75 08             	pushl  0x8(%ebp)
  800eab:	e8 9a ff ff ff       	call   800e4a <vsnprintf>
	va_end(ap);

	return rc;
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	eb 03                	jmp    800ec2 <strlen+0x10>
		n++;
  800ebf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ec2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ec6:	75 f7                	jne    800ebf <strlen+0xd>
		n++;
	return n;
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ed3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed8:	eb 03                	jmp    800edd <strnlen+0x13>
		n++;
  800eda:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800edd:	39 c2                	cmp    %eax,%edx
  800edf:	74 08                	je     800ee9 <strnlen+0x1f>
  800ee1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ee5:	75 f3                	jne    800eda <strnlen+0x10>
  800ee7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	53                   	push   %ebx
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ef5:	89 c2                	mov    %eax,%edx
  800ef7:	83 c2 01             	add    $0x1,%edx
  800efa:	83 c1 01             	add    $0x1,%ecx
  800efd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800f01:	88 5a ff             	mov    %bl,-0x1(%edx)
  800f04:	84 db                	test   %bl,%bl
  800f06:	75 ef                	jne    800ef7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800f08:	5b                   	pop    %ebx
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	53                   	push   %ebx
  800f0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f12:	53                   	push   %ebx
  800f13:	e8 9a ff ff ff       	call   800eb2 <strlen>
  800f18:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800f1b:	ff 75 0c             	pushl  0xc(%ebp)
  800f1e:	01 d8                	add    %ebx,%eax
  800f20:	50                   	push   %eax
  800f21:	e8 c5 ff ff ff       	call   800eeb <strcpy>
	return dst;
}
  800f26:	89 d8                	mov    %ebx,%eax
  800f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	8b 75 08             	mov    0x8(%ebp),%esi
  800f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f38:	89 f3                	mov    %esi,%ebx
  800f3a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	eb 0f                	jmp    800f50 <strncpy+0x23>
		*dst++ = *src;
  800f41:	83 c2 01             	add    $0x1,%edx
  800f44:	0f b6 01             	movzbl (%ecx),%eax
  800f47:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f4a:	80 39 01             	cmpb   $0x1,(%ecx)
  800f4d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f50:	39 da                	cmp    %ebx,%edx
  800f52:	75 ed                	jne    800f41 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f54:	89 f0                	mov    %esi,%eax
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 10             	mov    0x10(%ebp),%edx
  800f68:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f6a:	85 d2                	test   %edx,%edx
  800f6c:	74 21                	je     800f8f <strlcpy+0x35>
  800f6e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	eb 09                	jmp    800f7f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f76:	83 c2 01             	add    $0x1,%edx
  800f79:	83 c1 01             	add    $0x1,%ecx
  800f7c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f7f:	39 c2                	cmp    %eax,%edx
  800f81:	74 09                	je     800f8c <strlcpy+0x32>
  800f83:	0f b6 19             	movzbl (%ecx),%ebx
  800f86:	84 db                	test   %bl,%bl
  800f88:	75 ec                	jne    800f76 <strlcpy+0x1c>
  800f8a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800f8c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f8f:	29 f0                	sub    %esi,%eax
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f9e:	eb 06                	jmp    800fa6 <strcmp+0x11>
		p++, q++;
  800fa0:	83 c1 01             	add    $0x1,%ecx
  800fa3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800fa6:	0f b6 01             	movzbl (%ecx),%eax
  800fa9:	84 c0                	test   %al,%al
  800fab:	74 04                	je     800fb1 <strcmp+0x1c>
  800fad:	3a 02                	cmp    (%edx),%al
  800faf:	74 ef                	je     800fa0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fb1:	0f b6 c0             	movzbl %al,%eax
  800fb4:	0f b6 12             	movzbl (%edx),%edx
  800fb7:	29 d0                	sub    %edx,%eax
}
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	53                   	push   %ebx
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc5:	89 c3                	mov    %eax,%ebx
  800fc7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fca:	eb 06                	jmp    800fd2 <strncmp+0x17>
		n--, p++, q++;
  800fcc:	83 c0 01             	add    $0x1,%eax
  800fcf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fd2:	39 d8                	cmp    %ebx,%eax
  800fd4:	74 15                	je     800feb <strncmp+0x30>
  800fd6:	0f b6 08             	movzbl (%eax),%ecx
  800fd9:	84 c9                	test   %cl,%cl
  800fdb:	74 04                	je     800fe1 <strncmp+0x26>
  800fdd:	3a 0a                	cmp    (%edx),%cl
  800fdf:	74 eb                	je     800fcc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fe1:	0f b6 00             	movzbl (%eax),%eax
  800fe4:	0f b6 12             	movzbl (%edx),%edx
  800fe7:	29 d0                	sub    %edx,%eax
  800fe9:	eb 05                	jmp    800ff0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ff0:	5b                   	pop    %ebx
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ffd:	eb 07                	jmp    801006 <strchr+0x13>
		if (*s == c)
  800fff:	38 ca                	cmp    %cl,%dl
  801001:	74 0f                	je     801012 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801003:	83 c0 01             	add    $0x1,%eax
  801006:	0f b6 10             	movzbl (%eax),%edx
  801009:	84 d2                	test   %dl,%dl
  80100b:	75 f2                	jne    800fff <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	8b 45 08             	mov    0x8(%ebp),%eax
  80101a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80101e:	eb 03                	jmp    801023 <strfind+0xf>
  801020:	83 c0 01             	add    $0x1,%eax
  801023:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801026:	38 ca                	cmp    %cl,%dl
  801028:	74 04                	je     80102e <strfind+0x1a>
  80102a:	84 d2                	test   %dl,%dl
  80102c:	75 f2                	jne    801020 <strfind+0xc>
			break;
	return (char *) s;
}
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	8b 7d 08             	mov    0x8(%ebp),%edi
  801039:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80103c:	85 c9                	test   %ecx,%ecx
  80103e:	74 36                	je     801076 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801040:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801046:	75 28                	jne    801070 <memset+0x40>
  801048:	f6 c1 03             	test   $0x3,%cl
  80104b:	75 23                	jne    801070 <memset+0x40>
		c &= 0xFF;
  80104d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801051:	89 d3                	mov    %edx,%ebx
  801053:	c1 e3 08             	shl    $0x8,%ebx
  801056:	89 d6                	mov    %edx,%esi
  801058:	c1 e6 18             	shl    $0x18,%esi
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	c1 e0 10             	shl    $0x10,%eax
  801060:	09 f0                	or     %esi,%eax
  801062:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801064:	89 d8                	mov    %ebx,%eax
  801066:	09 d0                	or     %edx,%eax
  801068:	c1 e9 02             	shr    $0x2,%ecx
  80106b:	fc                   	cld    
  80106c:	f3 ab                	rep stos %eax,%es:(%edi)
  80106e:	eb 06                	jmp    801076 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801070:	8b 45 0c             	mov    0xc(%ebp),%eax
  801073:	fc                   	cld    
  801074:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801076:	89 f8                	mov    %edi,%eax
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	8b 75 0c             	mov    0xc(%ebp),%esi
  801088:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80108b:	39 c6                	cmp    %eax,%esi
  80108d:	73 35                	jae    8010c4 <memmove+0x47>
  80108f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801092:	39 d0                	cmp    %edx,%eax
  801094:	73 2e                	jae    8010c4 <memmove+0x47>
		s += n;
		d += n;
  801096:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801099:	89 d6                	mov    %edx,%esi
  80109b:	09 fe                	or     %edi,%esi
  80109d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8010a3:	75 13                	jne    8010b8 <memmove+0x3b>
  8010a5:	f6 c1 03             	test   $0x3,%cl
  8010a8:	75 0e                	jne    8010b8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8010aa:	83 ef 04             	sub    $0x4,%edi
  8010ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010b0:	c1 e9 02             	shr    $0x2,%ecx
  8010b3:	fd                   	std    
  8010b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010b6:	eb 09                	jmp    8010c1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8010b8:	83 ef 01             	sub    $0x1,%edi
  8010bb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8010be:	fd                   	std    
  8010bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010c1:	fc                   	cld    
  8010c2:	eb 1d                	jmp    8010e1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010c4:	89 f2                	mov    %esi,%edx
  8010c6:	09 c2                	or     %eax,%edx
  8010c8:	f6 c2 03             	test   $0x3,%dl
  8010cb:	75 0f                	jne    8010dc <memmove+0x5f>
  8010cd:	f6 c1 03             	test   $0x3,%cl
  8010d0:	75 0a                	jne    8010dc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8010d2:	c1 e9 02             	shr    $0x2,%ecx
  8010d5:	89 c7                	mov    %eax,%edi
  8010d7:	fc                   	cld    
  8010d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010da:	eb 05                	jmp    8010e1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	fc                   	cld    
  8010df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8010e8:	ff 75 10             	pushl  0x10(%ebp)
  8010eb:	ff 75 0c             	pushl  0xc(%ebp)
  8010ee:	ff 75 08             	pushl  0x8(%ebp)
  8010f1:	e8 87 ff ff ff       	call   80107d <memmove>
}
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	8b 55 0c             	mov    0xc(%ebp),%edx
  801103:	89 c6                	mov    %eax,%esi
  801105:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801108:	eb 1a                	jmp    801124 <memcmp+0x2c>
		if (*s1 != *s2)
  80110a:	0f b6 08             	movzbl (%eax),%ecx
  80110d:	0f b6 1a             	movzbl (%edx),%ebx
  801110:	38 d9                	cmp    %bl,%cl
  801112:	74 0a                	je     80111e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801114:	0f b6 c1             	movzbl %cl,%eax
  801117:	0f b6 db             	movzbl %bl,%ebx
  80111a:	29 d8                	sub    %ebx,%eax
  80111c:	eb 0f                	jmp    80112d <memcmp+0x35>
		s1++, s2++;
  80111e:	83 c0 01             	add    $0x1,%eax
  801121:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801124:	39 f0                	cmp    %esi,%eax
  801126:	75 e2                	jne    80110a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	53                   	push   %ebx
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801138:	89 c1                	mov    %eax,%ecx
  80113a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80113d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801141:	eb 0a                	jmp    80114d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801143:	0f b6 10             	movzbl (%eax),%edx
  801146:	39 da                	cmp    %ebx,%edx
  801148:	74 07                	je     801151 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	39 c8                	cmp    %ecx,%eax
  80114f:	72 f2                	jb     801143 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801151:	5b                   	pop    %ebx
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801160:	eb 03                	jmp    801165 <strtol+0x11>
		s++;
  801162:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801165:	0f b6 01             	movzbl (%ecx),%eax
  801168:	3c 20                	cmp    $0x20,%al
  80116a:	74 f6                	je     801162 <strtol+0xe>
  80116c:	3c 09                	cmp    $0x9,%al
  80116e:	74 f2                	je     801162 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801170:	3c 2b                	cmp    $0x2b,%al
  801172:	75 0a                	jne    80117e <strtol+0x2a>
		s++;
  801174:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801177:	bf 00 00 00 00       	mov    $0x0,%edi
  80117c:	eb 11                	jmp    80118f <strtol+0x3b>
  80117e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801183:	3c 2d                	cmp    $0x2d,%al
  801185:	75 08                	jne    80118f <strtol+0x3b>
		s++, neg = 1;
  801187:	83 c1 01             	add    $0x1,%ecx
  80118a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80118f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801195:	75 15                	jne    8011ac <strtol+0x58>
  801197:	80 39 30             	cmpb   $0x30,(%ecx)
  80119a:	75 10                	jne    8011ac <strtol+0x58>
  80119c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8011a0:	75 7c                	jne    80121e <strtol+0xca>
		s += 2, base = 16;
  8011a2:	83 c1 02             	add    $0x2,%ecx
  8011a5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8011aa:	eb 16                	jmp    8011c2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8011ac:	85 db                	test   %ebx,%ebx
  8011ae:	75 12                	jne    8011c2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011b0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8011b8:	75 08                	jne    8011c2 <strtol+0x6e>
		s++, base = 8;
  8011ba:	83 c1 01             	add    $0x1,%ecx
  8011bd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011ca:	0f b6 11             	movzbl (%ecx),%edx
  8011cd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8011d0:	89 f3                	mov    %esi,%ebx
  8011d2:	80 fb 09             	cmp    $0x9,%bl
  8011d5:	77 08                	ja     8011df <strtol+0x8b>
			dig = *s - '0';
  8011d7:	0f be d2             	movsbl %dl,%edx
  8011da:	83 ea 30             	sub    $0x30,%edx
  8011dd:	eb 22                	jmp    801201 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8011df:	8d 72 9f             	lea    -0x61(%edx),%esi
  8011e2:	89 f3                	mov    %esi,%ebx
  8011e4:	80 fb 19             	cmp    $0x19,%bl
  8011e7:	77 08                	ja     8011f1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8011e9:	0f be d2             	movsbl %dl,%edx
  8011ec:	83 ea 57             	sub    $0x57,%edx
  8011ef:	eb 10                	jmp    801201 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8011f1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8011f4:	89 f3                	mov    %esi,%ebx
  8011f6:	80 fb 19             	cmp    $0x19,%bl
  8011f9:	77 16                	ja     801211 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8011fb:	0f be d2             	movsbl %dl,%edx
  8011fe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801201:	3b 55 10             	cmp    0x10(%ebp),%edx
  801204:	7d 0b                	jge    801211 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801206:	83 c1 01             	add    $0x1,%ecx
  801209:	0f af 45 10          	imul   0x10(%ebp),%eax
  80120d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80120f:	eb b9                	jmp    8011ca <strtol+0x76>

	if (endptr)
  801211:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801215:	74 0d                	je     801224 <strtol+0xd0>
		*endptr = (char *) s;
  801217:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121a:	89 0e                	mov    %ecx,(%esi)
  80121c:	eb 06                	jmp    801224 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80121e:	85 db                	test   %ebx,%ebx
  801220:	74 98                	je     8011ba <strtol+0x66>
  801222:	eb 9e                	jmp    8011c2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801224:	89 c2                	mov    %eax,%edx
  801226:	f7 da                	neg    %edx
  801228:	85 ff                	test   %edi,%edi
  80122a:	0f 45 c2             	cmovne %edx,%eax
}
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	57                   	push   %edi
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	89 c3                	mov    %eax,%ebx
  801245:	89 c7                	mov    %eax,%edi
  801247:	89 c6                	mov    %eax,%esi
  801249:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sys_cgetc>:

int
sys_cgetc(void)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801256:	ba 00 00 00 00       	mov    $0x0,%edx
  80125b:	b8 01 00 00 00       	mov    $0x1,%eax
  801260:	89 d1                	mov    %edx,%ecx
  801262:	89 d3                	mov    %edx,%ebx
  801264:	89 d7                	mov    %edx,%edi
  801266:	89 d6                	mov    %edx,%esi
  801268:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	57                   	push   %edi
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801278:	b9 00 00 00 00       	mov    $0x0,%ecx
  80127d:	b8 03 00 00 00       	mov    $0x3,%eax
  801282:	8b 55 08             	mov    0x8(%ebp),%edx
  801285:	89 cb                	mov    %ecx,%ebx
  801287:	89 cf                	mov    %ecx,%edi
  801289:	89 ce                	mov    %ecx,%esi
  80128b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80128d:	85 c0                	test   %eax,%eax
  80128f:	7e 17                	jle    8012a8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	50                   	push   %eax
  801295:	6a 03                	push   $0x3
  801297:	68 1f 32 80 00       	push   $0x80321f
  80129c:	6a 23                	push   $0x23
  80129e:	68 3c 32 80 00       	push   $0x80323c
  8012a3:	e8 e5 f5 ff ff       	call   80088d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5f                   	pop    %edi
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	57                   	push   %edi
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8012c0:	89 d1                	mov    %edx,%ecx
  8012c2:	89 d3                	mov    %edx,%ebx
  8012c4:	89 d7                	mov    %edx,%edi
  8012c6:	89 d6                	mov    %edx,%esi
  8012c8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5f                   	pop    %edi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <sys_yield>:

void
sys_yield(void)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	57                   	push   %edi
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012df:	89 d1                	mov    %edx,%ecx
  8012e1:	89 d3                	mov    %edx,%ebx
  8012e3:	89 d7                	mov    %edx,%edi
  8012e5:	89 d6                	mov    %edx,%esi
  8012e7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5f                   	pop    %edi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f7:	be 00 00 00 00       	mov    $0x0,%esi
  8012fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801304:	8b 55 08             	mov    0x8(%ebp),%edx
  801307:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130a:	89 f7                	mov    %esi,%edi
  80130c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80130e:	85 c0                	test   %eax,%eax
  801310:	7e 17                	jle    801329 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	50                   	push   %eax
  801316:	6a 04                	push   $0x4
  801318:	68 1f 32 80 00       	push   $0x80321f
  80131d:	6a 23                	push   $0x23
  80131f:	68 3c 32 80 00       	push   $0x80323c
  801324:	e8 64 f5 ff ff       	call   80088d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801329:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5f                   	pop    %edi
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	57                   	push   %edi
  801335:	56                   	push   %esi
  801336:	53                   	push   %ebx
  801337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80133a:	b8 05 00 00 00       	mov    $0x5,%eax
  80133f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801342:	8b 55 08             	mov    0x8(%ebp),%edx
  801345:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801348:	8b 7d 14             	mov    0x14(%ebp),%edi
  80134b:	8b 75 18             	mov    0x18(%ebp),%esi
  80134e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801350:	85 c0                	test   %eax,%eax
  801352:	7e 17                	jle    80136b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	50                   	push   %eax
  801358:	6a 05                	push   $0x5
  80135a:	68 1f 32 80 00       	push   $0x80321f
  80135f:	6a 23                	push   $0x23
  801361:	68 3c 32 80 00       	push   $0x80323c
  801366:	e8 22 f5 ff ff       	call   80088d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80136b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	57                   	push   %edi
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80137c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801381:	b8 06 00 00 00       	mov    $0x6,%eax
  801386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801389:	8b 55 08             	mov    0x8(%ebp),%edx
  80138c:	89 df                	mov    %ebx,%edi
  80138e:	89 de                	mov    %ebx,%esi
  801390:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801392:	85 c0                	test   %eax,%eax
  801394:	7e 17                	jle    8013ad <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	50                   	push   %eax
  80139a:	6a 06                	push   $0x6
  80139c:	68 1f 32 80 00       	push   $0x80321f
  8013a1:	6a 23                	push   $0x23
  8013a3:	68 3c 32 80 00       	push   $0x80323c
  8013a8:	e8 e0 f4 ff ff       	call   80088d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	57                   	push   %edi
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8013c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	89 df                	mov    %ebx,%edi
  8013d0:	89 de                	mov    %ebx,%esi
  8013d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	7e 17                	jle    8013ef <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	50                   	push   %eax
  8013dc:	6a 08                	push   $0x8
  8013de:	68 1f 32 80 00       	push   $0x80321f
  8013e3:	6a 23                	push   $0x23
  8013e5:	68 3c 32 80 00       	push   $0x80323c
  8013ea:	e8 9e f4 ff ff       	call   80088d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5f                   	pop    %edi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
  801405:	b8 09 00 00 00       	mov    $0x9,%eax
  80140a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140d:	8b 55 08             	mov    0x8(%ebp),%edx
  801410:	89 df                	mov    %ebx,%edi
  801412:	89 de                	mov    %ebx,%esi
  801414:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801416:	85 c0                	test   %eax,%eax
  801418:	7e 17                	jle    801431 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	50                   	push   %eax
  80141e:	6a 09                	push   $0x9
  801420:	68 1f 32 80 00       	push   $0x80321f
  801425:	6a 23                	push   $0x23
  801427:	68 3c 32 80 00       	push   $0x80323c
  80142c:	e8 5c f4 ff ff       	call   80088d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801431:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	57                   	push   %edi
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801442:	bb 00 00 00 00       	mov    $0x0,%ebx
  801447:	b8 0a 00 00 00       	mov    $0xa,%eax
  80144c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144f:	8b 55 08             	mov    0x8(%ebp),%edx
  801452:	89 df                	mov    %ebx,%edi
  801454:	89 de                	mov    %ebx,%esi
  801456:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801458:	85 c0                	test   %eax,%eax
  80145a:	7e 17                	jle    801473 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	50                   	push   %eax
  801460:	6a 0a                	push   $0xa
  801462:	68 1f 32 80 00       	push   $0x80321f
  801467:	6a 23                	push   $0x23
  801469:	68 3c 32 80 00       	push   $0x80323c
  80146e:	e8 1a f4 ff ff       	call   80088d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	57                   	push   %edi
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801481:	be 00 00 00 00       	mov    $0x0,%esi
  801486:	b8 0c 00 00 00       	mov    $0xc,%eax
  80148b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148e:	8b 55 08             	mov    0x8(%ebp),%edx
  801491:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801494:	8b 7d 14             	mov    0x14(%ebp),%edi
  801497:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5f                   	pop    %edi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	57                   	push   %edi
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ac:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b4:	89 cb                	mov    %ecx,%ebx
  8014b6:	89 cf                	mov    %ecx,%edi
  8014b8:	89 ce                	mov    %ecx,%esi
  8014ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	7e 17                	jle    8014d7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	50                   	push   %eax
  8014c4:	6a 0d                	push   $0xd
  8014c6:	68 1f 32 80 00       	push   $0x80321f
  8014cb:	6a 23                	push   $0x23
  8014cd:	68 3c 32 80 00       	push   $0x80323c
  8014d2:	e8 b6 f3 ff ff       	call   80088d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5f                   	pop    %edi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	57                   	push   %edi
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ea:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014ef:	89 d1                	mov    %edx,%ecx
  8014f1:	89 d3                	mov    %edx,%ebx
  8014f3:	89 d7                	mov    %edx,%edi
  8014f5:	89 d6                	mov    %edx,%esi
  8014f7:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801507:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150c:	b8 0f 00 00 00       	mov    $0xf,%eax
  801511:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801514:	8b 55 08             	mov    0x8(%ebp),%edx
  801517:	89 df                	mov    %ebx,%edi
  801519:	89 de                	mov    %ebx,%esi
  80151b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80151d:	85 c0                	test   %eax,%eax
  80151f:	7e 17                	jle    801538 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	50                   	push   %eax
  801525:	6a 0f                	push   $0xf
  801527:	68 1f 32 80 00       	push   $0x80321f
  80152c:	6a 23                	push   $0x23
  80152e:	68 3c 32 80 00       	push   $0x80323c
  801533:	e8 55 f3 ff ff       	call   80088d <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  801538:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153b:	5b                   	pop    %ebx
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	57                   	push   %edi
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801549:	bb 00 00 00 00       	mov    $0x0,%ebx
  80154e:	b8 10 00 00 00       	mov    $0x10,%eax
  801553:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801556:	8b 55 08             	mov    0x8(%ebp),%edx
  801559:	89 df                	mov    %ebx,%edi
  80155b:	89 de                	mov    %ebx,%esi
  80155d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80155f:	85 c0                	test   %eax,%eax
  801561:	7e 17                	jle    80157a <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	50                   	push   %eax
  801567:	6a 10                	push   $0x10
  801569:	68 1f 32 80 00       	push   $0x80321f
  80156e:	6a 23                	push   $0x23
  801570:	68 3c 32 80 00       	push   $0x80323c
  801575:	e8 13 f3 ff ff       	call   80088d <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  80157a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157d:	5b                   	pop    %ebx
  80157e:	5e                   	pop    %esi
  80157f:	5f                   	pop    %edi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80158a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  80158c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801590:	75 25                	jne    8015b7 <pgfault+0x35>
  801592:	89 d8                	mov    %ebx,%eax
  801594:	c1 e8 0c             	shr    $0xc,%eax
  801597:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80159e:	f6 c4 08             	test   $0x8,%ah
  8015a1:	75 14                	jne    8015b7 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	68 4c 32 80 00       	push   $0x80324c
  8015ab:	6a 1e                	push   $0x1e
  8015ad:	68 e0 32 80 00       	push   $0x8032e0
  8015b2:	e8 d6 f2 ff ff       	call   80088d <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  8015b7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8015bd:	e8 ee fc ff ff       	call   8012b0 <sys_getenvid>
  8015c2:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	6a 07                	push   $0x7
  8015c9:	68 00 f0 7f 00       	push   $0x7ff000
  8015ce:	50                   	push   %eax
  8015cf:	e8 1a fd ff ff       	call   8012ee <sys_page_alloc>
	if (r < 0)
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	79 12                	jns    8015ed <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  8015db:	50                   	push   %eax
  8015dc:	68 78 32 80 00       	push   $0x803278
  8015e1:	6a 33                	push   $0x33
  8015e3:	68 e0 32 80 00       	push   $0x8032e0
  8015e8:	e8 a0 f2 ff ff       	call   80088d <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	68 00 10 00 00       	push   $0x1000
  8015f5:	53                   	push   %ebx
  8015f6:	68 00 f0 7f 00       	push   $0x7ff000
  8015fb:	e8 e5 fa ff ff       	call   8010e5 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  801600:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801607:	53                   	push   %ebx
  801608:	56                   	push   %esi
  801609:	68 00 f0 7f 00       	push   $0x7ff000
  80160e:	56                   	push   %esi
  80160f:	e8 1d fd ff ff       	call   801331 <sys_page_map>
	if (r < 0)
  801614:	83 c4 20             	add    $0x20,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	79 12                	jns    80162d <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  80161b:	50                   	push   %eax
  80161c:	68 9c 32 80 00       	push   $0x80329c
  801621:	6a 3b                	push   $0x3b
  801623:	68 e0 32 80 00       	push   $0x8032e0
  801628:	e8 60 f2 ff ff       	call   80088d <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	68 00 f0 7f 00       	push   $0x7ff000
  801635:	56                   	push   %esi
  801636:	e8 38 fd ff ff       	call   801373 <sys_page_unmap>
	if (r < 0)
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	79 12                	jns    801654 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  801642:	50                   	push   %eax
  801643:	68 c0 32 80 00       	push   $0x8032c0
  801648:	6a 40                	push   $0x40
  80164a:	68 e0 32 80 00       	push   $0x8032e0
  80164f:	e8 39 f2 ff ff       	call   80088d <_panic>
}
  801654:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	57                   	push   %edi
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801664:	68 82 15 80 00       	push   $0x801582
  801669:	e8 dc 13 00 00       	call   802a4a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80166e:	b8 07 00 00 00       	mov    $0x7,%eax
  801673:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	0f 88 64 01 00 00    	js     8017e4 <fork+0x189>
  801680:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801685:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80168a:	85 c0                	test   %eax,%eax
  80168c:	75 21                	jne    8016af <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  80168e:	e8 1d fc ff ff       	call   8012b0 <sys_getenvid>
  801693:	25 ff 03 00 00       	and    $0x3ff,%eax
  801698:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80169b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016a0:	a3 20 50 80 00       	mov    %eax,0x805020
        return 0;
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	e9 3f 01 00 00       	jmp    8017ee <fork+0x193>
  8016af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b2:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8016b4:	89 d8                	mov    %ebx,%eax
  8016b6:	c1 e8 16             	shr    $0x16,%eax
  8016b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c0:	a8 01                	test   $0x1,%al
  8016c2:	0f 84 bd 00 00 00    	je     801785 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	c1 e8 0c             	shr    $0xc,%eax
  8016cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d4:	f6 c2 01             	test   $0x1,%dl
  8016d7:	0f 84 a8 00 00 00    	je     801785 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  8016dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e4:	a8 04                	test   $0x4,%al
  8016e6:	0f 84 99 00 00 00    	je     801785 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8016ec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8016f3:	f6 c4 04             	test   $0x4,%ah
  8016f6:	74 17                	je     80170f <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	68 07 0e 00 00       	push   $0xe07
  801700:	53                   	push   %ebx
  801701:	57                   	push   %edi
  801702:	53                   	push   %ebx
  801703:	6a 00                	push   $0x0
  801705:	e8 27 fc ff ff       	call   801331 <sys_page_map>
  80170a:	83 c4 20             	add    $0x20,%esp
  80170d:	eb 76                	jmp    801785 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80170f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801716:	a8 02                	test   $0x2,%al
  801718:	75 0c                	jne    801726 <fork+0xcb>
  80171a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801721:	f6 c4 08             	test   $0x8,%ah
  801724:	74 3f                	je     801765 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	68 05 08 00 00       	push   $0x805
  80172e:	53                   	push   %ebx
  80172f:	57                   	push   %edi
  801730:	53                   	push   %ebx
  801731:	6a 00                	push   $0x0
  801733:	e8 f9 fb ff ff       	call   801331 <sys_page_map>
		if (r < 0)
  801738:	83 c4 20             	add    $0x20,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	0f 88 a5 00 00 00    	js     8017e8 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	68 05 08 00 00       	push   $0x805
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	53                   	push   %ebx
  80174f:	6a 00                	push   $0x0
  801751:	e8 db fb ff ff       	call   801331 <sys_page_map>
  801756:	83 c4 20             	add    $0x20,%esp
  801759:	85 c0                	test   %eax,%eax
  80175b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801760:	0f 4f c1             	cmovg  %ecx,%eax
  801763:	eb 1c                	jmp    801781 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	6a 05                	push   $0x5
  80176a:	53                   	push   %ebx
  80176b:	57                   	push   %edi
  80176c:	53                   	push   %ebx
  80176d:	6a 00                	push   $0x0
  80176f:	e8 bd fb ff ff       	call   801331 <sys_page_map>
  801774:	83 c4 20             	add    $0x20,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	b9 00 00 00 00       	mov    $0x0,%ecx
  80177e:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801781:	85 c0                	test   %eax,%eax
  801783:	78 67                	js     8017ec <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801785:	83 c6 01             	add    $0x1,%esi
  801788:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80178e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801794:	0f 85 1a ff ff ff    	jne    8016b4 <fork+0x59>
  80179a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 f0 bf ee       	push   $0xeebff000
  8017a7:	57                   	push   %edi
  8017a8:	e8 41 fb ff ff       	call   8012ee <sys_page_alloc>
	if (r < 0)
  8017ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b0:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 38                	js     8017ee <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	68 91 2a 80 00       	push   $0x802a91
  8017be:	57                   	push   %edi
  8017bf:	e8 75 fc ff ff       	call   801439 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8017c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8017c7:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 21                	js     8017ee <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	6a 02                	push   $0x2
  8017d2:	57                   	push   %edi
  8017d3:	e8 dd fb ff ff       	call   8013b5 <sys_env_set_status>
	if (r < 0)
  8017d8:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	0f 48 f8             	cmovs  %eax,%edi
  8017e0:	89 fa                	mov    %edi,%edx
  8017e2:	eb 0a                	jmp    8017ee <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	eb 06                	jmp    8017ee <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	eb 02                	jmp    8017ee <fork+0x193>
  8017ec:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8017ee:	89 d0                	mov    %edx,%eax
  8017f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5f                   	pop    %edi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <sfork>:

// Challenge!
int
sfork(void)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8017fe:	68 eb 32 80 00       	push   $0x8032eb
  801803:	68 c9 00 00 00       	push   $0xc9
  801808:	68 e0 32 80 00       	push   $0x8032e0
  80180d:	e8 7b f0 ff ff       	call   80088d <_panic>

00801812 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	8b 75 08             	mov    0x8(%ebp),%esi
  80181a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801820:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801822:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801827:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	50                   	push   %eax
  80182e:	e8 6b fc ff ff       	call   80149e <sys_ipc_recv>

	if (from_env_store != NULL)
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 f6                	test   %esi,%esi
  801838:	74 14                	je     80184e <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 09                	js     80184c <ipc_recv+0x3a>
  801843:	8b 15 20 50 80 00    	mov    0x805020,%edx
  801849:	8b 52 74             	mov    0x74(%edx),%edx
  80184c:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80184e:	85 db                	test   %ebx,%ebx
  801850:	74 14                	je     801866 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	85 c0                	test   %eax,%eax
  801859:	78 09                	js     801864 <ipc_recv+0x52>
  80185b:	8b 15 20 50 80 00    	mov    0x805020,%edx
  801861:	8b 52 78             	mov    0x78(%edx),%edx
  801864:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801866:	85 c0                	test   %eax,%eax
  801868:	78 08                	js     801872 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80186a:	a1 20 50 80 00       	mov    0x805020,%eax
  80186f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	57                   	push   %edi
  80187d:	56                   	push   %esi
  80187e:	53                   	push   %ebx
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	8b 7d 08             	mov    0x8(%ebp),%edi
  801885:	8b 75 0c             	mov    0xc(%ebp),%esi
  801888:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80188b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80188d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801892:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801895:	ff 75 14             	pushl  0x14(%ebp)
  801898:	53                   	push   %ebx
  801899:	56                   	push   %esi
  80189a:	57                   	push   %edi
  80189b:	e8 db fb ff ff       	call   80147b <sys_ipc_try_send>

		if (err < 0) {
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	79 1e                	jns    8018c5 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8018a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018aa:	75 07                	jne    8018b3 <ipc_send+0x3a>
				sys_yield();
  8018ac:	e8 1e fa ff ff       	call   8012cf <sys_yield>
  8018b1:	eb e2                	jmp    801895 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8018b3:	50                   	push   %eax
  8018b4:	68 01 33 80 00       	push   $0x803301
  8018b9:	6a 49                	push   $0x49
  8018bb:	68 0e 33 80 00       	push   $0x80330e
  8018c0:	e8 c8 ef ff ff       	call   80088d <_panic>
		}

	} while (err < 0);

}
  8018c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5e                   	pop    %esi
  8018ca:	5f                   	pop    %edi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8018d8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8018db:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8018e1:	8b 52 50             	mov    0x50(%edx),%edx
  8018e4:	39 ca                	cmp    %ecx,%edx
  8018e6:	75 0d                	jne    8018f5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8018e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018f0:	8b 40 48             	mov    0x48(%eax),%eax
  8018f3:	eb 0f                	jmp    801904 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018f5:	83 c0 01             	add    $0x1,%eax
  8018f8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8018fd:	75 d9                	jne    8018d8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	05 00 00 00 30       	add    $0x30000000,%eax
  801911:	c1 e8 0c             	shr    $0xc,%eax
}
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	05 00 00 00 30       	add    $0x30000000,%eax
  801921:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801926:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801933:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801938:	89 c2                	mov    %eax,%edx
  80193a:	c1 ea 16             	shr    $0x16,%edx
  80193d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801944:	f6 c2 01             	test   $0x1,%dl
  801947:	74 11                	je     80195a <fd_alloc+0x2d>
  801949:	89 c2                	mov    %eax,%edx
  80194b:	c1 ea 0c             	shr    $0xc,%edx
  80194e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801955:	f6 c2 01             	test   $0x1,%dl
  801958:	75 09                	jne    801963 <fd_alloc+0x36>
			*fd_store = fd;
  80195a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
  801961:	eb 17                	jmp    80197a <fd_alloc+0x4d>
  801963:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801968:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80196d:	75 c9                	jne    801938 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80196f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801975:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801982:	83 f8 1f             	cmp    $0x1f,%eax
  801985:	77 36                	ja     8019bd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801987:	c1 e0 0c             	shl    $0xc,%eax
  80198a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80198f:	89 c2                	mov    %eax,%edx
  801991:	c1 ea 16             	shr    $0x16,%edx
  801994:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80199b:	f6 c2 01             	test   $0x1,%dl
  80199e:	74 24                	je     8019c4 <fd_lookup+0x48>
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	c1 ea 0c             	shr    $0xc,%edx
  8019a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019ac:	f6 c2 01             	test   $0x1,%dl
  8019af:	74 1a                	je     8019cb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	eb 13                	jmp    8019d0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8019bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c2:	eb 0c                	jmp    8019d0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8019c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c9:	eb 05                	jmp    8019d0 <fd_lookup+0x54>
  8019cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019db:	ba 98 33 80 00       	mov    $0x803398,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8019e0:	eb 13                	jmp    8019f5 <dev_lookup+0x23>
  8019e2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8019e5:	39 08                	cmp    %ecx,(%eax)
  8019e7:	75 0c                	jne    8019f5 <dev_lookup+0x23>
			*dev = devtab[i];
  8019e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f3:	eb 2e                	jmp    801a23 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019f5:	8b 02                	mov    (%edx),%eax
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	75 e7                	jne    8019e2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019fb:	a1 20 50 80 00       	mov    0x805020,%eax
  801a00:	8b 40 48             	mov    0x48(%eax),%eax
  801a03:	83 ec 04             	sub    $0x4,%esp
  801a06:	51                   	push   %ecx
  801a07:	50                   	push   %eax
  801a08:	68 18 33 80 00       	push   $0x803318
  801a0d:	e8 54 ef ff ff       	call   800966 <cprintf>
	*dev = 0;
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 10             	sub    $0x10,%esp
  801a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801a3d:	c1 e8 0c             	shr    $0xc,%eax
  801a40:	50                   	push   %eax
  801a41:	e8 36 ff ff ff       	call   80197c <fd_lookup>
  801a46:	83 c4 08             	add    $0x8,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 05                	js     801a52 <fd_close+0x2d>
	    || fd != fd2)
  801a4d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a50:	74 0c                	je     801a5e <fd_close+0x39>
		return (must_exist ? r : 0);
  801a52:	84 db                	test   %bl,%bl
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	0f 44 c2             	cmove  %edx,%eax
  801a5c:	eb 41                	jmp    801a9f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a64:	50                   	push   %eax
  801a65:	ff 36                	pushl  (%esi)
  801a67:	e8 66 ff ff ff       	call   8019d2 <dev_lookup>
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	78 1a                	js     801a8f <fd_close+0x6a>
		if (dev->dev_close)
  801a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a78:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801a7b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801a80:	85 c0                	test   %eax,%eax
  801a82:	74 0b                	je     801a8f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	56                   	push   %esi
  801a88:	ff d0                	call   *%eax
  801a8a:	89 c3                	mov    %eax,%ebx
  801a8c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	56                   	push   %esi
  801a93:	6a 00                	push   $0x0
  801a95:	e8 d9 f8 ff ff       	call   801373 <sys_page_unmap>
	return r;
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	89 d8                	mov    %ebx,%eax
}
  801a9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa2:	5b                   	pop    %ebx
  801aa3:	5e                   	pop    %esi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	ff 75 08             	pushl  0x8(%ebp)
  801ab3:	e8 c4 fe ff ff       	call   80197c <fd_lookup>
  801ab8:	83 c4 08             	add    $0x8,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 10                	js     801acf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	6a 01                	push   $0x1
  801ac4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac7:	e8 59 ff ff ff       	call   801a25 <fd_close>
  801acc:	83 c4 10             	add    $0x10,%esp
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <close_all>:

void
close_all(void)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801ad8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	53                   	push   %ebx
  801ae1:	e8 c0 ff ff ff       	call   801aa6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801ae6:	83 c3 01             	add    $0x1,%ebx
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	83 fb 20             	cmp    $0x20,%ebx
  801aef:	75 ec                	jne    801add <close_all+0xc>
		close(i);
}
  801af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 2c             	sub    $0x2c,%esp
  801aff:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	ff 75 08             	pushl  0x8(%ebp)
  801b09:	e8 6e fe ff ff       	call   80197c <fd_lookup>
  801b0e:	83 c4 08             	add    $0x8,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	0f 88 c1 00 00 00    	js     801bda <dup+0xe4>
		return r;
	close(newfdnum);
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	56                   	push   %esi
  801b1d:	e8 84 ff ff ff       	call   801aa6 <close>

	newfd = INDEX2FD(newfdnum);
  801b22:	89 f3                	mov    %esi,%ebx
  801b24:	c1 e3 0c             	shl    $0xc,%ebx
  801b27:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801b2d:	83 c4 04             	add    $0x4,%esp
  801b30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b33:	e8 de fd ff ff       	call   801916 <fd2data>
  801b38:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801b3a:	89 1c 24             	mov    %ebx,(%esp)
  801b3d:	e8 d4 fd ff ff       	call   801916 <fd2data>
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801b48:	89 f8                	mov    %edi,%eax
  801b4a:	c1 e8 16             	shr    $0x16,%eax
  801b4d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b54:	a8 01                	test   $0x1,%al
  801b56:	74 37                	je     801b8f <dup+0x99>
  801b58:	89 f8                	mov    %edi,%eax
  801b5a:	c1 e8 0c             	shr    $0xc,%eax
  801b5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b64:	f6 c2 01             	test   $0x1,%dl
  801b67:	74 26                	je     801b8f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	25 07 0e 00 00       	and    $0xe07,%eax
  801b78:	50                   	push   %eax
  801b79:	ff 75 d4             	pushl  -0x2c(%ebp)
  801b7c:	6a 00                	push   $0x0
  801b7e:	57                   	push   %edi
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 ab f7 ff ff       	call   801331 <sys_page_map>
  801b86:	89 c7                	mov    %eax,%edi
  801b88:	83 c4 20             	add    $0x20,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 2e                	js     801bbd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b92:	89 d0                	mov    %edx,%eax
  801b94:	c1 e8 0c             	shr    $0xc,%eax
  801b97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b9e:	83 ec 0c             	sub    $0xc,%esp
  801ba1:	25 07 0e 00 00       	and    $0xe07,%eax
  801ba6:	50                   	push   %eax
  801ba7:	53                   	push   %ebx
  801ba8:	6a 00                	push   $0x0
  801baa:	52                   	push   %edx
  801bab:	6a 00                	push   $0x0
  801bad:	e8 7f f7 ff ff       	call   801331 <sys_page_map>
  801bb2:	89 c7                	mov    %eax,%edi
  801bb4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801bb7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801bb9:	85 ff                	test   %edi,%edi
  801bbb:	79 1d                	jns    801bda <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	53                   	push   %ebx
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 ab f7 ff ff       	call   801373 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bc8:	83 c4 08             	add    $0x8,%esp
  801bcb:	ff 75 d4             	pushl  -0x2c(%ebp)
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 9e f7 ff ff       	call   801373 <sys_page_unmap>
	return r;
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	89 f8                	mov    %edi,%eax
}
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	53                   	push   %ebx
  801be6:	83 ec 14             	sub    $0x14,%esp
  801be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bef:	50                   	push   %eax
  801bf0:	53                   	push   %ebx
  801bf1:	e8 86 fd ff ff       	call   80197c <fd_lookup>
  801bf6:	83 c4 08             	add    $0x8,%esp
  801bf9:	89 c2                	mov    %eax,%edx
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 6d                	js     801c6c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bff:	83 ec 08             	sub    $0x8,%esp
  801c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c05:	50                   	push   %eax
  801c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c09:	ff 30                	pushl  (%eax)
  801c0b:	e8 c2 fd ff ff       	call   8019d2 <dev_lookup>
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	85 c0                	test   %eax,%eax
  801c15:	78 4c                	js     801c63 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c17:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c1a:	8b 42 08             	mov    0x8(%edx),%eax
  801c1d:	83 e0 03             	and    $0x3,%eax
  801c20:	83 f8 01             	cmp    $0x1,%eax
  801c23:	75 21                	jne    801c46 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c25:	a1 20 50 80 00       	mov    0x805020,%eax
  801c2a:	8b 40 48             	mov    0x48(%eax),%eax
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	53                   	push   %ebx
  801c31:	50                   	push   %eax
  801c32:	68 5c 33 80 00       	push   $0x80335c
  801c37:	e8 2a ed ff ff       	call   800966 <cprintf>
		return -E_INVAL;
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c44:	eb 26                	jmp    801c6c <read+0x8a>
	}
	if (!dev->dev_read)
  801c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c49:	8b 40 08             	mov    0x8(%eax),%eax
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	74 17                	je     801c67 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	ff 75 10             	pushl  0x10(%ebp)
  801c56:	ff 75 0c             	pushl  0xc(%ebp)
  801c59:	52                   	push   %edx
  801c5a:	ff d0                	call   *%eax
  801c5c:	89 c2                	mov    %eax,%edx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	eb 09                	jmp    801c6c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c63:	89 c2                	mov    %eax,%edx
  801c65:	eb 05                	jmp    801c6c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801c67:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801c6c:	89 d0                	mov    %edx,%eax
  801c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	57                   	push   %edi
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c7f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c87:	eb 21                	jmp    801caa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c89:	83 ec 04             	sub    $0x4,%esp
  801c8c:	89 f0                	mov    %esi,%eax
  801c8e:	29 d8                	sub    %ebx,%eax
  801c90:	50                   	push   %eax
  801c91:	89 d8                	mov    %ebx,%eax
  801c93:	03 45 0c             	add    0xc(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	57                   	push   %edi
  801c98:	e8 45 ff ff ff       	call   801be2 <read>
		if (m < 0)
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 10                	js     801cb4 <readn+0x41>
			return m;
		if (m == 0)
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	74 0a                	je     801cb2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ca8:	01 c3                	add    %eax,%ebx
  801caa:	39 f3                	cmp    %esi,%ebx
  801cac:	72 db                	jb     801c89 <readn+0x16>
  801cae:	89 d8                	mov    %ebx,%eax
  801cb0:	eb 02                	jmp    801cb4 <readn+0x41>
  801cb2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	53                   	push   %ebx
  801cc0:	83 ec 14             	sub    $0x14,%esp
  801cc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc9:	50                   	push   %eax
  801cca:	53                   	push   %ebx
  801ccb:	e8 ac fc ff ff       	call   80197c <fd_lookup>
  801cd0:	83 c4 08             	add    $0x8,%esp
  801cd3:	89 c2                	mov    %eax,%edx
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 68                	js     801d41 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce3:	ff 30                	pushl  (%eax)
  801ce5:	e8 e8 fc ff ff       	call   8019d2 <dev_lookup>
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	78 47                	js     801d38 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cf8:	75 21                	jne    801d1b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801cfa:	a1 20 50 80 00       	mov    0x805020,%eax
  801cff:	8b 40 48             	mov    0x48(%eax),%eax
  801d02:	83 ec 04             	sub    $0x4,%esp
  801d05:	53                   	push   %ebx
  801d06:	50                   	push   %eax
  801d07:	68 78 33 80 00       	push   $0x803378
  801d0c:	e8 55 ec ff ff       	call   800966 <cprintf>
		return -E_INVAL;
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801d19:	eb 26                	jmp    801d41 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1e:	8b 52 0c             	mov    0xc(%edx),%edx
  801d21:	85 d2                	test   %edx,%edx
  801d23:	74 17                	je     801d3c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d25:	83 ec 04             	sub    $0x4,%esp
  801d28:	ff 75 10             	pushl  0x10(%ebp)
  801d2b:	ff 75 0c             	pushl  0xc(%ebp)
  801d2e:	50                   	push   %eax
  801d2f:	ff d2                	call   *%edx
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	eb 09                	jmp    801d41 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	eb 05                	jmp    801d41 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801d3c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801d41:	89 d0                	mov    %edx,%eax
  801d43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <seek>:

int
seek(int fdnum, off_t offset)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	ff 75 08             	pushl  0x8(%ebp)
  801d55:	e8 22 fc ff ff       	call   80197c <fd_lookup>
  801d5a:	83 c4 08             	add    $0x8,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 0e                	js     801d6f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d67:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	53                   	push   %ebx
  801d75:	83 ec 14             	sub    $0x14,%esp
  801d78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7e:	50                   	push   %eax
  801d7f:	53                   	push   %ebx
  801d80:	e8 f7 fb ff ff       	call   80197c <fd_lookup>
  801d85:	83 c4 08             	add    $0x8,%esp
  801d88:	89 c2                	mov    %eax,%edx
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 65                	js     801df3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d94:	50                   	push   %eax
  801d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d98:	ff 30                	pushl  (%eax)
  801d9a:	e8 33 fc ff ff       	call   8019d2 <dev_lookup>
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	78 44                	js     801dea <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801dad:	75 21                	jne    801dd0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801daf:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801db4:	8b 40 48             	mov    0x48(%eax),%eax
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	53                   	push   %ebx
  801dbb:	50                   	push   %eax
  801dbc:	68 38 33 80 00       	push   $0x803338
  801dc1:	e8 a0 eb ff ff       	call   800966 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801dce:	eb 23                	jmp    801df3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801dd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dd3:	8b 52 18             	mov    0x18(%edx),%edx
  801dd6:	85 d2                	test   %edx,%edx
  801dd8:	74 14                	je     801dee <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801dda:	83 ec 08             	sub    $0x8,%esp
  801ddd:	ff 75 0c             	pushl  0xc(%ebp)
  801de0:	50                   	push   %eax
  801de1:	ff d2                	call   *%edx
  801de3:	89 c2                	mov    %eax,%edx
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	eb 09                	jmp    801df3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dea:	89 c2                	mov    %eax,%edx
  801dec:	eb 05                	jmp    801df3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801dee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801df3:	89 d0                	mov    %edx,%eax
  801df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 14             	sub    $0x14,%esp
  801e01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	ff 75 08             	pushl  0x8(%ebp)
  801e0b:	e8 6c fb ff ff       	call   80197c <fd_lookup>
  801e10:	83 c4 08             	add    $0x8,%esp
  801e13:	89 c2                	mov    %eax,%edx
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 58                	js     801e71 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e19:	83 ec 08             	sub    $0x8,%esp
  801e1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e23:	ff 30                	pushl  (%eax)
  801e25:	e8 a8 fb ff ff       	call   8019d2 <dev_lookup>
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 37                	js     801e68 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e34:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801e38:	74 32                	je     801e6c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801e3a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801e3d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801e44:	00 00 00 
	stat->st_isdir = 0;
  801e47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e4e:	00 00 00 
	stat->st_dev = dev;
  801e51:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	53                   	push   %ebx
  801e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e5e:	ff 50 14             	call   *0x14(%eax)
  801e61:	89 c2                	mov    %eax,%edx
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	eb 09                	jmp    801e71 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e68:	89 c2                	mov    %eax,%edx
  801e6a:	eb 05                	jmp    801e71 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801e6c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801e71:	89 d0                	mov    %edx,%eax
  801e73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801e7d:	83 ec 08             	sub    $0x8,%esp
  801e80:	6a 00                	push   $0x0
  801e82:	ff 75 08             	pushl  0x8(%ebp)
  801e85:	e8 d6 01 00 00       	call   802060 <open>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 1b                	js     801eae <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801e93:	83 ec 08             	sub    $0x8,%esp
  801e96:	ff 75 0c             	pushl  0xc(%ebp)
  801e99:	50                   	push   %eax
  801e9a:	e8 5b ff ff ff       	call   801dfa <fstat>
  801e9f:	89 c6                	mov    %eax,%esi
	close(fd);
  801ea1:	89 1c 24             	mov    %ebx,(%esp)
  801ea4:	e8 fd fb ff ff       	call   801aa6 <close>
	return r;
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	89 f0                	mov    %esi,%eax
}
  801eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	56                   	push   %esi
  801eb9:	53                   	push   %ebx
  801eba:	89 c6                	mov    %eax,%esi
  801ebc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ebe:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801ec5:	75 12                	jne    801ed9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	6a 01                	push   $0x1
  801ecc:	e8 fc f9 ff ff       	call   8018cd <ipc_find_env>
  801ed1:	a3 18 50 80 00       	mov    %eax,0x805018
  801ed6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ed9:	6a 07                	push   $0x7
  801edb:	68 00 60 80 00       	push   $0x806000
  801ee0:	56                   	push   %esi
  801ee1:	ff 35 18 50 80 00    	pushl  0x805018
  801ee7:	e8 8d f9 ff ff       	call   801879 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801eec:	83 c4 0c             	add    $0xc,%esp
  801eef:	6a 00                	push   $0x0
  801ef1:	53                   	push   %ebx
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 19 f9 ff ff       	call   801812 <ipc_recv>
}
  801ef9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f06:	8b 45 08             	mov    0x8(%ebp),%eax
  801f09:	8b 40 0c             	mov    0xc(%eax),%eax
  801f0c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f14:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f19:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1e:	b8 02 00 00 00       	mov    $0x2,%eax
  801f23:	e8 8d ff ff ff       	call   801eb5 <fsipc>
}
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f30:	8b 45 08             	mov    0x8(%ebp),%eax
  801f33:	8b 40 0c             	mov    0xc(%eax),%eax
  801f36:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f40:	b8 06 00 00 00       	mov    $0x6,%eax
  801f45:	e8 6b ff ff ff       	call   801eb5 <fsipc>
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	53                   	push   %ebx
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f56:	8b 45 08             	mov    0x8(%ebp),%eax
  801f59:	8b 40 0c             	mov    0xc(%eax),%eax
  801f5c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f61:	ba 00 00 00 00       	mov    $0x0,%edx
  801f66:	b8 05 00 00 00       	mov    $0x5,%eax
  801f6b:	e8 45 ff ff ff       	call   801eb5 <fsipc>
  801f70:	85 c0                	test   %eax,%eax
  801f72:	78 2c                	js     801fa0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f74:	83 ec 08             	sub    $0x8,%esp
  801f77:	68 00 60 80 00       	push   $0x806000
  801f7c:	53                   	push   %ebx
  801f7d:	e8 69 ef ff ff       	call   800eeb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f82:	a1 80 60 80 00       	mov    0x806080,%eax
  801f87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f8d:	a1 84 60 80 00       	mov    0x806084,%eax
  801f92:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 0c             	sub    $0xc,%esp
  801fab:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801fae:	8b 55 08             	mov    0x8(%ebp),%edx
  801fb1:	8b 52 0c             	mov    0xc(%edx),%edx
  801fb4:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801fba:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801fbf:	50                   	push   %eax
  801fc0:	ff 75 0c             	pushl  0xc(%ebp)
  801fc3:	68 08 60 80 00       	push   $0x806008
  801fc8:	e8 b0 f0 ff ff       	call   80107d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd2:	b8 04 00 00 00       	mov    $0x4,%eax
  801fd7:	e8 d9 fe ff ff       	call   801eb5 <fsipc>

}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	8b 40 0c             	mov    0xc(%eax),%eax
  801fec:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ff1:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ff7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffc:	b8 03 00 00 00       	mov    $0x3,%eax
  802001:	e8 af fe ff ff       	call   801eb5 <fsipc>
  802006:	89 c3                	mov    %eax,%ebx
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 4b                	js     802057 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80200c:	39 c6                	cmp    %eax,%esi
  80200e:	73 16                	jae    802026 <devfile_read+0x48>
  802010:	68 ac 33 80 00       	push   $0x8033ac
  802015:	68 b3 33 80 00       	push   $0x8033b3
  80201a:	6a 7c                	push   $0x7c
  80201c:	68 c8 33 80 00       	push   $0x8033c8
  802021:	e8 67 e8 ff ff       	call   80088d <_panic>
	assert(r <= PGSIZE);
  802026:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80202b:	7e 16                	jle    802043 <devfile_read+0x65>
  80202d:	68 d3 33 80 00       	push   $0x8033d3
  802032:	68 b3 33 80 00       	push   $0x8033b3
  802037:	6a 7d                	push   $0x7d
  802039:	68 c8 33 80 00       	push   $0x8033c8
  80203e:	e8 4a e8 ff ff       	call   80088d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	50                   	push   %eax
  802047:	68 00 60 80 00       	push   $0x806000
  80204c:	ff 75 0c             	pushl  0xc(%ebp)
  80204f:	e8 29 f0 ff ff       	call   80107d <memmove>
	return r;
  802054:	83 c4 10             	add    $0x10,%esp
}
  802057:	89 d8                	mov    %ebx,%eax
  802059:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205c:	5b                   	pop    %ebx
  80205d:	5e                   	pop    %esi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	53                   	push   %ebx
  802064:	83 ec 20             	sub    $0x20,%esp
  802067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80206a:	53                   	push   %ebx
  80206b:	e8 42 ee ff ff       	call   800eb2 <strlen>
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802078:	7f 67                	jg     8020e1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80207a:	83 ec 0c             	sub    $0xc,%esp
  80207d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802080:	50                   	push   %eax
  802081:	e8 a7 f8 ff ff       	call   80192d <fd_alloc>
  802086:	83 c4 10             	add    $0x10,%esp
		return r;
  802089:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80208b:	85 c0                	test   %eax,%eax
  80208d:	78 57                	js     8020e6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80208f:	83 ec 08             	sub    $0x8,%esp
  802092:	53                   	push   %ebx
  802093:	68 00 60 80 00       	push   $0x806000
  802098:	e8 4e ee ff ff       	call   800eeb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80209d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8020a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ad:	e8 03 fe ff ff       	call   801eb5 <fsipc>
  8020b2:	89 c3                	mov    %eax,%ebx
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	79 14                	jns    8020cf <open+0x6f>
		fd_close(fd, 0);
  8020bb:	83 ec 08             	sub    $0x8,%esp
  8020be:	6a 00                	push   $0x0
  8020c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c3:	e8 5d f9 ff ff       	call   801a25 <fd_close>
		return r;
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	89 da                	mov    %ebx,%edx
  8020cd:	eb 17                	jmp    8020e6 <open+0x86>
	}

	return fd2num(fd);
  8020cf:	83 ec 0c             	sub    $0xc,%esp
  8020d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d5:	e8 2c f8 ff ff       	call   801906 <fd2num>
  8020da:	89 c2                	mov    %eax,%edx
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	eb 05                	jmp    8020e6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8020e1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    

008020ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8020fd:	e8 b3 fd ff ff       	call   801eb5 <fsipc>
}
  802102:	c9                   	leave  
  802103:	c3                   	ret    

00802104 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80210a:	68 df 33 80 00       	push   $0x8033df
  80210f:	ff 75 0c             	pushl  0xc(%ebp)
  802112:	e8 d4 ed ff ff       	call   800eeb <strcpy>
	return 0;
}
  802117:	b8 00 00 00 00       	mov    $0x0,%eax
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	53                   	push   %ebx
  802122:	83 ec 10             	sub    $0x10,%esp
  802125:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802128:	53                   	push   %ebx
  802129:	e8 87 09 00 00       	call   802ab5 <pageref>
  80212e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802131:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802136:	83 f8 01             	cmp    $0x1,%eax
  802139:	75 10                	jne    80214b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80213b:	83 ec 0c             	sub    $0xc,%esp
  80213e:	ff 73 0c             	pushl  0xc(%ebx)
  802141:	e8 c0 02 00 00       	call   802406 <nsipc_close>
  802146:	89 c2                	mov    %eax,%edx
  802148:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802150:	c9                   	leave  
  802151:	c3                   	ret    

00802152 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
  802155:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802158:	6a 00                	push   $0x0
  80215a:	ff 75 10             	pushl  0x10(%ebp)
  80215d:	ff 75 0c             	pushl  0xc(%ebp)
  802160:	8b 45 08             	mov    0x8(%ebp),%eax
  802163:	ff 70 0c             	pushl  0xc(%eax)
  802166:	e8 78 03 00 00       	call   8024e3 <nsipc_send>
}
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    

0080216d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802173:	6a 00                	push   $0x0
  802175:	ff 75 10             	pushl  0x10(%ebp)
  802178:	ff 75 0c             	pushl  0xc(%ebp)
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	ff 70 0c             	pushl  0xc(%eax)
  802181:	e8 f1 02 00 00       	call   802477 <nsipc_recv>
}
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80218e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802191:	52                   	push   %edx
  802192:	50                   	push   %eax
  802193:	e8 e4 f7 ff ff       	call   80197c <fd_lookup>
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	85 c0                	test   %eax,%eax
  80219d:	78 17                	js     8021b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80219f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a2:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  8021a8:	39 08                	cmp    %ecx,(%eax)
  8021aa:	75 05                	jne    8021b1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8021af:	eb 05                	jmp    8021b6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8021b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	56                   	push   %esi
  8021bc:	53                   	push   %ebx
  8021bd:	83 ec 1c             	sub    $0x1c,%esp
  8021c0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8021c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c5:	50                   	push   %eax
  8021c6:	e8 62 f7 ff ff       	call   80192d <fd_alloc>
  8021cb:	89 c3                	mov    %eax,%ebx
  8021cd:	83 c4 10             	add    $0x10,%esp
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 1b                	js     8021ef <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8021d4:	83 ec 04             	sub    $0x4,%esp
  8021d7:	68 07 04 00 00       	push   $0x407
  8021dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021df:	6a 00                	push   $0x0
  8021e1:	e8 08 f1 ff ff       	call   8012ee <sys_page_alloc>
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	83 c4 10             	add    $0x10,%esp
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	79 10                	jns    8021ff <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8021ef:	83 ec 0c             	sub    $0xc,%esp
  8021f2:	56                   	push   %esi
  8021f3:	e8 0e 02 00 00       	call   802406 <nsipc_close>
		return r;
  8021f8:	83 c4 10             	add    $0x10,%esp
  8021fb:	89 d8                	mov    %ebx,%eax
  8021fd:	eb 24                	jmp    802223 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8021ff:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802205:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802208:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80220a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802214:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802217:	83 ec 0c             	sub    $0xc,%esp
  80221a:	50                   	push   %eax
  80221b:	e8 e6 f6 ff ff       	call   801906 <fd2num>
  802220:	83 c4 10             	add    $0x10,%esp
}
  802223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802226:	5b                   	pop    %ebx
  802227:	5e                   	pop    %esi
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    

0080222a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
  80222d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802230:	8b 45 08             	mov    0x8(%ebp),%eax
  802233:	e8 50 ff ff ff       	call   802188 <fd2sockid>
		return r;
  802238:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80223a:	85 c0                	test   %eax,%eax
  80223c:	78 1f                	js     80225d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80223e:	83 ec 04             	sub    $0x4,%esp
  802241:	ff 75 10             	pushl  0x10(%ebp)
  802244:	ff 75 0c             	pushl  0xc(%ebp)
  802247:	50                   	push   %eax
  802248:	e8 12 01 00 00       	call   80235f <nsipc_accept>
  80224d:	83 c4 10             	add    $0x10,%esp
		return r;
  802250:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802252:	85 c0                	test   %eax,%eax
  802254:	78 07                	js     80225d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802256:	e8 5d ff ff ff       	call   8021b8 <alloc_sockfd>
  80225b:	89 c1                	mov    %eax,%ecx
}
  80225d:	89 c8                	mov    %ecx,%eax
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802267:	8b 45 08             	mov    0x8(%ebp),%eax
  80226a:	e8 19 ff ff ff       	call   802188 <fd2sockid>
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 12                	js     802285 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802273:	83 ec 04             	sub    $0x4,%esp
  802276:	ff 75 10             	pushl  0x10(%ebp)
  802279:	ff 75 0c             	pushl  0xc(%ebp)
  80227c:	50                   	push   %eax
  80227d:	e8 2d 01 00 00       	call   8023af <nsipc_bind>
  802282:	83 c4 10             	add    $0x10,%esp
}
  802285:	c9                   	leave  
  802286:	c3                   	ret    

00802287 <shutdown>:

int
shutdown(int s, int how)
{
  802287:	55                   	push   %ebp
  802288:	89 e5                	mov    %esp,%ebp
  80228a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80228d:	8b 45 08             	mov    0x8(%ebp),%eax
  802290:	e8 f3 fe ff ff       	call   802188 <fd2sockid>
  802295:	85 c0                	test   %eax,%eax
  802297:	78 0f                	js     8022a8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802299:	83 ec 08             	sub    $0x8,%esp
  80229c:	ff 75 0c             	pushl  0xc(%ebp)
  80229f:	50                   	push   %eax
  8022a0:	e8 3f 01 00 00       	call   8023e4 <nsipc_shutdown>
  8022a5:	83 c4 10             	add    $0x10,%esp
}
  8022a8:	c9                   	leave  
  8022a9:	c3                   	ret    

008022aa <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b3:	e8 d0 fe ff ff       	call   802188 <fd2sockid>
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	78 12                	js     8022ce <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8022bc:	83 ec 04             	sub    $0x4,%esp
  8022bf:	ff 75 10             	pushl  0x10(%ebp)
  8022c2:	ff 75 0c             	pushl  0xc(%ebp)
  8022c5:	50                   	push   %eax
  8022c6:	e8 55 01 00 00       	call   802420 <nsipc_connect>
  8022cb:	83 c4 10             	add    $0x10,%esp
}
  8022ce:	c9                   	leave  
  8022cf:	c3                   	ret    

008022d0 <listen>:

int
listen(int s, int backlog)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d9:	e8 aa fe ff ff       	call   802188 <fd2sockid>
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	78 0f                	js     8022f1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8022e2:	83 ec 08             	sub    $0x8,%esp
  8022e5:	ff 75 0c             	pushl  0xc(%ebp)
  8022e8:	50                   	push   %eax
  8022e9:	e8 67 01 00 00       	call   802455 <nsipc_listen>
  8022ee:	83 c4 10             	add    $0x10,%esp
}
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8022f9:	ff 75 10             	pushl  0x10(%ebp)
  8022fc:	ff 75 0c             	pushl  0xc(%ebp)
  8022ff:	ff 75 08             	pushl  0x8(%ebp)
  802302:	e8 3a 02 00 00       	call   802541 <nsipc_socket>
  802307:	83 c4 10             	add    $0x10,%esp
  80230a:	85 c0                	test   %eax,%eax
  80230c:	78 05                	js     802313 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80230e:	e8 a5 fe ff ff       	call   8021b8 <alloc_sockfd>
}
  802313:	c9                   	leave  
  802314:	c3                   	ret    

00802315 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	53                   	push   %ebx
  802319:	83 ec 04             	sub    $0x4,%esp
  80231c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80231e:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  802325:	75 12                	jne    802339 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802327:	83 ec 0c             	sub    $0xc,%esp
  80232a:	6a 02                	push   $0x2
  80232c:	e8 9c f5 ff ff       	call   8018cd <ipc_find_env>
  802331:	a3 1c 50 80 00       	mov    %eax,0x80501c
  802336:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802339:	6a 07                	push   $0x7
  80233b:	68 00 70 80 00       	push   $0x807000
  802340:	53                   	push   %ebx
  802341:	ff 35 1c 50 80 00    	pushl  0x80501c
  802347:	e8 2d f5 ff ff       	call   801879 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80234c:	83 c4 0c             	add    $0xc,%esp
  80234f:	6a 00                	push   $0x0
  802351:	6a 00                	push   $0x0
  802353:	6a 00                	push   $0x0
  802355:	e8 b8 f4 ff ff       	call   801812 <ipc_recv>
}
  80235a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80235d:	c9                   	leave  
  80235e:	c3                   	ret    

0080235f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802367:	8b 45 08             	mov    0x8(%ebp),%eax
  80236a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80236f:	8b 06                	mov    (%esi),%eax
  802371:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	e8 95 ff ff ff       	call   802315 <nsipc>
  802380:	89 c3                	mov    %eax,%ebx
  802382:	85 c0                	test   %eax,%eax
  802384:	78 20                	js     8023a6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802386:	83 ec 04             	sub    $0x4,%esp
  802389:	ff 35 10 70 80 00    	pushl  0x807010
  80238f:	68 00 70 80 00       	push   $0x807000
  802394:	ff 75 0c             	pushl  0xc(%ebp)
  802397:	e8 e1 ec ff ff       	call   80107d <memmove>
		*addrlen = ret->ret_addrlen;
  80239c:	a1 10 70 80 00       	mov    0x807010,%eax
  8023a1:	89 06                	mov    %eax,(%esi)
  8023a3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8023a6:	89 d8                	mov    %ebx,%eax
  8023a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ab:	5b                   	pop    %ebx
  8023ac:	5e                   	pop    %esi
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    

008023af <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	53                   	push   %ebx
  8023b3:	83 ec 08             	sub    $0x8,%esp
  8023b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8023b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8023c1:	53                   	push   %ebx
  8023c2:	ff 75 0c             	pushl  0xc(%ebp)
  8023c5:	68 04 70 80 00       	push   $0x807004
  8023ca:	e8 ae ec ff ff       	call   80107d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023cf:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8023d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8023da:	e8 36 ff ff ff       	call   802315 <nsipc>
}
  8023df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023e2:	c9                   	leave  
  8023e3:	c3                   	ret    

008023e4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8023ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ed:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8023f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f5:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8023fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8023ff:	e8 11 ff ff ff       	call   802315 <nsipc>
}
  802404:	c9                   	leave  
  802405:	c3                   	ret    

00802406 <nsipc_close>:

int
nsipc_close(int s)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
  80240f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802414:	b8 04 00 00 00       	mov    $0x4,%eax
  802419:	e8 f7 fe ff ff       	call   802315 <nsipc>
}
  80241e:	c9                   	leave  
  80241f:	c3                   	ret    

00802420 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	53                   	push   %ebx
  802424:	83 ec 08             	sub    $0x8,%esp
  802427:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80242a:	8b 45 08             	mov    0x8(%ebp),%eax
  80242d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802432:	53                   	push   %ebx
  802433:	ff 75 0c             	pushl  0xc(%ebp)
  802436:	68 04 70 80 00       	push   $0x807004
  80243b:	e8 3d ec ff ff       	call   80107d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802440:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802446:	b8 05 00 00 00       	mov    $0x5,%eax
  80244b:	e8 c5 fe ff ff       	call   802315 <nsipc>
}
  802450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802453:	c9                   	leave  
  802454:	c3                   	ret    

00802455 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80245b:	8b 45 08             	mov    0x8(%ebp),%eax
  80245e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802463:	8b 45 0c             	mov    0xc(%ebp),%eax
  802466:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80246b:	b8 06 00 00 00       	mov    $0x6,%eax
  802470:	e8 a0 fe ff ff       	call   802315 <nsipc>
}
  802475:	c9                   	leave  
  802476:	c3                   	ret    

00802477 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	56                   	push   %esi
  80247b:	53                   	push   %ebx
  80247c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
  802482:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802487:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80248d:	8b 45 14             	mov    0x14(%ebp),%eax
  802490:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802495:	b8 07 00 00 00       	mov    $0x7,%eax
  80249a:	e8 76 fe ff ff       	call   802315 <nsipc>
  80249f:	89 c3                	mov    %eax,%ebx
  8024a1:	85 c0                	test   %eax,%eax
  8024a3:	78 35                	js     8024da <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8024a5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8024aa:	7f 04                	jg     8024b0 <nsipc_recv+0x39>
  8024ac:	39 c6                	cmp    %eax,%esi
  8024ae:	7d 16                	jge    8024c6 <nsipc_recv+0x4f>
  8024b0:	68 eb 33 80 00       	push   $0x8033eb
  8024b5:	68 b3 33 80 00       	push   $0x8033b3
  8024ba:	6a 62                	push   $0x62
  8024bc:	68 00 34 80 00       	push   $0x803400
  8024c1:	e8 c7 e3 ff ff       	call   80088d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8024c6:	83 ec 04             	sub    $0x4,%esp
  8024c9:	50                   	push   %eax
  8024ca:	68 00 70 80 00       	push   $0x807000
  8024cf:	ff 75 0c             	pushl  0xc(%ebp)
  8024d2:	e8 a6 eb ff ff       	call   80107d <memmove>
  8024d7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8024da:	89 d8                	mov    %ebx,%eax
  8024dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    

008024e3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	53                   	push   %ebx
  8024e7:	83 ec 04             	sub    $0x4,%esp
  8024ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8024ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f0:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8024f5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8024fb:	7e 16                	jle    802513 <nsipc_send+0x30>
  8024fd:	68 0c 34 80 00       	push   $0x80340c
  802502:	68 b3 33 80 00       	push   $0x8033b3
  802507:	6a 6d                	push   $0x6d
  802509:	68 00 34 80 00       	push   $0x803400
  80250e:	e8 7a e3 ff ff       	call   80088d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802513:	83 ec 04             	sub    $0x4,%esp
  802516:	53                   	push   %ebx
  802517:	ff 75 0c             	pushl  0xc(%ebp)
  80251a:	68 0c 70 80 00       	push   $0x80700c
  80251f:	e8 59 eb ff ff       	call   80107d <memmove>
	nsipcbuf.send.req_size = size;
  802524:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80252a:	8b 45 14             	mov    0x14(%ebp),%eax
  80252d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802532:	b8 08 00 00 00       	mov    $0x8,%eax
  802537:	e8 d9 fd ff ff       	call   802315 <nsipc>
}
  80253c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80253f:	c9                   	leave  
  802540:	c3                   	ret    

00802541 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802541:	55                   	push   %ebp
  802542:	89 e5                	mov    %esp,%ebp
  802544:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802547:	8b 45 08             	mov    0x8(%ebp),%eax
  80254a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80254f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802552:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802557:	8b 45 10             	mov    0x10(%ebp),%eax
  80255a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80255f:	b8 09 00 00 00       	mov    $0x9,%eax
  802564:	e8 ac fd ff ff       	call   802315 <nsipc>
}
  802569:	c9                   	leave  
  80256a:	c3                   	ret    

0080256b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80256b:	55                   	push   %ebp
  80256c:	89 e5                	mov    %esp,%ebp
  80256e:	56                   	push   %esi
  80256f:	53                   	push   %ebx
  802570:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802573:	83 ec 0c             	sub    $0xc,%esp
  802576:	ff 75 08             	pushl  0x8(%ebp)
  802579:	e8 98 f3 ff ff       	call   801916 <fd2data>
  80257e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802580:	83 c4 08             	add    $0x8,%esp
  802583:	68 18 34 80 00       	push   $0x803418
  802588:	53                   	push   %ebx
  802589:	e8 5d e9 ff ff       	call   800eeb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80258e:	8b 46 04             	mov    0x4(%esi),%eax
  802591:	2b 06                	sub    (%esi),%eax
  802593:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802599:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8025a0:	00 00 00 
	stat->st_dev = &devpipe;
  8025a3:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8025aa:	40 80 00 
	return 0;
}
  8025ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025b5:	5b                   	pop    %ebx
  8025b6:	5e                   	pop    %esi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    

008025b9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	53                   	push   %ebx
  8025bd:	83 ec 0c             	sub    $0xc,%esp
  8025c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8025c3:	53                   	push   %ebx
  8025c4:	6a 00                	push   $0x0
  8025c6:	e8 a8 ed ff ff       	call   801373 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8025cb:	89 1c 24             	mov    %ebx,(%esp)
  8025ce:	e8 43 f3 ff ff       	call   801916 <fd2data>
  8025d3:	83 c4 08             	add    $0x8,%esp
  8025d6:	50                   	push   %eax
  8025d7:	6a 00                	push   $0x0
  8025d9:	e8 95 ed ff ff       	call   801373 <sys_page_unmap>
}
  8025de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025e1:	c9                   	leave  
  8025e2:	c3                   	ret    

008025e3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8025e3:	55                   	push   %ebp
  8025e4:	89 e5                	mov    %esp,%ebp
  8025e6:	57                   	push   %edi
  8025e7:	56                   	push   %esi
  8025e8:	53                   	push   %ebx
  8025e9:	83 ec 1c             	sub    $0x1c,%esp
  8025ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8025ef:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8025f1:	a1 20 50 80 00       	mov    0x805020,%eax
  8025f6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8025f9:	83 ec 0c             	sub    $0xc,%esp
  8025fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8025ff:	e8 b1 04 00 00       	call   802ab5 <pageref>
  802604:	89 c3                	mov    %eax,%ebx
  802606:	89 3c 24             	mov    %edi,(%esp)
  802609:	e8 a7 04 00 00       	call   802ab5 <pageref>
  80260e:	83 c4 10             	add    $0x10,%esp
  802611:	39 c3                	cmp    %eax,%ebx
  802613:	0f 94 c1             	sete   %cl
  802616:	0f b6 c9             	movzbl %cl,%ecx
  802619:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80261c:	8b 15 20 50 80 00    	mov    0x805020,%edx
  802622:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802625:	39 ce                	cmp    %ecx,%esi
  802627:	74 1b                	je     802644 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802629:	39 c3                	cmp    %eax,%ebx
  80262b:	75 c4                	jne    8025f1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80262d:	8b 42 58             	mov    0x58(%edx),%eax
  802630:	ff 75 e4             	pushl  -0x1c(%ebp)
  802633:	50                   	push   %eax
  802634:	56                   	push   %esi
  802635:	68 1f 34 80 00       	push   $0x80341f
  80263a:	e8 27 e3 ff ff       	call   800966 <cprintf>
  80263f:	83 c4 10             	add    $0x10,%esp
  802642:	eb ad                	jmp    8025f1 <_pipeisclosed+0xe>
	}
}
  802644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264a:	5b                   	pop    %ebx
  80264b:	5e                   	pop    %esi
  80264c:	5f                   	pop    %edi
  80264d:	5d                   	pop    %ebp
  80264e:	c3                   	ret    

0080264f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80264f:	55                   	push   %ebp
  802650:	89 e5                	mov    %esp,%ebp
  802652:	57                   	push   %edi
  802653:	56                   	push   %esi
  802654:	53                   	push   %ebx
  802655:	83 ec 28             	sub    $0x28,%esp
  802658:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80265b:	56                   	push   %esi
  80265c:	e8 b5 f2 ff ff       	call   801916 <fd2data>
  802661:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802663:	83 c4 10             	add    $0x10,%esp
  802666:	bf 00 00 00 00       	mov    $0x0,%edi
  80266b:	eb 4b                	jmp    8026b8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80266d:	89 da                	mov    %ebx,%edx
  80266f:	89 f0                	mov    %esi,%eax
  802671:	e8 6d ff ff ff       	call   8025e3 <_pipeisclosed>
  802676:	85 c0                	test   %eax,%eax
  802678:	75 48                	jne    8026c2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80267a:	e8 50 ec ff ff       	call   8012cf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80267f:	8b 43 04             	mov    0x4(%ebx),%eax
  802682:	8b 0b                	mov    (%ebx),%ecx
  802684:	8d 51 20             	lea    0x20(%ecx),%edx
  802687:	39 d0                	cmp    %edx,%eax
  802689:	73 e2                	jae    80266d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80268b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80268e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802692:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802695:	89 c2                	mov    %eax,%edx
  802697:	c1 fa 1f             	sar    $0x1f,%edx
  80269a:	89 d1                	mov    %edx,%ecx
  80269c:	c1 e9 1b             	shr    $0x1b,%ecx
  80269f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8026a2:	83 e2 1f             	and    $0x1f,%edx
  8026a5:	29 ca                	sub    %ecx,%edx
  8026a7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8026ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8026af:	83 c0 01             	add    $0x1,%eax
  8026b2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026b5:	83 c7 01             	add    $0x1,%edi
  8026b8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8026bb:	75 c2                	jne    80267f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8026bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8026c0:	eb 05                	jmp    8026c7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8026c2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8026c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026ca:	5b                   	pop    %ebx
  8026cb:	5e                   	pop    %esi
  8026cc:	5f                   	pop    %edi
  8026cd:	5d                   	pop    %ebp
  8026ce:	c3                   	ret    

008026cf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026cf:	55                   	push   %ebp
  8026d0:	89 e5                	mov    %esp,%ebp
  8026d2:	57                   	push   %edi
  8026d3:	56                   	push   %esi
  8026d4:	53                   	push   %ebx
  8026d5:	83 ec 18             	sub    $0x18,%esp
  8026d8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8026db:	57                   	push   %edi
  8026dc:	e8 35 f2 ff ff       	call   801916 <fd2data>
  8026e1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026e3:	83 c4 10             	add    $0x10,%esp
  8026e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026eb:	eb 3d                	jmp    80272a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8026ed:	85 db                	test   %ebx,%ebx
  8026ef:	74 04                	je     8026f5 <devpipe_read+0x26>
				return i;
  8026f1:	89 d8                	mov    %ebx,%eax
  8026f3:	eb 44                	jmp    802739 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8026f5:	89 f2                	mov    %esi,%edx
  8026f7:	89 f8                	mov    %edi,%eax
  8026f9:	e8 e5 fe ff ff       	call   8025e3 <_pipeisclosed>
  8026fe:	85 c0                	test   %eax,%eax
  802700:	75 32                	jne    802734 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802702:	e8 c8 eb ff ff       	call   8012cf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802707:	8b 06                	mov    (%esi),%eax
  802709:	3b 46 04             	cmp    0x4(%esi),%eax
  80270c:	74 df                	je     8026ed <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80270e:	99                   	cltd   
  80270f:	c1 ea 1b             	shr    $0x1b,%edx
  802712:	01 d0                	add    %edx,%eax
  802714:	83 e0 1f             	and    $0x1f,%eax
  802717:	29 d0                	sub    %edx,%eax
  802719:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80271e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802721:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802724:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802727:	83 c3 01             	add    $0x1,%ebx
  80272a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80272d:	75 d8                	jne    802707 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80272f:	8b 45 10             	mov    0x10(%ebp),%eax
  802732:	eb 05                	jmp    802739 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802734:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802739:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80273c:	5b                   	pop    %ebx
  80273d:	5e                   	pop    %esi
  80273e:	5f                   	pop    %edi
  80273f:	5d                   	pop    %ebp
  802740:	c3                   	ret    

00802741 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802741:	55                   	push   %ebp
  802742:	89 e5                	mov    %esp,%ebp
  802744:	56                   	push   %esi
  802745:	53                   	push   %ebx
  802746:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80274c:	50                   	push   %eax
  80274d:	e8 db f1 ff ff       	call   80192d <fd_alloc>
  802752:	83 c4 10             	add    $0x10,%esp
  802755:	89 c2                	mov    %eax,%edx
  802757:	85 c0                	test   %eax,%eax
  802759:	0f 88 2c 01 00 00    	js     80288b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80275f:	83 ec 04             	sub    $0x4,%esp
  802762:	68 07 04 00 00       	push   $0x407
  802767:	ff 75 f4             	pushl  -0xc(%ebp)
  80276a:	6a 00                	push   $0x0
  80276c:	e8 7d eb ff ff       	call   8012ee <sys_page_alloc>
  802771:	83 c4 10             	add    $0x10,%esp
  802774:	89 c2                	mov    %eax,%edx
  802776:	85 c0                	test   %eax,%eax
  802778:	0f 88 0d 01 00 00    	js     80288b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80277e:	83 ec 0c             	sub    $0xc,%esp
  802781:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802784:	50                   	push   %eax
  802785:	e8 a3 f1 ff ff       	call   80192d <fd_alloc>
  80278a:	89 c3                	mov    %eax,%ebx
  80278c:	83 c4 10             	add    $0x10,%esp
  80278f:	85 c0                	test   %eax,%eax
  802791:	0f 88 e2 00 00 00    	js     802879 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802797:	83 ec 04             	sub    $0x4,%esp
  80279a:	68 07 04 00 00       	push   $0x407
  80279f:	ff 75 f0             	pushl  -0x10(%ebp)
  8027a2:	6a 00                	push   $0x0
  8027a4:	e8 45 eb ff ff       	call   8012ee <sys_page_alloc>
  8027a9:	89 c3                	mov    %eax,%ebx
  8027ab:	83 c4 10             	add    $0x10,%esp
  8027ae:	85 c0                	test   %eax,%eax
  8027b0:	0f 88 c3 00 00 00    	js     802879 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8027b6:	83 ec 0c             	sub    $0xc,%esp
  8027b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8027bc:	e8 55 f1 ff ff       	call   801916 <fd2data>
  8027c1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027c3:	83 c4 0c             	add    $0xc,%esp
  8027c6:	68 07 04 00 00       	push   $0x407
  8027cb:	50                   	push   %eax
  8027cc:	6a 00                	push   $0x0
  8027ce:	e8 1b eb ff ff       	call   8012ee <sys_page_alloc>
  8027d3:	89 c3                	mov    %eax,%ebx
  8027d5:	83 c4 10             	add    $0x10,%esp
  8027d8:	85 c0                	test   %eax,%eax
  8027da:	0f 88 89 00 00 00    	js     802869 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027e0:	83 ec 0c             	sub    $0xc,%esp
  8027e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8027e6:	e8 2b f1 ff ff       	call   801916 <fd2data>
  8027eb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8027f2:	50                   	push   %eax
  8027f3:	6a 00                	push   $0x0
  8027f5:	56                   	push   %esi
  8027f6:	6a 00                	push   $0x0
  8027f8:	e8 34 eb ff ff       	call   801331 <sys_page_map>
  8027fd:	89 c3                	mov    %eax,%ebx
  8027ff:	83 c4 20             	add    $0x20,%esp
  802802:	85 c0                	test   %eax,%eax
  802804:	78 55                	js     80285b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802806:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80280c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80280f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802811:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802814:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80281b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802824:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802829:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802830:	83 ec 0c             	sub    $0xc,%esp
  802833:	ff 75 f4             	pushl  -0xc(%ebp)
  802836:	e8 cb f0 ff ff       	call   801906 <fd2num>
  80283b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80283e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802840:	83 c4 04             	add    $0x4,%esp
  802843:	ff 75 f0             	pushl  -0x10(%ebp)
  802846:	e8 bb f0 ff ff       	call   801906 <fd2num>
  80284b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80284e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802851:	83 c4 10             	add    $0x10,%esp
  802854:	ba 00 00 00 00       	mov    $0x0,%edx
  802859:	eb 30                	jmp    80288b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80285b:	83 ec 08             	sub    $0x8,%esp
  80285e:	56                   	push   %esi
  80285f:	6a 00                	push   $0x0
  802861:	e8 0d eb ff ff       	call   801373 <sys_page_unmap>
  802866:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802869:	83 ec 08             	sub    $0x8,%esp
  80286c:	ff 75 f0             	pushl  -0x10(%ebp)
  80286f:	6a 00                	push   $0x0
  802871:	e8 fd ea ff ff       	call   801373 <sys_page_unmap>
  802876:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802879:	83 ec 08             	sub    $0x8,%esp
  80287c:	ff 75 f4             	pushl  -0xc(%ebp)
  80287f:	6a 00                	push   $0x0
  802881:	e8 ed ea ff ff       	call   801373 <sys_page_unmap>
  802886:	83 c4 10             	add    $0x10,%esp
  802889:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80288b:	89 d0                	mov    %edx,%eax
  80288d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802890:	5b                   	pop    %ebx
  802891:	5e                   	pop    %esi
  802892:	5d                   	pop    %ebp
  802893:	c3                   	ret    

00802894 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802894:	55                   	push   %ebp
  802895:	89 e5                	mov    %esp,%ebp
  802897:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80289a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80289d:	50                   	push   %eax
  80289e:	ff 75 08             	pushl  0x8(%ebp)
  8028a1:	e8 d6 f0 ff ff       	call   80197c <fd_lookup>
  8028a6:	83 c4 10             	add    $0x10,%esp
  8028a9:	85 c0                	test   %eax,%eax
  8028ab:	78 18                	js     8028c5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8028ad:	83 ec 0c             	sub    $0xc,%esp
  8028b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8028b3:	e8 5e f0 ff ff       	call   801916 <fd2data>
	return _pipeisclosed(fd, p);
  8028b8:	89 c2                	mov    %eax,%edx
  8028ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028bd:	e8 21 fd ff ff       	call   8025e3 <_pipeisclosed>
  8028c2:	83 c4 10             	add    $0x10,%esp
}
  8028c5:	c9                   	leave  
  8028c6:	c3                   	ret    

008028c7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8028c7:	55                   	push   %ebp
  8028c8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8028ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8028cf:	5d                   	pop    %ebp
  8028d0:	c3                   	ret    

008028d1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8028d1:	55                   	push   %ebp
  8028d2:	89 e5                	mov    %esp,%ebp
  8028d4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8028d7:	68 37 34 80 00       	push   $0x803437
  8028dc:	ff 75 0c             	pushl  0xc(%ebp)
  8028df:	e8 07 e6 ff ff       	call   800eeb <strcpy>
	return 0;
}
  8028e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8028e9:	c9                   	leave  
  8028ea:	c3                   	ret    

008028eb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8028eb:	55                   	push   %ebp
  8028ec:	89 e5                	mov    %esp,%ebp
  8028ee:	57                   	push   %edi
  8028ef:	56                   	push   %esi
  8028f0:	53                   	push   %ebx
  8028f1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8028f7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8028fc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802902:	eb 2d                	jmp    802931 <devcons_write+0x46>
		m = n - tot;
  802904:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802907:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802909:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80290c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802911:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802914:	83 ec 04             	sub    $0x4,%esp
  802917:	53                   	push   %ebx
  802918:	03 45 0c             	add    0xc(%ebp),%eax
  80291b:	50                   	push   %eax
  80291c:	57                   	push   %edi
  80291d:	e8 5b e7 ff ff       	call   80107d <memmove>
		sys_cputs(buf, m);
  802922:	83 c4 08             	add    $0x8,%esp
  802925:	53                   	push   %ebx
  802926:	57                   	push   %edi
  802927:	e8 06 e9 ff ff       	call   801232 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80292c:	01 de                	add    %ebx,%esi
  80292e:	83 c4 10             	add    $0x10,%esp
  802931:	89 f0                	mov    %esi,%eax
  802933:	3b 75 10             	cmp    0x10(%ebp),%esi
  802936:	72 cc                	jb     802904 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802938:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80293b:	5b                   	pop    %ebx
  80293c:	5e                   	pop    %esi
  80293d:	5f                   	pop    %edi
  80293e:	5d                   	pop    %ebp
  80293f:	c3                   	ret    

00802940 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802940:	55                   	push   %ebp
  802941:	89 e5                	mov    %esp,%ebp
  802943:	83 ec 08             	sub    $0x8,%esp
  802946:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80294b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80294f:	74 2a                	je     80297b <devcons_read+0x3b>
  802951:	eb 05                	jmp    802958 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802953:	e8 77 e9 ff ff       	call   8012cf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802958:	e8 f3 e8 ff ff       	call   801250 <sys_cgetc>
  80295d:	85 c0                	test   %eax,%eax
  80295f:	74 f2                	je     802953 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802961:	85 c0                	test   %eax,%eax
  802963:	78 16                	js     80297b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802965:	83 f8 04             	cmp    $0x4,%eax
  802968:	74 0c                	je     802976 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80296a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80296d:	88 02                	mov    %al,(%edx)
	return 1;
  80296f:	b8 01 00 00 00       	mov    $0x1,%eax
  802974:	eb 05                	jmp    80297b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802976:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80297b:	c9                   	leave  
  80297c:	c3                   	ret    

0080297d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80297d:	55                   	push   %ebp
  80297e:	89 e5                	mov    %esp,%ebp
  802980:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802983:	8b 45 08             	mov    0x8(%ebp),%eax
  802986:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802989:	6a 01                	push   $0x1
  80298b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80298e:	50                   	push   %eax
  80298f:	e8 9e e8 ff ff       	call   801232 <sys_cputs>
}
  802994:	83 c4 10             	add    $0x10,%esp
  802997:	c9                   	leave  
  802998:	c3                   	ret    

00802999 <getchar>:

int
getchar(void)
{
  802999:	55                   	push   %ebp
  80299a:	89 e5                	mov    %esp,%ebp
  80299c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80299f:	6a 01                	push   $0x1
  8029a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8029a4:	50                   	push   %eax
  8029a5:	6a 00                	push   $0x0
  8029a7:	e8 36 f2 ff ff       	call   801be2 <read>
	if (r < 0)
  8029ac:	83 c4 10             	add    $0x10,%esp
  8029af:	85 c0                	test   %eax,%eax
  8029b1:	78 0f                	js     8029c2 <getchar+0x29>
		return r;
	if (r < 1)
  8029b3:	85 c0                	test   %eax,%eax
  8029b5:	7e 06                	jle    8029bd <getchar+0x24>
		return -E_EOF;
	return c;
  8029b7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8029bb:	eb 05                	jmp    8029c2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8029bd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8029c2:	c9                   	leave  
  8029c3:	c3                   	ret    

008029c4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8029c4:	55                   	push   %ebp
  8029c5:	89 e5                	mov    %esp,%ebp
  8029c7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029cd:	50                   	push   %eax
  8029ce:	ff 75 08             	pushl  0x8(%ebp)
  8029d1:	e8 a6 ef ff ff       	call   80197c <fd_lookup>
  8029d6:	83 c4 10             	add    $0x10,%esp
  8029d9:	85 c0                	test   %eax,%eax
  8029db:	78 11                	js     8029ee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8029dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029e0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029e6:	39 10                	cmp    %edx,(%eax)
  8029e8:	0f 94 c0             	sete   %al
  8029eb:	0f b6 c0             	movzbl %al,%eax
}
  8029ee:	c9                   	leave  
  8029ef:	c3                   	ret    

008029f0 <opencons>:

int
opencons(void)
{
  8029f0:	55                   	push   %ebp
  8029f1:	89 e5                	mov    %esp,%ebp
  8029f3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8029f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029f9:	50                   	push   %eax
  8029fa:	e8 2e ef ff ff       	call   80192d <fd_alloc>
  8029ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802a02:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802a04:	85 c0                	test   %eax,%eax
  802a06:	78 3e                	js     802a46 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802a08:	83 ec 04             	sub    $0x4,%esp
  802a0b:	68 07 04 00 00       	push   $0x407
  802a10:	ff 75 f4             	pushl  -0xc(%ebp)
  802a13:	6a 00                	push   $0x0
  802a15:	e8 d4 e8 ff ff       	call   8012ee <sys_page_alloc>
  802a1a:	83 c4 10             	add    $0x10,%esp
		return r;
  802a1d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802a1f:	85 c0                	test   %eax,%eax
  802a21:	78 23                	js     802a46 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802a23:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802a38:	83 ec 0c             	sub    $0xc,%esp
  802a3b:	50                   	push   %eax
  802a3c:	e8 c5 ee ff ff       	call   801906 <fd2num>
  802a41:	89 c2                	mov    %eax,%edx
  802a43:	83 c4 10             	add    $0x10,%esp
}
  802a46:	89 d0                	mov    %edx,%eax
  802a48:	c9                   	leave  
  802a49:	c3                   	ret    

00802a4a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a4a:	55                   	push   %ebp
  802a4b:	89 e5                	mov    %esp,%ebp
  802a4d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802a50:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802a57:	75 2e                	jne    802a87 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802a59:	e8 52 e8 ff ff       	call   8012b0 <sys_getenvid>
  802a5e:	83 ec 04             	sub    $0x4,%esp
  802a61:	68 07 0e 00 00       	push   $0xe07
  802a66:	68 00 f0 bf ee       	push   $0xeebff000
  802a6b:	50                   	push   %eax
  802a6c:	e8 7d e8 ff ff       	call   8012ee <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802a71:	e8 3a e8 ff ff       	call   8012b0 <sys_getenvid>
  802a76:	83 c4 08             	add    $0x8,%esp
  802a79:	68 91 2a 80 00       	push   $0x802a91
  802a7e:	50                   	push   %eax
  802a7f:	e8 b5 e9 ff ff       	call   801439 <sys_env_set_pgfault_upcall>
  802a84:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a87:	8b 45 08             	mov    0x8(%ebp),%eax
  802a8a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802a8f:	c9                   	leave  
  802a90:	c3                   	ret    

00802a91 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a91:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a92:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802a97:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a99:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802a9c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802aa0:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802aa4:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802aa7:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802aaa:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802aab:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802aae:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802aaf:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802ab0:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802ab4:	c3                   	ret    

00802ab5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ab5:	55                   	push   %ebp
  802ab6:	89 e5                	mov    %esp,%ebp
  802ab8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802abb:	89 d0                	mov    %edx,%eax
  802abd:	c1 e8 16             	shr    $0x16,%eax
  802ac0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802ac7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802acc:	f6 c1 01             	test   $0x1,%cl
  802acf:	74 1d                	je     802aee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ad1:	c1 ea 0c             	shr    $0xc,%edx
  802ad4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802adb:	f6 c2 01             	test   $0x1,%dl
  802ade:	74 0e                	je     802aee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ae0:	c1 ea 0c             	shr    $0xc,%edx
  802ae3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802aea:	ef 
  802aeb:	0f b7 c0             	movzwl %ax,%eax
}
  802aee:	5d                   	pop    %ebp
  802aef:	c3                   	ret    

00802af0 <__udivdi3>:
  802af0:	55                   	push   %ebp
  802af1:	57                   	push   %edi
  802af2:	56                   	push   %esi
  802af3:	53                   	push   %ebx
  802af4:	83 ec 1c             	sub    $0x1c,%esp
  802af7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802afb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802aff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802b03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b07:	85 f6                	test   %esi,%esi
  802b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b0d:	89 ca                	mov    %ecx,%edx
  802b0f:	89 f8                	mov    %edi,%eax
  802b11:	75 3d                	jne    802b50 <__udivdi3+0x60>
  802b13:	39 cf                	cmp    %ecx,%edi
  802b15:	0f 87 c5 00 00 00    	ja     802be0 <__udivdi3+0xf0>
  802b1b:	85 ff                	test   %edi,%edi
  802b1d:	89 fd                	mov    %edi,%ebp
  802b1f:	75 0b                	jne    802b2c <__udivdi3+0x3c>
  802b21:	b8 01 00 00 00       	mov    $0x1,%eax
  802b26:	31 d2                	xor    %edx,%edx
  802b28:	f7 f7                	div    %edi
  802b2a:	89 c5                	mov    %eax,%ebp
  802b2c:	89 c8                	mov    %ecx,%eax
  802b2e:	31 d2                	xor    %edx,%edx
  802b30:	f7 f5                	div    %ebp
  802b32:	89 c1                	mov    %eax,%ecx
  802b34:	89 d8                	mov    %ebx,%eax
  802b36:	89 cf                	mov    %ecx,%edi
  802b38:	f7 f5                	div    %ebp
  802b3a:	89 c3                	mov    %eax,%ebx
  802b3c:	89 d8                	mov    %ebx,%eax
  802b3e:	89 fa                	mov    %edi,%edx
  802b40:	83 c4 1c             	add    $0x1c,%esp
  802b43:	5b                   	pop    %ebx
  802b44:	5e                   	pop    %esi
  802b45:	5f                   	pop    %edi
  802b46:	5d                   	pop    %ebp
  802b47:	c3                   	ret    
  802b48:	90                   	nop
  802b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b50:	39 ce                	cmp    %ecx,%esi
  802b52:	77 74                	ja     802bc8 <__udivdi3+0xd8>
  802b54:	0f bd fe             	bsr    %esi,%edi
  802b57:	83 f7 1f             	xor    $0x1f,%edi
  802b5a:	0f 84 98 00 00 00    	je     802bf8 <__udivdi3+0x108>
  802b60:	bb 20 00 00 00       	mov    $0x20,%ebx
  802b65:	89 f9                	mov    %edi,%ecx
  802b67:	89 c5                	mov    %eax,%ebp
  802b69:	29 fb                	sub    %edi,%ebx
  802b6b:	d3 e6                	shl    %cl,%esi
  802b6d:	89 d9                	mov    %ebx,%ecx
  802b6f:	d3 ed                	shr    %cl,%ebp
  802b71:	89 f9                	mov    %edi,%ecx
  802b73:	d3 e0                	shl    %cl,%eax
  802b75:	09 ee                	or     %ebp,%esi
  802b77:	89 d9                	mov    %ebx,%ecx
  802b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b7d:	89 d5                	mov    %edx,%ebp
  802b7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b83:	d3 ed                	shr    %cl,%ebp
  802b85:	89 f9                	mov    %edi,%ecx
  802b87:	d3 e2                	shl    %cl,%edx
  802b89:	89 d9                	mov    %ebx,%ecx
  802b8b:	d3 e8                	shr    %cl,%eax
  802b8d:	09 c2                	or     %eax,%edx
  802b8f:	89 d0                	mov    %edx,%eax
  802b91:	89 ea                	mov    %ebp,%edx
  802b93:	f7 f6                	div    %esi
  802b95:	89 d5                	mov    %edx,%ebp
  802b97:	89 c3                	mov    %eax,%ebx
  802b99:	f7 64 24 0c          	mull   0xc(%esp)
  802b9d:	39 d5                	cmp    %edx,%ebp
  802b9f:	72 10                	jb     802bb1 <__udivdi3+0xc1>
  802ba1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ba5:	89 f9                	mov    %edi,%ecx
  802ba7:	d3 e6                	shl    %cl,%esi
  802ba9:	39 c6                	cmp    %eax,%esi
  802bab:	73 07                	jae    802bb4 <__udivdi3+0xc4>
  802bad:	39 d5                	cmp    %edx,%ebp
  802baf:	75 03                	jne    802bb4 <__udivdi3+0xc4>
  802bb1:	83 eb 01             	sub    $0x1,%ebx
  802bb4:	31 ff                	xor    %edi,%edi
  802bb6:	89 d8                	mov    %ebx,%eax
  802bb8:	89 fa                	mov    %edi,%edx
  802bba:	83 c4 1c             	add    $0x1c,%esp
  802bbd:	5b                   	pop    %ebx
  802bbe:	5e                   	pop    %esi
  802bbf:	5f                   	pop    %edi
  802bc0:	5d                   	pop    %ebp
  802bc1:	c3                   	ret    
  802bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bc8:	31 ff                	xor    %edi,%edi
  802bca:	31 db                	xor    %ebx,%ebx
  802bcc:	89 d8                	mov    %ebx,%eax
  802bce:	89 fa                	mov    %edi,%edx
  802bd0:	83 c4 1c             	add    $0x1c,%esp
  802bd3:	5b                   	pop    %ebx
  802bd4:	5e                   	pop    %esi
  802bd5:	5f                   	pop    %edi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    
  802bd8:	90                   	nop
  802bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802be0:	89 d8                	mov    %ebx,%eax
  802be2:	f7 f7                	div    %edi
  802be4:	31 ff                	xor    %edi,%edi
  802be6:	89 c3                	mov    %eax,%ebx
  802be8:	89 d8                	mov    %ebx,%eax
  802bea:	89 fa                	mov    %edi,%edx
  802bec:	83 c4 1c             	add    $0x1c,%esp
  802bef:	5b                   	pop    %ebx
  802bf0:	5e                   	pop    %esi
  802bf1:	5f                   	pop    %edi
  802bf2:	5d                   	pop    %ebp
  802bf3:	c3                   	ret    
  802bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bf8:	39 ce                	cmp    %ecx,%esi
  802bfa:	72 0c                	jb     802c08 <__udivdi3+0x118>
  802bfc:	31 db                	xor    %ebx,%ebx
  802bfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802c02:	0f 87 34 ff ff ff    	ja     802b3c <__udivdi3+0x4c>
  802c08:	bb 01 00 00 00       	mov    $0x1,%ebx
  802c0d:	e9 2a ff ff ff       	jmp    802b3c <__udivdi3+0x4c>
  802c12:	66 90                	xchg   %ax,%ax
  802c14:	66 90                	xchg   %ax,%ax
  802c16:	66 90                	xchg   %ax,%ax
  802c18:	66 90                	xchg   %ax,%ax
  802c1a:	66 90                	xchg   %ax,%ax
  802c1c:	66 90                	xchg   %ax,%ax
  802c1e:	66 90                	xchg   %ax,%ax

00802c20 <__umoddi3>:
  802c20:	55                   	push   %ebp
  802c21:	57                   	push   %edi
  802c22:	56                   	push   %esi
  802c23:	53                   	push   %ebx
  802c24:	83 ec 1c             	sub    $0x1c,%esp
  802c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802c2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c37:	85 d2                	test   %edx,%edx
  802c39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c41:	89 f3                	mov    %esi,%ebx
  802c43:	89 3c 24             	mov    %edi,(%esp)
  802c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c4a:	75 1c                	jne    802c68 <__umoddi3+0x48>
  802c4c:	39 f7                	cmp    %esi,%edi
  802c4e:	76 50                	jbe    802ca0 <__umoddi3+0x80>
  802c50:	89 c8                	mov    %ecx,%eax
  802c52:	89 f2                	mov    %esi,%edx
  802c54:	f7 f7                	div    %edi
  802c56:	89 d0                	mov    %edx,%eax
  802c58:	31 d2                	xor    %edx,%edx
  802c5a:	83 c4 1c             	add    $0x1c,%esp
  802c5d:	5b                   	pop    %ebx
  802c5e:	5e                   	pop    %esi
  802c5f:	5f                   	pop    %edi
  802c60:	5d                   	pop    %ebp
  802c61:	c3                   	ret    
  802c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c68:	39 f2                	cmp    %esi,%edx
  802c6a:	89 d0                	mov    %edx,%eax
  802c6c:	77 52                	ja     802cc0 <__umoddi3+0xa0>
  802c6e:	0f bd ea             	bsr    %edx,%ebp
  802c71:	83 f5 1f             	xor    $0x1f,%ebp
  802c74:	75 5a                	jne    802cd0 <__umoddi3+0xb0>
  802c76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802c7a:	0f 82 e0 00 00 00    	jb     802d60 <__umoddi3+0x140>
  802c80:	39 0c 24             	cmp    %ecx,(%esp)
  802c83:	0f 86 d7 00 00 00    	jbe    802d60 <__umoddi3+0x140>
  802c89:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c91:	83 c4 1c             	add    $0x1c,%esp
  802c94:	5b                   	pop    %ebx
  802c95:	5e                   	pop    %esi
  802c96:	5f                   	pop    %edi
  802c97:	5d                   	pop    %ebp
  802c98:	c3                   	ret    
  802c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ca0:	85 ff                	test   %edi,%edi
  802ca2:	89 fd                	mov    %edi,%ebp
  802ca4:	75 0b                	jne    802cb1 <__umoddi3+0x91>
  802ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  802cab:	31 d2                	xor    %edx,%edx
  802cad:	f7 f7                	div    %edi
  802caf:	89 c5                	mov    %eax,%ebp
  802cb1:	89 f0                	mov    %esi,%eax
  802cb3:	31 d2                	xor    %edx,%edx
  802cb5:	f7 f5                	div    %ebp
  802cb7:	89 c8                	mov    %ecx,%eax
  802cb9:	f7 f5                	div    %ebp
  802cbb:	89 d0                	mov    %edx,%eax
  802cbd:	eb 99                	jmp    802c58 <__umoddi3+0x38>
  802cbf:	90                   	nop
  802cc0:	89 c8                	mov    %ecx,%eax
  802cc2:	89 f2                	mov    %esi,%edx
  802cc4:	83 c4 1c             	add    $0x1c,%esp
  802cc7:	5b                   	pop    %ebx
  802cc8:	5e                   	pop    %esi
  802cc9:	5f                   	pop    %edi
  802cca:	5d                   	pop    %ebp
  802ccb:	c3                   	ret    
  802ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	8b 34 24             	mov    (%esp),%esi
  802cd3:	bf 20 00 00 00       	mov    $0x20,%edi
  802cd8:	89 e9                	mov    %ebp,%ecx
  802cda:	29 ef                	sub    %ebp,%edi
  802cdc:	d3 e0                	shl    %cl,%eax
  802cde:	89 f9                	mov    %edi,%ecx
  802ce0:	89 f2                	mov    %esi,%edx
  802ce2:	d3 ea                	shr    %cl,%edx
  802ce4:	89 e9                	mov    %ebp,%ecx
  802ce6:	09 c2                	or     %eax,%edx
  802ce8:	89 d8                	mov    %ebx,%eax
  802cea:	89 14 24             	mov    %edx,(%esp)
  802ced:	89 f2                	mov    %esi,%edx
  802cef:	d3 e2                	shl    %cl,%edx
  802cf1:	89 f9                	mov    %edi,%ecx
  802cf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802cf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802cfb:	d3 e8                	shr    %cl,%eax
  802cfd:	89 e9                	mov    %ebp,%ecx
  802cff:	89 c6                	mov    %eax,%esi
  802d01:	d3 e3                	shl    %cl,%ebx
  802d03:	89 f9                	mov    %edi,%ecx
  802d05:	89 d0                	mov    %edx,%eax
  802d07:	d3 e8                	shr    %cl,%eax
  802d09:	89 e9                	mov    %ebp,%ecx
  802d0b:	09 d8                	or     %ebx,%eax
  802d0d:	89 d3                	mov    %edx,%ebx
  802d0f:	89 f2                	mov    %esi,%edx
  802d11:	f7 34 24             	divl   (%esp)
  802d14:	89 d6                	mov    %edx,%esi
  802d16:	d3 e3                	shl    %cl,%ebx
  802d18:	f7 64 24 04          	mull   0x4(%esp)
  802d1c:	39 d6                	cmp    %edx,%esi
  802d1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d22:	89 d1                	mov    %edx,%ecx
  802d24:	89 c3                	mov    %eax,%ebx
  802d26:	72 08                	jb     802d30 <__umoddi3+0x110>
  802d28:	75 11                	jne    802d3b <__umoddi3+0x11b>
  802d2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802d2e:	73 0b                	jae    802d3b <__umoddi3+0x11b>
  802d30:	2b 44 24 04          	sub    0x4(%esp),%eax
  802d34:	1b 14 24             	sbb    (%esp),%edx
  802d37:	89 d1                	mov    %edx,%ecx
  802d39:	89 c3                	mov    %eax,%ebx
  802d3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802d3f:	29 da                	sub    %ebx,%edx
  802d41:	19 ce                	sbb    %ecx,%esi
  802d43:	89 f9                	mov    %edi,%ecx
  802d45:	89 f0                	mov    %esi,%eax
  802d47:	d3 e0                	shl    %cl,%eax
  802d49:	89 e9                	mov    %ebp,%ecx
  802d4b:	d3 ea                	shr    %cl,%edx
  802d4d:	89 e9                	mov    %ebp,%ecx
  802d4f:	d3 ee                	shr    %cl,%esi
  802d51:	09 d0                	or     %edx,%eax
  802d53:	89 f2                	mov    %esi,%edx
  802d55:	83 c4 1c             	add    $0x1c,%esp
  802d58:	5b                   	pop    %ebx
  802d59:	5e                   	pop    %esi
  802d5a:	5f                   	pop    %edi
  802d5b:	5d                   	pop    %ebp
  802d5c:	c3                   	ret    
  802d5d:	8d 76 00             	lea    0x0(%esi),%esi
  802d60:	29 f9                	sub    %edi,%ecx
  802d62:	19 d6                	sbb    %edx,%esi
  802d64:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d6c:	e9 18 ff ff ff       	jmp    802c89 <__umoddi3+0x69>
