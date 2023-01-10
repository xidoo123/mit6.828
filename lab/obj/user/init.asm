
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 80 2a 80 00       	push   $0x802a80
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 48 2b 80 00       	push   $0x802b48
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 8f 2a 80 00       	push   $0x802a8f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 60 80 00       	push   $0x806020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 84 2b 80 00       	push   $0x802b84
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 a6 2a 80 00       	push   $0x802aa6
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 bc 2a 80 00       	push   $0x802abc
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 72 09 00 00       	call   800a7d <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 c8 2a 80 00       	push   $0x802ac8
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 c9 2a 80 00       	push   $0x802ac9
  80013d:	56                   	push   %esi
  80013e:	e8 3a 09 00 00       	call   800a7d <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 cb 2a 80 00       	push   $0x802acb
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 cf 2a 80 00 	movl   $0x802acf,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 d8 10 00 00       	call   801252 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 e1 2a 80 00       	push   $0x802ae1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ee 2a 80 00       	push   $0x802aee
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 fa 2a 80 00       	push   $0x802afa
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ee 2a 80 00       	push   $0x802aee
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 e8 10 00 00       	call   8012a2 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 14 2b 80 00       	push   $0x802b14
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ee 2a 80 00       	push   $0x802aee
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 1c 2b 80 00       	push   $0x802b1c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 30 2b 80 00       	push   $0x802b30
  8001ea:	68 2f 2b 80 00       	push   $0x802b2f
  8001ef:	e8 39 1c 00 00       	call   801e2d <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 33 2b 80 00       	push   $0x802b33
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 4c 24 00 00       	call   802663 <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 b3 2b 80 00       	push   $0x802bb3
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 24 08 00 00       	call   800a5d <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 78 09 00 00       	call   800bef <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 23 0b 00 00       	call   800da4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 94 0b 00 00       	call   800e41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 10 0b 00 00       	call   800dc2 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 bb 0a 00 00       	call   800da4 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 8d 10 00 00       	call   80138e <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 fd 0d 00 00       	call   801128 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 85 0d 00 00       	call   8010d9 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 f1 0a 00 00       	call   800e60 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 1c 0d 00 00       	call   8010b2 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 73 0a 00 00       	call   800e22 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 8d 0e 00 00       	call   80127d <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 e7 09 00 00       	call   800de1 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  80040d:	e8 10 0a 00 00       	call   800e22 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 cc 2b 80 00       	push   $0x802bcc
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 f5 30 80 00 	movl   $0x8030f5,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 2f 09 00 00       	call   800da4 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 d4 08 00 00       	call   800da4 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 b0 22 00 00       	call   8027f0 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 9d 23 00 00       	call   802920 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 ef 2b 80 00 	movsbl 0x802bef(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 89 03 00 00    	je     8009b4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 1a 03 00 00    	ja     800999 <vprintfmt+0x38a>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 40 2d 80 00 	jmp    *0x802d40(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006aa:	83 fa 09             	cmp    $0x9,%edx
  8006ad:	77 39                	ja     8006e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b2:	eb e9                	jmp    80069d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c5:	eb 27                	jmp    8006ee <vprintfmt+0xdf>
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	0f 49 c8             	cmovns %eax,%ecx
  8006d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x59>
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e6:	eb 80                	jmp    800668 <vprintfmt+0x59>
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	0f 89 70 ff ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800705:	e9 5e ff ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800710:	e9 53 ff ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	ff 30                	pushl  (%eax)
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072c:	e9 04 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	99                   	cltd   
  80073d:	31 d0                	xor    %edx,%eax
  80073f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800741:	83 f8 0f             	cmp    $0xf,%eax
  800744:	7f 0b                	jg     800751 <vprintfmt+0x142>
  800746:	8b 14 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 07 2c 80 00       	push   $0x802c07
  800757:	53                   	push   %ebx
  800758:	56                   	push   %esi
  800759:	e8 94 fe ff ff       	call   8005f2 <printfmt>
  80075e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800764:	e9 cc fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800769:	52                   	push   %edx
  80076a:	68 d5 2f 80 00       	push   $0x802fd5
  80076f:	53                   	push   %ebx
  800770:	56                   	push   %esi
  800771:	e8 7c fe ff ff       	call   8005f2 <printfmt>
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	e9 b4 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078c:	85 ff                	test   %edi,%edi
  80078e:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  800793:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079a:	0f 8e 94 00 00 00    	jle    800834 <vprintfmt+0x225>
  8007a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a4:	0f 84 98 00 00 00    	je     800842 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	e8 86 02 00 00       	call   800a3c <strnlen>
  8007b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0f                	jmp    8007de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 ff                	test   %edi,%edi
  8007e0:	7f ed                	jg     8007cf <vprintfmt+0x1c0>
  8007e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f 49 c1             	cmovns %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x213>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x213>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x23f>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x23f>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x270>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f2>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f2>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x278>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 a2 fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d1>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ef:	79 74                	jns    800965 <vprintfmt+0x356>
				putch('-', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 2d                	push   $0x2d
  8008f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ff:	f7 d8                	neg    %eax
  800901:	83 d2 00             	adc    $0x0,%edx
  800904:	f7 da                	neg    %edx
  800906:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090e:	eb 55                	jmp    800965 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
  800913:	e8 83 fc ff ff       	call   80059b <getuint>
			base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80091d:	eb 46                	jmp    800965 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 74 fc ff ff       	call   80059b <getuint>
			base = 8;
  800927:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80092c:	eb 37                	jmp    800965 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d6                	call   *%esi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80094e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800951:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800956:	eb 0d                	jmp    800965 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	e8 3b fc ff ff       	call   80059b <getuint>
			base = 16;
  800960:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80096c:	57                   	push   %edi
  80096d:	ff 75 e0             	pushl  -0x20(%ebp)
  800970:	51                   	push   %ecx
  800971:	52                   	push   %edx
  800972:	50                   	push   %eax
  800973:	89 da                	mov    %ebx,%edx
  800975:	89 f0                	mov    %esi,%eax
  800977:	e8 70 fb ff ff       	call   8004ec <printnum>
			break;
  80097c:	83 c4 20             	add    $0x20,%esp
  80097f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800982:	e9 ae fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	53                   	push   %ebx
  80098b:	51                   	push   %ecx
  80098c:	ff d6                	call   *%esi
			break;
  80098e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800991:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800994:	e9 9c fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	6a 25                	push   $0x25
  80099f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	eb 03                	jmp    8009a9 <vprintfmt+0x39a>
  8009a6:	83 ef 01             	sub    $0x1,%edi
  8009a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009ad:	75 f7                	jne    8009a6 <vprintfmt+0x397>
  8009af:	e9 81 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 18             	sub    $0x18,%esp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	74 26                	je     800a03 <vsnprintf+0x47>
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	7e 22                	jle    800a03 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e1:	ff 75 14             	pushl  0x14(%ebp)
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	68 d5 05 80 00       	push   $0x8005d5
  8009f0:	e8 1a fc ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb 05                	jmp    800a08 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a13:	50                   	push   %eax
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 9a ff ff ff       	call   8009bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 03                	jmp    800a34 <strlen+0x10>
		n++;
  800a31:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a38:	75 f7                	jne    800a31 <strlen+0xd>
		n++;
	return n;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	eb 03                	jmp    800a4f <strnlen+0x13>
		n++;
  800a4c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 08                	je     800a5b <strnlen+0x1f>
  800a53:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a57:	75 f3                	jne    800a4c <strnlen+0x10>
  800a59:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a76:	84 db                	test   %bl,%bl
  800a78:	75 ef                	jne    800a69 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	53                   	push   %ebx
  800a85:	e8 9a ff ff ff       	call   800a24 <strlen>
  800a8a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	01 d8                	add    %ebx,%eax
  800a92:	50                   	push   %eax
  800a93:	e8 c5 ff ff ff       	call   800a5d <strcpy>
	return dst;
}
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aaf:	89 f2                	mov    %esi,%edx
  800ab1:	eb 0f                	jmp    800ac2 <strncpy+0x23>
		*dst++ = *src;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abc:	80 39 01             	cmpb   $0x1,(%ecx)
  800abf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac2:	39 da                	cmp    %ebx,%edx
  800ac4:	75 ed                	jne    800ab3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
  800ada:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800adc:	85 d2                	test   %edx,%edx
  800ade:	74 21                	je     800b01 <strlcpy+0x35>
  800ae0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ae4:	89 f2                	mov    %esi,%edx
  800ae6:	eb 09                	jmp    800af1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	74 09                	je     800afe <strlcpy+0x32>
  800af5:	0f b6 19             	movzbl (%ecx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	75 ec                	jne    800ae8 <strlcpy+0x1c>
  800afc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800afe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b01:	29 f0                	sub    %esi,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b10:	eb 06                	jmp    800b18 <strcmp+0x11>
		p++, q++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	84 c0                	test   %al,%al
  800b1d:	74 04                	je     800b23 <strcmp+0x1c>
  800b1f:	3a 02                	cmp    (%edx),%al
  800b21:	74 ef                	je     800b12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 c0             	movzbl %al,%eax
  800b26:	0f b6 12             	movzbl (%edx),%edx
  800b29:	29 d0                	sub    %edx,%eax
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	53                   	push   %ebx
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3c:	eb 06                	jmp    800b44 <strncmp+0x17>
		n--, p++, q++;
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b44:	39 d8                	cmp    %ebx,%eax
  800b46:	74 15                	je     800b5d <strncmp+0x30>
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	84 c9                	test   %cl,%cl
  800b4d:	74 04                	je     800b53 <strncmp+0x26>
  800b4f:	3a 0a                	cmp    (%edx),%cl
  800b51:	74 eb                	je     800b3e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 00             	movzbl (%eax),%eax
  800b56:	0f b6 12             	movzbl (%edx),%edx
  800b59:	29 d0                	sub    %edx,%eax
  800b5b:	eb 05                	jmp    800b62 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b6f:	eb 07                	jmp    800b78 <strchr+0x13>
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0f                	je     800b84 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b90:	eb 03                	jmp    800b95 <strfind+0xf>
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b98:	38 ca                	cmp    %cl,%dl
  800b9a:	74 04                	je     800ba0 <strfind+0x1a>
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f2                	jne    800b92 <strfind+0xc>
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bae:	85 c9                	test   %ecx,%ecx
  800bb0:	74 36                	je     800be8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb8:	75 28                	jne    800be2 <memset+0x40>
  800bba:	f6 c1 03             	test   $0x3,%cl
  800bbd:	75 23                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bbf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	c1 e3 08             	shl    $0x8,%ebx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	c1 e6 18             	shl    $0x18,%esi
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	c1 e0 10             	shl    $0x10,%eax
  800bd2:	09 f0                	or     %esi,%eax
  800bd4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bd6:	89 d8                	mov    %ebx,%eax
  800bd8:	09 d0                	or     %edx,%eax
  800bda:	c1 e9 02             	shr    $0x2,%ecx
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 06                	jmp    800be8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	fc                   	cld    
  800be6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x47>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x47>
		s += n;
		d += n;
  800c08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	09 fe                	or     %edi,%esi
  800c0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c15:	75 13                	jne    800c2a <memmove+0x3b>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c28:	eb 09                	jmp    800c33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
  800c34:	eb 1d                	jmp    800c53 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	89 f2                	mov    %esi,%edx
  800c38:	09 c2                	or     %eax,%edx
  800c3a:	f6 c2 03             	test   $0x3,%dl
  800c3d:	75 0f                	jne    800c4e <memmove+0x5f>
  800c3f:	f6 c1 03             	test   $0x3,%cl
  800c42:	75 0a                	jne    800c4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c44:	c1 e9 02             	shr    $0x2,%ecx
  800c47:	89 c7                	mov    %eax,%edi
  800c49:	fc                   	cld    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 05                	jmp    800c53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4e:	89 c7                	mov    %eax,%edi
  800c50:	fc                   	cld    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	ff 75 08             	pushl  0x8(%ebp)
  800c63:	e8 87 ff ff ff       	call   800bef <memmove>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	eb 1a                	jmp    800c96 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7c:	0f b6 08             	movzbl (%eax),%ecx
  800c7f:	0f b6 1a             	movzbl (%edx),%ebx
  800c82:	38 d9                	cmp    %bl,%cl
  800c84:	74 0a                	je     800c90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c86:	0f b6 c1             	movzbl %cl,%eax
  800c89:	0f b6 db             	movzbl %bl,%ebx
  800c8c:	29 d8                	sub    %ebx,%eax
  800c8e:	eb 0f                	jmp    800c9f <memcmp+0x35>
		s1++, s2++;
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	39 f0                	cmp    %esi,%eax
  800c98:	75 e2                	jne    800c7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	53                   	push   %ebx
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800caa:	89 c1                	mov    %eax,%ecx
  800cac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800caf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb3:	eb 0a                	jmp    800cbf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	39 da                	cmp    %ebx,%edx
  800cba:	74 07                	je     800cc3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	39 c8                	cmp    %ecx,%eax
  800cc1:	72 f2                	jb     800cb5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd2:	eb 03                	jmp    800cd7 <strtol+0x11>
		s++;
  800cd4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd7:	0f b6 01             	movzbl (%ecx),%eax
  800cda:	3c 20                	cmp    $0x20,%al
  800cdc:	74 f6                	je     800cd4 <strtol+0xe>
  800cde:	3c 09                	cmp    $0x9,%al
  800ce0:	74 f2                	je     800cd4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce2:	3c 2b                	cmp    $0x2b,%al
  800ce4:	75 0a                	jne    800cf0 <strtol+0x2a>
		s++;
  800ce6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cee:	eb 11                	jmp    800d01 <strtol+0x3b>
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf5:	3c 2d                	cmp    $0x2d,%al
  800cf7:	75 08                	jne    800d01 <strtol+0x3b>
		s++, neg = 1;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d07:	75 15                	jne    800d1e <strtol+0x58>
  800d09:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0c:	75 10                	jne    800d1e <strtol+0x58>
  800d0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d12:	75 7c                	jne    800d90 <strtol+0xca>
		s += 2, base = 16;
  800d14:	83 c1 02             	add    $0x2,%ecx
  800d17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1c:	eb 16                	jmp    800d34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d1e:	85 db                	test   %ebx,%ebx
  800d20:	75 12                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d27:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2a:	75 08                	jne    800d34 <strtol+0x6e>
		s++, base = 8;
  800d2c:	83 c1 01             	add    $0x1,%ecx
  800d2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
  800d39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	0f b6 11             	movzbl (%ecx),%edx
  800d3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d42:	89 f3                	mov    %esi,%ebx
  800d44:	80 fb 09             	cmp    $0x9,%bl
  800d47:	77 08                	ja     800d51 <strtol+0x8b>
			dig = *s - '0';
  800d49:	0f be d2             	movsbl %dl,%edx
  800d4c:	83 ea 30             	sub    $0x30,%edx
  800d4f:	eb 22                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d54:	89 f3                	mov    %esi,%ebx
  800d56:	80 fb 19             	cmp    $0x19,%bl
  800d59:	77 08                	ja     800d63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d5b:	0f be d2             	movsbl %dl,%edx
  800d5e:	83 ea 57             	sub    $0x57,%edx
  800d61:	eb 10                	jmp    800d73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d66:	89 f3                	mov    %esi,%ebx
  800d68:	80 fb 19             	cmp    $0x19,%bl
  800d6b:	77 16                	ja     800d83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d6d:	0f be d2             	movsbl %dl,%edx
  800d70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d76:	7d 0b                	jge    800d83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d78:	83 c1 01             	add    $0x1,%ecx
  800d7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d81:	eb b9                	jmp    800d3c <strtol+0x76>

	if (endptr)
  800d83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d87:	74 0d                	je     800d96 <strtol+0xd0>
		*endptr = (char *) s;
  800d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8c:	89 0e                	mov    %ecx,(%esi)
  800d8e:	eb 06                	jmp    800d96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d90:	85 db                	test   %ebx,%ebx
  800d92:	74 98                	je     800d2c <strtol+0x66>
  800d94:	eb 9e                	jmp    800d34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	f7 da                	neg    %edx
  800d9a:	85 ff                	test   %edi,%edi
  800d9c:	0f 45 c2             	cmovne %edx,%eax
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	89 c7                	mov    %eax,%edi
  800db9:	89 c6                	mov    %eax,%esi
  800dbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 03 00 00 00       	mov    $0x3,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 03                	push   $0x3
  800e09:	68 ff 2e 80 00       	push   $0x802eff
  800e0e:	6a 23                	push   $0x23
  800e10:	68 1c 2f 80 00       	push   $0x802f1c
  800e15:	e8 e5 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_yield>:

void
sys_yield(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	be 00 00 00 00       	mov    $0x0,%esi
  800e6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	89 f7                	mov    %esi,%edi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 04                	push   $0x4
  800e8a:	68 ff 2e 80 00       	push   $0x802eff
  800e8f:	6a 23                	push   $0x23
  800e91:	68 1c 2f 80 00       	push   $0x802f1c
  800e96:	e8 64 f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 17                	jle    800edd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	50                   	push   %eax
  800eca:	6a 05                	push   $0x5
  800ecc:	68 ff 2e 80 00       	push   $0x802eff
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 1c 2f 80 00       	push   $0x802f1c
  800ed8:	e8 22 f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 17                	jle    800f1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 06                	push   $0x6
  800f0e:	68 ff 2e 80 00       	push   $0x802eff
  800f13:	6a 23                	push   $0x23
  800f15:	68 1c 2f 80 00       	push   $0x802f1c
  800f1a:	e8 e0 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 08                	push   $0x8
  800f50:	68 ff 2e 80 00       	push   $0x802eff
  800f55:	6a 23                	push   $0x23
  800f57:	68 1c 2f 80 00       	push   $0x802f1c
  800f5c:	e8 9e f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f77:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f82:	89 df                	mov    %ebx,%edi
  800f84:	89 de                	mov    %ebx,%esi
  800f86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7e 17                	jle    800fa3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 09                	push   $0x9
  800f92:	68 ff 2e 80 00       	push   $0x802eff
  800f97:	6a 23                	push   $0x23
  800f99:	68 1c 2f 80 00       	push   $0x802f1c
  800f9e:	e8 5c f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 df                	mov    %ebx,%edi
  800fc6:	89 de                	mov    %ebx,%esi
  800fc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 0a                	push   $0xa
  800fd4:	68 ff 2e 80 00       	push   $0x802eff
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 1c 2f 80 00       	push   $0x802f1c
  800fe0:	e8 1a f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	be 00 00 00 00       	mov    $0x0,%esi
  800ff8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801006:	8b 7d 14             	mov    0x14(%ebp),%edi
  801009:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 cb                	mov    %ecx,%ebx
  801028:	89 cf                	mov    %ecx,%edi
  80102a:	89 ce                	mov    %ecx,%esi
  80102c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 17                	jle    801049 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	6a 0d                	push   $0xd
  801038:	68 ff 2e 80 00       	push   $0x802eff
  80103d:	6a 23                	push   $0x23
  80103f:	68 1c 2f 80 00       	push   $0x802f1c
  801044:	e8 b6 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	ba 00 00 00 00       	mov    $0x0,%edx
  80105c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801061:	89 d1                	mov    %edx,%ecx
  801063:	89 d3                	mov    %edx,%ebx
  801065:	89 d7                	mov    %edx,%edi
  801067:	89 d6                	mov    %edx,%esi
  801069:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	b8 0f 00 00 00       	mov    $0xf,%eax
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 df                	mov    %ebx,%edi
  80108b:	89 de                	mov    %ebx,%esi
  80108d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	7e 17                	jle    8010aa <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 0f                	push   $0xf
  801099:	68 ff 2e 80 00       	push   $0x802eff
  80109e:	6a 23                	push   $0x23
  8010a0:	68 1c 2f 80 00       	push   $0x802f1c
  8010a5:	e8 55 f3 ff ff       	call   8003ff <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bd:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010df:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 16             	shr    $0x16,%edx
  8010e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	74 11                	je     801106 <fd_alloc+0x2d>
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	75 09                	jne    80110f <fd_alloc+0x36>
			*fd_store = fd;
  801106:	89 01                	mov    %eax,(%ecx)
			return 0;
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	eb 17                	jmp    801126 <fd_alloc+0x4d>
  80110f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801114:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801119:	75 c9                	jne    8010e4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801121:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80112e:	83 f8 1f             	cmp    $0x1f,%eax
  801131:	77 36                	ja     801169 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801133:	c1 e0 0c             	shl    $0xc,%eax
  801136:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 16             	shr    $0x16,%edx
  801140:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 24                	je     801170 <fd_lookup+0x48>
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	c1 ea 0c             	shr    $0xc,%edx
  801151:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801158:	f6 c2 01             	test   $0x1,%dl
  80115b:	74 1a                	je     801177 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80115d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801160:	89 02                	mov    %eax,(%edx)
	return 0;
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
  801167:	eb 13                	jmp    80117c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116e:	eb 0c                	jmp    80117c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801170:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801175:	eb 05                	jmp    80117c <fd_lookup+0x54>
  801177:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801187:	ba a8 2f 80 00       	mov    $0x802fa8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80118c:	eb 13                	jmp    8011a1 <dev_lookup+0x23>
  80118e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801191:	39 08                	cmp    %ecx,(%eax)
  801193:	75 0c                	jne    8011a1 <dev_lookup+0x23>
			*dev = devtab[i];
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
  80119f:	eb 2e                	jmp    8011cf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a1:	8b 02                	mov    (%edx),%eax
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	75 e7                	jne    80118e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a7:	a1 90 77 80 00       	mov    0x807790,%eax
  8011ac:	8b 40 48             	mov    0x48(%eax),%eax
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	51                   	push   %ecx
  8011b3:	50                   	push   %eax
  8011b4:	68 2c 2f 80 00       	push   $0x802f2c
  8011b9:	e8 1a f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  8011be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 10             	sub    $0x10,%esp
  8011d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e9:	c1 e8 0c             	shr    $0xc,%eax
  8011ec:	50                   	push   %eax
  8011ed:	e8 36 ff ff ff       	call   801128 <fd_lookup>
  8011f2:	83 c4 08             	add    $0x8,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 05                	js     8011fe <fd_close+0x2d>
	    || fd != fd2)
  8011f9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011fc:	74 0c                	je     80120a <fd_close+0x39>
		return (must_exist ? r : 0);
  8011fe:	84 db                	test   %bl,%bl
  801200:	ba 00 00 00 00       	mov    $0x0,%edx
  801205:	0f 44 c2             	cmove  %edx,%eax
  801208:	eb 41                	jmp    80124b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	ff 36                	pushl  (%esi)
  801213:	e8 66 ff ff ff       	call   80117e <dev_lookup>
  801218:	89 c3                	mov    %eax,%ebx
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 1a                	js     80123b <fd_close+0x6a>
		if (dev->dev_close)
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80122c:	85 c0                	test   %eax,%eax
  80122e:	74 0b                	je     80123b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	56                   	push   %esi
  801234:	ff d0                	call   *%eax
  801236:	89 c3                	mov    %eax,%ebx
  801238:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	56                   	push   %esi
  80123f:	6a 00                	push   $0x0
  801241:	e8 9f fc ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	89 d8                	mov    %ebx,%eax
}
  80124b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 c4 fe ff ff       	call   801128 <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 10                	js     80127b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	6a 01                	push   $0x1
  801270:	ff 75 f4             	pushl  -0xc(%ebp)
  801273:	e8 59 ff ff ff       	call   8011d1 <fd_close>
  801278:	83 c4 10             	add    $0x10,%esp
}
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <close_all>:

void
close_all(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	53                   	push   %ebx
  801281:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801284:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801289:	83 ec 0c             	sub    $0xc,%esp
  80128c:	53                   	push   %ebx
  80128d:	e8 c0 ff ff ff       	call   801252 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801292:	83 c3 01             	add    $0x1,%ebx
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	83 fb 20             	cmp    $0x20,%ebx
  80129b:	75 ec                	jne    801289 <close_all+0xc>
		close(i);
}
  80129d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 2c             	sub    $0x2c,%esp
  8012ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 08             	pushl  0x8(%ebp)
  8012b5:	e8 6e fe ff ff       	call   801128 <fd_lookup>
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	0f 88 c1 00 00 00    	js     801386 <dup+0xe4>
		return r;
	close(newfdnum);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	56                   	push   %esi
  8012c9:	e8 84 ff ff ff       	call   801252 <close>

	newfd = INDEX2FD(newfdnum);
  8012ce:	89 f3                	mov    %esi,%ebx
  8012d0:	c1 e3 0c             	shl    $0xc,%ebx
  8012d3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d9:	83 c4 04             	add    $0x4,%esp
  8012dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012df:	e8 de fd ff ff       	call   8010c2 <fd2data>
  8012e4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 d4 fd ff ff       	call   8010c2 <fd2data>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f4:	89 f8                	mov    %edi,%eax
  8012f6:	c1 e8 16             	shr    $0x16,%eax
  8012f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801300:	a8 01                	test   $0x1,%al
  801302:	74 37                	je     80133b <dup+0x99>
  801304:	89 f8                	mov    %edi,%eax
  801306:	c1 e8 0c             	shr    $0xc,%eax
  801309:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 26                	je     80133b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801315:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	25 07 0e 00 00       	and    $0xe07,%eax
  801324:	50                   	push   %eax
  801325:	ff 75 d4             	pushl  -0x2c(%ebp)
  801328:	6a 00                	push   $0x0
  80132a:	57                   	push   %edi
  80132b:	6a 00                	push   $0x0
  80132d:	e8 71 fb ff ff       	call   800ea3 <sys_page_map>
  801332:	89 c7                	mov    %eax,%edi
  801334:	83 c4 20             	add    $0x20,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 2e                	js     801369 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133e:	89 d0                	mov    %edx,%eax
  801340:	c1 e8 0c             	shr    $0xc,%eax
  801343:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	25 07 0e 00 00       	and    $0xe07,%eax
  801352:	50                   	push   %eax
  801353:	53                   	push   %ebx
  801354:	6a 00                	push   $0x0
  801356:	52                   	push   %edx
  801357:	6a 00                	push   $0x0
  801359:	e8 45 fb ff ff       	call   800ea3 <sys_page_map>
  80135e:	89 c7                	mov    %eax,%edi
  801360:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801363:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801365:	85 ff                	test   %edi,%edi
  801367:	79 1d                	jns    801386 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	53                   	push   %ebx
  80136d:	6a 00                	push   $0x0
  80136f:	e8 71 fb ff ff       	call   800ee5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801374:	83 c4 08             	add    $0x8,%esp
  801377:	ff 75 d4             	pushl  -0x2c(%ebp)
  80137a:	6a 00                	push   $0x0
  80137c:	e8 64 fb ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	89 f8                	mov    %edi,%eax
}
  801386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5f                   	pop    %edi
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 14             	sub    $0x14,%esp
  801395:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801398:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	53                   	push   %ebx
  80139d:	e8 86 fd ff ff       	call   801128 <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 6d                	js     801418 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	e8 c2 fd ff ff       	call   80117e <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 4c                	js     80140f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c6:	8b 42 08             	mov    0x8(%edx),%eax
  8013c9:	83 e0 03             	and    $0x3,%eax
  8013cc:	83 f8 01             	cmp    $0x1,%eax
  8013cf:	75 21                	jne    8013f2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d1:	a1 90 77 80 00       	mov    0x807790,%eax
  8013d6:	8b 40 48             	mov    0x48(%eax),%eax
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	50                   	push   %eax
  8013de:	68 6d 2f 80 00       	push   $0x802f6d
  8013e3:	e8 f0 f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f0:	eb 26                	jmp    801418 <read+0x8a>
	}
	if (!dev->dev_read)
  8013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f5:	8b 40 08             	mov    0x8(%eax),%eax
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	74 17                	je     801413 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	ff 75 10             	pushl  0x10(%ebp)
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	52                   	push   %edx
  801406:	ff d0                	call   *%eax
  801408:	89 c2                	mov    %eax,%edx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb 09                	jmp    801418 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	89 c2                	mov    %eax,%edx
  801411:	eb 05                	jmp    801418 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801413:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801418:	89 d0                	mov    %edx,%eax
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	57                   	push   %edi
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801433:	eb 21                	jmp    801456 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	89 f0                	mov    %esi,%eax
  80143a:	29 d8                	sub    %ebx,%eax
  80143c:	50                   	push   %eax
  80143d:	89 d8                	mov    %ebx,%eax
  80143f:	03 45 0c             	add    0xc(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	57                   	push   %edi
  801444:	e8 45 ff ff ff       	call   80138e <read>
		if (m < 0)
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 10                	js     801460 <readn+0x41>
			return m;
		if (m == 0)
  801450:	85 c0                	test   %eax,%eax
  801452:	74 0a                	je     80145e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801454:	01 c3                	add    %eax,%ebx
  801456:	39 f3                	cmp    %esi,%ebx
  801458:	72 db                	jb     801435 <readn+0x16>
  80145a:	89 d8                	mov    %ebx,%eax
  80145c:	eb 02                	jmp    801460 <readn+0x41>
  80145e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	e8 ac fc ff ff       	call   801128 <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	89 c2                	mov    %eax,%edx
  801481:	85 c0                	test   %eax,%eax
  801483:	78 68                	js     8014ed <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148f:	ff 30                	pushl  (%eax)
  801491:	e8 e8 fc ff ff       	call   80117e <dev_lookup>
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 47                	js     8014e4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a4:	75 21                	jne    8014c7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a6:	a1 90 77 80 00       	mov    0x807790,%eax
  8014ab:	8b 40 48             	mov    0x48(%eax),%eax
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	50                   	push   %eax
  8014b3:	68 89 2f 80 00       	push   $0x802f89
  8014b8:	e8 1b f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c5:	eb 26                	jmp    8014ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ca:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cd:	85 d2                	test   %edx,%edx
  8014cf:	74 17                	je     8014e8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	ff 75 10             	pushl  0x10(%ebp)
  8014d7:	ff 75 0c             	pushl  0xc(%ebp)
  8014da:	50                   	push   %eax
  8014db:	ff d2                	call   *%edx
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	eb 09                	jmp    8014ed <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	eb 05                	jmp    8014ed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ed:	89 d0                	mov    %edx,%eax
  8014ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	e8 22 fc ff ff       	call   801128 <fd_lookup>
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 0e                	js     80151b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80150d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801510:	8b 55 0c             	mov    0xc(%ebp),%edx
  801513:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 14             	sub    $0x14,%esp
  801524:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801527:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	53                   	push   %ebx
  80152c:	e8 f7 fb ff ff       	call   801128 <fd_lookup>
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	89 c2                	mov    %eax,%edx
  801536:	85 c0                	test   %eax,%eax
  801538:	78 65                	js     80159f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801544:	ff 30                	pushl  (%eax)
  801546:	e8 33 fc ff ff       	call   80117e <dev_lookup>
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 44                	js     801596 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801559:	75 21                	jne    80157c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80155b:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801560:	8b 40 48             	mov    0x48(%eax),%eax
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	53                   	push   %ebx
  801567:	50                   	push   %eax
  801568:	68 4c 2f 80 00       	push   $0x802f4c
  80156d:	e8 66 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157a:	eb 23                	jmp    80159f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80157c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157f:	8b 52 18             	mov    0x18(%edx),%edx
  801582:	85 d2                	test   %edx,%edx
  801584:	74 14                	je     80159a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	50                   	push   %eax
  80158d:	ff d2                	call   *%edx
  80158f:	89 c2                	mov    %eax,%edx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	eb 09                	jmp    80159f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	89 c2                	mov    %eax,%edx
  801598:	eb 05                	jmp    80159f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80159a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 08             	pushl  0x8(%ebp)
  8015b7:	e8 6c fb ff ff       	call   801128 <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 58                	js     80161d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	ff 30                	pushl  (%eax)
  8015d1:	e8 a8 fb ff ff       	call   80117e <dev_lookup>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 37                	js     801614 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e4:	74 32                	je     801618 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f0:	00 00 00 
	stat->st_isdir = 0;
  8015f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fa:	00 00 00 
	stat->st_dev = dev;
  8015fd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	53                   	push   %ebx
  801607:	ff 75 f0             	pushl  -0x10(%ebp)
  80160a:	ff 50 14             	call   *0x14(%eax)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb 09                	jmp    80161d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801614:	89 c2                	mov    %eax,%edx
  801616:	eb 05                	jmp    80161d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801618:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	56                   	push   %esi
  801628:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	6a 00                	push   $0x0
  80162e:	ff 75 08             	pushl  0x8(%ebp)
  801631:	e8 d6 01 00 00       	call   80180c <open>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 1b                	js     80165a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	e8 5b ff ff ff       	call   8015a6 <fstat>
  80164b:	89 c6                	mov    %eax,%esi
	close(fd);
  80164d:	89 1c 24             	mov    %ebx,(%esp)
  801650:	e8 fd fb ff ff       	call   801252 <close>
	return r;
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	89 f0                	mov    %esi,%eax
}
  80165a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	89 c6                	mov    %eax,%esi
  801668:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80166a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801671:	75 12                	jne    801685 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	6a 01                	push   $0x1
  801678:	e8 f0 10 00 00       	call   80276d <ipc_find_env>
  80167d:	a3 00 60 80 00       	mov    %eax,0x806000
  801682:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801685:	6a 07                	push   $0x7
  801687:	68 00 80 80 00       	push   $0x808000
  80168c:	56                   	push   %esi
  80168d:	ff 35 00 60 80 00    	pushl  0x806000
  801693:	e8 81 10 00 00       	call   802719 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801698:	83 c4 0c             	add    $0xc,%esp
  80169b:	6a 00                	push   $0x0
  80169d:	53                   	push   %ebx
  80169e:	6a 00                	push   $0x0
  8016a0:	e8 0d 10 00 00       	call   8026b2 <ipc_recv>
}
  8016a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b8:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  8016bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c0:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8016cf:	e8 8d ff ff ff       	call   801661 <fsipc>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e2:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8016e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f1:	e8 6b ff ff ff       	call   801661 <fsipc>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801702:	8b 45 08             	mov    0x8(%ebp),%eax
  801705:	8b 40 0c             	mov    0xc(%eax),%eax
  801708:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
  801712:	b8 05 00 00 00       	mov    $0x5,%eax
  801717:	e8 45 ff ff ff       	call   801661 <fsipc>
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 2c                	js     80174c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	68 00 80 80 00       	push   $0x808000
  801728:	53                   	push   %ebx
  801729:	e8 2f f3 ff ff       	call   800a5d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80172e:	a1 80 80 80 00       	mov    0x808080,%eax
  801733:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801739:	a1 84 80 80 00       	mov    0x808084,%eax
  80173e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175a:	8b 55 08             	mov    0x8(%ebp),%edx
  80175d:	8b 52 0c             	mov    0xc(%edx),%edx
  801760:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  801766:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80176b:	50                   	push   %eax
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	68 08 80 80 00       	push   $0x808008
  801774:	e8 76 f4 ff ff       	call   800bef <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801779:	ba 00 00 00 00       	mov    $0x0,%edx
  80177e:	b8 04 00 00 00       	mov    $0x4,%eax
  801783:	e8 d9 fe ff ff       	call   801661 <fsipc>

}
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  80179d:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ad:	e8 af fe ff ff       	call   801661 <fsipc>
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 4b                	js     801803 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b8:	39 c6                	cmp    %eax,%esi
  8017ba:	73 16                	jae    8017d2 <devfile_read+0x48>
  8017bc:	68 bc 2f 80 00       	push   $0x802fbc
  8017c1:	68 c3 2f 80 00       	push   $0x802fc3
  8017c6:	6a 7c                	push   $0x7c
  8017c8:	68 d8 2f 80 00       	push   $0x802fd8
  8017cd:	e8 2d ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017d2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d7:	7e 16                	jle    8017ef <devfile_read+0x65>
  8017d9:	68 e3 2f 80 00       	push   $0x802fe3
  8017de:	68 c3 2f 80 00       	push   $0x802fc3
  8017e3:	6a 7d                	push   $0x7d
  8017e5:	68 d8 2f 80 00       	push   $0x802fd8
  8017ea:	e8 10 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ef:	83 ec 04             	sub    $0x4,%esp
  8017f2:	50                   	push   %eax
  8017f3:	68 00 80 80 00       	push   $0x808000
  8017f8:	ff 75 0c             	pushl  0xc(%ebp)
  8017fb:	e8 ef f3 ff ff       	call   800bef <memmove>
	return r;
  801800:	83 c4 10             	add    $0x10,%esp
}
  801803:	89 d8                	mov    %ebx,%eax
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 20             	sub    $0x20,%esp
  801813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801816:	53                   	push   %ebx
  801817:	e8 08 f2 ff ff       	call   800a24 <strlen>
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801824:	7f 67                	jg     80188d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801826:	83 ec 0c             	sub    $0xc,%esp
  801829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	e8 a7 f8 ff ff       	call   8010d9 <fd_alloc>
  801832:	83 c4 10             	add    $0x10,%esp
		return r;
  801835:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801837:	85 c0                	test   %eax,%eax
  801839:	78 57                	js     801892 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	53                   	push   %ebx
  80183f:	68 00 80 80 00       	push   $0x808000
  801844:	e8 14 f2 ff ff       	call   800a5d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184c:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801851:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801854:	b8 01 00 00 00       	mov    $0x1,%eax
  801859:	e8 03 fe ff ff       	call   801661 <fsipc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	79 14                	jns    80187b <open+0x6f>
		fd_close(fd, 0);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	6a 00                	push   $0x0
  80186c:	ff 75 f4             	pushl  -0xc(%ebp)
  80186f:	e8 5d f9 ff ff       	call   8011d1 <fd_close>
		return r;
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	89 da                	mov    %ebx,%edx
  801879:	eb 17                	jmp    801892 <open+0x86>
	}

	return fd2num(fd);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff 75 f4             	pushl  -0xc(%ebp)
  801881:	e8 2c f8 ff ff       	call   8010b2 <fd2num>
  801886:	89 c2                	mov    %eax,%edx
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	eb 05                	jmp    801892 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801892:	89 d0                	mov    %edx,%eax
  801894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a9:	e8 b3 fd ff ff       	call   801661 <fsipc>
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018bc:	6a 00                	push   $0x0
  8018be:	ff 75 08             	pushl  0x8(%ebp)
  8018c1:	e8 46 ff ff ff       	call   80180c <open>
  8018c6:	89 c7                	mov    %eax,%edi
  8018c8:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	0f 88 97 04 00 00    	js     801d70 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018d9:	83 ec 04             	sub    $0x4,%esp
  8018dc:	68 00 02 00 00       	push   $0x200
  8018e1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018e7:	50                   	push   %eax
  8018e8:	57                   	push   %edi
  8018e9:	e8 31 fb ff ff       	call   80141f <readn>
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018f6:	75 0c                	jne    801904 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018f8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018ff:	45 4c 46 
  801902:	74 33                	je     801937 <spawn+0x87>
		close(fd);
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80190d:	e8 40 f9 ff ff       	call   801252 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801912:	83 c4 0c             	add    $0xc,%esp
  801915:	68 7f 45 4c 46       	push   $0x464c457f
  80191a:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801920:	68 ef 2f 80 00       	push   $0x802fef
  801925:	e8 ae eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801932:	e9 ec 04 00 00       	jmp    801e23 <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801937:	b8 07 00 00 00       	mov    $0x7,%eax
  80193c:	cd 30                	int    $0x30
  80193e:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801944:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80194a:	85 c0                	test   %eax,%eax
  80194c:	0f 88 29 04 00 00    	js     801d7b <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801952:	89 c6                	mov    %eax,%esi
  801954:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80195a:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80195d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801963:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801969:	b9 11 00 00 00       	mov    $0x11,%ecx
  80196e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801970:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801976:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80197c:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801981:	be 00 00 00 00       	mov    $0x0,%esi
  801986:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801989:	eb 13                	jmp    80199e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	50                   	push   %eax
  80198f:	e8 90 f0 ff ff       	call   800a24 <strlen>
  801994:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801998:	83 c3 01             	add    $0x1,%ebx
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019a5:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	75 df                	jne    80198b <spawn+0xdb>
  8019ac:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019b2:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019b8:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019bd:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019bf:	89 fa                	mov    %edi,%edx
  8019c1:	83 e2 fc             	and    $0xfffffffc,%edx
  8019c4:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019cb:	29 c2                	sub    %eax,%edx
  8019cd:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019d3:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019d6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019db:	0f 86 b0 03 00 00    	jbe    801d91 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019e1:	83 ec 04             	sub    $0x4,%esp
  8019e4:	6a 07                	push   $0x7
  8019e6:	68 00 00 40 00       	push   $0x400000
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 6e f4 ff ff       	call   800e60 <sys_page_alloc>
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 88 9e 03 00 00    	js     801d9b <spawn+0x4eb>
  8019fd:	be 00 00 00 00       	mov    $0x0,%esi
  801a02:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a0b:	eb 30                	jmp    801a3d <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a0d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a13:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a19:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a22:	57                   	push   %edi
  801a23:	e8 35 f0 ff ff       	call   800a5d <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a28:	83 c4 04             	add    $0x4,%esp
  801a2b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a2e:	e8 f1 ef ff ff       	call   800a24 <strlen>
  801a33:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a37:	83 c6 01             	add    $0x1,%esi
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a43:	7f c8                	jg     801a0d <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a45:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a4b:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a51:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a58:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a5e:	74 19                	je     801a79 <spawn+0x1c9>
  801a60:	68 7c 30 80 00       	push   $0x80307c
  801a65:	68 c3 2f 80 00       	push   $0x802fc3
  801a6a:	68 f2 00 00 00       	push   $0xf2
  801a6f:	68 09 30 80 00       	push   $0x803009
  801a74:	e8 86 e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a79:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a7f:	89 f8                	mov    %edi,%eax
  801a81:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a86:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a89:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a8f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a92:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a98:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	6a 07                	push   $0x7
  801aa3:	68 00 d0 bf ee       	push   $0xeebfd000
  801aa8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aae:	68 00 00 40 00       	push   $0x400000
  801ab3:	6a 00                	push   $0x0
  801ab5:	e8 e9 f3 ff ff       	call   800ea3 <sys_page_map>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	83 c4 20             	add    $0x20,%esp
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	0f 88 4a 03 00 00    	js     801e11 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	68 00 00 40 00       	push   $0x400000
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 0f f4 ff ff       	call   800ee5 <sys_page_unmap>
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	0f 88 2e 03 00 00    	js     801e11 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ae3:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ae9:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801af0:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801af6:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801afd:	00 00 00 
  801b00:	e9 8a 01 00 00       	jmp    801c8f <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801b05:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b0b:	83 38 01             	cmpl   $0x1,(%eax)
  801b0e:	0f 85 6d 01 00 00    	jne    801c81 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b14:	89 c7                	mov    %eax,%edi
  801b16:	8b 40 18             	mov    0x18(%eax),%eax
  801b19:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b1f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b22:	83 f8 01             	cmp    $0x1,%eax
  801b25:	19 c0                	sbb    %eax,%eax
  801b27:	83 e0 fe             	and    $0xfffffffe,%eax
  801b2a:	83 c0 07             	add    $0x7,%eax
  801b2d:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b33:	89 f8                	mov    %edi,%eax
  801b35:	8b 7f 04             	mov    0x4(%edi),%edi
  801b38:	89 f9                	mov    %edi,%ecx
  801b3a:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b40:	8b 78 10             	mov    0x10(%eax),%edi
  801b43:	8b 70 14             	mov    0x14(%eax),%esi
  801b46:	89 f3                	mov    %esi,%ebx
  801b48:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b4e:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b51:	89 f0                	mov    %esi,%eax
  801b53:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b58:	74 14                	je     801b6e <spawn+0x2be>
		va -= i;
  801b5a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b5c:	01 c3                	add    %eax,%ebx
  801b5e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801b64:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b66:	29 c1                	sub    %eax,%ecx
  801b68:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b73:	e9 f7 00 00 00       	jmp    801c6f <spawn+0x3bf>
		if (i >= filesz) {
  801b78:	39 df                	cmp    %ebx,%edi
  801b7a:	77 27                	ja     801ba3 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b85:	56                   	push   %esi
  801b86:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b8c:	e8 cf f2 ff ff       	call   800e60 <sys_page_alloc>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	85 c0                	test   %eax,%eax
  801b96:	0f 89 c7 00 00 00    	jns    801c63 <spawn+0x3b3>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	e9 09 02 00 00       	jmp    801dac <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ba3:	83 ec 04             	sub    $0x4,%esp
  801ba6:	6a 07                	push   $0x7
  801ba8:	68 00 00 40 00       	push   $0x400000
  801bad:	6a 00                	push   $0x0
  801baf:	e8 ac f2 ff ff       	call   800e60 <sys_page_alloc>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 e3 01 00 00    	js     801da2 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bc8:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bce:	50                   	push   %eax
  801bcf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bd5:	e8 1a f9 ff ff       	call   8014f4 <seek>
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 c1 01 00 00    	js     801da6 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	89 f8                	mov    %edi,%eax
  801bea:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bf0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bf5:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801bfa:	0f 47 c1             	cmova  %ecx,%eax
  801bfd:	50                   	push   %eax
  801bfe:	68 00 00 40 00       	push   $0x400000
  801c03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c09:	e8 11 f8 ff ff       	call   80141f <readn>
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	0f 88 91 01 00 00    	js     801daa <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c19:	83 ec 0c             	sub    $0xc,%esp
  801c1c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c22:	56                   	push   %esi
  801c23:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c29:	68 00 00 40 00       	push   $0x400000
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 6e f2 ff ff       	call   800ea3 <sys_page_map>
  801c35:	83 c4 20             	add    $0x20,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	79 15                	jns    801c51 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801c3c:	50                   	push   %eax
  801c3d:	68 15 30 80 00       	push   $0x803015
  801c42:	68 25 01 00 00       	push   $0x125
  801c47:	68 09 30 80 00       	push   $0x803009
  801c4c:	e8 ae e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c51:	83 ec 08             	sub    $0x8,%esp
  801c54:	68 00 00 40 00       	push   $0x400000
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 85 f2 ff ff       	call   800ee5 <sys_page_unmap>
  801c60:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c63:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c69:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c6f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c75:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c7b:	0f 87 f7 fe ff ff    	ja     801b78 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c81:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c88:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c8f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c96:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c9c:	0f 8c 63 fe ff ff    	jl     801b05 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cab:	e8 a2 f5 ff ff       	call   801252 <close>
  801cb0:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801cb3:	bb 00 08 00 00       	mov    $0x800,%ebx
  801cb8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801cbe:	89 d8                	mov    %ebx,%eax
  801cc0:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	c1 ea 16             	shr    $0x16,%edx
  801cc8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ccf:	f6 c2 01             	test   $0x1,%dl
  801cd2:	74 4b                	je     801d1f <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801cd4:	89 c2                	mov    %eax,%edx
  801cd6:	c1 ea 0c             	shr    $0xc,%edx
  801cd9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801ce0:	f6 c1 01             	test   $0x1,%cl
  801ce3:	74 3a                	je     801d1f <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801ce5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cec:	f6 c6 04             	test   $0x4,%dh
  801cef:	74 2e                	je     801d1f <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801cf1:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801cf8:	8b 0d 90 77 80 00    	mov    0x807790,%ecx
  801cfe:	8b 49 48             	mov    0x48(%ecx),%ecx
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d0a:	52                   	push   %edx
  801d0b:	50                   	push   %eax
  801d0c:	56                   	push   %esi
  801d0d:	50                   	push   %eax
  801d0e:	51                   	push   %ecx
  801d0f:	e8 8f f1 ff ff       	call   800ea3 <sys_page_map>
					if (r < 0)
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	0f 88 ae 00 00 00    	js     801dcd <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801d1f:	83 c3 01             	add    $0x1,%ebx
  801d22:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801d28:	75 94                	jne    801cbe <spawn+0x40e>
  801d2a:	e9 b3 00 00 00       	jmp    801de2 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d2f:	50                   	push   %eax
  801d30:	68 32 30 80 00       	push   $0x803032
  801d35:	68 86 00 00 00       	push   $0x86
  801d3a:	68 09 30 80 00       	push   $0x803009
  801d3f:	e8 bb e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	6a 02                	push   $0x2
  801d49:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d4f:	e8 d3 f1 ff ff       	call   800f27 <sys_env_set_status>
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	79 2b                	jns    801d86 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801d5b:	50                   	push   %eax
  801d5c:	68 4c 30 80 00       	push   $0x80304c
  801d61:	68 89 00 00 00       	push   $0x89
  801d66:	68 09 30 80 00       	push   $0x803009
  801d6b:	e8 8f e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d70:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d76:	e9 a8 00 00 00       	jmp    801e23 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d7b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d81:	e9 9d 00 00 00       	jmp    801e23 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d8c:	e9 92 00 00 00       	jmp    801e23 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d91:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d96:	e9 88 00 00 00       	jmp    801e23 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	e9 81 00 00 00       	jmp    801e23 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da2:	89 c3                	mov    %eax,%ebx
  801da4:	eb 06                	jmp    801dac <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	eb 02                	jmp    801dac <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801daa:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801dac:	83 ec 0c             	sub    $0xc,%esp
  801daf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801db5:	e8 27 f0 ff ff       	call   800de1 <sys_env_destroy>
	close(fd);
  801dba:	83 c4 04             	add    $0x4,%esp
  801dbd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dc3:	e8 8a f4 ff ff       	call   801252 <close>
	return r;
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	eb 56                	jmp    801e23 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801dcd:	50                   	push   %eax
  801dce:	68 63 30 80 00       	push   $0x803063
  801dd3:	68 82 00 00 00       	push   $0x82
  801dd8:	68 09 30 80 00       	push   $0x803009
  801ddd:	e8 1d e6 ff ff       	call   8003ff <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801de2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801de9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dec:	83 ec 08             	sub    $0x8,%esp
  801def:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801df5:	50                   	push   %eax
  801df6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dfc:	e8 68 f1 ff ff       	call   800f69 <sys_env_set_trapframe>
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	0f 89 38 ff ff ff    	jns    801d44 <spawn+0x494>
  801e0c:	e9 1e ff ff ff       	jmp    801d2f <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e11:	83 ec 08             	sub    $0x8,%esp
  801e14:	68 00 00 40 00       	push   $0x400000
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 c5 f0 ff ff       	call   800ee5 <sys_page_unmap>
  801e20:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e23:	89 d8                	mov    %ebx,%eax
  801e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e32:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e3a:	eb 03                	jmp    801e3f <spawnl+0x12>
		argc++;
  801e3c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e3f:	83 c2 04             	add    $0x4,%edx
  801e42:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e46:	75 f4                	jne    801e3c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e48:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e4f:	83 e2 f0             	and    $0xfffffff0,%edx
  801e52:	29 d4                	sub    %edx,%esp
  801e54:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e58:	c1 ea 02             	shr    $0x2,%edx
  801e5b:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e62:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e67:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e6e:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e75:	00 
  801e76:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7d:	eb 0a                	jmp    801e89 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e7f:	83 c0 01             	add    $0x1,%eax
  801e82:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e86:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e89:	39 d0                	cmp    %edx,%eax
  801e8b:	75 f2                	jne    801e7f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e8d:	83 ec 08             	sub    $0x8,%esp
  801e90:	56                   	push   %esi
  801e91:	ff 75 08             	pushl  0x8(%ebp)
  801e94:	e8 17 fa ff ff       	call   8018b0 <spawn>
}
  801e99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5d                   	pop    %ebp
  801e9f:	c3                   	ret    

00801ea0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ea6:	68 a4 30 80 00       	push   $0x8030a4
  801eab:	ff 75 0c             	pushl  0xc(%ebp)
  801eae:	e8 aa eb ff ff       	call   800a5d <strcpy>
	return 0;
}
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 10             	sub    $0x10,%esp
  801ec1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ec4:	53                   	push   %ebx
  801ec5:	e8 dc 08 00 00       	call   8027a6 <pageref>
  801eca:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ecd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ed2:	83 f8 01             	cmp    $0x1,%eax
  801ed5:	75 10                	jne    801ee7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ed7:	83 ec 0c             	sub    $0xc,%esp
  801eda:	ff 73 0c             	pushl  0xc(%ebx)
  801edd:	e8 c0 02 00 00       	call   8021a2 <nsipc_close>
  801ee2:	89 c2                	mov    %eax,%edx
  801ee4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ee7:	89 d0                	mov    %edx,%eax
  801ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ef4:	6a 00                	push   $0x0
  801ef6:	ff 75 10             	pushl  0x10(%ebp)
  801ef9:	ff 75 0c             	pushl  0xc(%ebp)
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	ff 70 0c             	pushl  0xc(%eax)
  801f02:	e8 78 03 00 00       	call   80227f <nsipc_send>
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f0f:	6a 00                	push   $0x0
  801f11:	ff 75 10             	pushl  0x10(%ebp)
  801f14:	ff 75 0c             	pushl  0xc(%ebp)
  801f17:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1a:	ff 70 0c             	pushl  0xc(%eax)
  801f1d:	e8 f1 02 00 00       	call   802213 <nsipc_recv>
}
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f2a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f2d:	52                   	push   %edx
  801f2e:	50                   	push   %eax
  801f2f:	e8 f4 f1 ff ff       	call   801128 <fd_lookup>
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 17                	js     801f52 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3e:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801f44:	39 08                	cmp    %ecx,(%eax)
  801f46:	75 05                	jne    801f4d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f48:	8b 40 0c             	mov    0xc(%eax),%eax
  801f4b:	eb 05                	jmp    801f52 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 1c             	sub    $0x1c,%esp
  801f5c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f61:	50                   	push   %eax
  801f62:	e8 72 f1 ff ff       	call   8010d9 <fd_alloc>
  801f67:	89 c3                	mov    %eax,%ebx
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 1b                	js     801f8b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f70:	83 ec 04             	sub    $0x4,%esp
  801f73:	68 07 04 00 00       	push   $0x407
  801f78:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 de ee ff ff       	call   800e60 <sys_page_alloc>
  801f82:	89 c3                	mov    %eax,%ebx
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	79 10                	jns    801f9b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f8b:	83 ec 0c             	sub    $0xc,%esp
  801f8e:	56                   	push   %esi
  801f8f:	e8 0e 02 00 00       	call   8021a2 <nsipc_close>
		return r;
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	89 d8                	mov    %ebx,%eax
  801f99:	eb 24                	jmp    801fbf <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f9b:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fb0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fb3:	83 ec 0c             	sub    $0xc,%esp
  801fb6:	50                   	push   %eax
  801fb7:	e8 f6 f0 ff ff       	call   8010b2 <fd2num>
  801fbc:	83 c4 10             	add    $0x10,%esp
}
  801fbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc2:	5b                   	pop    %ebx
  801fc3:	5e                   	pop    %esi
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    

00801fc6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcf:	e8 50 ff ff ff       	call   801f24 <fd2sockid>
		return r;
  801fd4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 1f                	js     801ff9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fda:	83 ec 04             	sub    $0x4,%esp
  801fdd:	ff 75 10             	pushl  0x10(%ebp)
  801fe0:	ff 75 0c             	pushl  0xc(%ebp)
  801fe3:	50                   	push   %eax
  801fe4:	e8 12 01 00 00       	call   8020fb <nsipc_accept>
  801fe9:	83 c4 10             	add    $0x10,%esp
		return r;
  801fec:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	78 07                	js     801ff9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ff2:	e8 5d ff ff ff       	call   801f54 <alloc_sockfd>
  801ff7:	89 c1                	mov    %eax,%ecx
}
  801ff9:	89 c8                	mov    %ecx,%eax
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    

00801ffd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802003:	8b 45 08             	mov    0x8(%ebp),%eax
  802006:	e8 19 ff ff ff       	call   801f24 <fd2sockid>
  80200b:	85 c0                	test   %eax,%eax
  80200d:	78 12                	js     802021 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80200f:	83 ec 04             	sub    $0x4,%esp
  802012:	ff 75 10             	pushl  0x10(%ebp)
  802015:	ff 75 0c             	pushl  0xc(%ebp)
  802018:	50                   	push   %eax
  802019:	e8 2d 01 00 00       	call   80214b <nsipc_bind>
  80201e:	83 c4 10             	add    $0x10,%esp
}
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <shutdown>:

int
shutdown(int s, int how)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	e8 f3 fe ff ff       	call   801f24 <fd2sockid>
  802031:	85 c0                	test   %eax,%eax
  802033:	78 0f                	js     802044 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802035:	83 ec 08             	sub    $0x8,%esp
  802038:	ff 75 0c             	pushl  0xc(%ebp)
  80203b:	50                   	push   %eax
  80203c:	e8 3f 01 00 00       	call   802180 <nsipc_shutdown>
  802041:	83 c4 10             	add    $0x10,%esp
}
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	e8 d0 fe ff ff       	call   801f24 <fd2sockid>
  802054:	85 c0                	test   %eax,%eax
  802056:	78 12                	js     80206a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802058:	83 ec 04             	sub    $0x4,%esp
  80205b:	ff 75 10             	pushl  0x10(%ebp)
  80205e:	ff 75 0c             	pushl  0xc(%ebp)
  802061:	50                   	push   %eax
  802062:	e8 55 01 00 00       	call   8021bc <nsipc_connect>
  802067:	83 c4 10             	add    $0x10,%esp
}
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <listen>:

int
listen(int s, int backlog)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802072:	8b 45 08             	mov    0x8(%ebp),%eax
  802075:	e8 aa fe ff ff       	call   801f24 <fd2sockid>
  80207a:	85 c0                	test   %eax,%eax
  80207c:	78 0f                	js     80208d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80207e:	83 ec 08             	sub    $0x8,%esp
  802081:	ff 75 0c             	pushl  0xc(%ebp)
  802084:	50                   	push   %eax
  802085:	e8 67 01 00 00       	call   8021f1 <nsipc_listen>
  80208a:	83 c4 10             	add    $0x10,%esp
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    

0080208f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802095:	ff 75 10             	pushl  0x10(%ebp)
  802098:	ff 75 0c             	pushl  0xc(%ebp)
  80209b:	ff 75 08             	pushl  0x8(%ebp)
  80209e:	e8 3a 02 00 00       	call   8022dd <nsipc_socket>
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 05                	js     8020af <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020aa:	e8 a5 fe ff ff       	call   801f54 <alloc_sockfd>
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	53                   	push   %ebx
  8020b5:	83 ec 04             	sub    $0x4,%esp
  8020b8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020ba:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  8020c1:	75 12                	jne    8020d5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	6a 02                	push   $0x2
  8020c8:	e8 a0 06 00 00       	call   80276d <ipc_find_env>
  8020cd:	a3 04 60 80 00       	mov    %eax,0x806004
  8020d2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020d5:	6a 07                	push   $0x7
  8020d7:	68 00 90 80 00       	push   $0x809000
  8020dc:	53                   	push   %ebx
  8020dd:	ff 35 04 60 80 00    	pushl  0x806004
  8020e3:	e8 31 06 00 00       	call   802719 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020e8:	83 c4 0c             	add    $0xc,%esp
  8020eb:	6a 00                	push   $0x0
  8020ed:	6a 00                	push   $0x0
  8020ef:	6a 00                	push   $0x0
  8020f1:	e8 bc 05 00 00       	call   8026b2 <ipc_recv>
}
  8020f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020f9:	c9                   	leave  
  8020fa:	c3                   	ret    

008020fb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	56                   	push   %esi
  8020ff:	53                   	push   %ebx
  802100:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802103:	8b 45 08             	mov    0x8(%ebp),%eax
  802106:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80210b:	8b 06                	mov    (%esi),%eax
  80210d:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802112:	b8 01 00 00 00       	mov    $0x1,%eax
  802117:	e8 95 ff ff ff       	call   8020b1 <nsipc>
  80211c:	89 c3                	mov    %eax,%ebx
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 20                	js     802142 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802122:	83 ec 04             	sub    $0x4,%esp
  802125:	ff 35 10 90 80 00    	pushl  0x809010
  80212b:	68 00 90 80 00       	push   $0x809000
  802130:	ff 75 0c             	pushl  0xc(%ebp)
  802133:	e8 b7 ea ff ff       	call   800bef <memmove>
		*addrlen = ret->ret_addrlen;
  802138:	a1 10 90 80 00       	mov    0x809010,%eax
  80213d:	89 06                	mov    %eax,(%esi)
  80213f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802142:	89 d8                	mov    %ebx,%eax
  802144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    

0080214b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	53                   	push   %ebx
  80214f:	83 ec 08             	sub    $0x8,%esp
  802152:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802155:	8b 45 08             	mov    0x8(%ebp),%eax
  802158:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80215d:	53                   	push   %ebx
  80215e:	ff 75 0c             	pushl  0xc(%ebp)
  802161:	68 04 90 80 00       	push   $0x809004
  802166:	e8 84 ea ff ff       	call   800bef <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80216b:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  802171:	b8 02 00 00 00       	mov    $0x2,%eax
  802176:	e8 36 ff ff ff       	call   8020b1 <nsipc>
}
  80217b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    

00802180 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802186:	8b 45 08             	mov    0x8(%ebp),%eax
  802189:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  80218e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802191:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802196:	b8 03 00 00 00       	mov    $0x3,%eax
  80219b:	e8 11 ff ff ff       	call   8020b1 <nsipc>
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <nsipc_close>:

int
nsipc_close(int s)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ab:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  8021b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8021b5:	e8 f7 fe ff ff       	call   8020b1 <nsipc>
}
  8021ba:	c9                   	leave  
  8021bb:	c3                   	ret    

008021bc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	53                   	push   %ebx
  8021c0:	83 ec 08             	sub    $0x8,%esp
  8021c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c9:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021ce:	53                   	push   %ebx
  8021cf:	ff 75 0c             	pushl  0xc(%ebp)
  8021d2:	68 04 90 80 00       	push   $0x809004
  8021d7:	e8 13 ea ff ff       	call   800bef <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021dc:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  8021e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8021e7:	e8 c5 fe ff ff       	call   8020b1 <nsipc>
}
  8021ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fa:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  8021ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  802202:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802207:	b8 06 00 00 00       	mov    $0x6,%eax
  80220c:	e8 a0 fe ff ff       	call   8020b1 <nsipc>
}
  802211:	c9                   	leave  
  802212:	c3                   	ret    

00802213 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  802223:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  802229:	8b 45 14             	mov    0x14(%ebp),%eax
  80222c:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802231:	b8 07 00 00 00       	mov    $0x7,%eax
  802236:	e8 76 fe ff ff       	call   8020b1 <nsipc>
  80223b:	89 c3                	mov    %eax,%ebx
  80223d:	85 c0                	test   %eax,%eax
  80223f:	78 35                	js     802276 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802241:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802246:	7f 04                	jg     80224c <nsipc_recv+0x39>
  802248:	39 c6                	cmp    %eax,%esi
  80224a:	7d 16                	jge    802262 <nsipc_recv+0x4f>
  80224c:	68 b0 30 80 00       	push   $0x8030b0
  802251:	68 c3 2f 80 00       	push   $0x802fc3
  802256:	6a 62                	push   $0x62
  802258:	68 c5 30 80 00       	push   $0x8030c5
  80225d:	e8 9d e1 ff ff       	call   8003ff <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802262:	83 ec 04             	sub    $0x4,%esp
  802265:	50                   	push   %eax
  802266:	68 00 90 80 00       	push   $0x809000
  80226b:	ff 75 0c             	pushl  0xc(%ebp)
  80226e:	e8 7c e9 ff ff       	call   800bef <memmove>
  802273:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802276:	89 d8                	mov    %ebx,%eax
  802278:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227b:	5b                   	pop    %ebx
  80227c:	5e                   	pop    %esi
  80227d:	5d                   	pop    %ebp
  80227e:	c3                   	ret    

0080227f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	53                   	push   %ebx
  802283:	83 ec 04             	sub    $0x4,%esp
  802286:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802289:	8b 45 08             	mov    0x8(%ebp),%eax
  80228c:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  802291:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802297:	7e 16                	jle    8022af <nsipc_send+0x30>
  802299:	68 d1 30 80 00       	push   $0x8030d1
  80229e:	68 c3 2f 80 00       	push   $0x802fc3
  8022a3:	6a 6d                	push   $0x6d
  8022a5:	68 c5 30 80 00       	push   $0x8030c5
  8022aa:	e8 50 e1 ff ff       	call   8003ff <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022af:	83 ec 04             	sub    $0x4,%esp
  8022b2:	53                   	push   %ebx
  8022b3:	ff 75 0c             	pushl  0xc(%ebp)
  8022b6:	68 0c 90 80 00       	push   $0x80900c
  8022bb:	e8 2f e9 ff ff       	call   800bef <memmove>
	nsipcbuf.send.req_size = size;
  8022c0:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  8022c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022c9:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  8022ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8022d3:	e8 d9 fd ff ff       	call   8020b1 <nsipc>
}
  8022d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022db:	c9                   	leave  
  8022dc:	c3                   	ret    

008022dd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e6:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  8022eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ee:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  8022f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8022f6:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  8022fb:	b8 09 00 00 00       	mov    $0x9,%eax
  802300:	e8 ac fd ff ff       	call   8020b1 <nsipc>
}
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	56                   	push   %esi
  80230b:	53                   	push   %ebx
  80230c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80230f:	83 ec 0c             	sub    $0xc,%esp
  802312:	ff 75 08             	pushl  0x8(%ebp)
  802315:	e8 a8 ed ff ff       	call   8010c2 <fd2data>
  80231a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80231c:	83 c4 08             	add    $0x8,%esp
  80231f:	68 dd 30 80 00       	push   $0x8030dd
  802324:	53                   	push   %ebx
  802325:	e8 33 e7 ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80232a:	8b 46 04             	mov    0x4(%esi),%eax
  80232d:	2b 06                	sub    (%esi),%eax
  80232f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802335:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80233c:	00 00 00 
	stat->st_dev = &devpipe;
  80233f:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  802346:	57 80 00 
	return 0;
}
  802349:	b8 00 00 00 00       	mov    $0x0,%eax
  80234e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802351:	5b                   	pop    %ebx
  802352:	5e                   	pop    %esi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    

00802355 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	53                   	push   %ebx
  802359:	83 ec 0c             	sub    $0xc,%esp
  80235c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80235f:	53                   	push   %ebx
  802360:	6a 00                	push   $0x0
  802362:	e8 7e eb ff ff       	call   800ee5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802367:	89 1c 24             	mov    %ebx,(%esp)
  80236a:	e8 53 ed ff ff       	call   8010c2 <fd2data>
  80236f:	83 c4 08             	add    $0x8,%esp
  802372:	50                   	push   %eax
  802373:	6a 00                	push   $0x0
  802375:	e8 6b eb ff ff       	call   800ee5 <sys_page_unmap>
}
  80237a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80237d:	c9                   	leave  
  80237e:	c3                   	ret    

0080237f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
  802382:	57                   	push   %edi
  802383:	56                   	push   %esi
  802384:	53                   	push   %ebx
  802385:	83 ec 1c             	sub    $0x1c,%esp
  802388:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80238b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80238d:	a1 90 77 80 00       	mov    0x807790,%eax
  802392:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802395:	83 ec 0c             	sub    $0xc,%esp
  802398:	ff 75 e0             	pushl  -0x20(%ebp)
  80239b:	e8 06 04 00 00       	call   8027a6 <pageref>
  8023a0:	89 c3                	mov    %eax,%ebx
  8023a2:	89 3c 24             	mov    %edi,(%esp)
  8023a5:	e8 fc 03 00 00       	call   8027a6 <pageref>
  8023aa:	83 c4 10             	add    $0x10,%esp
  8023ad:	39 c3                	cmp    %eax,%ebx
  8023af:	0f 94 c1             	sete   %cl
  8023b2:	0f b6 c9             	movzbl %cl,%ecx
  8023b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8023b8:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8023be:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023c1:	39 ce                	cmp    %ecx,%esi
  8023c3:	74 1b                	je     8023e0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8023c5:	39 c3                	cmp    %eax,%ebx
  8023c7:	75 c4                	jne    80238d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8023c9:	8b 42 58             	mov    0x58(%edx),%eax
  8023cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023cf:	50                   	push   %eax
  8023d0:	56                   	push   %esi
  8023d1:	68 e4 30 80 00       	push   $0x8030e4
  8023d6:	e8 fd e0 ff ff       	call   8004d8 <cprintf>
  8023db:	83 c4 10             	add    $0x10,%esp
  8023de:	eb ad                	jmp    80238d <_pipeisclosed+0xe>
	}
}
  8023e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e6:	5b                   	pop    %ebx
  8023e7:	5e                   	pop    %esi
  8023e8:	5f                   	pop    %edi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    

008023eb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	57                   	push   %edi
  8023ef:	56                   	push   %esi
  8023f0:	53                   	push   %ebx
  8023f1:	83 ec 28             	sub    $0x28,%esp
  8023f4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023f7:	56                   	push   %esi
  8023f8:	e8 c5 ec ff ff       	call   8010c2 <fd2data>
  8023fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ff:	83 c4 10             	add    $0x10,%esp
  802402:	bf 00 00 00 00       	mov    $0x0,%edi
  802407:	eb 4b                	jmp    802454 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802409:	89 da                	mov    %ebx,%edx
  80240b:	89 f0                	mov    %esi,%eax
  80240d:	e8 6d ff ff ff       	call   80237f <_pipeisclosed>
  802412:	85 c0                	test   %eax,%eax
  802414:	75 48                	jne    80245e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802416:	e8 26 ea ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80241b:	8b 43 04             	mov    0x4(%ebx),%eax
  80241e:	8b 0b                	mov    (%ebx),%ecx
  802420:	8d 51 20             	lea    0x20(%ecx),%edx
  802423:	39 d0                	cmp    %edx,%eax
  802425:	73 e2                	jae    802409 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802427:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80242a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80242e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802431:	89 c2                	mov    %eax,%edx
  802433:	c1 fa 1f             	sar    $0x1f,%edx
  802436:	89 d1                	mov    %edx,%ecx
  802438:	c1 e9 1b             	shr    $0x1b,%ecx
  80243b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80243e:	83 e2 1f             	and    $0x1f,%edx
  802441:	29 ca                	sub    %ecx,%edx
  802443:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802447:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80244b:	83 c0 01             	add    $0x1,%eax
  80244e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802451:	83 c7 01             	add    $0x1,%edi
  802454:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802457:	75 c2                	jne    80241b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802459:	8b 45 10             	mov    0x10(%ebp),%eax
  80245c:	eb 05                	jmp    802463 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80245e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802463:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802466:	5b                   	pop    %ebx
  802467:	5e                   	pop    %esi
  802468:	5f                   	pop    %edi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    

0080246b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	57                   	push   %edi
  80246f:	56                   	push   %esi
  802470:	53                   	push   %ebx
  802471:	83 ec 18             	sub    $0x18,%esp
  802474:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802477:	57                   	push   %edi
  802478:	e8 45 ec ff ff       	call   8010c2 <fd2data>
  80247d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80247f:	83 c4 10             	add    $0x10,%esp
  802482:	bb 00 00 00 00       	mov    $0x0,%ebx
  802487:	eb 3d                	jmp    8024c6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802489:	85 db                	test   %ebx,%ebx
  80248b:	74 04                	je     802491 <devpipe_read+0x26>
				return i;
  80248d:	89 d8                	mov    %ebx,%eax
  80248f:	eb 44                	jmp    8024d5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802491:	89 f2                	mov    %esi,%edx
  802493:	89 f8                	mov    %edi,%eax
  802495:	e8 e5 fe ff ff       	call   80237f <_pipeisclosed>
  80249a:	85 c0                	test   %eax,%eax
  80249c:	75 32                	jne    8024d0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80249e:	e8 9e e9 ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024a3:	8b 06                	mov    (%esi),%eax
  8024a5:	3b 46 04             	cmp    0x4(%esi),%eax
  8024a8:	74 df                	je     802489 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024aa:	99                   	cltd   
  8024ab:	c1 ea 1b             	shr    $0x1b,%edx
  8024ae:	01 d0                	add    %edx,%eax
  8024b0:	83 e0 1f             	and    $0x1f,%eax
  8024b3:	29 d0                	sub    %edx,%eax
  8024b5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8024ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024bd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8024c0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024c3:	83 c3 01             	add    $0x1,%ebx
  8024c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8024c9:	75 d8                	jne    8024a3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8024ce:	eb 05                	jmp    8024d5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024d0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8024d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    

008024dd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8024dd:	55                   	push   %ebp
  8024de:	89 e5                	mov    %esp,%ebp
  8024e0:	56                   	push   %esi
  8024e1:	53                   	push   %ebx
  8024e2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e8:	50                   	push   %eax
  8024e9:	e8 eb eb ff ff       	call   8010d9 <fd_alloc>
  8024ee:	83 c4 10             	add    $0x10,%esp
  8024f1:	89 c2                	mov    %eax,%edx
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	0f 88 2c 01 00 00    	js     802627 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024fb:	83 ec 04             	sub    $0x4,%esp
  8024fe:	68 07 04 00 00       	push   $0x407
  802503:	ff 75 f4             	pushl  -0xc(%ebp)
  802506:	6a 00                	push   $0x0
  802508:	e8 53 e9 ff ff       	call   800e60 <sys_page_alloc>
  80250d:	83 c4 10             	add    $0x10,%esp
  802510:	89 c2                	mov    %eax,%edx
  802512:	85 c0                	test   %eax,%eax
  802514:	0f 88 0d 01 00 00    	js     802627 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80251a:	83 ec 0c             	sub    $0xc,%esp
  80251d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802520:	50                   	push   %eax
  802521:	e8 b3 eb ff ff       	call   8010d9 <fd_alloc>
  802526:	89 c3                	mov    %eax,%ebx
  802528:	83 c4 10             	add    $0x10,%esp
  80252b:	85 c0                	test   %eax,%eax
  80252d:	0f 88 e2 00 00 00    	js     802615 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802533:	83 ec 04             	sub    $0x4,%esp
  802536:	68 07 04 00 00       	push   $0x407
  80253b:	ff 75 f0             	pushl  -0x10(%ebp)
  80253e:	6a 00                	push   $0x0
  802540:	e8 1b e9 ff ff       	call   800e60 <sys_page_alloc>
  802545:	89 c3                	mov    %eax,%ebx
  802547:	83 c4 10             	add    $0x10,%esp
  80254a:	85 c0                	test   %eax,%eax
  80254c:	0f 88 c3 00 00 00    	js     802615 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802552:	83 ec 0c             	sub    $0xc,%esp
  802555:	ff 75 f4             	pushl  -0xc(%ebp)
  802558:	e8 65 eb ff ff       	call   8010c2 <fd2data>
  80255d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80255f:	83 c4 0c             	add    $0xc,%esp
  802562:	68 07 04 00 00       	push   $0x407
  802567:	50                   	push   %eax
  802568:	6a 00                	push   $0x0
  80256a:	e8 f1 e8 ff ff       	call   800e60 <sys_page_alloc>
  80256f:	89 c3                	mov    %eax,%ebx
  802571:	83 c4 10             	add    $0x10,%esp
  802574:	85 c0                	test   %eax,%eax
  802576:	0f 88 89 00 00 00    	js     802605 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80257c:	83 ec 0c             	sub    $0xc,%esp
  80257f:	ff 75 f0             	pushl  -0x10(%ebp)
  802582:	e8 3b eb ff ff       	call   8010c2 <fd2data>
  802587:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80258e:	50                   	push   %eax
  80258f:	6a 00                	push   $0x0
  802591:	56                   	push   %esi
  802592:	6a 00                	push   $0x0
  802594:	e8 0a e9 ff ff       	call   800ea3 <sys_page_map>
  802599:	89 c3                	mov    %eax,%ebx
  80259b:	83 c4 20             	add    $0x20,%esp
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	78 55                	js     8025f7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025a2:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  8025a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ab:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025b7:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  8025bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025c0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025c5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025cc:	83 ec 0c             	sub    $0xc,%esp
  8025cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8025d2:	e8 db ea ff ff       	call   8010b2 <fd2num>
  8025d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025da:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8025dc:	83 c4 04             	add    $0x4,%esp
  8025df:	ff 75 f0             	pushl  -0x10(%ebp)
  8025e2:	e8 cb ea ff ff       	call   8010b2 <fd2num>
  8025e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025ea:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025ed:	83 c4 10             	add    $0x10,%esp
  8025f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8025f5:	eb 30                	jmp    802627 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8025f7:	83 ec 08             	sub    $0x8,%esp
  8025fa:	56                   	push   %esi
  8025fb:	6a 00                	push   $0x0
  8025fd:	e8 e3 e8 ff ff       	call   800ee5 <sys_page_unmap>
  802602:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802605:	83 ec 08             	sub    $0x8,%esp
  802608:	ff 75 f0             	pushl  -0x10(%ebp)
  80260b:	6a 00                	push   $0x0
  80260d:	e8 d3 e8 ff ff       	call   800ee5 <sys_page_unmap>
  802612:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802615:	83 ec 08             	sub    $0x8,%esp
  802618:	ff 75 f4             	pushl  -0xc(%ebp)
  80261b:	6a 00                	push   $0x0
  80261d:	e8 c3 e8 ff ff       	call   800ee5 <sys_page_unmap>
  802622:	83 c4 10             	add    $0x10,%esp
  802625:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802627:	89 d0                	mov    %edx,%eax
  802629:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80262c:	5b                   	pop    %ebx
  80262d:	5e                   	pop    %esi
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    

00802630 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802639:	50                   	push   %eax
  80263a:	ff 75 08             	pushl  0x8(%ebp)
  80263d:	e8 e6 ea ff ff       	call   801128 <fd_lookup>
  802642:	83 c4 10             	add    $0x10,%esp
  802645:	85 c0                	test   %eax,%eax
  802647:	78 18                	js     802661 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802649:	83 ec 0c             	sub    $0xc,%esp
  80264c:	ff 75 f4             	pushl  -0xc(%ebp)
  80264f:	e8 6e ea ff ff       	call   8010c2 <fd2data>
	return _pipeisclosed(fd, p);
  802654:	89 c2                	mov    %eax,%edx
  802656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802659:	e8 21 fd ff ff       	call   80237f <_pipeisclosed>
  80265e:	83 c4 10             	add    $0x10,%esp
}
  802661:	c9                   	leave  
  802662:	c3                   	ret    

00802663 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802663:	55                   	push   %ebp
  802664:	89 e5                	mov    %esp,%ebp
  802666:	56                   	push   %esi
  802667:	53                   	push   %ebx
  802668:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80266b:	85 f6                	test   %esi,%esi
  80266d:	75 16                	jne    802685 <wait+0x22>
  80266f:	68 fc 30 80 00       	push   $0x8030fc
  802674:	68 c3 2f 80 00       	push   $0x802fc3
  802679:	6a 09                	push   $0x9
  80267b:	68 07 31 80 00       	push   $0x803107
  802680:	e8 7a dd ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  802685:	89 f3                	mov    %esi,%ebx
  802687:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80268d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802690:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802696:	eb 05                	jmp    80269d <wait+0x3a>
		sys_yield();
  802698:	e8 a4 e7 ff ff       	call   800e41 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80269d:	8b 43 48             	mov    0x48(%ebx),%eax
  8026a0:	39 c6                	cmp    %eax,%esi
  8026a2:	75 07                	jne    8026ab <wait+0x48>
  8026a4:	8b 43 54             	mov    0x54(%ebx),%eax
  8026a7:	85 c0                	test   %eax,%eax
  8026a9:	75 ed                	jne    802698 <wait+0x35>
		sys_yield();
}
  8026ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026ae:	5b                   	pop    %ebx
  8026af:	5e                   	pop    %esi
  8026b0:	5d                   	pop    %ebp
  8026b1:	c3                   	ret    

008026b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026b2:	55                   	push   %ebp
  8026b3:	89 e5                	mov    %esp,%ebp
  8026b5:	56                   	push   %esi
  8026b6:	53                   	push   %ebx
  8026b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8026ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8026c0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8026c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8026c7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8026ca:	83 ec 0c             	sub    $0xc,%esp
  8026cd:	50                   	push   %eax
  8026ce:	e8 3d e9 ff ff       	call   801010 <sys_ipc_recv>

	if (from_env_store != NULL)
  8026d3:	83 c4 10             	add    $0x10,%esp
  8026d6:	85 f6                	test   %esi,%esi
  8026d8:	74 14                	je     8026ee <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8026da:	ba 00 00 00 00       	mov    $0x0,%edx
  8026df:	85 c0                	test   %eax,%eax
  8026e1:	78 09                	js     8026ec <ipc_recv+0x3a>
  8026e3:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8026e9:	8b 52 74             	mov    0x74(%edx),%edx
  8026ec:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8026ee:	85 db                	test   %ebx,%ebx
  8026f0:	74 14                	je     802706 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8026f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	78 09                	js     802704 <ipc_recv+0x52>
  8026fb:	8b 15 90 77 80 00    	mov    0x807790,%edx
  802701:	8b 52 78             	mov    0x78(%edx),%edx
  802704:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802706:	85 c0                	test   %eax,%eax
  802708:	78 08                	js     802712 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80270a:	a1 90 77 80 00       	mov    0x807790,%eax
  80270f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802712:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802715:	5b                   	pop    %ebx
  802716:	5e                   	pop    %esi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    

00802719 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802719:	55                   	push   %ebp
  80271a:	89 e5                	mov    %esp,%ebp
  80271c:	57                   	push   %edi
  80271d:	56                   	push   %esi
  80271e:	53                   	push   %ebx
  80271f:	83 ec 0c             	sub    $0xc,%esp
  802722:	8b 7d 08             	mov    0x8(%ebp),%edi
  802725:	8b 75 0c             	mov    0xc(%ebp),%esi
  802728:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80272b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80272d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802732:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802735:	ff 75 14             	pushl  0x14(%ebp)
  802738:	53                   	push   %ebx
  802739:	56                   	push   %esi
  80273a:	57                   	push   %edi
  80273b:	e8 ad e8 ff ff       	call   800fed <sys_ipc_try_send>

		if (err < 0) {
  802740:	83 c4 10             	add    $0x10,%esp
  802743:	85 c0                	test   %eax,%eax
  802745:	79 1e                	jns    802765 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802747:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80274a:	75 07                	jne    802753 <ipc_send+0x3a>
				sys_yield();
  80274c:	e8 f0 e6 ff ff       	call   800e41 <sys_yield>
  802751:	eb e2                	jmp    802735 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802753:	50                   	push   %eax
  802754:	68 12 31 80 00       	push   $0x803112
  802759:	6a 49                	push   $0x49
  80275b:	68 1f 31 80 00       	push   $0x80311f
  802760:	e8 9a dc ff ff       	call   8003ff <_panic>
		}

	} while (err < 0);

}
  802765:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802768:	5b                   	pop    %ebx
  802769:	5e                   	pop    %esi
  80276a:	5f                   	pop    %edi
  80276b:	5d                   	pop    %ebp
  80276c:	c3                   	ret    

0080276d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80276d:	55                   	push   %ebp
  80276e:	89 e5                	mov    %esp,%ebp
  802770:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802773:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802778:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80277b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802781:	8b 52 50             	mov    0x50(%edx),%edx
  802784:	39 ca                	cmp    %ecx,%edx
  802786:	75 0d                	jne    802795 <ipc_find_env+0x28>
			return envs[i].env_id;
  802788:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80278b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802790:	8b 40 48             	mov    0x48(%eax),%eax
  802793:	eb 0f                	jmp    8027a4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802795:	83 c0 01             	add    $0x1,%eax
  802798:	3d 00 04 00 00       	cmp    $0x400,%eax
  80279d:	75 d9                	jne    802778 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80279f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027a4:	5d                   	pop    %ebp
  8027a5:	c3                   	ret    

008027a6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027a6:	55                   	push   %ebp
  8027a7:	89 e5                	mov    %esp,%ebp
  8027a9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027ac:	89 d0                	mov    %edx,%eax
  8027ae:	c1 e8 16             	shr    $0x16,%eax
  8027b1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027b8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027bd:	f6 c1 01             	test   $0x1,%cl
  8027c0:	74 1d                	je     8027df <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027c2:	c1 ea 0c             	shr    $0xc,%edx
  8027c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027cc:	f6 c2 01             	test   $0x1,%dl
  8027cf:	74 0e                	je     8027df <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027d1:	c1 ea 0c             	shr    $0xc,%edx
  8027d4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027db:	ef 
  8027dc:	0f b7 c0             	movzwl %ax,%eax
}
  8027df:	5d                   	pop    %ebp
  8027e0:	c3                   	ret    
  8027e1:	66 90                	xchg   %ax,%ax
  8027e3:	66 90                	xchg   %ax,%ax
  8027e5:	66 90                	xchg   %ax,%ax
  8027e7:	66 90                	xchg   %ax,%ax
  8027e9:	66 90                	xchg   %ax,%ax
  8027eb:	66 90                	xchg   %ax,%ax
  8027ed:	66 90                	xchg   %ax,%ax
  8027ef:	90                   	nop

008027f0 <__udivdi3>:
  8027f0:	55                   	push   %ebp
  8027f1:	57                   	push   %edi
  8027f2:	56                   	push   %esi
  8027f3:	53                   	push   %ebx
  8027f4:	83 ec 1c             	sub    $0x1c,%esp
  8027f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802803:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802807:	85 f6                	test   %esi,%esi
  802809:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80280d:	89 ca                	mov    %ecx,%edx
  80280f:	89 f8                	mov    %edi,%eax
  802811:	75 3d                	jne    802850 <__udivdi3+0x60>
  802813:	39 cf                	cmp    %ecx,%edi
  802815:	0f 87 c5 00 00 00    	ja     8028e0 <__udivdi3+0xf0>
  80281b:	85 ff                	test   %edi,%edi
  80281d:	89 fd                	mov    %edi,%ebp
  80281f:	75 0b                	jne    80282c <__udivdi3+0x3c>
  802821:	b8 01 00 00 00       	mov    $0x1,%eax
  802826:	31 d2                	xor    %edx,%edx
  802828:	f7 f7                	div    %edi
  80282a:	89 c5                	mov    %eax,%ebp
  80282c:	89 c8                	mov    %ecx,%eax
  80282e:	31 d2                	xor    %edx,%edx
  802830:	f7 f5                	div    %ebp
  802832:	89 c1                	mov    %eax,%ecx
  802834:	89 d8                	mov    %ebx,%eax
  802836:	89 cf                	mov    %ecx,%edi
  802838:	f7 f5                	div    %ebp
  80283a:	89 c3                	mov    %eax,%ebx
  80283c:	89 d8                	mov    %ebx,%eax
  80283e:	89 fa                	mov    %edi,%edx
  802840:	83 c4 1c             	add    $0x1c,%esp
  802843:	5b                   	pop    %ebx
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	90                   	nop
  802849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802850:	39 ce                	cmp    %ecx,%esi
  802852:	77 74                	ja     8028c8 <__udivdi3+0xd8>
  802854:	0f bd fe             	bsr    %esi,%edi
  802857:	83 f7 1f             	xor    $0x1f,%edi
  80285a:	0f 84 98 00 00 00    	je     8028f8 <__udivdi3+0x108>
  802860:	bb 20 00 00 00       	mov    $0x20,%ebx
  802865:	89 f9                	mov    %edi,%ecx
  802867:	89 c5                	mov    %eax,%ebp
  802869:	29 fb                	sub    %edi,%ebx
  80286b:	d3 e6                	shl    %cl,%esi
  80286d:	89 d9                	mov    %ebx,%ecx
  80286f:	d3 ed                	shr    %cl,%ebp
  802871:	89 f9                	mov    %edi,%ecx
  802873:	d3 e0                	shl    %cl,%eax
  802875:	09 ee                	or     %ebp,%esi
  802877:	89 d9                	mov    %ebx,%ecx
  802879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80287d:	89 d5                	mov    %edx,%ebp
  80287f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802883:	d3 ed                	shr    %cl,%ebp
  802885:	89 f9                	mov    %edi,%ecx
  802887:	d3 e2                	shl    %cl,%edx
  802889:	89 d9                	mov    %ebx,%ecx
  80288b:	d3 e8                	shr    %cl,%eax
  80288d:	09 c2                	or     %eax,%edx
  80288f:	89 d0                	mov    %edx,%eax
  802891:	89 ea                	mov    %ebp,%edx
  802893:	f7 f6                	div    %esi
  802895:	89 d5                	mov    %edx,%ebp
  802897:	89 c3                	mov    %eax,%ebx
  802899:	f7 64 24 0c          	mull   0xc(%esp)
  80289d:	39 d5                	cmp    %edx,%ebp
  80289f:	72 10                	jb     8028b1 <__udivdi3+0xc1>
  8028a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028a5:	89 f9                	mov    %edi,%ecx
  8028a7:	d3 e6                	shl    %cl,%esi
  8028a9:	39 c6                	cmp    %eax,%esi
  8028ab:	73 07                	jae    8028b4 <__udivdi3+0xc4>
  8028ad:	39 d5                	cmp    %edx,%ebp
  8028af:	75 03                	jne    8028b4 <__udivdi3+0xc4>
  8028b1:	83 eb 01             	sub    $0x1,%ebx
  8028b4:	31 ff                	xor    %edi,%edi
  8028b6:	89 d8                	mov    %ebx,%eax
  8028b8:	89 fa                	mov    %edi,%edx
  8028ba:	83 c4 1c             	add    $0x1c,%esp
  8028bd:	5b                   	pop    %ebx
  8028be:	5e                   	pop    %esi
  8028bf:	5f                   	pop    %edi
  8028c0:	5d                   	pop    %ebp
  8028c1:	c3                   	ret    
  8028c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028c8:	31 ff                	xor    %edi,%edi
  8028ca:	31 db                	xor    %ebx,%ebx
  8028cc:	89 d8                	mov    %ebx,%eax
  8028ce:	89 fa                	mov    %edi,%edx
  8028d0:	83 c4 1c             	add    $0x1c,%esp
  8028d3:	5b                   	pop    %ebx
  8028d4:	5e                   	pop    %esi
  8028d5:	5f                   	pop    %edi
  8028d6:	5d                   	pop    %ebp
  8028d7:	c3                   	ret    
  8028d8:	90                   	nop
  8028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	89 d8                	mov    %ebx,%eax
  8028e2:	f7 f7                	div    %edi
  8028e4:	31 ff                	xor    %edi,%edi
  8028e6:	89 c3                	mov    %eax,%ebx
  8028e8:	89 d8                	mov    %ebx,%eax
  8028ea:	89 fa                	mov    %edi,%edx
  8028ec:	83 c4 1c             	add    $0x1c,%esp
  8028ef:	5b                   	pop    %ebx
  8028f0:	5e                   	pop    %esi
  8028f1:	5f                   	pop    %edi
  8028f2:	5d                   	pop    %ebp
  8028f3:	c3                   	ret    
  8028f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028f8:	39 ce                	cmp    %ecx,%esi
  8028fa:	72 0c                	jb     802908 <__udivdi3+0x118>
  8028fc:	31 db                	xor    %ebx,%ebx
  8028fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802902:	0f 87 34 ff ff ff    	ja     80283c <__udivdi3+0x4c>
  802908:	bb 01 00 00 00       	mov    $0x1,%ebx
  80290d:	e9 2a ff ff ff       	jmp    80283c <__udivdi3+0x4c>
  802912:	66 90                	xchg   %ax,%ax
  802914:	66 90                	xchg   %ax,%ax
  802916:	66 90                	xchg   %ax,%ax
  802918:	66 90                	xchg   %ax,%ax
  80291a:	66 90                	xchg   %ax,%ax
  80291c:	66 90                	xchg   %ax,%ax
  80291e:	66 90                	xchg   %ax,%ax

00802920 <__umoddi3>:
  802920:	55                   	push   %ebp
  802921:	57                   	push   %edi
  802922:	56                   	push   %esi
  802923:	53                   	push   %ebx
  802924:	83 ec 1c             	sub    $0x1c,%esp
  802927:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80292b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80292f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802933:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802937:	85 d2                	test   %edx,%edx
  802939:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80293d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802941:	89 f3                	mov    %esi,%ebx
  802943:	89 3c 24             	mov    %edi,(%esp)
  802946:	89 74 24 04          	mov    %esi,0x4(%esp)
  80294a:	75 1c                	jne    802968 <__umoddi3+0x48>
  80294c:	39 f7                	cmp    %esi,%edi
  80294e:	76 50                	jbe    8029a0 <__umoddi3+0x80>
  802950:	89 c8                	mov    %ecx,%eax
  802952:	89 f2                	mov    %esi,%edx
  802954:	f7 f7                	div    %edi
  802956:	89 d0                	mov    %edx,%eax
  802958:	31 d2                	xor    %edx,%edx
  80295a:	83 c4 1c             	add    $0x1c,%esp
  80295d:	5b                   	pop    %ebx
  80295e:	5e                   	pop    %esi
  80295f:	5f                   	pop    %edi
  802960:	5d                   	pop    %ebp
  802961:	c3                   	ret    
  802962:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802968:	39 f2                	cmp    %esi,%edx
  80296a:	89 d0                	mov    %edx,%eax
  80296c:	77 52                	ja     8029c0 <__umoddi3+0xa0>
  80296e:	0f bd ea             	bsr    %edx,%ebp
  802971:	83 f5 1f             	xor    $0x1f,%ebp
  802974:	75 5a                	jne    8029d0 <__umoddi3+0xb0>
  802976:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80297a:	0f 82 e0 00 00 00    	jb     802a60 <__umoddi3+0x140>
  802980:	39 0c 24             	cmp    %ecx,(%esp)
  802983:	0f 86 d7 00 00 00    	jbe    802a60 <__umoddi3+0x140>
  802989:	8b 44 24 08          	mov    0x8(%esp),%eax
  80298d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802991:	83 c4 1c             	add    $0x1c,%esp
  802994:	5b                   	pop    %ebx
  802995:	5e                   	pop    %esi
  802996:	5f                   	pop    %edi
  802997:	5d                   	pop    %ebp
  802998:	c3                   	ret    
  802999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029a0:	85 ff                	test   %edi,%edi
  8029a2:	89 fd                	mov    %edi,%ebp
  8029a4:	75 0b                	jne    8029b1 <__umoddi3+0x91>
  8029a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029ab:	31 d2                	xor    %edx,%edx
  8029ad:	f7 f7                	div    %edi
  8029af:	89 c5                	mov    %eax,%ebp
  8029b1:	89 f0                	mov    %esi,%eax
  8029b3:	31 d2                	xor    %edx,%edx
  8029b5:	f7 f5                	div    %ebp
  8029b7:	89 c8                	mov    %ecx,%eax
  8029b9:	f7 f5                	div    %ebp
  8029bb:	89 d0                	mov    %edx,%eax
  8029bd:	eb 99                	jmp    802958 <__umoddi3+0x38>
  8029bf:	90                   	nop
  8029c0:	89 c8                	mov    %ecx,%eax
  8029c2:	89 f2                	mov    %esi,%edx
  8029c4:	83 c4 1c             	add    $0x1c,%esp
  8029c7:	5b                   	pop    %ebx
  8029c8:	5e                   	pop    %esi
  8029c9:	5f                   	pop    %edi
  8029ca:	5d                   	pop    %ebp
  8029cb:	c3                   	ret    
  8029cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029d0:	8b 34 24             	mov    (%esp),%esi
  8029d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8029d8:	89 e9                	mov    %ebp,%ecx
  8029da:	29 ef                	sub    %ebp,%edi
  8029dc:	d3 e0                	shl    %cl,%eax
  8029de:	89 f9                	mov    %edi,%ecx
  8029e0:	89 f2                	mov    %esi,%edx
  8029e2:	d3 ea                	shr    %cl,%edx
  8029e4:	89 e9                	mov    %ebp,%ecx
  8029e6:	09 c2                	or     %eax,%edx
  8029e8:	89 d8                	mov    %ebx,%eax
  8029ea:	89 14 24             	mov    %edx,(%esp)
  8029ed:	89 f2                	mov    %esi,%edx
  8029ef:	d3 e2                	shl    %cl,%edx
  8029f1:	89 f9                	mov    %edi,%ecx
  8029f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029fb:	d3 e8                	shr    %cl,%eax
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	89 c6                	mov    %eax,%esi
  802a01:	d3 e3                	shl    %cl,%ebx
  802a03:	89 f9                	mov    %edi,%ecx
  802a05:	89 d0                	mov    %edx,%eax
  802a07:	d3 e8                	shr    %cl,%eax
  802a09:	89 e9                	mov    %ebp,%ecx
  802a0b:	09 d8                	or     %ebx,%eax
  802a0d:	89 d3                	mov    %edx,%ebx
  802a0f:	89 f2                	mov    %esi,%edx
  802a11:	f7 34 24             	divl   (%esp)
  802a14:	89 d6                	mov    %edx,%esi
  802a16:	d3 e3                	shl    %cl,%ebx
  802a18:	f7 64 24 04          	mull   0x4(%esp)
  802a1c:	39 d6                	cmp    %edx,%esi
  802a1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a22:	89 d1                	mov    %edx,%ecx
  802a24:	89 c3                	mov    %eax,%ebx
  802a26:	72 08                	jb     802a30 <__umoddi3+0x110>
  802a28:	75 11                	jne    802a3b <__umoddi3+0x11b>
  802a2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a2e:	73 0b                	jae    802a3b <__umoddi3+0x11b>
  802a30:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a34:	1b 14 24             	sbb    (%esp),%edx
  802a37:	89 d1                	mov    %edx,%ecx
  802a39:	89 c3                	mov    %eax,%ebx
  802a3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a3f:	29 da                	sub    %ebx,%edx
  802a41:	19 ce                	sbb    %ecx,%esi
  802a43:	89 f9                	mov    %edi,%ecx
  802a45:	89 f0                	mov    %esi,%eax
  802a47:	d3 e0                	shl    %cl,%eax
  802a49:	89 e9                	mov    %ebp,%ecx
  802a4b:	d3 ea                	shr    %cl,%edx
  802a4d:	89 e9                	mov    %ebp,%ecx
  802a4f:	d3 ee                	shr    %cl,%esi
  802a51:	09 d0                	or     %edx,%eax
  802a53:	89 f2                	mov    %esi,%edx
  802a55:	83 c4 1c             	add    $0x1c,%esp
  802a58:	5b                   	pop    %ebx
  802a59:	5e                   	pop    %esi
  802a5a:	5f                   	pop    %edi
  802a5b:	5d                   	pop    %ebp
  802a5c:	c3                   	ret    
  802a5d:	8d 76 00             	lea    0x0(%esi),%esi
  802a60:	29 f9                	sub    %edi,%ecx
  802a62:	19 d6                	sbb    %edx,%esi
  802a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a6c:	e9 18 ff ff ff       	jmp    802989 <__umoddi3+0x69>
