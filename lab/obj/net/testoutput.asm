
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9c 02 00 00       	call   8002cd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 13 0d 00 00       	call   800d50 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 20 	movl   $0x802820,0x803000
  800046:	28 80 00 

	output_envid = fork();
  800049:	e8 ad 10 00 00       	call   8010fb <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 2b 28 80 00       	push   $0x80282b
  80005f:	6a 16                	push   $0x16
  800061:	68 39 28 80 00       	push   $0x802839
  800066:	e8 c2 02 00 00       	call   80032d <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 fe 01 00 00       	call   80027b <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 f8 0c 00 00       	call   800d8e <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 4a 28 80 00       	push   $0x80284a
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 39 28 80 00       	push   $0x802839
  8000aa:	e8 7e 02 00 00       	call   80032d <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 5d 28 80 00       	push   $0x80285d
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 74 08 00 00       	call   800938 <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 69 28 80 00       	push   $0x802869
  8000d2:	e8 2f 03 00 00       	call   800406 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 2e 12 00 00       	call   801319 <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 19 0d 00 00       	call   800e13 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 60 0c 00 00       	call   800d6f <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 53 0e 00 00       	call   800f7f <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 81 	movl   $0x802881,0x803000
  800138:	28 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 2a 0c 00 00       	call   800d6f <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 35 0e 00 00       	call   800f7f <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 8a 28 80 00       	push   $0x80288a
  80015e:	6a 0f                	push   $0xf
  800160:	68 9c 28 80 00       	push   $0x80289c
  800165:	e8 c3 01 00 00       	call   80032d <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 a3 11 00 00       	call   801319 <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 2c 11 00 00       	call   8012b2 <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 a8 28 80 00       	push   $0x8028a8
  80019b:	e8 66 02 00 00       	call   800406 <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 d5 0d 00 00       	call   800f7f <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <sleep>:
extern union Nsipc nsipcbuf;


void
sleep(int msec)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 04             	sub    $0x4,%esp
    unsigned now = sys_time_msec();
  8001b5:	e8 c5 0d 00 00       	call   800f7f <sys_time_msec>
    unsigned end = now + msec;
  8001ba:	89 c3                	mov    %eax,%ebx
  8001bc:	03 5d 08             	add    0x8(%ebp),%ebx

    if ((int)now < 0 && (int)now > -MAXERROR)
  8001bf:	89 c2                	mov    %eax,%edx
  8001c1:	c1 ea 1f             	shr    $0x1f,%edx
  8001c4:	84 d2                	test   %dl,%dl
  8001c6:	74 17                	je     8001df <sleep+0x31>
  8001c8:	83 f8 f1             	cmp    $0xfffffff1,%eax
  8001cb:	7c 12                	jl     8001df <sleep+0x31>
        panic("sys_time_msec: %e", (int)now);
  8001cd:	50                   	push   %eax
  8001ce:	68 8a 28 80 00       	push   $0x80288a
  8001d3:	6a 0d                	push   $0xd
  8001d5:	68 e3 28 80 00       	push   $0x8028e3
  8001da:	e8 4e 01 00 00       	call   80032d <_panic>
    if (end < now)
  8001df:	39 d8                	cmp    %ebx,%eax
  8001e1:	76 19                	jbe    8001fc <sleep+0x4e>
        panic("sleep: wrap");
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	68 ef 28 80 00       	push   $0x8028ef
  8001eb:	6a 0f                	push   $0xf
  8001ed:	68 e3 28 80 00       	push   $0x8028e3
  8001f2:	e8 36 01 00 00       	call   80032d <_panic>

    while (sys_time_msec() < end)
        sys_yield();
  8001f7:	e8 73 0b 00 00       	call   800d6f <sys_yield>
    if ((int)now < 0 && (int)now > -MAXERROR)
        panic("sys_time_msec: %e", (int)now);
    if (end < now)
        panic("sleep: wrap");

    while (sys_time_msec() < end)
  8001fc:	e8 7e 0d 00 00       	call   800f7f <sys_time_msec>
  800201:	39 c3                	cmp    %eax,%ebx
  800203:	77 f2                	ja     8001f7 <sleep+0x49>
        sys_yield();
}
  800205:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <input>:

void
input(envid_t ns_envid)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	57                   	push   %edi
  80020e:	56                   	push   %esi
  80020f:	53                   	push   %ebx
  800210:	81 ec 0c 06 00 00    	sub    $0x60c,%esp
  800216:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800219:	c7 05 00 30 80 00 fb 	movl   $0x8028fb,0x803000
  800220:	28 80 00 
	size_t len;
    char rev_buf[1520];
    size_t i = 0;
    while(1) {

        while (sys_e1000_try_recv(rev_buf, &len) < 0) {
  800223:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800226:	8d 9d f4 f9 ff ff    	lea    -0x60c(%ebp),%ebx
  80022c:	eb 05                	jmp    800233 <input+0x29>
            sys_yield();    
  80022e:	e8 3c 0b 00 00       	call   800d6f <sys_yield>
	size_t len;
    char rev_buf[1520];
    size_t i = 0;
    while(1) {

        while (sys_e1000_try_recv(rev_buf, &len) < 0) {
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	e8 a3 0d 00 00       	call   800fe0 <sys_e1000_try_recv>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	85 c0                	test   %eax,%eax
  800242:	78 ea                	js     80022e <input+0x24>
            sys_yield();    
        }

        memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
  800244:	83 ec 04             	sub    $0x4,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	53                   	push   %ebx
  80024b:	68 04 60 80 00       	push   $0x806004
  800250:	e8 30 09 00 00       	call   800b85 <memcpy>
        nsipcbuf.pkt.jp_len = len;
  800255:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800258:	a3 00 60 80 00       	mov    %eax,0x806000
        
        ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
  80025d:	6a 05                	push   $0x5
  80025f:	68 00 60 80 00       	push   $0x806000
  800264:	6a 0a                	push   $0xa
  800266:	57                   	push   %edi
  800267:	e8 ad 10 00 00       	call   801319 <ipc_send>
        sleep(50);
  80026c:	83 c4 14             	add    $0x14,%esp
  80026f:	6a 32                	push   $0x32
  800271:	e8 38 ff ff ff       	call   8001ae <sleep>
    }
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	eb b8                	jmp    800233 <input+0x29>

0080027b <output>:



void
output(envid_t ns_envid)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 10             	sub    $0x10,%esp
	binaryname = "ns_output";
  800283:	c7 05 00 30 80 00 04 	movl   $0x802904,0x803000
  80028a:	29 80 00 
	uint32_t whom;
    int perm;
    int32_t req;

    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
  80028d:	8d 75 f0             	lea    -0x10(%ebp),%esi
  800290:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	56                   	push   %esi
  800297:	68 00 60 80 00       	push   $0x806000
  80029c:	53                   	push   %ebx
  80029d:	e8 10 10 00 00       	call   8012b2 <ipc_recv>
        if (req != NSREQ_OUTPUT) {
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	83 f8 0b             	cmp    $0xb,%eax
  8002a8:	75 e9                	jne    800293 <output+0x18>
  8002aa:	eb 05                	jmp    8002b1 <output+0x36>
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
            sys_yield();
  8002ac:	e8 be 0a 00 00       	call   800d6f <sys_yield>
    while (1) {
        req = ipc_recv((envid_t *)&whom, &nsipcbuf, &perm);
        if (req != NSREQ_OUTPUT) {
            continue;
        }
        while (sys_e1000_try_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) < 0) {
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	ff 35 00 60 80 00    	pushl  0x806000
  8002ba:	68 04 60 80 00       	push   $0x806004
  8002bf:	e8 da 0c 00 00       	call   800f9e <sys_e1000_try_send>
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	78 e1                	js     8002ac <output+0x31>
  8002cb:	eb c6                	jmp    800293 <output+0x18>

008002cd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d8:	e8 73 0a 00 00       	call   800d50 <sys_getenvid>
  8002dd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002ea:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ef:	85 db                	test   %ebx,%ebx
  8002f1:	7e 07                	jle    8002fa <libmain+0x2d>
		binaryname = argv[0];
  8002f3:	8b 06                	mov    (%esi),%eax
  8002f5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	56                   	push   %esi
  8002fe:	53                   	push   %ebx
  8002ff:	e8 2f fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800304:	e8 0a 00 00 00       	call   800313 <exit>
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800319:	e8 53 12 00 00       	call   801571 <close_all>
	sys_env_destroy(0);
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	6a 00                	push   $0x0
  800323:	e8 e7 09 00 00       	call   800d0f <sys_env_destroy>
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800332:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800335:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80033b:	e8 10 0a 00 00       	call   800d50 <sys_getenvid>
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	ff 75 0c             	pushl  0xc(%ebp)
  800346:	ff 75 08             	pushl  0x8(%ebp)
  800349:	56                   	push   %esi
  80034a:	50                   	push   %eax
  80034b:	68 18 29 80 00       	push   $0x802918
  800350:	e8 b1 00 00 00       	call   800406 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800355:	83 c4 18             	add    $0x18,%esp
  800358:	53                   	push   %ebx
  800359:	ff 75 10             	pushl  0x10(%ebp)
  80035c:	e8 54 00 00 00       	call   8003b5 <vcprintf>
	cprintf("\n");
  800361:	c7 04 24 7f 28 80 00 	movl   $0x80287f,(%esp)
  800368:	e8 99 00 00 00       	call   800406 <cprintf>
  80036d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800370:	cc                   	int3   
  800371:	eb fd                	jmp    800370 <_panic+0x43>

00800373 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	53                   	push   %ebx
  800377:	83 ec 04             	sub    $0x4,%esp
  80037a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037d:	8b 13                	mov    (%ebx),%edx
  80037f:	8d 42 01             	lea    0x1(%edx),%eax
  800382:	89 03                	mov    %eax,(%ebx)
  800384:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800387:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800390:	75 1a                	jne    8003ac <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	68 ff 00 00 00       	push   $0xff
  80039a:	8d 43 08             	lea    0x8(%ebx),%eax
  80039d:	50                   	push   %eax
  80039e:	e8 2f 09 00 00       	call   800cd2 <sys_cputs>
		b->idx = 0;
  8003a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b3:	c9                   	leave  
  8003b4:	c3                   	ret    

008003b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c5:	00 00 00 
	b.cnt = 0;
  8003c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d2:	ff 75 0c             	pushl  0xc(%ebp)
  8003d5:	ff 75 08             	pushl  0x8(%ebp)
  8003d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	68 73 03 80 00       	push   $0x800373
  8003e4:	e8 54 01 00 00       	call   80053d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e9:	83 c4 08             	add    $0x8,%esp
  8003ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f8:	50                   	push   %eax
  8003f9:	e8 d4 08 00 00       	call   800cd2 <sys_cputs>

	return b.cnt;
}
  8003fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040f:	50                   	push   %eax
  800410:	ff 75 08             	pushl  0x8(%ebp)
  800413:	e8 9d ff ff ff       	call   8003b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 1c             	sub    $0x1c,%esp
  800423:	89 c7                	mov    %eax,%edi
  800425:	89 d6                	mov    %edx,%esi
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800430:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800433:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800441:	39 d3                	cmp    %edx,%ebx
  800443:	72 05                	jb     80044a <printnum+0x30>
  800445:	39 45 10             	cmp    %eax,0x10(%ebp)
  800448:	77 45                	ja     80048f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044a:	83 ec 0c             	sub    $0xc,%esp
  80044d:	ff 75 18             	pushl  0x18(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800456:	53                   	push   %ebx
  800457:	ff 75 10             	pushl  0x10(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800460:	ff 75 e0             	pushl  -0x20(%ebp)
  800463:	ff 75 dc             	pushl  -0x24(%ebp)
  800466:	ff 75 d8             	pushl  -0x28(%ebp)
  800469:	e8 22 21 00 00       	call   802590 <__udivdi3>
  80046e:	83 c4 18             	add    $0x18,%esp
  800471:	52                   	push   %edx
  800472:	50                   	push   %eax
  800473:	89 f2                	mov    %esi,%edx
  800475:	89 f8                	mov    %edi,%eax
  800477:	e8 9e ff ff ff       	call   80041a <printnum>
  80047c:	83 c4 20             	add    $0x20,%esp
  80047f:	eb 18                	jmp    800499 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	56                   	push   %esi
  800485:	ff 75 18             	pushl  0x18(%ebp)
  800488:	ff d7                	call   *%edi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb 03                	jmp    800492 <printnum+0x78>
  80048f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800492:	83 eb 01             	sub    $0x1,%ebx
  800495:	85 db                	test   %ebx,%ebx
  800497:	7f e8                	jg     800481 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	56                   	push   %esi
  80049d:	83 ec 04             	sub    $0x4,%esp
  8004a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ac:	e8 0f 22 00 00       	call   8026c0 <__umoddi3>
  8004b1:	83 c4 14             	add    $0x14,%esp
  8004b4:	0f be 80 3b 29 80 00 	movsbl 0x80293b(%eax),%eax
  8004bb:	50                   	push   %eax
  8004bc:	ff d7                	call   *%edi
}
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c4:	5b                   	pop    %ebx
  8004c5:	5e                   	pop    %esi
  8004c6:	5f                   	pop    %edi
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004cc:	83 fa 01             	cmp    $0x1,%edx
  8004cf:	7e 0e                	jle    8004df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	8b 52 04             	mov    0x4(%edx),%edx
  8004dd:	eb 22                	jmp    800501 <getuint+0x38>
	else if (lflag)
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 10                	je     8004f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e3:	8b 10                	mov    (%eax),%edx
  8004e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 02                	mov    (%edx),%eax
  8004ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f1:	eb 0e                	jmp    800501 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800501:	5d                   	pop    %ebp
  800502:	c3                   	ret    

00800503 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800509:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	3b 50 04             	cmp    0x4(%eax),%edx
  800512:	73 0a                	jae    80051e <sprintputch+0x1b>
		*b->buf++ = ch;
  800514:	8d 4a 01             	lea    0x1(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 45 08             	mov    0x8(%ebp),%eax
  80051c:	88 02                	mov    %al,(%edx)
}
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800526:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800529:	50                   	push   %eax
  80052a:	ff 75 10             	pushl  0x10(%ebp)
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	ff 75 08             	pushl  0x8(%ebp)
  800533:	e8 05 00 00 00       	call   80053d <vprintfmt>
	va_end(ap);
}
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
  800543:	83 ec 2c             	sub    $0x2c,%esp
  800546:	8b 75 08             	mov    0x8(%ebp),%esi
  800549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054f:	eb 12                	jmp    800563 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 84 89 03 00 00    	je     8008e2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	50                   	push   %eax
  80055e:	ff d6                	call   *%esi
  800560:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800563:	83 c7 01             	add    $0x1,%edi
  800566:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056a:	83 f8 25             	cmp    $0x25,%eax
  80056d:	75 e2                	jne    800551 <vprintfmt+0x14>
  80056f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800573:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80057a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800581:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800588:	ba 00 00 00 00       	mov    $0x0,%edx
  80058d:	eb 07                	jmp    800596 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800592:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8d 47 01             	lea    0x1(%edi),%eax
  800599:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059c:	0f b6 07             	movzbl (%edi),%eax
  80059f:	0f b6 c8             	movzbl %al,%ecx
  8005a2:	83 e8 23             	sub    $0x23,%eax
  8005a5:	3c 55                	cmp    $0x55,%al
  8005a7:	0f 87 1a 03 00 00    	ja     8008c7 <vprintfmt+0x38a>
  8005ad:	0f b6 c0             	movzbl %al,%eax
  8005b0:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ba:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005be:	eb d6                	jmp    800596 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005cb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ce:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d8:	83 fa 09             	cmp    $0x9,%edx
  8005db:	77 39                	ja     800616 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005dd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e0:	eb e9                	jmp    8005cb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f3:	eb 27                	jmp    80061c <vprintfmt+0xdf>
  8005f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	0f 49 c8             	cmovns %eax,%ecx
  800602:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800608:	eb 8c                	jmp    800596 <vprintfmt+0x59>
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80060d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800614:	eb 80                	jmp    800596 <vprintfmt+0x59>
  800616:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800619:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80061c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800620:	0f 89 70 ff ff ff    	jns    800596 <vprintfmt+0x59>
				width = precision, precision = -1;
  800626:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800629:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800633:	e9 5e ff ff ff       	jmp    800596 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800638:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063e:	e9 53 ff ff ff       	jmp    800596 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	ff 30                	pushl  (%eax)
  800652:	ff d6                	call   *%esi
			break;
  800654:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80065a:	e9 04 ff ff ff       	jmp    800563 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	99                   	cltd   
  80066b:	31 d0                	xor    %edx,%eax
  80066d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066f:	83 f8 0f             	cmp    $0xf,%eax
  800672:	7f 0b                	jg     80067f <vprintfmt+0x142>
  800674:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  80067b:	85 d2                	test   %edx,%edx
  80067d:	75 18                	jne    800697 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80067f:	50                   	push   %eax
  800680:	68 53 29 80 00       	push   $0x802953
  800685:	53                   	push   %ebx
  800686:	56                   	push   %esi
  800687:	e8 94 fe ff ff       	call   800520 <printfmt>
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800692:	e9 cc fe ff ff       	jmp    800563 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800697:	52                   	push   %edx
  800698:	68 e5 2d 80 00       	push   $0x802de5
  80069d:	53                   	push   %ebx
  80069e:	56                   	push   %esi
  80069f:	e8 7c fe ff ff       	call   800520 <printfmt>
  8006a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	e9 b4 fe ff ff       	jmp    800563 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006ba:	85 ff                	test   %edi,%edi
  8006bc:	b8 4c 29 80 00       	mov    $0x80294c,%eax
  8006c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c8:	0f 8e 94 00 00 00    	jle    800762 <vprintfmt+0x225>
  8006ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d2:	0f 84 98 00 00 00    	je     800770 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	ff 75 d0             	pushl  -0x30(%ebp)
  8006de:	57                   	push   %edi
  8006df:	e8 86 02 00 00       	call   80096a <strnlen>
  8006e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e7:	29 c1                	sub    %eax,%ecx
  8006e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fb:	eb 0f                	jmp    80070c <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800706:	83 ef 01             	sub    $0x1,%edi
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 ff                	test   %edi,%edi
  80070e:	7f ed                	jg     8006fd <vprintfmt+0x1c0>
  800710:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800713:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800716:	85 c9                	test   %ecx,%ecx
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	0f 49 c1             	cmovns %ecx,%eax
  800720:	29 c1                	sub    %eax,%ecx
  800722:	89 75 08             	mov    %esi,0x8(%ebp)
  800725:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800728:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072b:	89 cb                	mov    %ecx,%ebx
  80072d:	eb 4d                	jmp    80077c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800733:	74 1b                	je     800750 <vprintfmt+0x213>
  800735:	0f be c0             	movsbl %al,%eax
  800738:	83 e8 20             	sub    $0x20,%eax
  80073b:	83 f8 5e             	cmp    $0x5e,%eax
  80073e:	76 10                	jbe    800750 <vprintfmt+0x213>
					putch('?', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	ff 75 0c             	pushl  0xc(%ebp)
  800746:	6a 3f                	push   $0x3f
  800748:	ff 55 08             	call   *0x8(%ebp)
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	eb 0d                	jmp    80075d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	52                   	push   %edx
  800757:	ff 55 08             	call   *0x8(%ebp)
  80075a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075d:	83 eb 01             	sub    $0x1,%ebx
  800760:	eb 1a                	jmp    80077c <vprintfmt+0x23f>
  800762:	89 75 08             	mov    %esi,0x8(%ebp)
  800765:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800768:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076e:	eb 0c                	jmp    80077c <vprintfmt+0x23f>
  800770:	89 75 08             	mov    %esi,0x8(%ebp)
  800773:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800776:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800779:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077c:	83 c7 01             	add    $0x1,%edi
  80077f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800783:	0f be d0             	movsbl %al,%edx
  800786:	85 d2                	test   %edx,%edx
  800788:	74 23                	je     8007ad <vprintfmt+0x270>
  80078a:	85 f6                	test   %esi,%esi
  80078c:	78 a1                	js     80072f <vprintfmt+0x1f2>
  80078e:	83 ee 01             	sub    $0x1,%esi
  800791:	79 9c                	jns    80072f <vprintfmt+0x1f2>
  800793:	89 df                	mov    %ebx,%edi
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079b:	eb 18                	jmp    8007b5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	53                   	push   %ebx
  8007a1:	6a 20                	push   $0x20
  8007a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a5:	83 ef 01             	sub    $0x1,%edi
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 08                	jmp    8007b5 <vprintfmt+0x278>
  8007ad:	89 df                	mov    %ebx,%edi
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b5:	85 ff                	test   %edi,%edi
  8007b7:	7f e4                	jg     80079d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bc:	e9 a2 fd ff ff       	jmp    800563 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c1:	83 fa 01             	cmp    $0x1,%edx
  8007c4:	7e 16                	jle    8007dc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 50 08             	lea    0x8(%eax),%edx
  8007cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cf:	8b 50 04             	mov    0x4(%eax),%edx
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007da:	eb 32                	jmp    80080e <vprintfmt+0x2d1>
	else if (lflag)
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 18                	je     8007f8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 c1                	mov    %eax,%ecx
  8007f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f6:	eb 16                	jmp    80080e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 00                	mov    (%eax),%eax
  800803:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800806:	89 c1                	mov    %eax,%ecx
  800808:	c1 f9 1f             	sar    $0x1f,%ecx
  80080b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800811:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800814:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800819:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081d:	79 74                	jns    800893 <vprintfmt+0x356>
				putch('-', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	6a 2d                	push   $0x2d
  800825:	ff d6                	call   *%esi
				num = -(long long) num;
  800827:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80082d:	f7 d8                	neg    %eax
  80082f:	83 d2 00             	adc    $0x0,%edx
  800832:	f7 da                	neg    %edx
  800834:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800837:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80083c:	eb 55                	jmp    800893 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
  800841:	e8 83 fc ff ff       	call   8004c9 <getuint>
			base = 10;
  800846:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80084b:	eb 46                	jmp    800893 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
  800850:	e8 74 fc ff ff       	call   8004c9 <getuint>
			base = 8;
  800855:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80085a:	eb 37                	jmp    800893 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 30                	push   $0x30
  800862:	ff d6                	call   *%esi
			putch('x', putdat);
  800864:	83 c4 08             	add    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 78                	push   $0x78
  80086a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8d 50 04             	lea    0x4(%eax),%edx
  800872:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800875:	8b 00                	mov    (%eax),%eax
  800877:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800884:	eb 0d                	jmp    800893 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
  800889:	e8 3b fc ff ff       	call   8004c9 <getuint>
			base = 16;
  80088e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800893:	83 ec 0c             	sub    $0xc,%esp
  800896:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089a:	57                   	push   %edi
  80089b:	ff 75 e0             	pushl  -0x20(%ebp)
  80089e:	51                   	push   %ecx
  80089f:	52                   	push   %edx
  8008a0:	50                   	push   %eax
  8008a1:	89 da                	mov    %ebx,%edx
  8008a3:	89 f0                	mov    %esi,%eax
  8008a5:	e8 70 fb ff ff       	call   80041a <printnum>
			break;
  8008aa:	83 c4 20             	add    $0x20,%esp
  8008ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b0:	e9 ae fc ff ff       	jmp    800563 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	51                   	push   %ecx
  8008ba:	ff d6                	call   *%esi
			break;
  8008bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c2:	e9 9c fc ff ff       	jmp    800563 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	6a 25                	push   $0x25
  8008cd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 03                	jmp    8008d7 <vprintfmt+0x39a>
  8008d4:	83 ef 01             	sub    $0x1,%edi
  8008d7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008db:	75 f7                	jne    8008d4 <vprintfmt+0x397>
  8008dd:	e9 81 fc ff ff       	jmp    800563 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	83 ec 18             	sub    $0x18,%esp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800900:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800907:	85 c0                	test   %eax,%eax
  800909:	74 26                	je     800931 <vsnprintf+0x47>
  80090b:	85 d2                	test   %edx,%edx
  80090d:	7e 22                	jle    800931 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090f:	ff 75 14             	pushl  0x14(%ebp)
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800918:	50                   	push   %eax
  800919:	68 03 05 80 00       	push   $0x800503
  80091e:	e8 1a fc ff ff       	call   80053d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800923:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800926:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	eb 05                	jmp    800936 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800931:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800941:	50                   	push   %eax
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 9a ff ff ff       	call   8008ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
  80095d:	eb 03                	jmp    800962 <strlen+0x10>
		n++;
  80095f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800962:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800966:	75 f7                	jne    80095f <strlen+0xd>
		n++;
	return n;
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800973:	ba 00 00 00 00       	mov    $0x0,%edx
  800978:	eb 03                	jmp    80097d <strnlen+0x13>
		n++;
  80097a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097d:	39 c2                	cmp    %eax,%edx
  80097f:	74 08                	je     800989 <strnlen+0x1f>
  800981:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800985:	75 f3                	jne    80097a <strnlen+0x10>
  800987:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800995:	89 c2                	mov    %eax,%edx
  800997:	83 c2 01             	add    $0x1,%edx
  80099a:	83 c1 01             	add    $0x1,%ecx
  80099d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a4:	84 db                	test   %bl,%bl
  8009a6:	75 ef                	jne    800997 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b2:	53                   	push   %ebx
  8009b3:	e8 9a ff ff ff       	call   800952 <strlen>
  8009b8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	01 d8                	add    %ebx,%eax
  8009c0:	50                   	push   %eax
  8009c1:	e8 c5 ff ff ff       	call   80098b <strcpy>
	return dst;
}
  8009c6:	89 d8                	mov    %ebx,%eax
  8009c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d8:	89 f3                	mov    %esi,%ebx
  8009da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009dd:	89 f2                	mov    %esi,%edx
  8009df:	eb 0f                	jmp    8009f0 <strncpy+0x23>
		*dst++ = *src;
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	0f b6 01             	movzbl (%ecx),%eax
  8009e7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ea:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ed:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f0:	39 da                	cmp    %ebx,%edx
  8009f2:	75 ed                	jne    8009e1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f4:	89 f0                	mov    %esi,%eax
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a05:	8b 55 10             	mov    0x10(%ebp),%edx
  800a08:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0a:	85 d2                	test   %edx,%edx
  800a0c:	74 21                	je     800a2f <strlcpy+0x35>
  800a0e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a12:	89 f2                	mov    %esi,%edx
  800a14:	eb 09                	jmp    800a1f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a1f:	39 c2                	cmp    %eax,%edx
  800a21:	74 09                	je     800a2c <strlcpy+0x32>
  800a23:	0f b6 19             	movzbl (%ecx),%ebx
  800a26:	84 db                	test   %bl,%bl
  800a28:	75 ec                	jne    800a16 <strlcpy+0x1c>
  800a2a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2f:	29 f0                	sub    %esi,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3e:	eb 06                	jmp    800a46 <strcmp+0x11>
		p++, q++;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a46:	0f b6 01             	movzbl (%ecx),%eax
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 04                	je     800a51 <strcmp+0x1c>
  800a4d:	3a 02                	cmp    (%edx),%al
  800a4f:	74 ef                	je     800a40 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 c0             	movzbl %al,%eax
  800a54:	0f b6 12             	movzbl (%edx),%edx
  800a57:	29 d0                	sub    %edx,%eax
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6a:	eb 06                	jmp    800a72 <strncmp+0x17>
		n--, p++, q++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 15                	je     800a8b <strncmp+0x30>
  800a76:	0f b6 08             	movzbl (%eax),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	74 04                	je     800a81 <strncmp+0x26>
  800a7d:	3a 0a                	cmp    (%edx),%cl
  800a7f:	74 eb                	je     800a6c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 00             	movzbl (%eax),%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
  800a89:	eb 05                	jmp    800a90 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9d:	eb 07                	jmp    800aa6 <strchr+0x13>
		if (*s == c)
  800a9f:	38 ca                	cmp    %cl,%dl
  800aa1:	74 0f                	je     800ab2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa3:	83 c0 01             	add    $0x1,%eax
  800aa6:	0f b6 10             	movzbl (%eax),%edx
  800aa9:	84 d2                	test   %dl,%dl
  800aab:	75 f2                	jne    800a9f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abe:	eb 03                	jmp    800ac3 <strfind+0xf>
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 04                	je     800ace <strfind+0x1a>
  800aca:	84 d2                	test   %dl,%dl
  800acc:	75 f2                	jne    800ac0 <strfind+0xc>
			break;
	return (char *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	74 36                	je     800b16 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae6:	75 28                	jne    800b10 <memset+0x40>
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 23                	jne    800b10 <memset+0x40>
		c &= 0xFF;
  800aed:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	c1 e3 08             	shl    $0x8,%ebx
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	c1 e6 18             	shl    $0x18,%esi
  800afb:	89 d0                	mov    %edx,%eax
  800afd:	c1 e0 10             	shl    $0x10,%eax
  800b00:	09 f0                	or     %esi,%eax
  800b02:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b04:	89 d8                	mov    %ebx,%eax
  800b06:	09 d0                	or     %edx,%eax
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	fc                   	cld    
  800b0c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0e:	eb 06                	jmp    800b16 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	fc                   	cld    
  800b14:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b16:	89 f8                	mov    %edi,%eax
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2b:	39 c6                	cmp    %eax,%esi
  800b2d:	73 35                	jae    800b64 <memmove+0x47>
  800b2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b32:	39 d0                	cmp    %edx,%eax
  800b34:	73 2e                	jae    800b64 <memmove+0x47>
		s += n;
		d += n;
  800b36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	09 fe                	or     %edi,%esi
  800b3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b43:	75 13                	jne    800b58 <memmove+0x3b>
  800b45:	f6 c1 03             	test   $0x3,%cl
  800b48:	75 0e                	jne    800b58 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b4a:	83 ef 04             	sub    $0x4,%edi
  800b4d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b50:	c1 e9 02             	shr    $0x2,%ecx
  800b53:	fd                   	std    
  800b54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b56:	eb 09                	jmp    800b61 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b58:	83 ef 01             	sub    $0x1,%edi
  800b5b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b5e:	fd                   	std    
  800b5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b61:	fc                   	cld    
  800b62:	eb 1d                	jmp    800b81 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	89 f2                	mov    %esi,%edx
  800b66:	09 c2                	or     %eax,%edx
  800b68:	f6 c2 03             	test   $0x3,%dl
  800b6b:	75 0f                	jne    800b7c <memmove+0x5f>
  800b6d:	f6 c1 03             	test   $0x3,%cl
  800b70:	75 0a                	jne    800b7c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b72:	c1 e9 02             	shr    $0x2,%ecx
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	fc                   	cld    
  800b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7a:	eb 05                	jmp    800b81 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7c:	89 c7                	mov    %eax,%edi
  800b7e:	fc                   	cld    
  800b7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	ff 75 0c             	pushl  0xc(%ebp)
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 87 ff ff ff       	call   800b1d <memmove>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba3:	89 c6                	mov    %eax,%esi
  800ba5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	eb 1a                	jmp    800bc4 <memcmp+0x2c>
		if (*s1 != *s2)
  800baa:	0f b6 08             	movzbl (%eax),%ecx
  800bad:	0f b6 1a             	movzbl (%edx),%ebx
  800bb0:	38 d9                	cmp    %bl,%cl
  800bb2:	74 0a                	je     800bbe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb4:	0f b6 c1             	movzbl %cl,%eax
  800bb7:	0f b6 db             	movzbl %bl,%ebx
  800bba:	29 d8                	sub    %ebx,%eax
  800bbc:	eb 0f                	jmp    800bcd <memcmp+0x35>
		s1++, s2++;
  800bbe:	83 c0 01             	add    $0x1,%eax
  800bc1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc4:	39 f0                	cmp    %esi,%eax
  800bc6:	75 e2                	jne    800baa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bd8:	89 c1                	mov    %eax,%ecx
  800bda:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bdd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	eb 0a                	jmp    800bed <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be3:	0f b6 10             	movzbl (%eax),%edx
  800be6:	39 da                	cmp    %ebx,%edx
  800be8:	74 07                	je     800bf1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bea:	83 c0 01             	add    $0x1,%eax
  800bed:	39 c8                	cmp    %ecx,%eax
  800bef:	72 f2                	jb     800be3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c00:	eb 03                	jmp    800c05 <strtol+0x11>
		s++;
  800c02:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c05:	0f b6 01             	movzbl (%ecx),%eax
  800c08:	3c 20                	cmp    $0x20,%al
  800c0a:	74 f6                	je     800c02 <strtol+0xe>
  800c0c:	3c 09                	cmp    $0x9,%al
  800c0e:	74 f2                	je     800c02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c10:	3c 2b                	cmp    $0x2b,%al
  800c12:	75 0a                	jne    800c1e <strtol+0x2a>
		s++;
  800c14:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c17:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1c:	eb 11                	jmp    800c2f <strtol+0x3b>
  800c1e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c23:	3c 2d                	cmp    $0x2d,%al
  800c25:	75 08                	jne    800c2f <strtol+0x3b>
		s++, neg = 1;
  800c27:	83 c1 01             	add    $0x1,%ecx
  800c2a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c35:	75 15                	jne    800c4c <strtol+0x58>
  800c37:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3a:	75 10                	jne    800c4c <strtol+0x58>
  800c3c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c40:	75 7c                	jne    800cbe <strtol+0xca>
		s += 2, base = 16;
  800c42:	83 c1 02             	add    $0x2,%ecx
  800c45:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4a:	eb 16                	jmp    800c62 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c4c:	85 db                	test   %ebx,%ebx
  800c4e:	75 12                	jne    800c62 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c50:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c55:	80 39 30             	cmpb   $0x30,(%ecx)
  800c58:	75 08                	jne    800c62 <strtol+0x6e>
		s++, base = 8;
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c62:	b8 00 00 00 00       	mov    $0x0,%eax
  800c67:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6a:	0f b6 11             	movzbl (%ecx),%edx
  800c6d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c70:	89 f3                	mov    %esi,%ebx
  800c72:	80 fb 09             	cmp    $0x9,%bl
  800c75:	77 08                	ja     800c7f <strtol+0x8b>
			dig = *s - '0';
  800c77:	0f be d2             	movsbl %dl,%edx
  800c7a:	83 ea 30             	sub    $0x30,%edx
  800c7d:	eb 22                	jmp    800ca1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c7f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c82:	89 f3                	mov    %esi,%ebx
  800c84:	80 fb 19             	cmp    $0x19,%bl
  800c87:	77 08                	ja     800c91 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 57             	sub    $0x57,%edx
  800c8f:	eb 10                	jmp    800ca1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c91:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c94:	89 f3                	mov    %esi,%ebx
  800c96:	80 fb 19             	cmp    $0x19,%bl
  800c99:	77 16                	ja     800cb1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c9b:	0f be d2             	movsbl %dl,%edx
  800c9e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca4:	7d 0b                	jge    800cb1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ca6:	83 c1 01             	add    $0x1,%ecx
  800ca9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cad:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800caf:	eb b9                	jmp    800c6a <strtol+0x76>

	if (endptr)
  800cb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb5:	74 0d                	je     800cc4 <strtol+0xd0>
		*endptr = (char *) s;
  800cb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cba:	89 0e                	mov    %ecx,(%esi)
  800cbc:	eb 06                	jmp    800cc4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cbe:	85 db                	test   %ebx,%ebx
  800cc0:	74 98                	je     800c5a <strtol+0x66>
  800cc2:	eb 9e                	jmp    800c62 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc4:	89 c2                	mov    %eax,%edx
  800cc6:	f7 da                	neg    %edx
  800cc8:	85 ff                	test   %edi,%edi
  800cca:	0f 45 c2             	cmovne %edx,%eax
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 c3                	mov    %eax,%ebx
  800ce5:	89 c7                	mov    %eax,%edi
  800ce7:	89 c6                	mov    %eax,%esi
  800ce9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800d00:	89 d1                	mov    %edx,%ecx
  800d02:	89 d3                	mov    %edx,%ebx
  800d04:	89 d7                	mov    %edx,%edi
  800d06:	89 d6                	mov    %edx,%esi
  800d08:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 cb                	mov    %ecx,%ebx
  800d27:	89 cf                	mov    %ecx,%edi
  800d29:	89 ce                	mov    %ecx,%esi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 03                	push   $0x3
  800d37:	68 3f 2c 80 00       	push   $0x802c3f
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 5c 2c 80 00       	push   $0x802c5c
  800d43:	e8 e5 f5 ff ff       	call   80032d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d60:	89 d1                	mov    %edx,%ecx
  800d62:	89 d3                	mov    %edx,%ebx
  800d64:	89 d7                	mov    %edx,%edi
  800d66:	89 d6                	mov    %edx,%esi
  800d68:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_yield>:

void
sys_yield(void)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7f:	89 d1                	mov    %edx,%ecx
  800d81:	89 d3                	mov    %edx,%ebx
  800d83:	89 d7                	mov    %edx,%edi
  800d85:	89 d6                	mov    %edx,%esi
  800d87:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	be 00 00 00 00       	mov    $0x0,%esi
  800d9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daa:	89 f7                	mov    %esi,%edi
  800dac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dae:	85 c0                	test   %eax,%eax
  800db0:	7e 17                	jle    800dc9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	50                   	push   %eax
  800db6:	6a 04                	push   $0x4
  800db8:	68 3f 2c 80 00       	push   $0x802c3f
  800dbd:	6a 23                	push   $0x23
  800dbf:	68 5c 2c 80 00       	push   $0x802c5c
  800dc4:	e8 64 f5 ff ff       	call   80032d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800deb:	8b 75 18             	mov    0x18(%ebp),%esi
  800dee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7e 17                	jle    800e0b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	50                   	push   %eax
  800df8:	6a 05                	push   $0x5
  800dfa:	68 3f 2c 80 00       	push   $0x802c3f
  800dff:	6a 23                	push   $0x23
  800e01:	68 5c 2c 80 00       	push   $0x802c5c
  800e06:	e8 22 f5 ff ff       	call   80032d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 06 00 00 00       	mov    $0x6,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 17                	jle    800e4d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	50                   	push   %eax
  800e3a:	6a 06                	push   $0x6
  800e3c:	68 3f 2c 80 00       	push   $0x802c3f
  800e41:	6a 23                	push   $0x23
  800e43:	68 5c 2c 80 00       	push   $0x802c5c
  800e48:	e8 e0 f4 ff ff       	call   80032d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e63:	b8 08 00 00 00       	mov    $0x8,%eax
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 df                	mov    %ebx,%edi
  800e70:	89 de                	mov    %ebx,%esi
  800e72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e74:	85 c0                	test   %eax,%eax
  800e76:	7e 17                	jle    800e8f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	50                   	push   %eax
  800e7c:	6a 08                	push   $0x8
  800e7e:	68 3f 2c 80 00       	push   $0x802c3f
  800e83:	6a 23                	push   $0x23
  800e85:	68 5c 2c 80 00       	push   $0x802c5c
  800e8a:	e8 9e f4 ff ff       	call   80032d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	89 df                	mov    %ebx,%edi
  800eb2:	89 de                	mov    %ebx,%esi
  800eb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	7e 17                	jle    800ed1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eba:	83 ec 0c             	sub    $0xc,%esp
  800ebd:	50                   	push   %eax
  800ebe:	6a 09                	push   $0x9
  800ec0:	68 3f 2c 80 00       	push   $0x802c3f
  800ec5:	6a 23                	push   $0x23
  800ec7:	68 5c 2c 80 00       	push   $0x802c5c
  800ecc:	e8 5c f4 ff ff       	call   80032d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef2:	89 df                	mov    %ebx,%edi
  800ef4:	89 de                	mov    %ebx,%esi
  800ef6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	7e 17                	jle    800f13 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	50                   	push   %eax
  800f00:	6a 0a                	push   $0xa
  800f02:	68 3f 2c 80 00       	push   $0x802c3f
  800f07:	6a 23                	push   $0x23
  800f09:	68 5c 2c 80 00       	push   $0x802c5c
  800f0e:	e8 1a f4 ff ff       	call   80032d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f21:	be 00 00 00 00       	mov    $0x0,%esi
  800f26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f37:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	89 cb                	mov    %ecx,%ebx
  800f56:	89 cf                	mov    %ecx,%edi
  800f58:	89 ce                	mov    %ecx,%esi
  800f5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 17                	jle    800f77 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	50                   	push   %eax
  800f64:	6a 0d                	push   $0xd
  800f66:	68 3f 2c 80 00       	push   $0x802c3f
  800f6b:	6a 23                	push   $0x23
  800f6d:	68 5c 2c 80 00       	push   $0x802c5c
  800f72:	e8 b6 f3 ff ff       	call   80032d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f8f:	89 d1                	mov    %edx,%ecx
  800f91:	89 d3                	mov    %edx,%ebx
  800f93:	89 d7                	mov    %edx,%edi
  800f95:	89 d6                	mov    %edx,%esi
  800f97:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fac:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb7:	89 df                	mov    %ebx,%edi
  800fb9:	89 de                	mov    %ebx,%esi
  800fbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7e 17                	jle    800fd8 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	50                   	push   %eax
  800fc5:	6a 0f                	push   $0xf
  800fc7:	68 3f 2c 80 00       	push   $0x802c3f
  800fcc:	6a 23                	push   $0x23
  800fce:	68 5c 2c 80 00       	push   $0x802c5c
  800fd3:	e8 55 f3 ff ff       	call   80032d <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fee:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff9:	89 df                	mov    %ebx,%edi
  800ffb:	89 de                	mov    %ebx,%esi
  800ffd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fff:	85 c0                	test   %eax,%eax
  801001:	7e 17                	jle    80101a <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	50                   	push   %eax
  801007:	6a 10                	push   $0x10
  801009:	68 3f 2c 80 00       	push   $0x802c3f
  80100e:	6a 23                	push   $0x23
  801010:	68 5c 2c 80 00       	push   $0x802c5c
  801015:	e8 13 f3 ff ff       	call   80032d <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  80101a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80102a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  80102c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801030:	75 25                	jne    801057 <pgfault+0x35>
  801032:	89 d8                	mov    %ebx,%eax
  801034:	c1 e8 0c             	shr    $0xc,%eax
  801037:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103e:	f6 c4 08             	test   $0x8,%ah
  801041:	75 14                	jne    801057 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	68 6c 2c 80 00       	push   $0x802c6c
  80104b:	6a 1e                	push   $0x1e
  80104d:	68 00 2d 80 00       	push   $0x802d00
  801052:	e8 d6 f2 ff ff       	call   80032d <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  801057:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  80105d:	e8 ee fc ff ff       	call   800d50 <sys_getenvid>
  801062:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	6a 07                	push   $0x7
  801069:	68 00 f0 7f 00       	push   $0x7ff000
  80106e:	50                   	push   %eax
  80106f:	e8 1a fd ff ff       	call   800d8e <sys_page_alloc>
	if (r < 0)
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	79 12                	jns    80108d <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  80107b:	50                   	push   %eax
  80107c:	68 98 2c 80 00       	push   $0x802c98
  801081:	6a 33                	push   $0x33
  801083:	68 00 2d 80 00       	push   $0x802d00
  801088:	e8 a0 f2 ff ff       	call   80032d <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  80108d:	83 ec 04             	sub    $0x4,%esp
  801090:	68 00 10 00 00       	push   $0x1000
  801095:	53                   	push   %ebx
  801096:	68 00 f0 7f 00       	push   $0x7ff000
  80109b:	e8 e5 fa ff ff       	call   800b85 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  8010a0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010a7:	53                   	push   %ebx
  8010a8:	56                   	push   %esi
  8010a9:	68 00 f0 7f 00       	push   $0x7ff000
  8010ae:	56                   	push   %esi
  8010af:	e8 1d fd ff ff       	call   800dd1 <sys_page_map>
	if (r < 0)
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	79 12                	jns    8010cd <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  8010bb:	50                   	push   %eax
  8010bc:	68 bc 2c 80 00       	push   $0x802cbc
  8010c1:	6a 3b                	push   $0x3b
  8010c3:	68 00 2d 80 00       	push   $0x802d00
  8010c8:	e8 60 f2 ff ff       	call   80032d <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	68 00 f0 7f 00       	push   $0x7ff000
  8010d5:	56                   	push   %esi
  8010d6:	e8 38 fd ff ff       	call   800e13 <sys_page_unmap>
	if (r < 0)
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 12                	jns    8010f4 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  8010e2:	50                   	push   %eax
  8010e3:	68 e0 2c 80 00       	push   $0x802ce0
  8010e8:	6a 40                	push   $0x40
  8010ea:	68 00 2d 80 00       	push   $0x802d00
  8010ef:	e8 39 f2 ff ff       	call   80032d <_panic>
}
  8010f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801104:	68 22 10 80 00       	push   $0x801022
  801109:	e8 dc 13 00 00       	call   8024ea <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80110e:	b8 07 00 00 00       	mov    $0x7,%eax
  801113:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	0f 88 64 01 00 00    	js     801284 <fork+0x189>
  801120:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801125:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80112a:	85 c0                	test   %eax,%eax
  80112c:	75 21                	jne    80114f <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  80112e:	e8 1d fc ff ff       	call   800d50 <sys_getenvid>
  801133:	25 ff 03 00 00       	and    $0x3ff,%eax
  801138:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80113b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801140:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  801145:	ba 00 00 00 00       	mov    $0x0,%edx
  80114a:	e9 3f 01 00 00       	jmp    80128e <fork+0x193>
  80114f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801152:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801154:	89 d8                	mov    %ebx,%eax
  801156:	c1 e8 16             	shr    $0x16,%eax
  801159:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801160:	a8 01                	test   $0x1,%al
  801162:	0f 84 bd 00 00 00    	je     801225 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801168:	89 d8                	mov    %ebx,%eax
  80116a:	c1 e8 0c             	shr    $0xc,%eax
  80116d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801174:	f6 c2 01             	test   $0x1,%dl
  801177:	0f 84 a8 00 00 00    	je     801225 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  80117d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801184:	a8 04                	test   $0x4,%al
  801186:	0f 84 99 00 00 00    	je     801225 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  80118c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801193:	f6 c4 04             	test   $0x4,%ah
  801196:	74 17                	je     8011af <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	68 07 0e 00 00       	push   $0xe07
  8011a0:	53                   	push   %ebx
  8011a1:	57                   	push   %edi
  8011a2:	53                   	push   %ebx
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 27 fc ff ff       	call   800dd1 <sys_page_map>
  8011aa:	83 c4 20             	add    $0x20,%esp
  8011ad:	eb 76                	jmp    801225 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8011af:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011b6:	a8 02                	test   $0x2,%al
  8011b8:	75 0c                	jne    8011c6 <fork+0xcb>
  8011ba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c1:	f6 c4 08             	test   $0x8,%ah
  8011c4:	74 3f                	je     801205 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	68 05 08 00 00       	push   $0x805
  8011ce:	53                   	push   %ebx
  8011cf:	57                   	push   %edi
  8011d0:	53                   	push   %ebx
  8011d1:	6a 00                	push   $0x0
  8011d3:	e8 f9 fb ff ff       	call   800dd1 <sys_page_map>
		if (r < 0)
  8011d8:	83 c4 20             	add    $0x20,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 a5 00 00 00    	js     801288 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	68 05 08 00 00       	push   $0x805
  8011eb:	53                   	push   %ebx
  8011ec:	6a 00                	push   $0x0
  8011ee:	53                   	push   %ebx
  8011ef:	6a 00                	push   $0x0
  8011f1:	e8 db fb ff ff       	call   800dd1 <sys_page_map>
  8011f6:	83 c4 20             	add    $0x20,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801200:	0f 4f c1             	cmovg  %ecx,%eax
  801203:	eb 1c                	jmp    801221 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	6a 05                	push   $0x5
  80120a:	53                   	push   %ebx
  80120b:	57                   	push   %edi
  80120c:	53                   	push   %ebx
  80120d:	6a 00                	push   $0x0
  80120f:	e8 bd fb ff ff       	call   800dd1 <sys_page_map>
  801214:	83 c4 20             	add    $0x20,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121e:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801221:	85 c0                	test   %eax,%eax
  801223:	78 67                	js     80128c <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801225:	83 c6 01             	add    $0x1,%esi
  801228:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80122e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801234:	0f 85 1a ff ff ff    	jne    801154 <fork+0x59>
  80123a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80123d:	83 ec 04             	sub    $0x4,%esp
  801240:	6a 07                	push   $0x7
  801242:	68 00 f0 bf ee       	push   $0xeebff000
  801247:	57                   	push   %edi
  801248:	e8 41 fb ff ff       	call   800d8e <sys_page_alloc>
	if (r < 0)
  80124d:	83 c4 10             	add    $0x10,%esp
		return r;
  801250:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801252:	85 c0                	test   %eax,%eax
  801254:	78 38                	js     80128e <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	68 31 25 80 00       	push   $0x802531
  80125e:	57                   	push   %edi
  80125f:	e8 75 fc ff ff       	call   800ed9 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801264:	83 c4 10             	add    $0x10,%esp
		return r;
  801267:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 21                	js     80128e <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	6a 02                	push   $0x2
  801272:	57                   	push   %edi
  801273:	e8 dd fb ff ff       	call   800e55 <sys_env_set_status>
	if (r < 0)
  801278:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 48 f8             	cmovs  %eax,%edi
  801280:	89 fa                	mov    %edi,%edx
  801282:	eb 0a                	jmp    80128e <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801284:	89 c2                	mov    %eax,%edx
  801286:	eb 06                	jmp    80128e <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801288:	89 c2                	mov    %eax,%edx
  80128a:	eb 02                	jmp    80128e <fork+0x193>
  80128c:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  80128e:	89 d0                	mov    %edx,%eax
  801290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <sfork>:

// Challenge!
int
sfork(void)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80129e:	68 0b 2d 80 00       	push   $0x802d0b
  8012a3:	68 c9 00 00 00       	push   $0xc9
  8012a8:	68 00 2d 80 00       	push   $0x802d00
  8012ad:	e8 7b f0 ff ff       	call   80032d <_panic>

008012b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8012c0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8012c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012c7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	50                   	push   %eax
  8012ce:	e8 6b fc ff ff       	call   800f3e <sys_ipc_recv>

	if (from_env_store != NULL)
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	85 f6                	test   %esi,%esi
  8012d8:	74 14                	je     8012ee <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8012da:	ba 00 00 00 00       	mov    $0x0,%edx
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 09                	js     8012ec <ipc_recv+0x3a>
  8012e3:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8012e9:	8b 52 74             	mov    0x74(%edx),%edx
  8012ec:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8012ee:	85 db                	test   %ebx,%ebx
  8012f0:	74 14                	je     801306 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8012f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 09                	js     801304 <ipc_recv+0x52>
  8012fb:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801301:	8b 52 78             	mov    0x78(%edx),%edx
  801304:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801306:	85 c0                	test   %eax,%eax
  801308:	78 08                	js     801312 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80130a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80130f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801312:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    

00801319 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	57                   	push   %edi
  80131d:	56                   	push   %esi
  80131e:	53                   	push   %ebx
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	8b 7d 08             	mov    0x8(%ebp),%edi
  801325:	8b 75 0c             	mov    0xc(%ebp),%esi
  801328:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80132b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80132d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801332:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801335:	ff 75 14             	pushl  0x14(%ebp)
  801338:	53                   	push   %ebx
  801339:	56                   	push   %esi
  80133a:	57                   	push   %edi
  80133b:	e8 db fb ff ff       	call   800f1b <sys_ipc_try_send>

		if (err < 0) {
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	79 1e                	jns    801365 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801347:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80134a:	75 07                	jne    801353 <ipc_send+0x3a>
				sys_yield();
  80134c:	e8 1e fa ff ff       	call   800d6f <sys_yield>
  801351:	eb e2                	jmp    801335 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801353:	50                   	push   %eax
  801354:	68 21 2d 80 00       	push   $0x802d21
  801359:	6a 49                	push   $0x49
  80135b:	68 2e 2d 80 00       	push   $0x802d2e
  801360:	e8 c8 ef ff ff       	call   80032d <_panic>
		}

	} while (err < 0);

}
  801365:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801368:	5b                   	pop    %ebx
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801378:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80137b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801381:	8b 52 50             	mov    0x50(%edx),%edx
  801384:	39 ca                	cmp    %ecx,%edx
  801386:	75 0d                	jne    801395 <ipc_find_env+0x28>
			return envs[i].env_id;
  801388:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80138b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801390:	8b 40 48             	mov    0x48(%eax),%eax
  801393:	eb 0f                	jmp    8013a4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801395:	83 c0 01             	add    $0x1,%eax
  801398:	3d 00 04 00 00       	cmp    $0x400,%eax
  80139d:	75 d9                	jne    801378 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b1:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	c1 ea 16             	shr    $0x16,%edx
  8013dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e4:	f6 c2 01             	test   $0x1,%dl
  8013e7:	74 11                	je     8013fa <fd_alloc+0x2d>
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	c1 ea 0c             	shr    $0xc,%edx
  8013ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	75 09                	jne    801403 <fd_alloc+0x36>
			*fd_store = fd;
  8013fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	eb 17                	jmp    80141a <fd_alloc+0x4d>
  801403:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801408:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140d:	75 c9                	jne    8013d8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80140f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801415:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801422:	83 f8 1f             	cmp    $0x1f,%eax
  801425:	77 36                	ja     80145d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801427:	c1 e0 0c             	shl    $0xc,%eax
  80142a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80142f:	89 c2                	mov    %eax,%edx
  801431:	c1 ea 16             	shr    $0x16,%edx
  801434:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143b:	f6 c2 01             	test   $0x1,%dl
  80143e:	74 24                	je     801464 <fd_lookup+0x48>
  801440:	89 c2                	mov    %eax,%edx
  801442:	c1 ea 0c             	shr    $0xc,%edx
  801445:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144c:	f6 c2 01             	test   $0x1,%dl
  80144f:	74 1a                	je     80146b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801451:	8b 55 0c             	mov    0xc(%ebp),%edx
  801454:	89 02                	mov    %eax,(%edx)
	return 0;
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
  80145b:	eb 13                	jmp    801470 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801462:	eb 0c                	jmp    801470 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801464:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801469:	eb 05                	jmp    801470 <fd_lookup+0x54>
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147b:	ba b8 2d 80 00       	mov    $0x802db8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801480:	eb 13                	jmp    801495 <dev_lookup+0x23>
  801482:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801485:	39 08                	cmp    %ecx,(%eax)
  801487:	75 0c                	jne    801495 <dev_lookup+0x23>
			*dev = devtab[i];
  801489:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	eb 2e                	jmp    8014c3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801495:	8b 02                	mov    (%edx),%eax
  801497:	85 c0                	test   %eax,%eax
  801499:	75 e7                	jne    801482 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014a0:	8b 40 48             	mov    0x48(%eax),%eax
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	51                   	push   %ecx
  8014a7:	50                   	push   %eax
  8014a8:	68 38 2d 80 00       	push   $0x802d38
  8014ad:	e8 54 ef ff ff       	call   800406 <cprintf>
	*dev = 0;
  8014b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	56                   	push   %esi
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 10             	sub    $0x10,%esp
  8014cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014dd:	c1 e8 0c             	shr    $0xc,%eax
  8014e0:	50                   	push   %eax
  8014e1:	e8 36 ff ff ff       	call   80141c <fd_lookup>
  8014e6:	83 c4 08             	add    $0x8,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 05                	js     8014f2 <fd_close+0x2d>
	    || fd != fd2)
  8014ed:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f0:	74 0c                	je     8014fe <fd_close+0x39>
		return (must_exist ? r : 0);
  8014f2:	84 db                	test   %bl,%bl
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	0f 44 c2             	cmove  %edx,%eax
  8014fc:	eb 41                	jmp    80153f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	ff 36                	pushl  (%esi)
  801507:	e8 66 ff ff ff       	call   801472 <dev_lookup>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 1a                	js     80152f <fd_close+0x6a>
		if (dev->dev_close)
  801515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801518:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80151b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801520:	85 c0                	test   %eax,%eax
  801522:	74 0b                	je     80152f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	56                   	push   %esi
  801528:	ff d0                	call   *%eax
  80152a:	89 c3                	mov    %eax,%ebx
  80152c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	56                   	push   %esi
  801533:	6a 00                	push   $0x0
  801535:	e8 d9 f8 ff ff       	call   800e13 <sys_page_unmap>
	return r;
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	89 d8                	mov    %ebx,%eax
}
  80153f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801542:	5b                   	pop    %ebx
  801543:	5e                   	pop    %esi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    

00801546 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	ff 75 08             	pushl  0x8(%ebp)
  801553:	e8 c4 fe ff ff       	call   80141c <fd_lookup>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 10                	js     80156f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	6a 01                	push   $0x1
  801564:	ff 75 f4             	pushl  -0xc(%ebp)
  801567:	e8 59 ff ff ff       	call   8014c5 <fd_close>
  80156c:	83 c4 10             	add    $0x10,%esp
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <close_all>:

void
close_all(void)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	53                   	push   %ebx
  801575:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801578:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	53                   	push   %ebx
  801581:	e8 c0 ff ff ff       	call   801546 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801586:	83 c3 01             	add    $0x1,%ebx
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	83 fb 20             	cmp    $0x20,%ebx
  80158f:	75 ec                	jne    80157d <close_all+0xc>
		close(i);
}
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	57                   	push   %edi
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	83 ec 2c             	sub    $0x2c,%esp
  80159f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	ff 75 08             	pushl  0x8(%ebp)
  8015a9:	e8 6e fe ff ff       	call   80141c <fd_lookup>
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	0f 88 c1 00 00 00    	js     80167a <dup+0xe4>
		return r;
	close(newfdnum);
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	56                   	push   %esi
  8015bd:	e8 84 ff ff ff       	call   801546 <close>

	newfd = INDEX2FD(newfdnum);
  8015c2:	89 f3                	mov    %esi,%ebx
  8015c4:	c1 e3 0c             	shl    $0xc,%ebx
  8015c7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015cd:	83 c4 04             	add    $0x4,%esp
  8015d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d3:	e8 de fd ff ff       	call   8013b6 <fd2data>
  8015d8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015da:	89 1c 24             	mov    %ebx,(%esp)
  8015dd:	e8 d4 fd ff ff       	call   8013b6 <fd2data>
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015e8:	89 f8                	mov    %edi,%eax
  8015ea:	c1 e8 16             	shr    $0x16,%eax
  8015ed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f4:	a8 01                	test   $0x1,%al
  8015f6:	74 37                	je     80162f <dup+0x99>
  8015f8:	89 f8                	mov    %edi,%eax
  8015fa:	c1 e8 0c             	shr    $0xc,%eax
  8015fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801604:	f6 c2 01             	test   $0x1,%dl
  801607:	74 26                	je     80162f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801609:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	25 07 0e 00 00       	and    $0xe07,%eax
  801618:	50                   	push   %eax
  801619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80161c:	6a 00                	push   $0x0
  80161e:	57                   	push   %edi
  80161f:	6a 00                	push   $0x0
  801621:	e8 ab f7 ff ff       	call   800dd1 <sys_page_map>
  801626:	89 c7                	mov    %eax,%edi
  801628:	83 c4 20             	add    $0x20,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 2e                	js     80165d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80162f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801632:	89 d0                	mov    %edx,%eax
  801634:	c1 e8 0c             	shr    $0xc,%eax
  801637:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	25 07 0e 00 00       	and    $0xe07,%eax
  801646:	50                   	push   %eax
  801647:	53                   	push   %ebx
  801648:	6a 00                	push   $0x0
  80164a:	52                   	push   %edx
  80164b:	6a 00                	push   $0x0
  80164d:	e8 7f f7 ff ff       	call   800dd1 <sys_page_map>
  801652:	89 c7                	mov    %eax,%edi
  801654:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801657:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801659:	85 ff                	test   %edi,%edi
  80165b:	79 1d                	jns    80167a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	53                   	push   %ebx
  801661:	6a 00                	push   $0x0
  801663:	e8 ab f7 ff ff       	call   800e13 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801668:	83 c4 08             	add    $0x8,%esp
  80166b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80166e:	6a 00                	push   $0x0
  801670:	e8 9e f7 ff ff       	call   800e13 <sys_page_unmap>
	return r;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	89 f8                	mov    %edi,%eax
}
  80167a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5f                   	pop    %edi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 14             	sub    $0x14,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	53                   	push   %ebx
  801691:	e8 86 fd ff ff       	call   80141c <fd_lookup>
  801696:	83 c4 08             	add    $0x8,%esp
  801699:	89 c2                	mov    %eax,%edx
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 6d                	js     80170c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a9:	ff 30                	pushl  (%eax)
  8016ab:	e8 c2 fd ff ff       	call   801472 <dev_lookup>
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 4c                	js     801703 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ba:	8b 42 08             	mov    0x8(%edx),%eax
  8016bd:	83 e0 03             	and    $0x3,%eax
  8016c0:	83 f8 01             	cmp    $0x1,%eax
  8016c3:	75 21                	jne    8016e6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8016ca:	8b 40 48             	mov    0x48(%eax),%eax
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	50                   	push   %eax
  8016d2:	68 7c 2d 80 00       	push   $0x802d7c
  8016d7:	e8 2a ed ff ff       	call   800406 <cprintf>
		return -E_INVAL;
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e4:	eb 26                	jmp    80170c <read+0x8a>
	}
	if (!dev->dev_read)
  8016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e9:	8b 40 08             	mov    0x8(%eax),%eax
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	74 17                	je     801707 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016f0:	83 ec 04             	sub    $0x4,%esp
  8016f3:	ff 75 10             	pushl  0x10(%ebp)
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	52                   	push   %edx
  8016fa:	ff d0                	call   *%eax
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	eb 09                	jmp    80170c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	89 c2                	mov    %eax,%edx
  801705:	eb 05                	jmp    80170c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801707:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80170c:	89 d0                	mov    %edx,%eax
  80170e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	57                   	push   %edi
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 0c             	sub    $0xc,%esp
  80171c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80171f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801722:	bb 00 00 00 00       	mov    $0x0,%ebx
  801727:	eb 21                	jmp    80174a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	89 f0                	mov    %esi,%eax
  80172e:	29 d8                	sub    %ebx,%eax
  801730:	50                   	push   %eax
  801731:	89 d8                	mov    %ebx,%eax
  801733:	03 45 0c             	add    0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	57                   	push   %edi
  801738:	e8 45 ff ff ff       	call   801682 <read>
		if (m < 0)
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 10                	js     801754 <readn+0x41>
			return m;
		if (m == 0)
  801744:	85 c0                	test   %eax,%eax
  801746:	74 0a                	je     801752 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801748:	01 c3                	add    %eax,%ebx
  80174a:	39 f3                	cmp    %esi,%ebx
  80174c:	72 db                	jb     801729 <readn+0x16>
  80174e:	89 d8                	mov    %ebx,%eax
  801750:	eb 02                	jmp    801754 <readn+0x41>
  801752:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5f                   	pop    %edi
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 14             	sub    $0x14,%esp
  801763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801766:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	53                   	push   %ebx
  80176b:	e8 ac fc ff ff       	call   80141c <fd_lookup>
  801770:	83 c4 08             	add    $0x8,%esp
  801773:	89 c2                	mov    %eax,%edx
  801775:	85 c0                	test   %eax,%eax
  801777:	78 68                	js     8017e1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801779:	83 ec 08             	sub    $0x8,%esp
  80177c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177f:	50                   	push   %eax
  801780:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801783:	ff 30                	pushl  (%eax)
  801785:	e8 e8 fc ff ff       	call   801472 <dev_lookup>
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 47                	js     8017d8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801794:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801798:	75 21                	jne    8017bb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80179a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80179f:	8b 40 48             	mov    0x48(%eax),%eax
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	53                   	push   %ebx
  8017a6:	50                   	push   %eax
  8017a7:	68 98 2d 80 00       	push   $0x802d98
  8017ac:	e8 55 ec ff ff       	call   800406 <cprintf>
		return -E_INVAL;
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017b9:	eb 26                	jmp    8017e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017be:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c1:	85 d2                	test   %edx,%edx
  8017c3:	74 17                	je     8017dc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	ff 75 10             	pushl  0x10(%ebp)
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	50                   	push   %eax
  8017cf:	ff d2                	call   *%edx
  8017d1:	89 c2                	mov    %eax,%edx
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	eb 09                	jmp    8017e1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d8:	89 c2                	mov    %eax,%edx
  8017da:	eb 05                	jmp    8017e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017e1:	89 d0                	mov    %edx,%eax
  8017e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017f1:	50                   	push   %eax
  8017f2:	ff 75 08             	pushl  0x8(%ebp)
  8017f5:	e8 22 fc ff ff       	call   80141c <fd_lookup>
  8017fa:	83 c4 08             	add    $0x8,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 0e                	js     80180f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801801:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801804:	8b 55 0c             	mov    0xc(%ebp),%edx
  801807:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 14             	sub    $0x14,%esp
  801818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181e:	50                   	push   %eax
  80181f:	53                   	push   %ebx
  801820:	e8 f7 fb ff ff       	call   80141c <fd_lookup>
  801825:	83 c4 08             	add    $0x8,%esp
  801828:	89 c2                	mov    %eax,%edx
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 65                	js     801893 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801838:	ff 30                	pushl  (%eax)
  80183a:	e8 33 fc ff ff       	call   801472 <dev_lookup>
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 44                	js     80188a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80184d:	75 21                	jne    801870 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80184f:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801854:	8b 40 48             	mov    0x48(%eax),%eax
  801857:	83 ec 04             	sub    $0x4,%esp
  80185a:	53                   	push   %ebx
  80185b:	50                   	push   %eax
  80185c:	68 58 2d 80 00       	push   $0x802d58
  801861:	e8 a0 eb ff ff       	call   800406 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80186e:	eb 23                	jmp    801893 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801870:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801873:	8b 52 18             	mov    0x18(%edx),%edx
  801876:	85 d2                	test   %edx,%edx
  801878:	74 14                	je     80188e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	50                   	push   %eax
  801881:	ff d2                	call   *%edx
  801883:	89 c2                	mov    %eax,%edx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	eb 09                	jmp    801893 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	eb 05                	jmp    801893 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80188e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801893:	89 d0                	mov    %edx,%eax
  801895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 14             	sub    $0x14,%esp
  8018a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a7:	50                   	push   %eax
  8018a8:	ff 75 08             	pushl  0x8(%ebp)
  8018ab:	e8 6c fb ff ff       	call   80141c <fd_lookup>
  8018b0:	83 c4 08             	add    $0x8,%esp
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 58                	js     801911 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018bf:	50                   	push   %eax
  8018c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c3:	ff 30                	pushl  (%eax)
  8018c5:	e8 a8 fb ff ff       	call   801472 <dev_lookup>
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 37                	js     801908 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018d8:	74 32                	je     80190c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e4:	00 00 00 
	stat->st_isdir = 0;
  8018e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ee:	00 00 00 
	stat->st_dev = dev;
  8018f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	53                   	push   %ebx
  8018fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8018fe:	ff 50 14             	call   *0x14(%eax)
  801901:	89 c2                	mov    %eax,%edx
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	eb 09                	jmp    801911 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801908:	89 c2                	mov    %eax,%edx
  80190a:	eb 05                	jmp    801911 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80190c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801911:	89 d0                	mov    %edx,%eax
  801913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	6a 00                	push   $0x0
  801922:	ff 75 08             	pushl  0x8(%ebp)
  801925:	e8 d6 01 00 00       	call   801b00 <open>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	85 c0                	test   %eax,%eax
  801931:	78 1b                	js     80194e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	50                   	push   %eax
  80193a:	e8 5b ff ff ff       	call   80189a <fstat>
  80193f:	89 c6                	mov    %eax,%esi
	close(fd);
  801941:	89 1c 24             	mov    %ebx,(%esp)
  801944:	e8 fd fb ff ff       	call   801546 <close>
	return r;
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	89 f0                	mov    %esi,%eax
}
  80194e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	89 c6                	mov    %eax,%esi
  80195c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80195e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801965:	75 12                	jne    801979 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	6a 01                	push   $0x1
  80196c:	e8 fc f9 ff ff       	call   80136d <ipc_find_env>
  801971:	a3 04 40 80 00       	mov    %eax,0x804004
  801976:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801979:	6a 07                	push   $0x7
  80197b:	68 00 50 80 00       	push   $0x805000
  801980:	56                   	push   %esi
  801981:	ff 35 04 40 80 00    	pushl  0x804004
  801987:	e8 8d f9 ff ff       	call   801319 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80198c:	83 c4 0c             	add    $0xc,%esp
  80198f:	6a 00                	push   $0x0
  801991:	53                   	push   %ebx
  801992:	6a 00                	push   $0x0
  801994:	e8 19 f9 ff ff       	call   8012b2 <ipc_recv>
}
  801999:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199c:	5b                   	pop    %ebx
  80199d:	5e                   	pop    %esi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019be:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c3:	e8 8d ff ff ff       	call   801955 <fsipc>
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019db:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e5:	e8 6b ff ff ff       	call   801955 <fsipc>
}
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a01:	ba 00 00 00 00       	mov    $0x0,%edx
  801a06:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0b:	e8 45 ff ff ff       	call   801955 <fsipc>
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 2c                	js     801a40 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	68 00 50 80 00       	push   $0x805000
  801a1c:	53                   	push   %ebx
  801a1d:	e8 69 ef ff ff       	call   80098b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a22:	a1 80 50 80 00       	mov    0x805080,%eax
  801a27:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a2d:	a1 84 50 80 00       	mov    0x805084,%eax
  801a32:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  801a51:	8b 52 0c             	mov    0xc(%edx),%edx
  801a54:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a5a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a5f:	50                   	push   %eax
  801a60:	ff 75 0c             	pushl  0xc(%ebp)
  801a63:	68 08 50 80 00       	push   $0x805008
  801a68:	e8 b0 f0 ff ff       	call   800b1d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a72:	b8 04 00 00 00       	mov    $0x4,%eax
  801a77:	e8 d9 fe ff ff       	call   801955 <fsipc>

}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	8b 40 0c             	mov    0xc(%eax),%eax
  801a8c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a91:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a97:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  801aa1:	e8 af fe ff ff       	call   801955 <fsipc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 4b                	js     801af7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aac:	39 c6                	cmp    %eax,%esi
  801aae:	73 16                	jae    801ac6 <devfile_read+0x48>
  801ab0:	68 cc 2d 80 00       	push   $0x802dcc
  801ab5:	68 d3 2d 80 00       	push   $0x802dd3
  801aba:	6a 7c                	push   $0x7c
  801abc:	68 e8 2d 80 00       	push   $0x802de8
  801ac1:	e8 67 e8 ff ff       	call   80032d <_panic>
	assert(r <= PGSIZE);
  801ac6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801acb:	7e 16                	jle    801ae3 <devfile_read+0x65>
  801acd:	68 f3 2d 80 00       	push   $0x802df3
  801ad2:	68 d3 2d 80 00       	push   $0x802dd3
  801ad7:	6a 7d                	push   $0x7d
  801ad9:	68 e8 2d 80 00       	push   $0x802de8
  801ade:	e8 4a e8 ff ff       	call   80032d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	50                   	push   %eax
  801ae7:	68 00 50 80 00       	push   $0x805000
  801aec:	ff 75 0c             	pushl  0xc(%ebp)
  801aef:	e8 29 f0 ff ff       	call   800b1d <memmove>
	return r;
  801af4:	83 c4 10             	add    $0x10,%esp
}
  801af7:	89 d8                	mov    %ebx,%eax
  801af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 20             	sub    $0x20,%esp
  801b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b0a:	53                   	push   %ebx
  801b0b:	e8 42 ee ff ff       	call   800952 <strlen>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b18:	7f 67                	jg     801b81 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b1a:	83 ec 0c             	sub    $0xc,%esp
  801b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b20:	50                   	push   %eax
  801b21:	e8 a7 f8 ff ff       	call   8013cd <fd_alloc>
  801b26:	83 c4 10             	add    $0x10,%esp
		return r;
  801b29:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 57                	js     801b86 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b2f:	83 ec 08             	sub    $0x8,%esp
  801b32:	53                   	push   %ebx
  801b33:	68 00 50 80 00       	push   $0x805000
  801b38:	e8 4e ee ff ff       	call   80098b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b40:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b48:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4d:	e8 03 fe ff ff       	call   801955 <fsipc>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	79 14                	jns    801b6f <open+0x6f>
		fd_close(fd, 0);
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	6a 00                	push   $0x0
  801b60:	ff 75 f4             	pushl  -0xc(%ebp)
  801b63:	e8 5d f9 ff ff       	call   8014c5 <fd_close>
		return r;
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	89 da                	mov    %ebx,%edx
  801b6d:	eb 17                	jmp    801b86 <open+0x86>
	}

	return fd2num(fd);
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	ff 75 f4             	pushl  -0xc(%ebp)
  801b75:	e8 2c f8 ff ff       	call   8013a6 <fd2num>
  801b7a:	89 c2                	mov    %eax,%edx
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	eb 05                	jmp    801b86 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b81:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b86:	89 d0                	mov    %edx,%eax
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b93:	ba 00 00 00 00       	mov    $0x0,%edx
  801b98:	b8 08 00 00 00       	mov    $0x8,%eax
  801b9d:	e8 b3 fd ff ff       	call   801955 <fsipc>
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801baa:	68 ff 2d 80 00       	push   $0x802dff
  801baf:	ff 75 0c             	pushl  0xc(%ebp)
  801bb2:	e8 d4 ed ff ff       	call   80098b <strcpy>
	return 0;
}
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 10             	sub    $0x10,%esp
  801bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bc8:	53                   	push   %ebx
  801bc9:	e8 87 09 00 00       	call   802555 <pageref>
  801bce:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bd1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bd6:	83 f8 01             	cmp    $0x1,%eax
  801bd9:	75 10                	jne    801beb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 73 0c             	pushl  0xc(%ebx)
  801be1:	e8 c0 02 00 00       	call   801ea6 <nsipc_close>
  801be6:	89 c2                	mov    %eax,%edx
  801be8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801beb:	89 d0                	mov    %edx,%eax
  801bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bf8:	6a 00                	push   $0x0
  801bfa:	ff 75 10             	pushl  0x10(%ebp)
  801bfd:	ff 75 0c             	pushl  0xc(%ebp)
  801c00:	8b 45 08             	mov    0x8(%ebp),%eax
  801c03:	ff 70 0c             	pushl  0xc(%eax)
  801c06:	e8 78 03 00 00       	call   801f83 <nsipc_send>
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c13:	6a 00                	push   $0x0
  801c15:	ff 75 10             	pushl  0x10(%ebp)
  801c18:	ff 75 0c             	pushl  0xc(%ebp)
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	ff 70 0c             	pushl  0xc(%eax)
  801c21:	e8 f1 02 00 00       	call   801f17 <nsipc_recv>
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c31:	52                   	push   %edx
  801c32:	50                   	push   %eax
  801c33:	e8 e4 f7 ff ff       	call   80141c <fd_lookup>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	78 17                	js     801c56 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c42:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c48:	39 08                	cmp    %ecx,(%eax)
  801c4a:	75 05                	jne    801c51 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c4f:	eb 05                	jmp    801c56 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c51:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 1c             	sub    $0x1c,%esp
  801c60:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c65:	50                   	push   %eax
  801c66:	e8 62 f7 ff ff       	call   8013cd <fd_alloc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 1b                	js     801c8f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 08 f1 ff ff       	call   800d8e <sys_page_alloc>
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	79 10                	jns    801c9f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	56                   	push   %esi
  801c93:	e8 0e 02 00 00       	call   801ea6 <nsipc_close>
		return r;
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	89 d8                	mov    %ebx,%eax
  801c9d:	eb 24                	jmp    801cc3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cb4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	50                   	push   %eax
  801cbb:	e8 e6 f6 ff ff       	call   8013a6 <fd2num>
  801cc0:	83 c4 10             	add    $0x10,%esp
}
  801cc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc6:	5b                   	pop    %ebx
  801cc7:	5e                   	pop    %esi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	e8 50 ff ff ff       	call   801c28 <fd2sockid>
		return r;
  801cd8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 1f                	js     801cfd <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cde:	83 ec 04             	sub    $0x4,%esp
  801ce1:	ff 75 10             	pushl  0x10(%ebp)
  801ce4:	ff 75 0c             	pushl  0xc(%ebp)
  801ce7:	50                   	push   %eax
  801ce8:	e8 12 01 00 00       	call   801dff <nsipc_accept>
  801ced:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 07                	js     801cfd <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801cf6:	e8 5d ff ff ff       	call   801c58 <alloc_sockfd>
  801cfb:	89 c1                	mov    %eax,%ecx
}
  801cfd:	89 c8                	mov    %ecx,%eax
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	e8 19 ff ff ff       	call   801c28 <fd2sockid>
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 12                	js     801d25 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d13:	83 ec 04             	sub    $0x4,%esp
  801d16:	ff 75 10             	pushl  0x10(%ebp)
  801d19:	ff 75 0c             	pushl  0xc(%ebp)
  801d1c:	50                   	push   %eax
  801d1d:	e8 2d 01 00 00       	call   801e4f <nsipc_bind>
  801d22:	83 c4 10             	add    $0x10,%esp
}
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <shutdown>:

int
shutdown(int s, int how)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d30:	e8 f3 fe ff ff       	call   801c28 <fd2sockid>
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 0f                	js     801d48 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d39:	83 ec 08             	sub    $0x8,%esp
  801d3c:	ff 75 0c             	pushl  0xc(%ebp)
  801d3f:	50                   	push   %eax
  801d40:	e8 3f 01 00 00       	call   801e84 <nsipc_shutdown>
  801d45:	83 c4 10             	add    $0x10,%esp
}
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	e8 d0 fe ff ff       	call   801c28 <fd2sockid>
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	78 12                	js     801d6e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d5c:	83 ec 04             	sub    $0x4,%esp
  801d5f:	ff 75 10             	pushl  0x10(%ebp)
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	50                   	push   %eax
  801d66:	e8 55 01 00 00       	call   801ec0 <nsipc_connect>
  801d6b:	83 c4 10             	add    $0x10,%esp
}
  801d6e:	c9                   	leave  
  801d6f:	c3                   	ret    

00801d70 <listen>:

int
listen(int s, int backlog)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	e8 aa fe ff ff       	call   801c28 <fd2sockid>
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 0f                	js     801d91 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d82:	83 ec 08             	sub    $0x8,%esp
  801d85:	ff 75 0c             	pushl  0xc(%ebp)
  801d88:	50                   	push   %eax
  801d89:	e8 67 01 00 00       	call   801ef5 <nsipc_listen>
  801d8e:	83 c4 10             	add    $0x10,%esp
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d99:	ff 75 10             	pushl  0x10(%ebp)
  801d9c:	ff 75 0c             	pushl  0xc(%ebp)
  801d9f:	ff 75 08             	pushl  0x8(%ebp)
  801da2:	e8 3a 02 00 00       	call   801fe1 <nsipc_socket>
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 05                	js     801db3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801dae:	e8 a5 fe ff ff       	call   801c58 <alloc_sockfd>
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	53                   	push   %ebx
  801db9:	83 ec 04             	sub    $0x4,%esp
  801dbc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dbe:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801dc5:	75 12                	jne    801dd9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	6a 02                	push   $0x2
  801dcc:	e8 9c f5 ff ff       	call   80136d <ipc_find_env>
  801dd1:	a3 08 40 80 00       	mov    %eax,0x804008
  801dd6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801dd9:	6a 07                	push   $0x7
  801ddb:	68 00 60 80 00       	push   $0x806000
  801de0:	53                   	push   %ebx
  801de1:	ff 35 08 40 80 00    	pushl  0x804008
  801de7:	e8 2d f5 ff ff       	call   801319 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dec:	83 c4 0c             	add    $0xc,%esp
  801def:	6a 00                	push   $0x0
  801df1:	6a 00                	push   $0x0
  801df3:	6a 00                	push   $0x0
  801df5:	e8 b8 f4 ff ff       	call   8012b2 <ipc_recv>
}
  801dfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e07:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e0f:	8b 06                	mov    (%esi),%eax
  801e11:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	e8 95 ff ff ff       	call   801db5 <nsipc>
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 20                	js     801e46 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	ff 35 10 60 80 00    	pushl  0x806010
  801e2f:	68 00 60 80 00       	push   $0x806000
  801e34:	ff 75 0c             	pushl  0xc(%ebp)
  801e37:	e8 e1 ec ff ff       	call   800b1d <memmove>
		*addrlen = ret->ret_addrlen;
  801e3c:	a1 10 60 80 00       	mov    0x806010,%eax
  801e41:	89 06                	mov    %eax,(%esi)
  801e43:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e46:	89 d8                	mov    %ebx,%eax
  801e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e61:	53                   	push   %ebx
  801e62:	ff 75 0c             	pushl  0xc(%ebp)
  801e65:	68 04 60 80 00       	push   $0x806004
  801e6a:	e8 ae ec ff ff       	call   800b1d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e6f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e75:	b8 02 00 00 00       	mov    $0x2,%eax
  801e7a:	e8 36 ff ff ff       	call   801db5 <nsipc>
}
  801e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e9a:	b8 03 00 00 00       	mov    $0x3,%eax
  801e9f:	e8 11 ff ff ff       	call   801db5 <nsipc>
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <nsipc_close>:

int
nsipc_close(int s)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801eb4:	b8 04 00 00 00       	mov    $0x4,%eax
  801eb9:	e8 f7 fe ff ff       	call   801db5 <nsipc>
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ed2:	53                   	push   %ebx
  801ed3:	ff 75 0c             	pushl  0xc(%ebp)
  801ed6:	68 04 60 80 00       	push   $0x806004
  801edb:	e8 3d ec ff ff       	call   800b1d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ee0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ee6:	b8 05 00 00 00       	mov    $0x5,%eax
  801eeb:	e8 c5 fe ff ff       	call   801db5 <nsipc>
}
  801ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
  801efe:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f06:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f0b:	b8 06 00 00 00       	mov    $0x6,%eax
  801f10:	e8 a0 fe ff ff       	call   801db5 <nsipc>
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f22:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f27:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801f30:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f35:	b8 07 00 00 00       	mov    $0x7,%eax
  801f3a:	e8 76 fe ff ff       	call   801db5 <nsipc>
  801f3f:	89 c3                	mov    %eax,%ebx
  801f41:	85 c0                	test   %eax,%eax
  801f43:	78 35                	js     801f7a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f45:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f4a:	7f 04                	jg     801f50 <nsipc_recv+0x39>
  801f4c:	39 c6                	cmp    %eax,%esi
  801f4e:	7d 16                	jge    801f66 <nsipc_recv+0x4f>
  801f50:	68 0b 2e 80 00       	push   $0x802e0b
  801f55:	68 d3 2d 80 00       	push   $0x802dd3
  801f5a:	6a 62                	push   $0x62
  801f5c:	68 20 2e 80 00       	push   $0x802e20
  801f61:	e8 c7 e3 ff ff       	call   80032d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f66:	83 ec 04             	sub    $0x4,%esp
  801f69:	50                   	push   %eax
  801f6a:	68 00 60 80 00       	push   $0x806000
  801f6f:	ff 75 0c             	pushl  0xc(%ebp)
  801f72:	e8 a6 eb ff ff       	call   800b1d <memmove>
  801f77:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f7a:	89 d8                	mov    %ebx,%eax
  801f7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    

00801f83 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	53                   	push   %ebx
  801f87:	83 ec 04             	sub    $0x4,%esp
  801f8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f95:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f9b:	7e 16                	jle    801fb3 <nsipc_send+0x30>
  801f9d:	68 2c 2e 80 00       	push   $0x802e2c
  801fa2:	68 d3 2d 80 00       	push   $0x802dd3
  801fa7:	6a 6d                	push   $0x6d
  801fa9:	68 20 2e 80 00       	push   $0x802e20
  801fae:	e8 7a e3 ff ff       	call   80032d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fb3:	83 ec 04             	sub    $0x4,%esp
  801fb6:	53                   	push   %ebx
  801fb7:	ff 75 0c             	pushl  0xc(%ebp)
  801fba:	68 0c 60 80 00       	push   $0x80600c
  801fbf:	e8 59 eb ff ff       	call   800b1d <memmove>
	nsipcbuf.send.req_size = size;
  801fc4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fca:	8b 45 14             	mov    0x14(%ebp),%eax
  801fcd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fd2:	b8 08 00 00 00       	mov    $0x8,%eax
  801fd7:	e8 d9 fd ff ff       	call   801db5 <nsipc>
}
  801fdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ff7:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fff:	b8 09 00 00 00       	mov    $0x9,%eax
  802004:	e8 ac fd ff ff       	call   801db5 <nsipc>
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	56                   	push   %esi
  80200f:	53                   	push   %ebx
  802010:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802013:	83 ec 0c             	sub    $0xc,%esp
  802016:	ff 75 08             	pushl  0x8(%ebp)
  802019:	e8 98 f3 ff ff       	call   8013b6 <fd2data>
  80201e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802020:	83 c4 08             	add    $0x8,%esp
  802023:	68 38 2e 80 00       	push   $0x802e38
  802028:	53                   	push   %ebx
  802029:	e8 5d e9 ff ff       	call   80098b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80202e:	8b 46 04             	mov    0x4(%esi),%eax
  802031:	2b 06                	sub    (%esi),%eax
  802033:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802039:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802040:	00 00 00 
	stat->st_dev = &devpipe;
  802043:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80204a:	30 80 00 
	return 0;
}
  80204d:	b8 00 00 00 00       	mov    $0x0,%eax
  802052:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	53                   	push   %ebx
  80205d:	83 ec 0c             	sub    $0xc,%esp
  802060:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802063:	53                   	push   %ebx
  802064:	6a 00                	push   $0x0
  802066:	e8 a8 ed ff ff       	call   800e13 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80206b:	89 1c 24             	mov    %ebx,(%esp)
  80206e:	e8 43 f3 ff ff       	call   8013b6 <fd2data>
  802073:	83 c4 08             	add    $0x8,%esp
  802076:	50                   	push   %eax
  802077:	6a 00                	push   $0x0
  802079:	e8 95 ed ff ff       	call   800e13 <sys_page_unmap>
}
  80207e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802081:	c9                   	leave  
  802082:	c3                   	ret    

00802083 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	57                   	push   %edi
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 1c             	sub    $0x1c,%esp
  80208c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80208f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802091:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802096:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802099:	83 ec 0c             	sub    $0xc,%esp
  80209c:	ff 75 e0             	pushl  -0x20(%ebp)
  80209f:	e8 b1 04 00 00       	call   802555 <pageref>
  8020a4:	89 c3                	mov    %eax,%ebx
  8020a6:	89 3c 24             	mov    %edi,(%esp)
  8020a9:	e8 a7 04 00 00       	call   802555 <pageref>
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	39 c3                	cmp    %eax,%ebx
  8020b3:	0f 94 c1             	sete   %cl
  8020b6:	0f b6 c9             	movzbl %cl,%ecx
  8020b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8020bc:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8020c2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020c5:	39 ce                	cmp    %ecx,%esi
  8020c7:	74 1b                	je     8020e4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8020c9:	39 c3                	cmp    %eax,%ebx
  8020cb:	75 c4                	jne    802091 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020cd:	8b 42 58             	mov    0x58(%edx),%eax
  8020d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020d3:	50                   	push   %eax
  8020d4:	56                   	push   %esi
  8020d5:	68 3f 2e 80 00       	push   $0x802e3f
  8020da:	e8 27 e3 ff ff       	call   800406 <cprintf>
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	eb ad                	jmp    802091 <_pipeisclosed+0xe>
	}
}
  8020e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ea:	5b                   	pop    %ebx
  8020eb:	5e                   	pop    %esi
  8020ec:	5f                   	pop    %edi
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    

008020ef <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020ef:	55                   	push   %ebp
  8020f0:	89 e5                	mov    %esp,%ebp
  8020f2:	57                   	push   %edi
  8020f3:	56                   	push   %esi
  8020f4:	53                   	push   %ebx
  8020f5:	83 ec 28             	sub    $0x28,%esp
  8020f8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020fb:	56                   	push   %esi
  8020fc:	e8 b5 f2 ff ff       	call   8013b6 <fd2data>
  802101:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	bf 00 00 00 00       	mov    $0x0,%edi
  80210b:	eb 4b                	jmp    802158 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80210d:	89 da                	mov    %ebx,%edx
  80210f:	89 f0                	mov    %esi,%eax
  802111:	e8 6d ff ff ff       	call   802083 <_pipeisclosed>
  802116:	85 c0                	test   %eax,%eax
  802118:	75 48                	jne    802162 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80211a:	e8 50 ec ff ff       	call   800d6f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80211f:	8b 43 04             	mov    0x4(%ebx),%eax
  802122:	8b 0b                	mov    (%ebx),%ecx
  802124:	8d 51 20             	lea    0x20(%ecx),%edx
  802127:	39 d0                	cmp    %edx,%eax
  802129:	73 e2                	jae    80210d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80212b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802132:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802135:	89 c2                	mov    %eax,%edx
  802137:	c1 fa 1f             	sar    $0x1f,%edx
  80213a:	89 d1                	mov    %edx,%ecx
  80213c:	c1 e9 1b             	shr    $0x1b,%ecx
  80213f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802142:	83 e2 1f             	and    $0x1f,%edx
  802145:	29 ca                	sub    %ecx,%edx
  802147:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80214b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80214f:	83 c0 01             	add    $0x1,%eax
  802152:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802155:	83 c7 01             	add    $0x1,%edi
  802158:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80215b:	75 c2                	jne    80211f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80215d:	8b 45 10             	mov    0x10(%ebp),%eax
  802160:	eb 05                	jmp    802167 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802162:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	57                   	push   %edi
  802173:	56                   	push   %esi
  802174:	53                   	push   %ebx
  802175:	83 ec 18             	sub    $0x18,%esp
  802178:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80217b:	57                   	push   %edi
  80217c:	e8 35 f2 ff ff       	call   8013b6 <fd2data>
  802181:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802183:	83 c4 10             	add    $0x10,%esp
  802186:	bb 00 00 00 00       	mov    $0x0,%ebx
  80218b:	eb 3d                	jmp    8021ca <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80218d:	85 db                	test   %ebx,%ebx
  80218f:	74 04                	je     802195 <devpipe_read+0x26>
				return i;
  802191:	89 d8                	mov    %ebx,%eax
  802193:	eb 44                	jmp    8021d9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802195:	89 f2                	mov    %esi,%edx
  802197:	89 f8                	mov    %edi,%eax
  802199:	e8 e5 fe ff ff       	call   802083 <_pipeisclosed>
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	75 32                	jne    8021d4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021a2:	e8 c8 eb ff ff       	call   800d6f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021a7:	8b 06                	mov    (%esi),%eax
  8021a9:	3b 46 04             	cmp    0x4(%esi),%eax
  8021ac:	74 df                	je     80218d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021ae:	99                   	cltd   
  8021af:	c1 ea 1b             	shr    $0x1b,%edx
  8021b2:	01 d0                	add    %edx,%eax
  8021b4:	83 e0 1f             	and    $0x1f,%eax
  8021b7:	29 d0                	sub    %edx,%eax
  8021b9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021c1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021c4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021c7:	83 c3 01             	add    $0x1,%ebx
  8021ca:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021cd:	75 d8                	jne    8021a7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8021d2:	eb 05                	jmp    8021d9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021d4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021dc:	5b                   	pop    %ebx
  8021dd:	5e                   	pop    %esi
  8021de:	5f                   	pop    %edi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	56                   	push   %esi
  8021e5:	53                   	push   %ebx
  8021e6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ec:	50                   	push   %eax
  8021ed:	e8 db f1 ff ff       	call   8013cd <fd_alloc>
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	89 c2                	mov    %eax,%edx
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	0f 88 2c 01 00 00    	js     80232b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ff:	83 ec 04             	sub    $0x4,%esp
  802202:	68 07 04 00 00       	push   $0x407
  802207:	ff 75 f4             	pushl  -0xc(%ebp)
  80220a:	6a 00                	push   $0x0
  80220c:	e8 7d eb ff ff       	call   800d8e <sys_page_alloc>
  802211:	83 c4 10             	add    $0x10,%esp
  802214:	89 c2                	mov    %eax,%edx
  802216:	85 c0                	test   %eax,%eax
  802218:	0f 88 0d 01 00 00    	js     80232b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80221e:	83 ec 0c             	sub    $0xc,%esp
  802221:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802224:	50                   	push   %eax
  802225:	e8 a3 f1 ff ff       	call   8013cd <fd_alloc>
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	85 c0                	test   %eax,%eax
  802231:	0f 88 e2 00 00 00    	js     802319 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802237:	83 ec 04             	sub    $0x4,%esp
  80223a:	68 07 04 00 00       	push   $0x407
  80223f:	ff 75 f0             	pushl  -0x10(%ebp)
  802242:	6a 00                	push   $0x0
  802244:	e8 45 eb ff ff       	call   800d8e <sys_page_alloc>
  802249:	89 c3                	mov    %eax,%ebx
  80224b:	83 c4 10             	add    $0x10,%esp
  80224e:	85 c0                	test   %eax,%eax
  802250:	0f 88 c3 00 00 00    	js     802319 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802256:	83 ec 0c             	sub    $0xc,%esp
  802259:	ff 75 f4             	pushl  -0xc(%ebp)
  80225c:	e8 55 f1 ff ff       	call   8013b6 <fd2data>
  802261:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802263:	83 c4 0c             	add    $0xc,%esp
  802266:	68 07 04 00 00       	push   $0x407
  80226b:	50                   	push   %eax
  80226c:	6a 00                	push   $0x0
  80226e:	e8 1b eb ff ff       	call   800d8e <sys_page_alloc>
  802273:	89 c3                	mov    %eax,%ebx
  802275:	83 c4 10             	add    $0x10,%esp
  802278:	85 c0                	test   %eax,%eax
  80227a:	0f 88 89 00 00 00    	js     802309 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802280:	83 ec 0c             	sub    $0xc,%esp
  802283:	ff 75 f0             	pushl  -0x10(%ebp)
  802286:	e8 2b f1 ff ff       	call   8013b6 <fd2data>
  80228b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802292:	50                   	push   %eax
  802293:	6a 00                	push   $0x0
  802295:	56                   	push   %esi
  802296:	6a 00                	push   $0x0
  802298:	e8 34 eb ff ff       	call   800dd1 <sys_page_map>
  80229d:	89 c3                	mov    %eax,%ebx
  80229f:	83 c4 20             	add    $0x20,%esp
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 55                	js     8022fb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022d0:	83 ec 0c             	sub    $0xc,%esp
  8022d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d6:	e8 cb f0 ff ff       	call   8013a6 <fd2num>
  8022db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022de:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022e0:	83 c4 04             	add    $0x4,%esp
  8022e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8022e6:	e8 bb f0 ff ff       	call   8013a6 <fd2num>
  8022eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ee:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022f1:	83 c4 10             	add    $0x10,%esp
  8022f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f9:	eb 30                	jmp    80232b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022fb:	83 ec 08             	sub    $0x8,%esp
  8022fe:	56                   	push   %esi
  8022ff:	6a 00                	push   $0x0
  802301:	e8 0d eb ff ff       	call   800e13 <sys_page_unmap>
  802306:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802309:	83 ec 08             	sub    $0x8,%esp
  80230c:	ff 75 f0             	pushl  -0x10(%ebp)
  80230f:	6a 00                	push   $0x0
  802311:	e8 fd ea ff ff       	call   800e13 <sys_page_unmap>
  802316:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802319:	83 ec 08             	sub    $0x8,%esp
  80231c:	ff 75 f4             	pushl  -0xc(%ebp)
  80231f:	6a 00                	push   $0x0
  802321:	e8 ed ea ff ff       	call   800e13 <sys_page_unmap>
  802326:	83 c4 10             	add    $0x10,%esp
  802329:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802330:	5b                   	pop    %ebx
  802331:	5e                   	pop    %esi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    

00802334 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80233a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80233d:	50                   	push   %eax
  80233e:	ff 75 08             	pushl  0x8(%ebp)
  802341:	e8 d6 f0 ff ff       	call   80141c <fd_lookup>
  802346:	83 c4 10             	add    $0x10,%esp
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 18                	js     802365 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80234d:	83 ec 0c             	sub    $0xc,%esp
  802350:	ff 75 f4             	pushl  -0xc(%ebp)
  802353:	e8 5e f0 ff ff       	call   8013b6 <fd2data>
	return _pipeisclosed(fd, p);
  802358:	89 c2                	mov    %eax,%edx
  80235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235d:	e8 21 fd ff ff       	call   802083 <_pipeisclosed>
  802362:	83 c4 10             	add    $0x10,%esp
}
  802365:	c9                   	leave  
  802366:	c3                   	ret    

00802367 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80236a:	b8 00 00 00 00       	mov    $0x0,%eax
  80236f:	5d                   	pop    %ebp
  802370:	c3                   	ret    

00802371 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802371:	55                   	push   %ebp
  802372:	89 e5                	mov    %esp,%ebp
  802374:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802377:	68 57 2e 80 00       	push   $0x802e57
  80237c:	ff 75 0c             	pushl  0xc(%ebp)
  80237f:	e8 07 e6 ff ff       	call   80098b <strcpy>
	return 0;
}
  802384:	b8 00 00 00 00       	mov    $0x0,%eax
  802389:	c9                   	leave  
  80238a:	c3                   	ret    

0080238b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	57                   	push   %edi
  80238f:	56                   	push   %esi
  802390:	53                   	push   %ebx
  802391:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802397:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80239c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023a2:	eb 2d                	jmp    8023d1 <devcons_write+0x46>
		m = n - tot;
  8023a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023a7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023a9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023ac:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023b1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023b4:	83 ec 04             	sub    $0x4,%esp
  8023b7:	53                   	push   %ebx
  8023b8:	03 45 0c             	add    0xc(%ebp),%eax
  8023bb:	50                   	push   %eax
  8023bc:	57                   	push   %edi
  8023bd:	e8 5b e7 ff ff       	call   800b1d <memmove>
		sys_cputs(buf, m);
  8023c2:	83 c4 08             	add    $0x8,%esp
  8023c5:	53                   	push   %ebx
  8023c6:	57                   	push   %edi
  8023c7:	e8 06 e9 ff ff       	call   800cd2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023cc:	01 de                	add    %ebx,%esi
  8023ce:	83 c4 10             	add    $0x10,%esp
  8023d1:	89 f0                	mov    %esi,%eax
  8023d3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023d6:	72 cc                	jb     8023a4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023db:	5b                   	pop    %ebx
  8023dc:	5e                   	pop    %esi
  8023dd:	5f                   	pop    %edi
  8023de:	5d                   	pop    %ebp
  8023df:	c3                   	ret    

008023e0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	83 ec 08             	sub    $0x8,%esp
  8023e6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023ef:	74 2a                	je     80241b <devcons_read+0x3b>
  8023f1:	eb 05                	jmp    8023f8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023f3:	e8 77 e9 ff ff       	call   800d6f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023f8:	e8 f3 e8 ff ff       	call   800cf0 <sys_cgetc>
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	74 f2                	je     8023f3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802401:	85 c0                	test   %eax,%eax
  802403:	78 16                	js     80241b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802405:	83 f8 04             	cmp    $0x4,%eax
  802408:	74 0c                	je     802416 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80240a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80240d:	88 02                	mov    %al,(%edx)
	return 1;
  80240f:	b8 01 00 00 00       	mov    $0x1,%eax
  802414:	eb 05                	jmp    80241b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802416:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80241b:	c9                   	leave  
  80241c:	c3                   	ret    

0080241d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802423:	8b 45 08             	mov    0x8(%ebp),%eax
  802426:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802429:	6a 01                	push   $0x1
  80242b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80242e:	50                   	push   %eax
  80242f:	e8 9e e8 ff ff       	call   800cd2 <sys_cputs>
}
  802434:	83 c4 10             	add    $0x10,%esp
  802437:	c9                   	leave  
  802438:	c3                   	ret    

00802439 <getchar>:

int
getchar(void)
{
  802439:	55                   	push   %ebp
  80243a:	89 e5                	mov    %esp,%ebp
  80243c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80243f:	6a 01                	push   $0x1
  802441:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802444:	50                   	push   %eax
  802445:	6a 00                	push   $0x0
  802447:	e8 36 f2 ff ff       	call   801682 <read>
	if (r < 0)
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	85 c0                	test   %eax,%eax
  802451:	78 0f                	js     802462 <getchar+0x29>
		return r;
	if (r < 1)
  802453:	85 c0                	test   %eax,%eax
  802455:	7e 06                	jle    80245d <getchar+0x24>
		return -E_EOF;
	return c;
  802457:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80245b:	eb 05                	jmp    802462 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80245d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802462:	c9                   	leave  
  802463:	c3                   	ret    

00802464 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802464:	55                   	push   %ebp
  802465:	89 e5                	mov    %esp,%ebp
  802467:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80246a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80246d:	50                   	push   %eax
  80246e:	ff 75 08             	pushl  0x8(%ebp)
  802471:	e8 a6 ef ff ff       	call   80141c <fd_lookup>
  802476:	83 c4 10             	add    $0x10,%esp
  802479:	85 c0                	test   %eax,%eax
  80247b:	78 11                	js     80248e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80247d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802480:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802486:	39 10                	cmp    %edx,(%eax)
  802488:	0f 94 c0             	sete   %al
  80248b:	0f b6 c0             	movzbl %al,%eax
}
  80248e:	c9                   	leave  
  80248f:	c3                   	ret    

00802490 <opencons>:

int
opencons(void)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802499:	50                   	push   %eax
  80249a:	e8 2e ef ff ff       	call   8013cd <fd_alloc>
  80249f:	83 c4 10             	add    $0x10,%esp
		return r;
  8024a2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	78 3e                	js     8024e6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024a8:	83 ec 04             	sub    $0x4,%esp
  8024ab:	68 07 04 00 00       	push   $0x407
  8024b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b3:	6a 00                	push   $0x0
  8024b5:	e8 d4 e8 ff ff       	call   800d8e <sys_page_alloc>
  8024ba:	83 c4 10             	add    $0x10,%esp
		return r;
  8024bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	78 23                	js     8024e6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024c3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024d8:	83 ec 0c             	sub    $0xc,%esp
  8024db:	50                   	push   %eax
  8024dc:	e8 c5 ee ff ff       	call   8013a6 <fd2num>
  8024e1:	89 c2                	mov    %eax,%edx
  8024e3:	83 c4 10             	add    $0x10,%esp
}
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	c9                   	leave  
  8024e9:	c3                   	ret    

008024ea <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024ea:	55                   	push   %ebp
  8024eb:	89 e5                	mov    %esp,%ebp
  8024ed:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024f0:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024f7:	75 2e                	jne    802527 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8024f9:	e8 52 e8 ff ff       	call   800d50 <sys_getenvid>
  8024fe:	83 ec 04             	sub    $0x4,%esp
  802501:	68 07 0e 00 00       	push   $0xe07
  802506:	68 00 f0 bf ee       	push   $0xeebff000
  80250b:	50                   	push   %eax
  80250c:	e8 7d e8 ff ff       	call   800d8e <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802511:	e8 3a e8 ff ff       	call   800d50 <sys_getenvid>
  802516:	83 c4 08             	add    $0x8,%esp
  802519:	68 31 25 80 00       	push   $0x802531
  80251e:	50                   	push   %eax
  80251f:	e8 b5 e9 ff ff       	call   800ed9 <sys_env_set_pgfault_upcall>
  802524:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802527:	8b 45 08             	mov    0x8(%ebp),%eax
  80252a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80252f:	c9                   	leave  
  802530:	c3                   	ret    

00802531 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802531:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802532:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802537:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802539:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80253c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802540:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802544:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802547:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80254a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80254b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80254e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80254f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802550:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802554:	c3                   	ret    

00802555 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	c1 e8 16             	shr    $0x16,%eax
  802560:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802567:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80256c:	f6 c1 01             	test   $0x1,%cl
  80256f:	74 1d                	je     80258e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802571:	c1 ea 0c             	shr    $0xc,%edx
  802574:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80257b:	f6 c2 01             	test   $0x1,%dl
  80257e:	74 0e                	je     80258e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802580:	c1 ea 0c             	shr    $0xc,%edx
  802583:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80258a:	ef 
  80258b:	0f b7 c0             	movzwl %ax,%eax
}
  80258e:	5d                   	pop    %ebp
  80258f:	c3                   	ret    

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80259b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80259f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 f6                	test   %esi,%esi
  8025a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ad:	89 ca                	mov    %ecx,%edx
  8025af:	89 f8                	mov    %edi,%eax
  8025b1:	75 3d                	jne    8025f0 <__udivdi3+0x60>
  8025b3:	39 cf                	cmp    %ecx,%edi
  8025b5:	0f 87 c5 00 00 00    	ja     802680 <__udivdi3+0xf0>
  8025bb:	85 ff                	test   %edi,%edi
  8025bd:	89 fd                	mov    %edi,%ebp
  8025bf:	75 0b                	jne    8025cc <__udivdi3+0x3c>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	31 d2                	xor    %edx,%edx
  8025c8:	f7 f7                	div    %edi
  8025ca:	89 c5                	mov    %eax,%ebp
  8025cc:	89 c8                	mov    %ecx,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	f7 f5                	div    %ebp
  8025d2:	89 c1                	mov    %eax,%ecx
  8025d4:	89 d8                	mov    %ebx,%eax
  8025d6:	89 cf                	mov    %ecx,%edi
  8025d8:	f7 f5                	div    %ebp
  8025da:	89 c3                	mov    %eax,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	39 ce                	cmp    %ecx,%esi
  8025f2:	77 74                	ja     802668 <__udivdi3+0xd8>
  8025f4:	0f bd fe             	bsr    %esi,%edi
  8025f7:	83 f7 1f             	xor    $0x1f,%edi
  8025fa:	0f 84 98 00 00 00    	je     802698 <__udivdi3+0x108>
  802600:	bb 20 00 00 00       	mov    $0x20,%ebx
  802605:	89 f9                	mov    %edi,%ecx
  802607:	89 c5                	mov    %eax,%ebp
  802609:	29 fb                	sub    %edi,%ebx
  80260b:	d3 e6                	shl    %cl,%esi
  80260d:	89 d9                	mov    %ebx,%ecx
  80260f:	d3 ed                	shr    %cl,%ebp
  802611:	89 f9                	mov    %edi,%ecx
  802613:	d3 e0                	shl    %cl,%eax
  802615:	09 ee                	or     %ebp,%esi
  802617:	89 d9                	mov    %ebx,%ecx
  802619:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261d:	89 d5                	mov    %edx,%ebp
  80261f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802623:	d3 ed                	shr    %cl,%ebp
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e2                	shl    %cl,%edx
  802629:	89 d9                	mov    %ebx,%ecx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	09 c2                	or     %eax,%edx
  80262f:	89 d0                	mov    %edx,%eax
  802631:	89 ea                	mov    %ebp,%edx
  802633:	f7 f6                	div    %esi
  802635:	89 d5                	mov    %edx,%ebp
  802637:	89 c3                	mov    %eax,%ebx
  802639:	f7 64 24 0c          	mull   0xc(%esp)
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	72 10                	jb     802651 <__udivdi3+0xc1>
  802641:	8b 74 24 08          	mov    0x8(%esp),%esi
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e6                	shl    %cl,%esi
  802649:	39 c6                	cmp    %eax,%esi
  80264b:	73 07                	jae    802654 <__udivdi3+0xc4>
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	75 03                	jne    802654 <__udivdi3+0xc4>
  802651:	83 eb 01             	sub    $0x1,%ebx
  802654:	31 ff                	xor    %edi,%edi
  802656:	89 d8                	mov    %ebx,%eax
  802658:	89 fa                	mov    %edi,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	31 ff                	xor    %edi,%edi
  80266a:	31 db                	xor    %ebx,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 d8                	mov    %ebx,%eax
  802682:	f7 f7                	div    %edi
  802684:	31 ff                	xor    %edi,%edi
  802686:	89 c3                	mov    %eax,%ebx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 fa                	mov    %edi,%edx
  80268c:	83 c4 1c             	add    $0x1c,%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	39 ce                	cmp    %ecx,%esi
  80269a:	72 0c                	jb     8026a8 <__udivdi3+0x118>
  80269c:	31 db                	xor    %ebx,%ebx
  80269e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026a2:	0f 87 34 ff ff ff    	ja     8025dc <__udivdi3+0x4c>
  8026a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ad:	e9 2a ff ff ff       	jmp    8025dc <__udivdi3+0x4c>
  8026b2:	66 90                	xchg   %ax,%ax
  8026b4:	66 90                	xchg   %ax,%ax
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e1:	89 f3                	mov    %esi,%ebx
  8026e3:	89 3c 24             	mov    %edi,(%esp)
  8026e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ea:	75 1c                	jne    802708 <__umoddi3+0x48>
  8026ec:	39 f7                	cmp    %esi,%edi
  8026ee:	76 50                	jbe    802740 <__umoddi3+0x80>
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	f7 f7                	div    %edi
  8026f6:	89 d0                	mov    %edx,%eax
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	39 f2                	cmp    %esi,%edx
  80270a:	89 d0                	mov    %edx,%eax
  80270c:	77 52                	ja     802760 <__umoddi3+0xa0>
  80270e:	0f bd ea             	bsr    %edx,%ebp
  802711:	83 f5 1f             	xor    $0x1f,%ebp
  802714:	75 5a                	jne    802770 <__umoddi3+0xb0>
  802716:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80271a:	0f 82 e0 00 00 00    	jb     802800 <__umoddi3+0x140>
  802720:	39 0c 24             	cmp    %ecx,(%esp)
  802723:	0f 86 d7 00 00 00    	jbe    802800 <__umoddi3+0x140>
  802729:	8b 44 24 08          	mov    0x8(%esp),%eax
  80272d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	85 ff                	test   %edi,%edi
  802742:	89 fd                	mov    %edi,%ebp
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f7                	div    %edi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	89 f0                	mov    %esi,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f5                	div    %ebp
  802757:	89 c8                	mov    %ecx,%eax
  802759:	f7 f5                	div    %ebp
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	eb 99                	jmp    8026f8 <__umoddi3+0x38>
  80275f:	90                   	nop
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 1c             	add    $0x1c,%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	8b 34 24             	mov    (%esp),%esi
  802773:	bf 20 00 00 00       	mov    $0x20,%edi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	29 ef                	sub    %ebp,%edi
  80277c:	d3 e0                	shl    %cl,%eax
  80277e:	89 f9                	mov    %edi,%ecx
  802780:	89 f2                	mov    %esi,%edx
  802782:	d3 ea                	shr    %cl,%edx
  802784:	89 e9                	mov    %ebp,%ecx
  802786:	09 c2                	or     %eax,%edx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 14 24             	mov    %edx,(%esp)
  80278d:	89 f2                	mov    %esi,%edx
  80278f:	d3 e2                	shl    %cl,%edx
  802791:	89 f9                	mov    %edi,%ecx
  802793:	89 54 24 04          	mov    %edx,0x4(%esp)
  802797:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80279b:	d3 e8                	shr    %cl,%eax
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	89 c6                	mov    %eax,%esi
  8027a1:	d3 e3                	shl    %cl,%ebx
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 d0                	mov    %edx,%eax
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	09 d8                	or     %ebx,%eax
  8027ad:	89 d3                	mov    %edx,%ebx
  8027af:	89 f2                	mov    %esi,%edx
  8027b1:	f7 34 24             	divl   (%esp)
  8027b4:	89 d6                	mov    %edx,%esi
  8027b6:	d3 e3                	shl    %cl,%ebx
  8027b8:	f7 64 24 04          	mull   0x4(%esp)
  8027bc:	39 d6                	cmp    %edx,%esi
  8027be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c2:	89 d1                	mov    %edx,%ecx
  8027c4:	89 c3                	mov    %eax,%ebx
  8027c6:	72 08                	jb     8027d0 <__umoddi3+0x110>
  8027c8:	75 11                	jne    8027db <__umoddi3+0x11b>
  8027ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ce:	73 0b                	jae    8027db <__umoddi3+0x11b>
  8027d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027d4:	1b 14 24             	sbb    (%esp),%edx
  8027d7:	89 d1                	mov    %edx,%ecx
  8027d9:	89 c3                	mov    %eax,%ebx
  8027db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027df:	29 da                	sub    %ebx,%edx
  8027e1:	19 ce                	sbb    %ecx,%esi
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	d3 ea                	shr    %cl,%edx
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	d3 ee                	shr    %cl,%esi
  8027f1:	09 d0                	or     %edx,%eax
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	83 c4 1c             	add    $0x1c,%esp
  8027f8:	5b                   	pop    %ebx
  8027f9:	5e                   	pop    %esi
  8027fa:	5f                   	pop    %edi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	29 f9                	sub    %edi,%ecx
  802802:	19 d6                	sbb    %edx,%esi
  802804:	89 74 24 04          	mov    %esi,0x4(%esp)
  802808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80280c:	e9 18 ff ff ff       	jmp    802729 <__umoddi3+0x69>
