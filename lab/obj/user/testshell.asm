
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 83 17 00 00       	call   8017d2 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 79 17 00 00       	call   8017d2 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 0b 29 80 00 	movl   $0x80290b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 da 15 00 00       	call   80166c <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 1a 29 80 00       	push   $0x80291a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 a5 15 00 00       	call   80166c <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 15 29 80 00       	push   $0x802915
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 35 14 00 00       	call   801530 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 29 14 00 00       	call   801530 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 28 29 80 00       	push   $0x802928
  80011b:	e8 ab 19 00 00       	call   801acb <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 35 29 80 00       	push   $0x802935
  80012f:	6a 13                	push   $0x13
  800131:	68 4b 29 80 00       	push   $0x80294b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 3e 21 00 00       	call   802285 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 5c 29 80 00       	push   $0x80295c
  800154:	6a 15                	push   $0x15
  800156:	68 4b 29 80 00       	push   $0x80294b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 c4 28 80 00       	push   $0x8028c4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 9a 10 00 00       	call   80120f <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 65 29 80 00       	push   $0x802965
  800182:	6a 1a                	push   $0x1a
  800184:	68 4b 29 80 00       	push   $0x80294b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 e3 13 00 00       	call   801580 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 d8 13 00 00       	call   801580 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 80 13 00 00       	call   801530 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 78 13 00 00       	call   801530 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 6e 29 80 00       	push   $0x80296e
  8001bf:	68 32 29 80 00       	push   $0x802932
  8001c4:	68 71 29 80 00       	push   $0x802971
  8001c9:	e8 6e 1e 00 00       	call   80203c <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 75 29 80 00       	push   $0x802975
  8001dd:	6a 21                	push   $0x21
  8001df:	68 4b 29 80 00       	push   $0x80294b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 3d 13 00 00       	call   801530 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 31 13 00 00       	call   801530 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 04 22 00 00       	call   80240b <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 18 13 00 00       	call   801530 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 10 13 00 00       	call   801530 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 7f 29 80 00       	push   $0x80297f
  800230:	e8 96 18 00 00       	call   801acb <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 e8 28 80 00       	push   $0x8028e8
  800245:	6a 2c                	push   $0x2c
  800247:	68 4b 29 80 00       	push   $0x80294b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 00 14 00 00       	call   80166c <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 ed 13 00 00       	call   80166c <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 8d 29 80 00       	push   $0x80298d
  80028c:	6a 33                	push   $0x33
  80028e:	68 4b 29 80 00       	push   $0x80294b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 a7 29 80 00       	push   $0x8029a7
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 4b 29 80 00       	push   $0x80294b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 c1 29 80 00       	push   $0x8029c1
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 d6 29 80 00       	push   $0x8029d6
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 86 12 00 00       	call   80166c <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 f6 0f 00 00       	call   801406 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 7e 0f 00 00       	call   8013b7 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 15 0f 00 00       	call   801390 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 86 10 00 00       	call   80155b <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 ec 29 80 00       	push   $0x8029ec
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 db 1f 00 00       	call   802600 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 c8 20 00 00       	call   802730 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 0f 2a 80 00 	movsbl 0x802a0f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 27 2a 80 00       	push   $0x802a27
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 d2 2e 80 00       	push   $0x802ed2
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 20 2a 80 00       	mov    $0x802a20,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
			base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 1f 2d 80 00       	push   $0x802d1f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 3c 2d 80 00       	push   $0x802d3c
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 1f 2d 80 00       	push   $0x802d1f
  800f74:	6a 23                	push   $0x23
  800f76:	68 3c 2d 80 00       	push   $0x802d3c
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 1f 2d 80 00       	push   $0x802d1f
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 3c 2d 80 00       	push   $0x802d3c
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 1f 2d 80 00       	push   $0x802d1f
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 3c 2d 80 00       	push   $0x802d3c
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 1f 2d 80 00       	push   $0x802d1f
  80103a:	6a 23                	push   $0x23
  80103c:	68 3c 2d 80 00       	push   $0x802d3c
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 1f 2d 80 00       	push   $0x802d1f
  80107c:	6a 23                	push   $0x23
  80107e:	68 3c 2d 80 00       	push   $0x802d3c
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 1f 2d 80 00       	push   $0x802d1f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 3c 2d 80 00       	push   $0x802d3c
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 1f 2d 80 00       	push   $0x802d1f
  801122:	6a 23                	push   $0x23
  801124:	68 3c 2d 80 00       	push   $0x802d3c
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80113e:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  801140:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801144:	75 25                	jne    80116b <pgfault+0x35>
  801146:	89 d8                	mov    %ebx,%eax
  801148:	c1 e8 0c             	shr    $0xc,%eax
  80114b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801152:	f6 c4 08             	test   $0x8,%ah
  801155:	75 14                	jne    80116b <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	68 4c 2d 80 00       	push   $0x802d4c
  80115f:	6a 1e                	push   $0x1e
  801161:	68 e0 2d 80 00       	push   $0x802de0
  801166:	e8 79 f3 ff ff       	call   8004e4 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  80116b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  801171:	e8 91 fd ff ff       	call   800f07 <sys_getenvid>
  801176:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	6a 07                	push   $0x7
  80117d:	68 00 f0 7f 00       	push   $0x7ff000
  801182:	50                   	push   %eax
  801183:	e8 bd fd ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	79 12                	jns    8011a1 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  80118f:	50                   	push   %eax
  801190:	68 78 2d 80 00       	push   $0x802d78
  801195:	6a 31                	push   $0x31
  801197:	68 e0 2d 80 00       	push   $0x802de0
  80119c:	e8 43 f3 ff ff       	call   8004e4 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	68 00 10 00 00       	push   $0x1000
  8011a9:	53                   	push   %ebx
  8011aa:	68 00 f0 7f 00       	push   $0x7ff000
  8011af:	e8 88 fb ff ff       	call   800d3c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  8011b4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011bb:	53                   	push   %ebx
  8011bc:	56                   	push   %esi
  8011bd:	68 00 f0 7f 00       	push   $0x7ff000
  8011c2:	56                   	push   %esi
  8011c3:	e8 c0 fd ff ff       	call   800f88 <sys_page_map>
	if (r < 0)
  8011c8:	83 c4 20             	add    $0x20,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	79 12                	jns    8011e1 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  8011cf:	50                   	push   %eax
  8011d0:	68 9c 2d 80 00       	push   $0x802d9c
  8011d5:	6a 39                	push   $0x39
  8011d7:	68 e0 2d 80 00       	push   $0x802de0
  8011dc:	e8 03 f3 ff ff       	call   8004e4 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	68 00 f0 7f 00       	push   $0x7ff000
  8011e9:	56                   	push   %esi
  8011ea:	e8 db fd ff ff       	call   800fca <sys_page_unmap>
	if (r < 0)
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	79 12                	jns    801208 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  8011f6:	50                   	push   %eax
  8011f7:	68 c0 2d 80 00       	push   $0x802dc0
  8011fc:	6a 3e                	push   $0x3e
  8011fe:	68 e0 2d 80 00       	push   $0x802de0
  801203:	e8 dc f2 ff ff       	call   8004e4 <_panic>
}
  801208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	57                   	push   %edi
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  801218:	68 36 11 80 00       	push   $0x801136
  80121d:	e8 38 12 00 00       	call   80245a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801222:	b8 07 00 00 00       	mov    $0x7,%eax
  801227:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	0f 88 3a 01 00 00    	js     80136e <fork+0x15f>
  801234:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801239:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  80123e:	85 c0                	test   %eax,%eax
  801240:	75 21                	jne    801263 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801242:	e8 c0 fc ff ff       	call   800f07 <sys_getenvid>
  801247:	25 ff 03 00 00       	and    $0x3ff,%eax
  80124c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80124f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801254:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	e9 0b 01 00 00       	jmp    80136e <fork+0x15f>
  801263:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801266:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801268:	89 d8                	mov    %ebx,%eax
  80126a:	c1 e8 16             	shr    $0x16,%eax
  80126d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801274:	a8 01                	test   $0x1,%al
  801276:	0f 84 99 00 00 00    	je     801315 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	c1 e8 0c             	shr    $0xc,%eax
  801281:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	0f 84 84 00 00 00    	je     801315 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  801291:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801298:	a9 02 08 00 00       	test   $0x802,%eax
  80129d:	74 76                	je     801315 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80129f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012a6:	a8 02                	test   $0x2,%al
  8012a8:	75 0c                	jne    8012b6 <fork+0xa7>
  8012aa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012b1:	f6 c4 08             	test   $0x8,%ah
  8012b4:	74 3f                	je     8012f5 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	68 05 08 00 00       	push   $0x805
  8012be:	53                   	push   %ebx
  8012bf:	57                   	push   %edi
  8012c0:	53                   	push   %ebx
  8012c1:	6a 00                	push   $0x0
  8012c3:	e8 c0 fc ff ff       	call   800f88 <sys_page_map>
		if (r < 0)
  8012c8:	83 c4 20             	add    $0x20,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	0f 88 9b 00 00 00    	js     80136e <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	68 05 08 00 00       	push   $0x805
  8012db:	53                   	push   %ebx
  8012dc:	6a 00                	push   $0x0
  8012de:	53                   	push   %ebx
  8012df:	6a 00                	push   $0x0
  8012e1:	e8 a2 fc ff ff       	call   800f88 <sys_page_map>
  8012e6:	83 c4 20             	add    $0x20,%esp
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f0:	0f 4f c1             	cmovg  %ecx,%eax
  8012f3:	eb 1c                	jmp    801311 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	6a 05                	push   $0x5
  8012fa:	53                   	push   %ebx
  8012fb:	57                   	push   %edi
  8012fc:	53                   	push   %ebx
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 84 fc ff ff       	call   800f88 <sys_page_map>
  801304:	83 c4 20             	add    $0x20,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	b9 00 00 00 00       	mov    $0x0,%ecx
  80130e:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801311:	85 c0                	test   %eax,%eax
  801313:	78 59                	js     80136e <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801315:	83 c6 01             	add    $0x1,%esi
  801318:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80131e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801324:	0f 85 3e ff ff ff    	jne    801268 <fork+0x59>
  80132a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80132d:	83 ec 04             	sub    $0x4,%esp
  801330:	6a 07                	push   $0x7
  801332:	68 00 f0 bf ee       	push   $0xeebff000
  801337:	57                   	push   %edi
  801338:	e8 08 fc ff ff       	call   800f45 <sys_page_alloc>
	if (r < 0)
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 2a                	js     80136e <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	68 a1 24 80 00       	push   $0x8024a1
  80134c:	57                   	push   %edi
  80134d:	e8 3e fd ff ff       	call   801090 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 15                	js     80136e <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	6a 02                	push   $0x2
  80135e:	57                   	push   %edi
  80135f:	e8 a8 fc ff ff       	call   80100c <sys_env_set_status>
	if (r < 0)
  801364:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801367:	85 c0                	test   %eax,%eax
  801369:	0f 49 c7             	cmovns %edi,%eax
  80136c:	eb 00                	jmp    80136e <fork+0x15f>
	// panic("fork not implemented");
}
  80136e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <sfork>:

// Challenge!
int
sfork(void)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80137c:	68 eb 2d 80 00       	push   $0x802deb
  801381:	68 c3 00 00 00       	push   $0xc3
  801386:	68 e0 2d 80 00       	push   $0x802de0
  80138b:	e8 54 f1 ff ff       	call   8004e4 <_panic>

00801390 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	05 00 00 00 30       	add    $0x30000000,%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
}
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 16             	shr    $0x16,%edx
  8013c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 11                	je     8013e4 <fd_alloc+0x2d>
  8013d3:	89 c2                	mov    %eax,%edx
  8013d5:	c1 ea 0c             	shr    $0xc,%edx
  8013d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	75 09                	jne    8013ed <fd_alloc+0x36>
			*fd_store = fd;
  8013e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013eb:	eb 17                	jmp    801404 <fd_alloc+0x4d>
  8013ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f7:	75 c9                	jne    8013c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80140c:	83 f8 1f             	cmp    $0x1f,%eax
  80140f:	77 36                	ja     801447 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801411:	c1 e0 0c             	shl    $0xc,%eax
  801414:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801419:	89 c2                	mov    %eax,%edx
  80141b:	c1 ea 16             	shr    $0x16,%edx
  80141e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801425:	f6 c2 01             	test   $0x1,%dl
  801428:	74 24                	je     80144e <fd_lookup+0x48>
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	c1 ea 0c             	shr    $0xc,%edx
  80142f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801436:	f6 c2 01             	test   $0x1,%dl
  801439:	74 1a                	je     801455 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80143b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143e:	89 02                	mov    %eax,(%edx)
	return 0;
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
  801445:	eb 13                	jmp    80145a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144c:	eb 0c                	jmp    80145a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80144e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801453:	eb 05                	jmp    80145a <fd_lookup+0x54>
  801455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801465:	ba 80 2e 80 00       	mov    $0x802e80,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80146a:	eb 13                	jmp    80147f <dev_lookup+0x23>
  80146c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80146f:	39 08                	cmp    %ecx,(%eax)
  801471:	75 0c                	jne    80147f <dev_lookup+0x23>
			*dev = devtab[i];
  801473:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801476:	89 01                	mov    %eax,(%ecx)
			return 0;
  801478:	b8 00 00 00 00       	mov    $0x0,%eax
  80147d:	eb 2e                	jmp    8014ad <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80147f:	8b 02                	mov    (%edx),%eax
  801481:	85 c0                	test   %eax,%eax
  801483:	75 e7                	jne    80146c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801485:	a1 04 40 80 00       	mov    0x804004,%eax
  80148a:	8b 40 48             	mov    0x48(%eax),%eax
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	51                   	push   %ecx
  801491:	50                   	push   %eax
  801492:	68 04 2e 80 00       	push   $0x802e04
  801497:	e8 21 f1 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  80149c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 10             	sub    $0x10,%esp
  8014b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014c7:	c1 e8 0c             	shr    $0xc,%eax
  8014ca:	50                   	push   %eax
  8014cb:	e8 36 ff ff ff       	call   801406 <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 05                	js     8014dc <fd_close+0x2d>
	    || fd != fd2)
  8014d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014da:	74 0c                	je     8014e8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014dc:	84 db                	test   %bl,%bl
  8014de:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e3:	0f 44 c2             	cmove  %edx,%eax
  8014e6:	eb 41                	jmp    801529 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	ff 36                	pushl  (%esi)
  8014f1:	e8 66 ff ff ff       	call   80145c <dev_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 1a                	js     801519 <fd_close+0x6a>
		if (dev->dev_close)
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801505:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	74 0b                	je     801519 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	56                   	push   %esi
  801512:	ff d0                	call   *%eax
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	56                   	push   %esi
  80151d:	6a 00                	push   $0x0
  80151f:	e8 a6 fa ff ff       	call   800fca <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 d8                	mov    %ebx,%eax
}
  801529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	ff 75 08             	pushl  0x8(%ebp)
  80153d:	e8 c4 fe ff ff       	call   801406 <fd_lookup>
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 10                	js     801559 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	6a 01                	push   $0x1
  80154e:	ff 75 f4             	pushl  -0xc(%ebp)
  801551:	e8 59 ff ff ff       	call   8014af <fd_close>
  801556:	83 c4 10             	add    $0x10,%esp
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <close_all>:

void
close_all(void)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801562:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	53                   	push   %ebx
  80156b:	e8 c0 ff ff ff       	call   801530 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801570:	83 c3 01             	add    $0x1,%ebx
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	83 fb 20             	cmp    $0x20,%ebx
  801579:	75 ec                	jne    801567 <close_all+0xc>
		close(i);
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 2c             	sub    $0x2c,%esp
  801589:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	ff 75 08             	pushl  0x8(%ebp)
  801593:	e8 6e fe ff ff       	call   801406 <fd_lookup>
  801598:	83 c4 08             	add    $0x8,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	0f 88 c1 00 00 00    	js     801664 <dup+0xe4>
		return r;
	close(newfdnum);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	56                   	push   %esi
  8015a7:	e8 84 ff ff ff       	call   801530 <close>

	newfd = INDEX2FD(newfdnum);
  8015ac:	89 f3                	mov    %esi,%ebx
  8015ae:	c1 e3 0c             	shl    $0xc,%ebx
  8015b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b7:	83 c4 04             	add    $0x4,%esp
  8015ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015bd:	e8 de fd ff ff       	call   8013a0 <fd2data>
  8015c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015c4:	89 1c 24             	mov    %ebx,(%esp)
  8015c7:	e8 d4 fd ff ff       	call   8013a0 <fd2data>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d2:	89 f8                	mov    %edi,%eax
  8015d4:	c1 e8 16             	shr    $0x16,%eax
  8015d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015de:	a8 01                	test   $0x1,%al
  8015e0:	74 37                	je     801619 <dup+0x99>
  8015e2:	89 f8                	mov    %edi,%eax
  8015e4:	c1 e8 0c             	shr    $0xc,%eax
  8015e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ee:	f6 c2 01             	test   $0x1,%dl
  8015f1:	74 26                	je     801619 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801602:	50                   	push   %eax
  801603:	ff 75 d4             	pushl  -0x2c(%ebp)
  801606:	6a 00                	push   $0x0
  801608:	57                   	push   %edi
  801609:	6a 00                	push   $0x0
  80160b:	e8 78 f9 ff ff       	call   800f88 <sys_page_map>
  801610:	89 c7                	mov    %eax,%edi
  801612:	83 c4 20             	add    $0x20,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 2e                	js     801647 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801619:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	25 07 0e 00 00       	and    $0xe07,%eax
  801630:	50                   	push   %eax
  801631:	53                   	push   %ebx
  801632:	6a 00                	push   $0x0
  801634:	52                   	push   %edx
  801635:	6a 00                	push   $0x0
  801637:	e8 4c f9 ff ff       	call   800f88 <sys_page_map>
  80163c:	89 c7                	mov    %eax,%edi
  80163e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801641:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801643:	85 ff                	test   %edi,%edi
  801645:	79 1d                	jns    801664 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	53                   	push   %ebx
  80164b:	6a 00                	push   $0x0
  80164d:	e8 78 f9 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	ff 75 d4             	pushl  -0x2c(%ebp)
  801658:	6a 00                	push   $0x0
  80165a:	e8 6b f9 ff ff       	call   800fca <sys_page_unmap>
	return r;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	89 f8                	mov    %edi,%eax
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 14             	sub    $0x14,%esp
  801673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	53                   	push   %ebx
  80167b:	e8 86 fd ff ff       	call   801406 <fd_lookup>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	89 c2                	mov    %eax,%edx
  801685:	85 c0                	test   %eax,%eax
  801687:	78 6d                	js     8016f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	ff 30                	pushl  (%eax)
  801695:	e8 c2 fd ff ff       	call   80145c <dev_lookup>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 4c                	js     8016ed <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016a4:	8b 42 08             	mov    0x8(%edx),%eax
  8016a7:	83 e0 03             	and    $0x3,%eax
  8016aa:	83 f8 01             	cmp    $0x1,%eax
  8016ad:	75 21                	jne    8016d0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016af:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b4:	8b 40 48             	mov    0x48(%eax),%eax
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	53                   	push   %ebx
  8016bb:	50                   	push   %eax
  8016bc:	68 45 2e 80 00       	push   $0x802e45
  8016c1:	e8 f7 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ce:	eb 26                	jmp    8016f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8016d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d3:	8b 40 08             	mov    0x8(%eax),%eax
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	74 17                	je     8016f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	ff 75 10             	pushl  0x10(%ebp)
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	52                   	push   %edx
  8016e4:	ff d0                	call   *%eax
  8016e6:	89 c2                	mov    %eax,%edx
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	eb 09                	jmp    8016f6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	eb 05                	jmp    8016f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	57                   	push   %edi
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	8b 7d 08             	mov    0x8(%ebp),%edi
  801709:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801711:	eb 21                	jmp    801734 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	89 f0                	mov    %esi,%eax
  801718:	29 d8                	sub    %ebx,%eax
  80171a:	50                   	push   %eax
  80171b:	89 d8                	mov    %ebx,%eax
  80171d:	03 45 0c             	add    0xc(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	57                   	push   %edi
  801722:	e8 45 ff ff ff       	call   80166c <read>
		if (m < 0)
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 10                	js     80173e <readn+0x41>
			return m;
		if (m == 0)
  80172e:	85 c0                	test   %eax,%eax
  801730:	74 0a                	je     80173c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801732:	01 c3                	add    %eax,%ebx
  801734:	39 f3                	cmp    %esi,%ebx
  801736:	72 db                	jb     801713 <readn+0x16>
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	eb 02                	jmp    80173e <readn+0x41>
  80173c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 14             	sub    $0x14,%esp
  80174d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	53                   	push   %ebx
  801755:	e8 ac fc ff ff       	call   801406 <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 68                	js     8017cb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	ff 30                	pushl  (%eax)
  80176f:	e8 e8 fc ff ff       	call   80145c <dev_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 47                	js     8017c2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801782:	75 21                	jne    8017a5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801784:	a1 04 40 80 00       	mov    0x804004,%eax
  801789:	8b 40 48             	mov    0x48(%eax),%eax
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	53                   	push   %ebx
  801790:	50                   	push   %eax
  801791:	68 61 2e 80 00       	push   $0x802e61
  801796:	e8 22 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a3:	eb 26                	jmp    8017cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ab:	85 d2                	test   %edx,%edx
  8017ad:	74 17                	je     8017c6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	ff 75 10             	pushl  0x10(%ebp)
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	50                   	push   %eax
  8017b9:	ff d2                	call   *%edx
  8017bb:	89 c2                	mov    %eax,%edx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	eb 09                	jmp    8017cb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c2:	89 c2                	mov    %eax,%edx
  8017c4:	eb 05                	jmp    8017cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017cb:	89 d0                	mov    %edx,%eax
  8017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017db:	50                   	push   %eax
  8017dc:	ff 75 08             	pushl  0x8(%ebp)
  8017df:	e8 22 fc ff ff       	call   801406 <fd_lookup>
  8017e4:	83 c4 08             	add    $0x8,%esp
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 0e                	js     8017f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 14             	sub    $0x14,%esp
  801802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801805:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	53                   	push   %ebx
  80180a:	e8 f7 fb ff ff       	call   801406 <fd_lookup>
  80180f:	83 c4 08             	add    $0x8,%esp
  801812:	89 c2                	mov    %eax,%edx
  801814:	85 c0                	test   %eax,%eax
  801816:	78 65                	js     80187d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181e:	50                   	push   %eax
  80181f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801822:	ff 30                	pushl  (%eax)
  801824:	e8 33 fc ff ff       	call   80145c <dev_lookup>
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 44                	js     801874 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801833:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801837:	75 21                	jne    80185a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801839:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80183e:	8b 40 48             	mov    0x48(%eax),%eax
  801841:	83 ec 04             	sub    $0x4,%esp
  801844:	53                   	push   %ebx
  801845:	50                   	push   %eax
  801846:	68 24 2e 80 00       	push   $0x802e24
  80184b:	e8 6d ed ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801858:	eb 23                	jmp    80187d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80185a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185d:	8b 52 18             	mov    0x18(%edx),%edx
  801860:	85 d2                	test   %edx,%edx
  801862:	74 14                	je     801878 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	50                   	push   %eax
  80186b:	ff d2                	call   *%edx
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	eb 09                	jmp    80187d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801874:	89 c2                	mov    %eax,%edx
  801876:	eb 05                	jmp    80187d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801878:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80187d:	89 d0                	mov    %edx,%eax
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	53                   	push   %ebx
  801888:	83 ec 14             	sub    $0x14,%esp
  80188b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801891:	50                   	push   %eax
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 6c fb ff ff       	call   801406 <fd_lookup>
  80189a:	83 c4 08             	add    $0x8,%esp
  80189d:	89 c2                	mov    %eax,%edx
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 58                	js     8018fb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ad:	ff 30                	pushl  (%eax)
  8018af:	e8 a8 fb ff ff       	call   80145c <dev_lookup>
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 37                	js     8018f2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018c2:	74 32                	je     8018f6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ce:	00 00 00 
	stat->st_isdir = 0;
  8018d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d8:	00 00 00 
	stat->st_dev = dev;
  8018db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	53                   	push   %ebx
  8018e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e8:	ff 50 14             	call   *0x14(%eax)
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	eb 09                	jmp    8018fb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f2:	89 c2                	mov    %eax,%edx
  8018f4:	eb 05                	jmp    8018fb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018fb:	89 d0                	mov    %edx,%eax
  8018fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	6a 00                	push   $0x0
  80190c:	ff 75 08             	pushl  0x8(%ebp)
  80190f:	e8 b7 01 00 00       	call   801acb <open>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 1b                	js     801938 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	50                   	push   %eax
  801924:	e8 5b ff ff ff       	call   801884 <fstat>
  801929:	89 c6                	mov    %eax,%esi
	close(fd);
  80192b:	89 1c 24             	mov    %ebx,(%esp)
  80192e:	e8 fd fb ff ff       	call   801530 <close>
	return r;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	89 f0                	mov    %esi,%eax
}
  801938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	89 c6                	mov    %eax,%esi
  801946:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801948:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80194f:	75 12                	jne    801963 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	6a 01                	push   $0x1
  801956:	e8 25 0c 00 00       	call   802580 <ipc_find_env>
  80195b:	a3 00 40 80 00       	mov    %eax,0x804000
  801960:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801963:	6a 07                	push   $0x7
  801965:	68 00 50 80 00       	push   $0x805000
  80196a:	56                   	push   %esi
  80196b:	ff 35 00 40 80 00    	pushl  0x804000
  801971:	e8 b6 0b 00 00       	call   80252c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801976:	83 c4 0c             	add    $0xc,%esp
  801979:	6a 00                	push   $0x0
  80197b:	53                   	push   %ebx
  80197c:	6a 00                	push   $0x0
  80197e:	e8 42 0b 00 00       	call   8024c5 <ipc_recv>
}
  801983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	8b 40 0c             	mov    0xc(%eax),%eax
  801996:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ad:	e8 8d ff ff ff       	call   80193f <fsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8019cf:	e8 6b ff ff ff       	call   80193f <fsipc>
}
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 04             	sub    $0x4,%esp
  8019dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f5:	e8 45 ff ff ff       	call   80193f <fsipc>
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 2c                	js     801a2a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	68 00 50 80 00       	push   $0x805000
  801a06:	53                   	push   %ebx
  801a07:	e8 36 f1 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0c:	a1 80 50 80 00       	mov    0x805080,%eax
  801a11:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a17:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a35:	68 90 2e 80 00       	push   $0x802e90
  801a3a:	68 90 00 00 00       	push   $0x90
  801a3f:	68 ae 2e 80 00       	push   $0x802eae
  801a44:	e8 9b ea ff ff       	call   8004e4 <_panic>

00801a49 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	8b 40 0c             	mov    0xc(%eax),%eax
  801a57:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6c:	e8 ce fe ff ff       	call   80193f <fsipc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 4b                	js     801ac2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a77:	39 c6                	cmp    %eax,%esi
  801a79:	73 16                	jae    801a91 <devfile_read+0x48>
  801a7b:	68 b9 2e 80 00       	push   $0x802eb9
  801a80:	68 c0 2e 80 00       	push   $0x802ec0
  801a85:	6a 7c                	push   $0x7c
  801a87:	68 ae 2e 80 00       	push   $0x802eae
  801a8c:	e8 53 ea ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801a91:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a96:	7e 16                	jle    801aae <devfile_read+0x65>
  801a98:	68 d5 2e 80 00       	push   $0x802ed5
  801a9d:	68 c0 2e 80 00       	push   $0x802ec0
  801aa2:	6a 7d                	push   $0x7d
  801aa4:	68 ae 2e 80 00       	push   $0x802eae
  801aa9:	e8 36 ea ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aae:	83 ec 04             	sub    $0x4,%esp
  801ab1:	50                   	push   %eax
  801ab2:	68 00 50 80 00       	push   $0x805000
  801ab7:	ff 75 0c             	pushl  0xc(%ebp)
  801aba:	e8 15 f2 ff ff       	call   800cd4 <memmove>
	return r;
  801abf:	83 c4 10             	add    $0x10,%esp
}
  801ac2:	89 d8                	mov    %ebx,%eax
  801ac4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	53                   	push   %ebx
  801acf:	83 ec 20             	sub    $0x20,%esp
  801ad2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad5:	53                   	push   %ebx
  801ad6:	e8 2e f0 ff ff       	call   800b09 <strlen>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae3:	7f 67                	jg     801b4c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	e8 c6 f8 ff ff       	call   8013b7 <fd_alloc>
  801af1:	83 c4 10             	add    $0x10,%esp
		return r;
  801af4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 57                	js     801b51 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	68 00 50 80 00       	push   $0x805000
  801b03:	e8 3a f0 ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b13:	b8 01 00 00 00       	mov    $0x1,%eax
  801b18:	e8 22 fe ff ff       	call   80193f <fsipc>
  801b1d:	89 c3                	mov    %eax,%ebx
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	85 c0                	test   %eax,%eax
  801b24:	79 14                	jns    801b3a <open+0x6f>
		fd_close(fd, 0);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	6a 00                	push   $0x0
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	e8 7c f9 ff ff       	call   8014af <fd_close>
		return r;
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	89 da                	mov    %ebx,%edx
  801b38:	eb 17                	jmp    801b51 <open+0x86>
	}

	return fd2num(fd);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b40:	e8 4b f8 ff ff       	call   801390 <fd2num>
  801b45:	89 c2                	mov    %eax,%edx
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	eb 05                	jmp    801b51 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b4c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b51:	89 d0                	mov    %edx,%eax
  801b53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b63:	b8 08 00 00 00       	mov    $0x8,%eax
  801b68:	e8 d2 fd ff ff       	call   80193f <fsipc>
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	57                   	push   %edi
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b7b:	6a 00                	push   $0x0
  801b7d:	ff 75 08             	pushl  0x8(%ebp)
  801b80:	e8 46 ff ff ff       	call   801acb <open>
  801b85:	89 c7                	mov    %eax,%edi
  801b87:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 3a 04 00 00    	js     801fd2 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b98:	83 ec 04             	sub    $0x4,%esp
  801b9b:	68 00 02 00 00       	push   $0x200
  801ba0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ba6:	50                   	push   %eax
  801ba7:	57                   	push   %edi
  801ba8:	e8 50 fb ff ff       	call   8016fd <readn>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bb5:	75 0c                	jne    801bc3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801bb7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801bbe:	45 4c 46 
  801bc1:	74 33                	je     801bf6 <spawn+0x87>
		close(fd);
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bcc:	e8 5f f9 ff ff       	call   801530 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801bd1:	83 c4 0c             	add    $0xc,%esp
  801bd4:	68 7f 45 4c 46       	push   $0x464c457f
  801bd9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801bdf:	68 e1 2e 80 00       	push   $0x802ee1
  801be4:	e8 d4 e9 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801bf1:	e9 3c 04 00 00       	jmp    802032 <spawn+0x4c3>
  801bf6:	b8 07 00 00 00       	mov    $0x7,%eax
  801bfb:	cd 30                	int    $0x30
  801bfd:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c03:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 c9 03 00 00    	js     801fda <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c11:	89 c6                	mov    %eax,%esi
  801c13:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c19:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801c1c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801c22:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c28:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c2f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c35:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c40:	be 00 00 00 00       	mov    $0x0,%esi
  801c45:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c48:	eb 13                	jmp    801c5d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	50                   	push   %eax
  801c4e:	e8 b6 ee ff ff       	call   800b09 <strlen>
  801c53:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c57:	83 c3 01             	add    $0x1,%ebx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801c64:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801c67:	85 c0                	test   %eax,%eax
  801c69:	75 df                	jne    801c4a <spawn+0xdb>
  801c6b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801c71:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801c77:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c7c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 e2 fc             	and    $0xfffffffc,%edx
  801c83:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801c8a:	29 c2                	sub    %eax,%edx
  801c8c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801c92:	8d 42 f8             	lea    -0x8(%edx),%eax
  801c95:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c9a:	0f 86 4a 03 00 00    	jbe    801fea <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ca0:	83 ec 04             	sub    $0x4,%esp
  801ca3:	6a 07                	push   $0x7
  801ca5:	68 00 00 40 00       	push   $0x400000
  801caa:	6a 00                	push   $0x0
  801cac:	e8 94 f2 ff ff       	call   800f45 <sys_page_alloc>
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	0f 88 35 03 00 00    	js     801ff1 <spawn+0x482>
  801cbc:	be 00 00 00 00       	mov    $0x0,%esi
  801cc1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801cc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cca:	eb 30                	jmp    801cfc <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ccc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801cd2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801cd8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801cdb:	83 ec 08             	sub    $0x8,%esp
  801cde:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ce1:	57                   	push   %edi
  801ce2:	e8 5b ee ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ce7:	83 c4 04             	add    $0x4,%esp
  801cea:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ced:	e8 17 ee ff ff       	call   800b09 <strlen>
  801cf2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801cf6:	83 c6 01             	add    $0x1,%esi
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d02:	7f c8                	jg     801ccc <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d04:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d0a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d10:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d17:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d1d:	74 19                	je     801d38 <spawn+0x1c9>
  801d1f:	68 58 2f 80 00       	push   $0x802f58
  801d24:	68 c0 2e 80 00       	push   $0x802ec0
  801d29:	68 f2 00 00 00       	push   $0xf2
  801d2e:	68 fb 2e 80 00       	push   $0x802efb
  801d33:	e8 ac e7 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d38:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801d3e:	89 c8                	mov    %ecx,%eax
  801d40:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d45:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801d48:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d4e:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d51:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801d57:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801d5d:	83 ec 0c             	sub    $0xc,%esp
  801d60:	6a 07                	push   $0x7
  801d62:	68 00 d0 bf ee       	push   $0xeebfd000
  801d67:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d6d:	68 00 00 40 00       	push   $0x400000
  801d72:	6a 00                	push   $0x0
  801d74:	e8 0f f2 ff ff       	call   800f88 <sys_page_map>
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	83 c4 20             	add    $0x20,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	0f 88 9a 02 00 00    	js     802020 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	68 00 00 40 00       	push   $0x400000
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 35 f2 ff ff       	call   800fca <sys_page_unmap>
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	0f 88 7e 02 00 00    	js     802020 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801da2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801da8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801daf:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801db5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801dbc:	00 00 00 
  801dbf:	e9 86 01 00 00       	jmp    801f4a <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801dc4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801dca:	83 38 01             	cmpl   $0x1,(%eax)
  801dcd:	0f 85 69 01 00 00    	jne    801f3c <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801dd3:	89 c1                	mov    %eax,%ecx
  801dd5:	8b 40 18             	mov    0x18(%eax),%eax
  801dd8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801dde:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801de1:	83 f8 01             	cmp    $0x1,%eax
  801de4:	19 c0                	sbb    %eax,%eax
  801de6:	83 e0 fe             	and    $0xfffffffe,%eax
  801de9:	83 c0 07             	add    $0x7,%eax
  801dec:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801df2:	89 c8                	mov    %ecx,%eax
  801df4:	8b 49 04             	mov    0x4(%ecx),%ecx
  801df7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801dfd:	8b 78 10             	mov    0x10(%eax),%edi
  801e00:	8b 50 14             	mov    0x14(%eax),%edx
  801e03:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e09:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e0c:	89 f0                	mov    %esi,%eax
  801e0e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e13:	74 14                	je     801e29 <spawn+0x2ba>
		va -= i;
  801e15:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e17:	01 c2                	add    %eax,%edx
  801e19:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e1f:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e21:	29 c1                	sub    %eax,%ecx
  801e23:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e29:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e2e:	e9 f7 00 00 00       	jmp    801f2a <spawn+0x3bb>
		if (i >= filesz) {
  801e33:	39 df                	cmp    %ebx,%edi
  801e35:	77 27                	ja     801e5e <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e37:	83 ec 04             	sub    $0x4,%esp
  801e3a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e40:	56                   	push   %esi
  801e41:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e47:	e8 f9 f0 ff ff       	call   800f45 <sys_page_alloc>
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	0f 89 c7 00 00 00    	jns    801f1e <spawn+0x3af>
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	e9 a1 01 00 00       	jmp    801fff <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e5e:	83 ec 04             	sub    $0x4,%esp
  801e61:	6a 07                	push   $0x7
  801e63:	68 00 00 40 00       	push   $0x400000
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 d6 f0 ff ff       	call   800f45 <sys_page_alloc>
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	85 c0                	test   %eax,%eax
  801e74:	0f 88 7b 01 00 00    	js     801ff5 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e7a:	83 ec 08             	sub    $0x8,%esp
  801e7d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e83:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e90:	e8 3d f9 ff ff       	call   8017d2 <seek>
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 59 01 00 00    	js     801ff9 <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ea0:	83 ec 04             	sub    $0x4,%esp
  801ea3:	89 f8                	mov    %edi,%eax
  801ea5:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801eab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801eb0:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801eb5:	0f 47 c1             	cmova  %ecx,%eax
  801eb8:	50                   	push   %eax
  801eb9:	68 00 00 40 00       	push   $0x400000
  801ebe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ec4:	e8 34 f8 ff ff       	call   8016fd <readn>
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	0f 88 29 01 00 00    	js     801ffd <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801edd:	56                   	push   %esi
  801ede:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ee4:	68 00 00 40 00       	push   $0x400000
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 98 f0 ff ff       	call   800f88 <sys_page_map>
  801ef0:	83 c4 20             	add    $0x20,%esp
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	79 15                	jns    801f0c <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  801ef7:	50                   	push   %eax
  801ef8:	68 07 2f 80 00       	push   $0x802f07
  801efd:	68 25 01 00 00       	push   $0x125
  801f02:	68 fb 2e 80 00       	push   $0x802efb
  801f07:	e8 d8 e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801f0c:	83 ec 08             	sub    $0x8,%esp
  801f0f:	68 00 00 40 00       	push   $0x400000
  801f14:	6a 00                	push   $0x0
  801f16:	e8 af f0 ff ff       	call   800fca <sys_page_unmap>
  801f1b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f1e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f24:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f2a:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f30:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801f36:	0f 87 f7 fe ff ff    	ja     801e33 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f3c:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f43:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f4a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f51:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801f57:	0f 8c 67 fe ff ff    	jl     801dc4 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f66:	e8 c5 f5 ff ff       	call   801530 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f6b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f72:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f75:	83 c4 08             	add    $0x8,%esp
  801f78:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f7e:	50                   	push   %eax
  801f7f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f85:	e8 c4 f0 ff ff       	call   80104e <sys_env_set_trapframe>
  801f8a:	83 c4 10             	add    $0x10,%esp
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	79 15                	jns    801fa6 <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  801f91:	50                   	push   %eax
  801f92:	68 24 2f 80 00       	push   $0x802f24
  801f97:	68 86 00 00 00       	push   $0x86
  801f9c:	68 fb 2e 80 00       	push   $0x802efb
  801fa1:	e8 3e e5 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801fa6:	83 ec 08             	sub    $0x8,%esp
  801fa9:	6a 02                	push   $0x2
  801fab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fb1:	e8 56 f0 ff ff       	call   80100c <sys_env_set_status>
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	79 25                	jns    801fe2 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801fbd:	50                   	push   %eax
  801fbe:	68 3e 2f 80 00       	push   $0x802f3e
  801fc3:	68 89 00 00 00       	push   $0x89
  801fc8:	68 fb 2e 80 00       	push   $0x802efb
  801fcd:	e8 12 e5 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801fd2:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801fd8:	eb 58                	jmp    802032 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801fda:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801fe0:	eb 50                	jmp    802032 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801fe2:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801fe8:	eb 48                	jmp    802032 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801fea:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801fef:	eb 41                	jmp    802032 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801ff1:	89 c3                	mov    %eax,%ebx
  801ff3:	eb 3d                	jmp    802032 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ff5:	89 c3                	mov    %eax,%ebx
  801ff7:	eb 06                	jmp    801fff <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ff9:	89 c3                	mov    %eax,%ebx
  801ffb:	eb 02                	jmp    801fff <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ffd:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801fff:	83 ec 0c             	sub    $0xc,%esp
  802002:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802008:	e8 b9 ee ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  80200d:	83 c4 04             	add    $0x4,%esp
  802010:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802016:	e8 15 f5 ff ff       	call   801530 <close>
	return r;
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	eb 12                	jmp    802032 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802020:	83 ec 08             	sub    $0x8,%esp
  802023:	68 00 00 40 00       	push   $0x400000
  802028:	6a 00                	push   $0x0
  80202a:	e8 9b ef ff ff       	call   800fca <sys_page_unmap>
  80202f:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802032:	89 d8                	mov    %ebx,%eax
  802034:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    

0080203c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802041:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802049:	eb 03                	jmp    80204e <spawnl+0x12>
		argc++;
  80204b:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80204e:	83 c2 04             	add    $0x4,%edx
  802051:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802055:	75 f4                	jne    80204b <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802057:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  80205e:	83 e2 f0             	and    $0xfffffff0,%edx
  802061:	29 d4                	sub    %edx,%esp
  802063:	8d 54 24 03          	lea    0x3(%esp),%edx
  802067:	c1 ea 02             	shr    $0x2,%edx
  80206a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802071:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802073:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802076:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80207d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802084:	00 
  802085:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
  80208c:	eb 0a                	jmp    802098 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80208e:	83 c0 01             	add    $0x1,%eax
  802091:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802095:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802098:	39 d0                	cmp    %edx,%eax
  80209a:	75 f2                	jne    80208e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80209c:	83 ec 08             	sub    $0x8,%esp
  80209f:	56                   	push   %esi
  8020a0:	ff 75 08             	pushl  0x8(%ebp)
  8020a3:	e8 c7 fa ff ff       	call   801b6f <spawn>
}
  8020a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5e                   	pop    %esi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    

008020af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020b7:	83 ec 0c             	sub    $0xc,%esp
  8020ba:	ff 75 08             	pushl  0x8(%ebp)
  8020bd:	e8 de f2 ff ff       	call   8013a0 <fd2data>
  8020c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020c4:	83 c4 08             	add    $0x8,%esp
  8020c7:	68 80 2f 80 00       	push   $0x802f80
  8020cc:	53                   	push   %ebx
  8020cd:	e8 70 ea ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020d2:	8b 46 04             	mov    0x4(%esi),%eax
  8020d5:	2b 06                	sub    (%esi),%eax
  8020d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020e4:	00 00 00 
	stat->st_dev = &devpipe;
  8020e7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8020ee:	30 80 00 
	return 0;
}
  8020f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f9:	5b                   	pop    %ebx
  8020fa:	5e                   	pop    %esi
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    

008020fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
  802100:	53                   	push   %ebx
  802101:	83 ec 0c             	sub    $0xc,%esp
  802104:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802107:	53                   	push   %ebx
  802108:	6a 00                	push   $0x0
  80210a:	e8 bb ee ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80210f:	89 1c 24             	mov    %ebx,(%esp)
  802112:	e8 89 f2 ff ff       	call   8013a0 <fd2data>
  802117:	83 c4 08             	add    $0x8,%esp
  80211a:	50                   	push   %eax
  80211b:	6a 00                	push   $0x0
  80211d:	e8 a8 ee ff ff       	call   800fca <sys_page_unmap>
}
  802122:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802125:	c9                   	leave  
  802126:	c3                   	ret    

00802127 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	57                   	push   %edi
  80212b:	56                   	push   %esi
  80212c:	53                   	push   %ebx
  80212d:	83 ec 1c             	sub    $0x1c,%esp
  802130:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802133:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802135:	a1 04 40 80 00       	mov    0x804004,%eax
  80213a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80213d:	83 ec 0c             	sub    $0xc,%esp
  802140:	ff 75 e0             	pushl  -0x20(%ebp)
  802143:	e8 71 04 00 00       	call   8025b9 <pageref>
  802148:	89 c3                	mov    %eax,%ebx
  80214a:	89 3c 24             	mov    %edi,(%esp)
  80214d:	e8 67 04 00 00       	call   8025b9 <pageref>
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	39 c3                	cmp    %eax,%ebx
  802157:	0f 94 c1             	sete   %cl
  80215a:	0f b6 c9             	movzbl %cl,%ecx
  80215d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802160:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802166:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802169:	39 ce                	cmp    %ecx,%esi
  80216b:	74 1b                	je     802188 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80216d:	39 c3                	cmp    %eax,%ebx
  80216f:	75 c4                	jne    802135 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802171:	8b 42 58             	mov    0x58(%edx),%eax
  802174:	ff 75 e4             	pushl  -0x1c(%ebp)
  802177:	50                   	push   %eax
  802178:	56                   	push   %esi
  802179:	68 87 2f 80 00       	push   $0x802f87
  80217e:	e8 3a e4 ff ff       	call   8005bd <cprintf>
  802183:	83 c4 10             	add    $0x10,%esp
  802186:	eb ad                	jmp    802135 <_pipeisclosed+0xe>
	}
}
  802188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218e:	5b                   	pop    %ebx
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    

00802193 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	57                   	push   %edi
  802197:	56                   	push   %esi
  802198:	53                   	push   %ebx
  802199:	83 ec 28             	sub    $0x28,%esp
  80219c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80219f:	56                   	push   %esi
  8021a0:	e8 fb f1 ff ff       	call   8013a0 <fd2data>
  8021a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a7:	83 c4 10             	add    $0x10,%esp
  8021aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8021af:	eb 4b                	jmp    8021fc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021b1:	89 da                	mov    %ebx,%edx
  8021b3:	89 f0                	mov    %esi,%eax
  8021b5:	e8 6d ff ff ff       	call   802127 <_pipeisclosed>
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	75 48                	jne    802206 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021be:	e8 63 ed ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8021c6:	8b 0b                	mov    (%ebx),%ecx
  8021c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8021cb:	39 d0                	cmp    %edx,%eax
  8021cd:	73 e2                	jae    8021b1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021d6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021d9:	89 c2                	mov    %eax,%edx
  8021db:	c1 fa 1f             	sar    $0x1f,%edx
  8021de:	89 d1                	mov    %edx,%ecx
  8021e0:	c1 e9 1b             	shr    $0x1b,%ecx
  8021e3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021e6:	83 e2 1f             	and    $0x1f,%edx
  8021e9:	29 ca                	sub    %ecx,%edx
  8021eb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021f3:	83 c0 01             	add    $0x1,%eax
  8021f6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f9:	83 c7 01             	add    $0x1,%edi
  8021fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021ff:	75 c2                	jne    8021c3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802201:	8b 45 10             	mov    0x10(%ebp),%eax
  802204:	eb 05                	jmp    80220b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802206:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80220b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    

00802213 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	57                   	push   %edi
  802217:	56                   	push   %esi
  802218:	53                   	push   %ebx
  802219:	83 ec 18             	sub    $0x18,%esp
  80221c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80221f:	57                   	push   %edi
  802220:	e8 7b f1 ff ff       	call   8013a0 <fd2data>
  802225:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802227:	83 c4 10             	add    $0x10,%esp
  80222a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80222f:	eb 3d                	jmp    80226e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802231:	85 db                	test   %ebx,%ebx
  802233:	74 04                	je     802239 <devpipe_read+0x26>
				return i;
  802235:	89 d8                	mov    %ebx,%eax
  802237:	eb 44                	jmp    80227d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802239:	89 f2                	mov    %esi,%edx
  80223b:	89 f8                	mov    %edi,%eax
  80223d:	e8 e5 fe ff ff       	call   802127 <_pipeisclosed>
  802242:	85 c0                	test   %eax,%eax
  802244:	75 32                	jne    802278 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802246:	e8 db ec ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80224b:	8b 06                	mov    (%esi),%eax
  80224d:	3b 46 04             	cmp    0x4(%esi),%eax
  802250:	74 df                	je     802231 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802252:	99                   	cltd   
  802253:	c1 ea 1b             	shr    $0x1b,%edx
  802256:	01 d0                	add    %edx,%eax
  802258:	83 e0 1f             	and    $0x1f,%eax
  80225b:	29 d0                	sub    %edx,%eax
  80225d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802265:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802268:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80226b:	83 c3 01             	add    $0x1,%ebx
  80226e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802271:	75 d8                	jne    80224b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802273:	8b 45 10             	mov    0x10(%ebp),%eax
  802276:	eb 05                	jmp    80227d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802278:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80227d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	56                   	push   %esi
  802289:	53                   	push   %ebx
  80228a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80228d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802290:	50                   	push   %eax
  802291:	e8 21 f1 ff ff       	call   8013b7 <fd_alloc>
  802296:	83 c4 10             	add    $0x10,%esp
  802299:	89 c2                	mov    %eax,%edx
  80229b:	85 c0                	test   %eax,%eax
  80229d:	0f 88 2c 01 00 00    	js     8023cf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a3:	83 ec 04             	sub    $0x4,%esp
  8022a6:	68 07 04 00 00       	push   $0x407
  8022ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ae:	6a 00                	push   $0x0
  8022b0:	e8 90 ec ff ff       	call   800f45 <sys_page_alloc>
  8022b5:	83 c4 10             	add    $0x10,%esp
  8022b8:	89 c2                	mov    %eax,%edx
  8022ba:	85 c0                	test   %eax,%eax
  8022bc:	0f 88 0d 01 00 00    	js     8023cf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022c2:	83 ec 0c             	sub    $0xc,%esp
  8022c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022c8:	50                   	push   %eax
  8022c9:	e8 e9 f0 ff ff       	call   8013b7 <fd_alloc>
  8022ce:	89 c3                	mov    %eax,%ebx
  8022d0:	83 c4 10             	add    $0x10,%esp
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	0f 88 e2 00 00 00    	js     8023bd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022db:	83 ec 04             	sub    $0x4,%esp
  8022de:	68 07 04 00 00       	push   $0x407
  8022e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8022e6:	6a 00                	push   $0x0
  8022e8:	e8 58 ec ff ff       	call   800f45 <sys_page_alloc>
  8022ed:	89 c3                	mov    %eax,%ebx
  8022ef:	83 c4 10             	add    $0x10,%esp
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	0f 88 c3 00 00 00    	js     8023bd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022fa:	83 ec 0c             	sub    $0xc,%esp
  8022fd:	ff 75 f4             	pushl  -0xc(%ebp)
  802300:	e8 9b f0 ff ff       	call   8013a0 <fd2data>
  802305:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802307:	83 c4 0c             	add    $0xc,%esp
  80230a:	68 07 04 00 00       	push   $0x407
  80230f:	50                   	push   %eax
  802310:	6a 00                	push   $0x0
  802312:	e8 2e ec ff ff       	call   800f45 <sys_page_alloc>
  802317:	89 c3                	mov    %eax,%ebx
  802319:	83 c4 10             	add    $0x10,%esp
  80231c:	85 c0                	test   %eax,%eax
  80231e:	0f 88 89 00 00 00    	js     8023ad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802324:	83 ec 0c             	sub    $0xc,%esp
  802327:	ff 75 f0             	pushl  -0x10(%ebp)
  80232a:	e8 71 f0 ff ff       	call   8013a0 <fd2data>
  80232f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802336:	50                   	push   %eax
  802337:	6a 00                	push   $0x0
  802339:	56                   	push   %esi
  80233a:	6a 00                	push   $0x0
  80233c:	e8 47 ec ff ff       	call   800f88 <sys_page_map>
  802341:	89 c3                	mov    %eax,%ebx
  802343:	83 c4 20             	add    $0x20,%esp
  802346:	85 c0                	test   %eax,%eax
  802348:	78 55                	js     80239f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80234a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802350:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802353:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802358:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80235f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802368:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80236a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80236d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802374:	83 ec 0c             	sub    $0xc,%esp
  802377:	ff 75 f4             	pushl  -0xc(%ebp)
  80237a:	e8 11 f0 ff ff       	call   801390 <fd2num>
  80237f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802382:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802384:	83 c4 04             	add    $0x4,%esp
  802387:	ff 75 f0             	pushl  -0x10(%ebp)
  80238a:	e8 01 f0 ff ff       	call   801390 <fd2num>
  80238f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802392:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802395:	83 c4 10             	add    $0x10,%esp
  802398:	ba 00 00 00 00       	mov    $0x0,%edx
  80239d:	eb 30                	jmp    8023cf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80239f:	83 ec 08             	sub    $0x8,%esp
  8023a2:	56                   	push   %esi
  8023a3:	6a 00                	push   $0x0
  8023a5:	e8 20 ec ff ff       	call   800fca <sys_page_unmap>
  8023aa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023ad:	83 ec 08             	sub    $0x8,%esp
  8023b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8023b3:	6a 00                	push   $0x0
  8023b5:	e8 10 ec ff ff       	call   800fca <sys_page_unmap>
  8023ba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023bd:	83 ec 08             	sub    $0x8,%esp
  8023c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c3:	6a 00                	push   $0x0
  8023c5:	e8 00 ec ff ff       	call   800fca <sys_page_unmap>
  8023ca:	83 c4 10             	add    $0x10,%esp
  8023cd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    

008023d8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023d8:	55                   	push   %ebp
  8023d9:	89 e5                	mov    %esp,%ebp
  8023db:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e1:	50                   	push   %eax
  8023e2:	ff 75 08             	pushl  0x8(%ebp)
  8023e5:	e8 1c f0 ff ff       	call   801406 <fd_lookup>
  8023ea:	83 c4 10             	add    $0x10,%esp
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 18                	js     802409 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023f1:	83 ec 0c             	sub    $0xc,%esp
  8023f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f7:	e8 a4 ef ff ff       	call   8013a0 <fd2data>
	return _pipeisclosed(fd, p);
  8023fc:	89 c2                	mov    %eax,%edx
  8023fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802401:	e8 21 fd ff ff       	call   802127 <_pipeisclosed>
  802406:	83 c4 10             	add    $0x10,%esp
}
  802409:	c9                   	leave  
  80240a:	c3                   	ret    

0080240b <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	56                   	push   %esi
  80240f:	53                   	push   %ebx
  802410:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802413:	85 f6                	test   %esi,%esi
  802415:	75 16                	jne    80242d <wait+0x22>
  802417:	68 9f 2f 80 00       	push   $0x802f9f
  80241c:	68 c0 2e 80 00       	push   $0x802ec0
  802421:	6a 09                	push   $0x9
  802423:	68 aa 2f 80 00       	push   $0x802faa
  802428:	e8 b7 e0 ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  80242d:	89 f3                	mov    %esi,%ebx
  80242f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802435:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802438:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80243e:	eb 05                	jmp    802445 <wait+0x3a>
		sys_yield();
  802440:	e8 e1 ea ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802445:	8b 43 48             	mov    0x48(%ebx),%eax
  802448:	39 c6                	cmp    %eax,%esi
  80244a:	75 07                	jne    802453 <wait+0x48>
  80244c:	8b 43 54             	mov    0x54(%ebx),%eax
  80244f:	85 c0                	test   %eax,%eax
  802451:	75 ed                	jne    802440 <wait+0x35>
		sys_yield();
}
  802453:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802456:	5b                   	pop    %ebx
  802457:	5e                   	pop    %esi
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    

0080245a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802460:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802467:	75 2e                	jne    802497 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802469:	e8 99 ea ff ff       	call   800f07 <sys_getenvid>
  80246e:	83 ec 04             	sub    $0x4,%esp
  802471:	68 07 0e 00 00       	push   $0xe07
  802476:	68 00 f0 bf ee       	push   $0xeebff000
  80247b:	50                   	push   %eax
  80247c:	e8 c4 ea ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802481:	e8 81 ea ff ff       	call   800f07 <sys_getenvid>
  802486:	83 c4 08             	add    $0x8,%esp
  802489:	68 a1 24 80 00       	push   $0x8024a1
  80248e:	50                   	push   %eax
  80248f:	e8 fc eb ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  802494:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802497:	8b 45 08             	mov    0x8(%ebp),%eax
  80249a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80249f:	c9                   	leave  
  8024a0:	c3                   	ret    

008024a1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024a1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024a2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024a7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024a9:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8024ac:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8024b0:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8024b4:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8024b7:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8024ba:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8024bb:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8024be:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8024bf:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8024c0:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8024c4:	c3                   	ret    

008024c5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	56                   	push   %esi
  8024c9:	53                   	push   %ebx
  8024ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8024cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8024d3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8024d5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024da:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8024dd:	83 ec 0c             	sub    $0xc,%esp
  8024e0:	50                   	push   %eax
  8024e1:	e8 0f ec ff ff       	call   8010f5 <sys_ipc_recv>

	if (from_env_store != NULL)
  8024e6:	83 c4 10             	add    $0x10,%esp
  8024e9:	85 f6                	test   %esi,%esi
  8024eb:	74 14                	je     802501 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8024ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f2:	85 c0                	test   %eax,%eax
  8024f4:	78 09                	js     8024ff <ipc_recv+0x3a>
  8024f6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8024fc:	8b 52 74             	mov    0x74(%edx),%edx
  8024ff:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802501:	85 db                	test   %ebx,%ebx
  802503:	74 14                	je     802519 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802505:	ba 00 00 00 00       	mov    $0x0,%edx
  80250a:	85 c0                	test   %eax,%eax
  80250c:	78 09                	js     802517 <ipc_recv+0x52>
  80250e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802514:	8b 52 78             	mov    0x78(%edx),%edx
  802517:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802519:	85 c0                	test   %eax,%eax
  80251b:	78 08                	js     802525 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80251d:	a1 04 40 80 00       	mov    0x804004,%eax
  802522:	8b 40 70             	mov    0x70(%eax),%eax
}
  802525:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802528:	5b                   	pop    %ebx
  802529:	5e                   	pop    %esi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    

0080252c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	57                   	push   %edi
  802530:	56                   	push   %esi
  802531:	53                   	push   %ebx
  802532:	83 ec 0c             	sub    $0xc,%esp
  802535:	8b 7d 08             	mov    0x8(%ebp),%edi
  802538:	8b 75 0c             	mov    0xc(%ebp),%esi
  80253b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80253e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802540:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802545:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802548:	ff 75 14             	pushl  0x14(%ebp)
  80254b:	53                   	push   %ebx
  80254c:	56                   	push   %esi
  80254d:	57                   	push   %edi
  80254e:	e8 7f eb ff ff       	call   8010d2 <sys_ipc_try_send>

		if (err < 0) {
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	85 c0                	test   %eax,%eax
  802558:	79 1e                	jns    802578 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80255a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80255d:	75 07                	jne    802566 <ipc_send+0x3a>
				sys_yield();
  80255f:	e8 c2 e9 ff ff       	call   800f26 <sys_yield>
  802564:	eb e2                	jmp    802548 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802566:	50                   	push   %eax
  802567:	68 b5 2f 80 00       	push   $0x802fb5
  80256c:	6a 49                	push   $0x49
  80256e:	68 c2 2f 80 00       	push   $0x802fc2
  802573:	e8 6c df ff ff       	call   8004e4 <_panic>
		}

	} while (err < 0);

}
  802578:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80257b:	5b                   	pop    %ebx
  80257c:	5e                   	pop    %esi
  80257d:	5f                   	pop    %edi
  80257e:	5d                   	pop    %ebp
  80257f:	c3                   	ret    

00802580 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
  802583:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802586:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80258b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80258e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802594:	8b 52 50             	mov    0x50(%edx),%edx
  802597:	39 ca                	cmp    %ecx,%edx
  802599:	75 0d                	jne    8025a8 <ipc_find_env+0x28>
			return envs[i].env_id;
  80259b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80259e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025a3:	8b 40 48             	mov    0x48(%eax),%eax
  8025a6:	eb 0f                	jmp    8025b7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025a8:	83 c0 01             	add    $0x1,%eax
  8025ab:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025b0:	75 d9                	jne    80258b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    

008025b9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025bf:	89 d0                	mov    %edx,%eax
  8025c1:	c1 e8 16             	shr    $0x16,%eax
  8025c4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025cb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025d0:	f6 c1 01             	test   $0x1,%cl
  8025d3:	74 1d                	je     8025f2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025d5:	c1 ea 0c             	shr    $0xc,%edx
  8025d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025df:	f6 c2 01             	test   $0x1,%dl
  8025e2:	74 0e                	je     8025f2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025e4:	c1 ea 0c             	shr    $0xc,%edx
  8025e7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025ee:	ef 
  8025ef:	0f b7 c0             	movzwl %ax,%eax
}
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    
  8025f4:	66 90                	xchg   %ax,%ax
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	66 90                	xchg   %ax,%ax
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	66 90                	xchg   %ax,%ax
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__udivdi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	53                   	push   %ebx
  802604:	83 ec 1c             	sub    $0x1c,%esp
  802607:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80260b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80260f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802613:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802617:	85 f6                	test   %esi,%esi
  802619:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80261d:	89 ca                	mov    %ecx,%edx
  80261f:	89 f8                	mov    %edi,%eax
  802621:	75 3d                	jne    802660 <__udivdi3+0x60>
  802623:	39 cf                	cmp    %ecx,%edi
  802625:	0f 87 c5 00 00 00    	ja     8026f0 <__udivdi3+0xf0>
  80262b:	85 ff                	test   %edi,%edi
  80262d:	89 fd                	mov    %edi,%ebp
  80262f:	75 0b                	jne    80263c <__udivdi3+0x3c>
  802631:	b8 01 00 00 00       	mov    $0x1,%eax
  802636:	31 d2                	xor    %edx,%edx
  802638:	f7 f7                	div    %edi
  80263a:	89 c5                	mov    %eax,%ebp
  80263c:	89 c8                	mov    %ecx,%eax
  80263e:	31 d2                	xor    %edx,%edx
  802640:	f7 f5                	div    %ebp
  802642:	89 c1                	mov    %eax,%ecx
  802644:	89 d8                	mov    %ebx,%eax
  802646:	89 cf                	mov    %ecx,%edi
  802648:	f7 f5                	div    %ebp
  80264a:	89 c3                	mov    %eax,%ebx
  80264c:	89 d8                	mov    %ebx,%eax
  80264e:	89 fa                	mov    %edi,%edx
  802650:	83 c4 1c             	add    $0x1c,%esp
  802653:	5b                   	pop    %ebx
  802654:	5e                   	pop    %esi
  802655:	5f                   	pop    %edi
  802656:	5d                   	pop    %ebp
  802657:	c3                   	ret    
  802658:	90                   	nop
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	39 ce                	cmp    %ecx,%esi
  802662:	77 74                	ja     8026d8 <__udivdi3+0xd8>
  802664:	0f bd fe             	bsr    %esi,%edi
  802667:	83 f7 1f             	xor    $0x1f,%edi
  80266a:	0f 84 98 00 00 00    	je     802708 <__udivdi3+0x108>
  802670:	bb 20 00 00 00       	mov    $0x20,%ebx
  802675:	89 f9                	mov    %edi,%ecx
  802677:	89 c5                	mov    %eax,%ebp
  802679:	29 fb                	sub    %edi,%ebx
  80267b:	d3 e6                	shl    %cl,%esi
  80267d:	89 d9                	mov    %ebx,%ecx
  80267f:	d3 ed                	shr    %cl,%ebp
  802681:	89 f9                	mov    %edi,%ecx
  802683:	d3 e0                	shl    %cl,%eax
  802685:	09 ee                	or     %ebp,%esi
  802687:	89 d9                	mov    %ebx,%ecx
  802689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80268d:	89 d5                	mov    %edx,%ebp
  80268f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802693:	d3 ed                	shr    %cl,%ebp
  802695:	89 f9                	mov    %edi,%ecx
  802697:	d3 e2                	shl    %cl,%edx
  802699:	89 d9                	mov    %ebx,%ecx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	09 c2                	or     %eax,%edx
  80269f:	89 d0                	mov    %edx,%eax
  8026a1:	89 ea                	mov    %ebp,%edx
  8026a3:	f7 f6                	div    %esi
  8026a5:	89 d5                	mov    %edx,%ebp
  8026a7:	89 c3                	mov    %eax,%ebx
  8026a9:	f7 64 24 0c          	mull   0xc(%esp)
  8026ad:	39 d5                	cmp    %edx,%ebp
  8026af:	72 10                	jb     8026c1 <__udivdi3+0xc1>
  8026b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	d3 e6                	shl    %cl,%esi
  8026b9:	39 c6                	cmp    %eax,%esi
  8026bb:	73 07                	jae    8026c4 <__udivdi3+0xc4>
  8026bd:	39 d5                	cmp    %edx,%ebp
  8026bf:	75 03                	jne    8026c4 <__udivdi3+0xc4>
  8026c1:	83 eb 01             	sub    $0x1,%ebx
  8026c4:	31 ff                	xor    %edi,%edi
  8026c6:	89 d8                	mov    %ebx,%eax
  8026c8:	89 fa                	mov    %edi,%edx
  8026ca:	83 c4 1c             	add    $0x1c,%esp
  8026cd:	5b                   	pop    %ebx
  8026ce:	5e                   	pop    %esi
  8026cf:	5f                   	pop    %edi
  8026d0:	5d                   	pop    %ebp
  8026d1:	c3                   	ret    
  8026d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026d8:	31 ff                	xor    %edi,%edi
  8026da:	31 db                	xor    %ebx,%ebx
  8026dc:	89 d8                	mov    %ebx,%eax
  8026de:	89 fa                	mov    %edi,%edx
  8026e0:	83 c4 1c             	add    $0x1c,%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    
  8026e8:	90                   	nop
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	89 d8                	mov    %ebx,%eax
  8026f2:	f7 f7                	div    %edi
  8026f4:	31 ff                	xor    %edi,%edi
  8026f6:	89 c3                	mov    %eax,%ebx
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	89 fa                	mov    %edi,%edx
  8026fc:	83 c4 1c             	add    $0x1c,%esp
  8026ff:	5b                   	pop    %ebx
  802700:	5e                   	pop    %esi
  802701:	5f                   	pop    %edi
  802702:	5d                   	pop    %ebp
  802703:	c3                   	ret    
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	39 ce                	cmp    %ecx,%esi
  80270a:	72 0c                	jb     802718 <__udivdi3+0x118>
  80270c:	31 db                	xor    %ebx,%ebx
  80270e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802712:	0f 87 34 ff ff ff    	ja     80264c <__udivdi3+0x4c>
  802718:	bb 01 00 00 00       	mov    $0x1,%ebx
  80271d:	e9 2a ff ff ff       	jmp    80264c <__udivdi3+0x4c>
  802722:	66 90                	xchg   %ax,%ax
  802724:	66 90                	xchg   %ax,%ax
  802726:	66 90                	xchg   %ax,%ax
  802728:	66 90                	xchg   %ax,%ax
  80272a:	66 90                	xchg   %ax,%ax
  80272c:	66 90                	xchg   %ax,%ax
  80272e:	66 90                	xchg   %ax,%ax

00802730 <__umoddi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	83 ec 1c             	sub    $0x1c,%esp
  802737:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80273b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80273f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802743:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802747:	85 d2                	test   %edx,%edx
  802749:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80274d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802751:	89 f3                	mov    %esi,%ebx
  802753:	89 3c 24             	mov    %edi,(%esp)
  802756:	89 74 24 04          	mov    %esi,0x4(%esp)
  80275a:	75 1c                	jne    802778 <__umoddi3+0x48>
  80275c:	39 f7                	cmp    %esi,%edi
  80275e:	76 50                	jbe    8027b0 <__umoddi3+0x80>
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	f7 f7                	div    %edi
  802766:	89 d0                	mov    %edx,%eax
  802768:	31 d2                	xor    %edx,%edx
  80276a:	83 c4 1c             	add    $0x1c,%esp
  80276d:	5b                   	pop    %ebx
  80276e:	5e                   	pop    %esi
  80276f:	5f                   	pop    %edi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    
  802772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802778:	39 f2                	cmp    %esi,%edx
  80277a:	89 d0                	mov    %edx,%eax
  80277c:	77 52                	ja     8027d0 <__umoddi3+0xa0>
  80277e:	0f bd ea             	bsr    %edx,%ebp
  802781:	83 f5 1f             	xor    $0x1f,%ebp
  802784:	75 5a                	jne    8027e0 <__umoddi3+0xb0>
  802786:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80278a:	0f 82 e0 00 00 00    	jb     802870 <__umoddi3+0x140>
  802790:	39 0c 24             	cmp    %ecx,(%esp)
  802793:	0f 86 d7 00 00 00    	jbe    802870 <__umoddi3+0x140>
  802799:	8b 44 24 08          	mov    0x8(%esp),%eax
  80279d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027a1:	83 c4 1c             	add    $0x1c,%esp
  8027a4:	5b                   	pop    %ebx
  8027a5:	5e                   	pop    %esi
  8027a6:	5f                   	pop    %edi
  8027a7:	5d                   	pop    %ebp
  8027a8:	c3                   	ret    
  8027a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	85 ff                	test   %edi,%edi
  8027b2:	89 fd                	mov    %edi,%ebp
  8027b4:	75 0b                	jne    8027c1 <__umoddi3+0x91>
  8027b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bb:	31 d2                	xor    %edx,%edx
  8027bd:	f7 f7                	div    %edi
  8027bf:	89 c5                	mov    %eax,%ebp
  8027c1:	89 f0                	mov    %esi,%eax
  8027c3:	31 d2                	xor    %edx,%edx
  8027c5:	f7 f5                	div    %ebp
  8027c7:	89 c8                	mov    %ecx,%eax
  8027c9:	f7 f5                	div    %ebp
  8027cb:	89 d0                	mov    %edx,%eax
  8027cd:	eb 99                	jmp    802768 <__umoddi3+0x38>
  8027cf:	90                   	nop
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	83 c4 1c             	add    $0x1c,%esp
  8027d7:	5b                   	pop    %ebx
  8027d8:	5e                   	pop    %esi
  8027d9:	5f                   	pop    %edi
  8027da:	5d                   	pop    %ebp
  8027db:	c3                   	ret    
  8027dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	8b 34 24             	mov    (%esp),%esi
  8027e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027e8:	89 e9                	mov    %ebp,%ecx
  8027ea:	29 ef                	sub    %ebp,%edi
  8027ec:	d3 e0                	shl    %cl,%eax
  8027ee:	89 f9                	mov    %edi,%ecx
  8027f0:	89 f2                	mov    %esi,%edx
  8027f2:	d3 ea                	shr    %cl,%edx
  8027f4:	89 e9                	mov    %ebp,%ecx
  8027f6:	09 c2                	or     %eax,%edx
  8027f8:	89 d8                	mov    %ebx,%eax
  8027fa:	89 14 24             	mov    %edx,(%esp)
  8027fd:	89 f2                	mov    %esi,%edx
  8027ff:	d3 e2                	shl    %cl,%edx
  802801:	89 f9                	mov    %edi,%ecx
  802803:	89 54 24 04          	mov    %edx,0x4(%esp)
  802807:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80280b:	d3 e8                	shr    %cl,%eax
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	89 c6                	mov    %eax,%esi
  802811:	d3 e3                	shl    %cl,%ebx
  802813:	89 f9                	mov    %edi,%ecx
  802815:	89 d0                	mov    %edx,%eax
  802817:	d3 e8                	shr    %cl,%eax
  802819:	89 e9                	mov    %ebp,%ecx
  80281b:	09 d8                	or     %ebx,%eax
  80281d:	89 d3                	mov    %edx,%ebx
  80281f:	89 f2                	mov    %esi,%edx
  802821:	f7 34 24             	divl   (%esp)
  802824:	89 d6                	mov    %edx,%esi
  802826:	d3 e3                	shl    %cl,%ebx
  802828:	f7 64 24 04          	mull   0x4(%esp)
  80282c:	39 d6                	cmp    %edx,%esi
  80282e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802832:	89 d1                	mov    %edx,%ecx
  802834:	89 c3                	mov    %eax,%ebx
  802836:	72 08                	jb     802840 <__umoddi3+0x110>
  802838:	75 11                	jne    80284b <__umoddi3+0x11b>
  80283a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80283e:	73 0b                	jae    80284b <__umoddi3+0x11b>
  802840:	2b 44 24 04          	sub    0x4(%esp),%eax
  802844:	1b 14 24             	sbb    (%esp),%edx
  802847:	89 d1                	mov    %edx,%ecx
  802849:	89 c3                	mov    %eax,%ebx
  80284b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80284f:	29 da                	sub    %ebx,%edx
  802851:	19 ce                	sbb    %ecx,%esi
  802853:	89 f9                	mov    %edi,%ecx
  802855:	89 f0                	mov    %esi,%eax
  802857:	d3 e0                	shl    %cl,%eax
  802859:	89 e9                	mov    %ebp,%ecx
  80285b:	d3 ea                	shr    %cl,%edx
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	d3 ee                	shr    %cl,%esi
  802861:	09 d0                	or     %edx,%eax
  802863:	89 f2                	mov    %esi,%edx
  802865:	83 c4 1c             	add    $0x1c,%esp
  802868:	5b                   	pop    %ebx
  802869:	5e                   	pop    %esi
  80286a:	5f                   	pop    %edi
  80286b:	5d                   	pop    %ebp
  80286c:	c3                   	ret    
  80286d:	8d 76 00             	lea    0x0(%esi),%esi
  802870:	29 f9                	sub    %edi,%ecx
  802872:	19 d6                	sbb    %edx,%esi
  802874:	89 74 24 04          	mov    %esi,0x4(%esp)
  802878:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80287c:	e9 18 ff ff ff       	jmp    802799 <__umoddi3+0x69>
