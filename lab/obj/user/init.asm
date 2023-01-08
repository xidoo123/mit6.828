
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
  80006d:	68 40 2a 80 00       	push   $0x802a40
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
  80009c:	68 08 2b 80 00       	push   $0x802b08
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 4f 2a 80 00       	push   $0x802a4f
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
  8000d8:	68 44 2b 80 00       	push   $0x802b44
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 66 2a 80 00       	push   $0x802a66
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 7c 2a 80 00       	push   $0x802a7c
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
  80011e:	68 88 2a 80 00       	push   $0x802a88
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 89 2a 80 00       	push   $0x802a89
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
  800158:	68 8b 2a 80 00       	push   $0x802a8b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 8f 2a 80 00 	movl   $0x802a8f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 96 10 00 00       	call   801210 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 a1 2a 80 00       	push   $0x802aa1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ae 2a 80 00       	push   $0x802aae
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 ba 2a 80 00       	push   $0x802aba
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ae 2a 80 00       	push   $0x802aae
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 a6 10 00 00       	call   801260 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 d4 2a 80 00       	push   $0x802ad4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ae 2a 80 00       	push   $0x802aae
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 dc 2a 80 00       	push   $0x802adc
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 f0 2a 80 00       	push   $0x802af0
  8001ea:	68 ef 2a 80 00       	push   $0x802aef
  8001ef:	e8 f7 1b 00 00       	call   801deb <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 f3 2a 80 00       	push   $0x802af3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 0a 24 00 00       	call   802621 <wait>
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
  80022c:	68 73 2b 80 00       	push   $0x802b73
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
  8002fc:	e8 4b 10 00 00       	call   80134c <read>
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
  800326:	e8 bb 0d 00 00       	call   8010e6 <fd_lookup>
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
  80034f:	e8 43 0d 00 00       	call   801097 <fd_alloc>
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
  800391:	e8 da 0c 00 00       	call   801070 <fd2num>
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
  8003eb:	e8 4b 0e 00 00       	call   80123b <close_all>
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
  80041d:	68 8c 2b 80 00       	push   $0x802b8c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 b5 30 80 00 	movl   $0x8030b5,(%esp)
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
  80053b:	e8 60 22 00 00       	call   8027a0 <__udivdi3>
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
  80057e:	e8 4d 23 00 00       	call   8028d0 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
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
  800682:	ff 24 85 00 2d 80 00 	jmp    *0x802d00(,%eax,4)
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
  800746:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 c7 2b 80 00       	push   $0x802bc7
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
  80076a:	68 95 2f 80 00       	push   $0x802f95
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
  80078e:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
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
  800e09:	68 bf 2e 80 00       	push   $0x802ebf
  800e0e:	6a 23                	push   $0x23
  800e10:	68 dc 2e 80 00       	push   $0x802edc
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
  800e8a:	68 bf 2e 80 00       	push   $0x802ebf
  800e8f:	6a 23                	push   $0x23
  800e91:	68 dc 2e 80 00       	push   $0x802edc
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
  800ecc:	68 bf 2e 80 00       	push   $0x802ebf
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 dc 2e 80 00       	push   $0x802edc
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
  800f0e:	68 bf 2e 80 00       	push   $0x802ebf
  800f13:	6a 23                	push   $0x23
  800f15:	68 dc 2e 80 00       	push   $0x802edc
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
  800f50:	68 bf 2e 80 00       	push   $0x802ebf
  800f55:	6a 23                	push   $0x23
  800f57:	68 dc 2e 80 00       	push   $0x802edc
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
  800f92:	68 bf 2e 80 00       	push   $0x802ebf
  800f97:	6a 23                	push   $0x23
  800f99:	68 dc 2e 80 00       	push   $0x802edc
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
  800fd4:	68 bf 2e 80 00       	push   $0x802ebf
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 dc 2e 80 00       	push   $0x802edc
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
  801038:	68 bf 2e 80 00       	push   $0x802ebf
  80103d:	6a 23                	push   $0x23
  80103f:	68 dc 2e 80 00       	push   $0x802edc
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

00801070 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	05 00 00 00 30       	add    $0x30000000,%eax
  80108b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801090:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	c1 ea 16             	shr    $0x16,%edx
  8010a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ae:	f6 c2 01             	test   $0x1,%dl
  8010b1:	74 11                	je     8010c4 <fd_alloc+0x2d>
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	c1 ea 0c             	shr    $0xc,%edx
  8010b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	75 09                	jne    8010cd <fd_alloc+0x36>
			*fd_store = fd;
  8010c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cb:	eb 17                	jmp    8010e4 <fd_alloc+0x4d>
  8010cd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d7:	75 c9                	jne    8010a2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ec:	83 f8 1f             	cmp    $0x1f,%eax
  8010ef:	77 36                	ja     801127 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f1:	c1 e0 0c             	shl    $0xc,%eax
  8010f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	c1 ea 16             	shr    $0x16,%edx
  8010fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801105:	f6 c2 01             	test   $0x1,%dl
  801108:	74 24                	je     80112e <fd_lookup+0x48>
  80110a:	89 c2                	mov    %eax,%edx
  80110c:	c1 ea 0c             	shr    $0xc,%edx
  80110f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801116:	f6 c2 01             	test   $0x1,%dl
  801119:	74 1a                	je     801135 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80111b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111e:	89 02                	mov    %eax,(%edx)
	return 0;
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
  801125:	eb 13                	jmp    80113a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112c:	eb 0c                	jmp    80113a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801133:	eb 05                	jmp    80113a <fd_lookup+0x54>
  801135:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801145:	ba 68 2f 80 00       	mov    $0x802f68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80114a:	eb 13                	jmp    80115f <dev_lookup+0x23>
  80114c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80114f:	39 08                	cmp    %ecx,(%eax)
  801151:	75 0c                	jne    80115f <dev_lookup+0x23>
			*dev = devtab[i];
  801153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801156:	89 01                	mov    %eax,(%ecx)
			return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
  80115d:	eb 2e                	jmp    80118d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80115f:	8b 02                	mov    (%edx),%eax
  801161:	85 c0                	test   %eax,%eax
  801163:	75 e7                	jne    80114c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801165:	a1 90 77 80 00       	mov    0x807790,%eax
  80116a:	8b 40 48             	mov    0x48(%eax),%eax
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	51                   	push   %ecx
  801171:	50                   	push   %eax
  801172:	68 ec 2e 80 00       	push   $0x802eec
  801177:	e8 5c f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80117c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 10             	sub    $0x10,%esp
  801197:	8b 75 08             	mov    0x8(%ebp),%esi
  80119a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a7:	c1 e8 0c             	shr    $0xc,%eax
  8011aa:	50                   	push   %eax
  8011ab:	e8 36 ff ff ff       	call   8010e6 <fd_lookup>
  8011b0:	83 c4 08             	add    $0x8,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 05                	js     8011bc <fd_close+0x2d>
	    || fd != fd2)
  8011b7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ba:	74 0c                	je     8011c8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011bc:	84 db                	test   %bl,%bl
  8011be:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c3:	0f 44 c2             	cmove  %edx,%eax
  8011c6:	eb 41                	jmp    801209 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	ff 36                	pushl  (%esi)
  8011d1:	e8 66 ff ff ff       	call   80113c <dev_lookup>
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 1a                	js     8011f9 <fd_close+0x6a>
		if (dev->dev_close)
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 0b                	je     8011f9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	56                   	push   %esi
  8011f2:	ff d0                	call   *%eax
  8011f4:	89 c3                	mov    %eax,%ebx
  8011f6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	6a 00                	push   $0x0
  8011ff:	e8 e1 fc ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	89 d8                	mov    %ebx,%eax
}
  801209:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	ff 75 08             	pushl  0x8(%ebp)
  80121d:	e8 c4 fe ff ff       	call   8010e6 <fd_lookup>
  801222:	83 c4 08             	add    $0x8,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 10                	js     801239 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	6a 01                	push   $0x1
  80122e:	ff 75 f4             	pushl  -0xc(%ebp)
  801231:	e8 59 ff ff ff       	call   80118f <fd_close>
  801236:	83 c4 10             	add    $0x10,%esp
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <close_all>:

void
close_all(void)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	53                   	push   %ebx
  80124b:	e8 c0 ff ff ff       	call   801210 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801250:	83 c3 01             	add    $0x1,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	83 fb 20             	cmp    $0x20,%ebx
  801259:	75 ec                	jne    801247 <close_all+0xc>
		close(i);
}
  80125b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 2c             	sub    $0x2c,%esp
  801269:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80126c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	ff 75 08             	pushl  0x8(%ebp)
  801273:	e8 6e fe ff ff       	call   8010e6 <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 88 c1 00 00 00    	js     801344 <dup+0xe4>
		return r;
	close(newfdnum);
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	56                   	push   %esi
  801287:	e8 84 ff ff ff       	call   801210 <close>

	newfd = INDEX2FD(newfdnum);
  80128c:	89 f3                	mov    %esi,%ebx
  80128e:	c1 e3 0c             	shl    $0xc,%ebx
  801291:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801297:	83 c4 04             	add    $0x4,%esp
  80129a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129d:	e8 de fd ff ff       	call   801080 <fd2data>
  8012a2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012a4:	89 1c 24             	mov    %ebx,(%esp)
  8012a7:	e8 d4 fd ff ff       	call   801080 <fd2data>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b2:	89 f8                	mov    %edi,%eax
  8012b4:	c1 e8 16             	shr    $0x16,%eax
  8012b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012be:	a8 01                	test   $0x1,%al
  8012c0:	74 37                	je     8012f9 <dup+0x99>
  8012c2:	89 f8                	mov    %edi,%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
  8012c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 26                	je     8012f9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e2:	50                   	push   %eax
  8012e3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e6:	6a 00                	push   $0x0
  8012e8:	57                   	push   %edi
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 b3 fb ff ff       	call   800ea3 <sys_page_map>
  8012f0:	89 c7                	mov    %eax,%edi
  8012f2:	83 c4 20             	add    $0x20,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 2e                	js     801327 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012fc:	89 d0                	mov    %edx,%eax
  8012fe:	c1 e8 0c             	shr    $0xc,%eax
  801301:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	25 07 0e 00 00       	and    $0xe07,%eax
  801310:	50                   	push   %eax
  801311:	53                   	push   %ebx
  801312:	6a 00                	push   $0x0
  801314:	52                   	push   %edx
  801315:	6a 00                	push   $0x0
  801317:	e8 87 fb ff ff       	call   800ea3 <sys_page_map>
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801321:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801323:	85 ff                	test   %edi,%edi
  801325:	79 1d                	jns    801344 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	53                   	push   %ebx
  80132b:	6a 00                	push   $0x0
  80132d:	e8 b3 fb ff ff       	call   800ee5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801332:	83 c4 08             	add    $0x8,%esp
  801335:	ff 75 d4             	pushl  -0x2c(%ebp)
  801338:	6a 00                	push   $0x0
  80133a:	e8 a6 fb ff ff       	call   800ee5 <sys_page_unmap>
	return r;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 f8                	mov    %edi,%eax
}
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 14             	sub    $0x14,%esp
  801353:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801356:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	53                   	push   %ebx
  80135b:	e8 86 fd ff ff       	call   8010e6 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	89 c2                	mov    %eax,%edx
  801365:	85 c0                	test   %eax,%eax
  801367:	78 6d                	js     8013d6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	ff 30                	pushl  (%eax)
  801375:	e8 c2 fd ff ff       	call   80113c <dev_lookup>
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 4c                	js     8013cd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801381:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801384:	8b 42 08             	mov    0x8(%edx),%eax
  801387:	83 e0 03             	and    $0x3,%eax
  80138a:	83 f8 01             	cmp    $0x1,%eax
  80138d:	75 21                	jne    8013b0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138f:	a1 90 77 80 00       	mov    0x807790,%eax
  801394:	8b 40 48             	mov    0x48(%eax),%eax
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	53                   	push   %ebx
  80139b:	50                   	push   %eax
  80139c:	68 2d 2f 80 00       	push   $0x802f2d
  8013a1:	e8 32 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ae:	eb 26                	jmp    8013d6 <read+0x8a>
	}
	if (!dev->dev_read)
  8013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b3:	8b 40 08             	mov    0x8(%eax),%eax
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	74 17                	je     8013d1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ba:	83 ec 04             	sub    $0x4,%esp
  8013bd:	ff 75 10             	pushl  0x10(%ebp)
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	52                   	push   %edx
  8013c4:	ff d0                	call   *%eax
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	eb 09                	jmp    8013d6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	eb 05                	jmp    8013d6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013d6:	89 d0                	mov    %edx,%eax
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	57                   	push   %edi
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f1:	eb 21                	jmp    801414 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	89 f0                	mov    %esi,%eax
  8013f8:	29 d8                	sub    %ebx,%eax
  8013fa:	50                   	push   %eax
  8013fb:	89 d8                	mov    %ebx,%eax
  8013fd:	03 45 0c             	add    0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	57                   	push   %edi
  801402:	e8 45 ff ff ff       	call   80134c <read>
		if (m < 0)
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 10                	js     80141e <readn+0x41>
			return m;
		if (m == 0)
  80140e:	85 c0                	test   %eax,%eax
  801410:	74 0a                	je     80141c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801412:	01 c3                	add    %eax,%ebx
  801414:	39 f3                	cmp    %esi,%ebx
  801416:	72 db                	jb     8013f3 <readn+0x16>
  801418:	89 d8                	mov    %ebx,%eax
  80141a:	eb 02                	jmp    80141e <readn+0x41>
  80141c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 14             	sub    $0x14,%esp
  80142d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	53                   	push   %ebx
  801435:	e8 ac fc ff ff       	call   8010e6 <fd_lookup>
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 68                	js     8014ab <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 e8 fc ff ff       	call   80113c <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 47                	js     8014a2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801462:	75 21                	jne    801485 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801464:	a1 90 77 80 00       	mov    0x807790,%eax
  801469:	8b 40 48             	mov    0x48(%eax),%eax
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	53                   	push   %ebx
  801470:	50                   	push   %eax
  801471:	68 49 2f 80 00       	push   $0x802f49
  801476:	e8 5d f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801483:	eb 26                	jmp    8014ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801485:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801488:	8b 52 0c             	mov    0xc(%edx),%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	74 17                	je     8014a6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	ff 75 10             	pushl  0x10(%ebp)
  801495:	ff 75 0c             	pushl  0xc(%ebp)
  801498:	50                   	push   %eax
  801499:	ff d2                	call   *%edx
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	eb 09                	jmp    8014ab <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	eb 05                	jmp    8014ab <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ab:	89 d0                	mov    %edx,%eax
  8014ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 08             	pushl  0x8(%ebp)
  8014bf:	e8 22 fc ff ff       	call   8010e6 <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 0e                	js     8014d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 14             	sub    $0x14,%esp
  8014e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	53                   	push   %ebx
  8014ea:	e8 f7 fb ff ff       	call   8010e6 <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 65                	js     80155d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	ff 30                	pushl  (%eax)
  801504:	e8 33 fc ff ff       	call   80113c <dev_lookup>
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 44                	js     801554 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801513:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801517:	75 21                	jne    80153a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801519:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 0c 2f 80 00       	push   $0x802f0c
  80152b:	e8 a8 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801538:	eb 23                	jmp    80155d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80153a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153d:	8b 52 18             	mov    0x18(%edx),%edx
  801540:	85 d2                	test   %edx,%edx
  801542:	74 14                	je     801558 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	ff 75 0c             	pushl  0xc(%ebp)
  80154a:	50                   	push   %eax
  80154b:	ff d2                	call   *%edx
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb 09                	jmp    80155d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801554:	89 c2                	mov    %eax,%edx
  801556:	eb 05                	jmp    80155d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801558:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 75 08             	pushl  0x8(%ebp)
  801575:	e8 6c fb ff ff       	call   8010e6 <fd_lookup>
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 58                	js     8015db <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	ff 30                	pushl  (%eax)
  80158f:	e8 a8 fb ff ff       	call   80113c <dev_lookup>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 37                	js     8015d2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80159b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a2:	74 32                	je     8015d6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ae:	00 00 00 
	stat->st_isdir = 0;
  8015b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b8:	00 00 00 
	stat->st_dev = dev;
  8015bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c8:	ff 50 14             	call   *0x14(%eax)
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 09                	jmp    8015db <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	eb 05                	jmp    8015db <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	6a 00                	push   $0x0
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 d6 01 00 00       	call   8017ca <open>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 1b                	js     801618 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	50                   	push   %eax
  801604:	e8 5b ff ff ff       	call   801564 <fstat>
  801609:	89 c6                	mov    %eax,%esi
	close(fd);
  80160b:	89 1c 24             	mov    %ebx,(%esp)
  80160e:	e8 fd fb ff ff       	call   801210 <close>
	return r;
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	89 f0                	mov    %esi,%eax
}
  801618:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	89 c6                	mov    %eax,%esi
  801626:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801628:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80162f:	75 12                	jne    801643 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	6a 01                	push   $0x1
  801636:	e8 f0 10 00 00       	call   80272b <ipc_find_env>
  80163b:	a3 00 60 80 00       	mov    %eax,0x806000
  801640:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801643:	6a 07                	push   $0x7
  801645:	68 00 80 80 00       	push   $0x808000
  80164a:	56                   	push   %esi
  80164b:	ff 35 00 60 80 00    	pushl  0x806000
  801651:	e8 81 10 00 00       	call   8026d7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801656:	83 c4 0c             	add    $0xc,%esp
  801659:	6a 00                	push   $0x0
  80165b:	53                   	push   %ebx
  80165c:	6a 00                	push   $0x0
  80165e:	e8 0d 10 00 00       	call   802670 <ipc_recv>
}
  801663:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	8b 40 0c             	mov    0xc(%eax),%eax
  801676:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80167b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167e:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801683:	ba 00 00 00 00       	mov    $0x0,%edx
  801688:	b8 02 00 00 00       	mov    $0x2,%eax
  80168d:	e8 8d ff ff ff       	call   80161f <fsipc>
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a0:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8016af:	e8 6b ff ff ff       	call   80161f <fsipc>
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 04             	sub    $0x4,%esp
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c6:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d5:	e8 45 ff ff ff       	call   80161f <fsipc>
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 2c                	js     80170a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	68 00 80 80 00       	push   $0x808000
  8016e6:	53                   	push   %ebx
  8016e7:	e8 71 f3 ff ff       	call   800a5d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ec:	a1 80 80 80 00       	mov    0x808080,%eax
  8016f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f7:	a1 84 80 80 00       	mov    0x808084,%eax
  8016fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 0c             	sub    $0xc,%esp
  801715:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801718:	8b 55 08             	mov    0x8(%ebp),%edx
  80171b:	8b 52 0c             	mov    0xc(%edx),%edx
  80171e:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  801724:	a3 04 80 80 00       	mov    %eax,0x808004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801729:	50                   	push   %eax
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	68 08 80 80 00       	push   $0x808008
  801732:	e8 b8 f4 ff ff       	call   800bef <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801737:	ba 00 00 00 00       	mov    $0x0,%edx
  80173c:	b8 04 00 00 00       	mov    $0x4,%eax
  801741:	e8 d9 fe ff ff       	call   80161f <fsipc>

}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
  80174d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 40 0c             	mov    0xc(%eax),%eax
  801756:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  80175b:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801761:	ba 00 00 00 00       	mov    $0x0,%edx
  801766:	b8 03 00 00 00       	mov    $0x3,%eax
  80176b:	e8 af fe ff ff       	call   80161f <fsipc>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	85 c0                	test   %eax,%eax
  801774:	78 4b                	js     8017c1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801776:	39 c6                	cmp    %eax,%esi
  801778:	73 16                	jae    801790 <devfile_read+0x48>
  80177a:	68 7c 2f 80 00       	push   $0x802f7c
  80177f:	68 83 2f 80 00       	push   $0x802f83
  801784:	6a 7c                	push   $0x7c
  801786:	68 98 2f 80 00       	push   $0x802f98
  80178b:	e8 6f ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  801790:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801795:	7e 16                	jle    8017ad <devfile_read+0x65>
  801797:	68 a3 2f 80 00       	push   $0x802fa3
  80179c:	68 83 2f 80 00       	push   $0x802f83
  8017a1:	6a 7d                	push   $0x7d
  8017a3:	68 98 2f 80 00       	push   $0x802f98
  8017a8:	e8 52 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ad:	83 ec 04             	sub    $0x4,%esp
  8017b0:	50                   	push   %eax
  8017b1:	68 00 80 80 00       	push   $0x808000
  8017b6:	ff 75 0c             	pushl  0xc(%ebp)
  8017b9:	e8 31 f4 ff ff       	call   800bef <memmove>
	return r;
  8017be:	83 c4 10             	add    $0x10,%esp
}
  8017c1:	89 d8                	mov    %ebx,%eax
  8017c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 20             	sub    $0x20,%esp
  8017d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017d4:	53                   	push   %ebx
  8017d5:	e8 4a f2 ff ff       	call   800a24 <strlen>
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017e2:	7f 67                	jg     80184b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	e8 a7 f8 ff ff       	call   801097 <fd_alloc>
  8017f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8017f3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 57                	js     801850 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	68 00 80 80 00       	push   $0x808000
  801802:	e8 56 f2 ff ff       	call   800a5d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180a:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80180f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801812:	b8 01 00 00 00       	mov    $0x1,%eax
  801817:	e8 03 fe ff ff       	call   80161f <fsipc>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	79 14                	jns    801839 <open+0x6f>
		fd_close(fd, 0);
  801825:	83 ec 08             	sub    $0x8,%esp
  801828:	6a 00                	push   $0x0
  80182a:	ff 75 f4             	pushl  -0xc(%ebp)
  80182d:	e8 5d f9 ff ff       	call   80118f <fd_close>
		return r;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	89 da                	mov    %ebx,%edx
  801837:	eb 17                	jmp    801850 <open+0x86>
	}

	return fd2num(fd);
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	ff 75 f4             	pushl  -0xc(%ebp)
  80183f:	e8 2c f8 ff ff       	call   801070 <fd2num>
  801844:	89 c2                	mov    %eax,%edx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	eb 05                	jmp    801850 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80184b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801850:	89 d0                	mov    %edx,%eax
  801852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	b8 08 00 00 00       	mov    $0x8,%eax
  801867:	e8 b3 fd ff ff       	call   80161f <fsipc>
}
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	57                   	push   %edi
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
  801874:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80187a:	6a 00                	push   $0x0
  80187c:	ff 75 08             	pushl  0x8(%ebp)
  80187f:	e8 46 ff ff ff       	call   8017ca <open>
  801884:	89 c7                	mov    %eax,%edi
  801886:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	0f 88 97 04 00 00    	js     801d2e <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801897:	83 ec 04             	sub    $0x4,%esp
  80189a:	68 00 02 00 00       	push   $0x200
  80189f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	57                   	push   %edi
  8018a7:	e8 31 fb ff ff       	call   8013dd <readn>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018b4:	75 0c                	jne    8018c2 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018b6:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018bd:	45 4c 46 
  8018c0:	74 33                	je     8018f5 <spawn+0x87>
		close(fd);
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018cb:	e8 40 f9 ff ff       	call   801210 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018d0:	83 c4 0c             	add    $0xc,%esp
  8018d3:	68 7f 45 4c 46       	push   $0x464c457f
  8018d8:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018de:	68 af 2f 80 00       	push   $0x802faf
  8018e3:	e8 f0 eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8018f0:	e9 ec 04 00 00       	jmp    801de1 <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018f5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018fa:	cd 30                	int    $0x30
  8018fc:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801902:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801908:	85 c0                	test   %eax,%eax
  80190a:	0f 88 29 04 00 00    	js     801d39 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801910:	89 c6                	mov    %eax,%esi
  801912:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801918:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80191b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801921:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801927:	b9 11 00 00 00       	mov    $0x11,%ecx
  80192c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80192e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801934:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80193a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80193f:	be 00 00 00 00       	mov    $0x0,%esi
  801944:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801947:	eb 13                	jmp    80195c <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	50                   	push   %eax
  80194d:	e8 d2 f0 ff ff       	call   800a24 <strlen>
  801952:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801956:	83 c3 01             	add    $0x1,%ebx
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801963:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801966:	85 c0                	test   %eax,%eax
  801968:	75 df                	jne    801949 <spawn+0xdb>
  80196a:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801970:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801976:	bf 00 10 40 00       	mov    $0x401000,%edi
  80197b:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80197d:	89 fa                	mov    %edi,%edx
  80197f:	83 e2 fc             	and    $0xfffffffc,%edx
  801982:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801989:	29 c2                	sub    %eax,%edx
  80198b:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801991:	8d 42 f8             	lea    -0x8(%edx),%eax
  801994:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801999:	0f 86 b0 03 00 00    	jbe    801d4f <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	6a 07                	push   $0x7
  8019a4:	68 00 00 40 00       	push   $0x400000
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 b0 f4 ff ff       	call   800e60 <sys_page_alloc>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	0f 88 9e 03 00 00    	js     801d59 <spawn+0x4eb>
  8019bb:	be 00 00 00 00       	mov    $0x0,%esi
  8019c0:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019c9:	eb 30                	jmp    8019fb <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019cb:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019d1:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019d7:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019e0:	57                   	push   %edi
  8019e1:	e8 77 f0 ff ff       	call   800a5d <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019e6:	83 c4 04             	add    $0x4,%esp
  8019e9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019ec:	e8 33 f0 ff ff       	call   800a24 <strlen>
  8019f1:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8019f5:	83 c6 01             	add    $0x1,%esi
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a01:	7f c8                	jg     8019cb <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a03:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a09:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a0f:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a16:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a1c:	74 19                	je     801a37 <spawn+0x1c9>
  801a1e:	68 3c 30 80 00       	push   $0x80303c
  801a23:	68 83 2f 80 00       	push   $0x802f83
  801a28:	68 f2 00 00 00       	push   $0xf2
  801a2d:	68 c9 2f 80 00       	push   $0x802fc9
  801a32:	e8 c8 e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a37:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a3d:	89 f8                	mov    %edi,%eax
  801a3f:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a44:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a47:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a4d:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a50:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a56:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	6a 07                	push   $0x7
  801a61:	68 00 d0 bf ee       	push   $0xeebfd000
  801a66:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a6c:	68 00 00 40 00       	push   $0x400000
  801a71:	6a 00                	push   $0x0
  801a73:	e8 2b f4 ff ff       	call   800ea3 <sys_page_map>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 20             	add    $0x20,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	0f 88 4a 03 00 00    	js     801dcf <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	68 00 00 40 00       	push   $0x400000
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 51 f4 ff ff       	call   800ee5 <sys_page_unmap>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	0f 88 2e 03 00 00    	js     801dcf <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801aa1:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801aa7:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801aae:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ab4:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801abb:	00 00 00 
  801abe:	e9 8a 01 00 00       	jmp    801c4d <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801ac3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ac9:	83 38 01             	cmpl   $0x1,(%eax)
  801acc:	0f 85 6d 01 00 00    	jne    801c3f <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ad2:	89 c7                	mov    %eax,%edi
  801ad4:	8b 40 18             	mov    0x18(%eax),%eax
  801ad7:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801add:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ae0:	83 f8 01             	cmp    $0x1,%eax
  801ae3:	19 c0                	sbb    %eax,%eax
  801ae5:	83 e0 fe             	and    $0xfffffffe,%eax
  801ae8:	83 c0 07             	add    $0x7,%eax
  801aeb:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801af1:	89 f8                	mov    %edi,%eax
  801af3:	8b 7f 04             	mov    0x4(%edi),%edi
  801af6:	89 f9                	mov    %edi,%ecx
  801af8:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801afe:	8b 78 10             	mov    0x10(%eax),%edi
  801b01:	8b 70 14             	mov    0x14(%eax),%esi
  801b04:	89 f3                	mov    %esi,%ebx
  801b06:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b0c:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b0f:	89 f0                	mov    %esi,%eax
  801b11:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b16:	74 14                	je     801b2c <spawn+0x2be>
		va -= i;
  801b18:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b1a:	01 c3                	add    %eax,%ebx
  801b1c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801b22:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b24:	29 c1                	sub    %eax,%ecx
  801b26:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b31:	e9 f7 00 00 00       	jmp    801c2d <spawn+0x3bf>
		if (i >= filesz) {
  801b36:	39 df                	cmp    %ebx,%edi
  801b38:	77 27                	ja     801b61 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b43:	56                   	push   %esi
  801b44:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b4a:	e8 11 f3 ff ff       	call   800e60 <sys_page_alloc>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 89 c7 00 00 00    	jns    801c21 <spawn+0x3b3>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	e9 09 02 00 00       	jmp    801d6a <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b61:	83 ec 04             	sub    $0x4,%esp
  801b64:	6a 07                	push   $0x7
  801b66:	68 00 00 40 00       	push   $0x400000
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 ee f2 ff ff       	call   800e60 <sys_page_alloc>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	0f 88 e3 01 00 00    	js     801d60 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b7d:	83 ec 08             	sub    $0x8,%esp
  801b80:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b86:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801b8c:	50                   	push   %eax
  801b8d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b93:	e8 1a f9 ff ff       	call   8014b2 <seek>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 c1 01 00 00    	js     801d64 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ba3:	83 ec 04             	sub    $0x4,%esp
  801ba6:	89 f8                	mov    %edi,%eax
  801ba8:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bb3:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801bb8:	0f 47 c1             	cmova  %ecx,%eax
  801bbb:	50                   	push   %eax
  801bbc:	68 00 00 40 00       	push   $0x400000
  801bc1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc7:	e8 11 f8 ff ff       	call   8013dd <readn>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 91 01 00 00    	js     801d68 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801be0:	56                   	push   %esi
  801be1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801be7:	68 00 00 40 00       	push   $0x400000
  801bec:	6a 00                	push   $0x0
  801bee:	e8 b0 f2 ff ff       	call   800ea3 <sys_page_map>
  801bf3:	83 c4 20             	add    $0x20,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	79 15                	jns    801c0f <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801bfa:	50                   	push   %eax
  801bfb:	68 d5 2f 80 00       	push   $0x802fd5
  801c00:	68 25 01 00 00       	push   $0x125
  801c05:	68 c9 2f 80 00       	push   $0x802fc9
  801c0a:	e8 f0 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c0f:	83 ec 08             	sub    $0x8,%esp
  801c12:	68 00 00 40 00       	push   $0x400000
  801c17:	6a 00                	push   $0x0
  801c19:	e8 c7 f2 ff ff       	call   800ee5 <sys_page_unmap>
  801c1e:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c21:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c27:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c2d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c33:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c39:	0f 87 f7 fe ff ff    	ja     801b36 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c3f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c46:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c4d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c54:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c5a:	0f 8c 63 fe ff ff    	jl     801ac3 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c60:	83 ec 0c             	sub    $0xc,%esp
  801c63:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c69:	e8 a2 f5 ff ff       	call   801210 <close>
  801c6e:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801c71:	bb 00 08 00 00       	mov    $0x800,%ebx
  801c76:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801c81:	89 c2                	mov    %eax,%edx
  801c83:	c1 ea 16             	shr    $0x16,%edx
  801c86:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c8d:	f6 c2 01             	test   $0x1,%dl
  801c90:	74 4b                	je     801cdd <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	c1 ea 0c             	shr    $0xc,%edx
  801c97:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801c9e:	f6 c1 01             	test   $0x1,%cl
  801ca1:	74 3a                	je     801cdd <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801ca3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801caa:	f6 c6 04             	test   $0x4,%dh
  801cad:	74 2e                	je     801cdd <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801caf:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801cb6:	8b 0d 90 77 80 00    	mov    0x807790,%ecx
  801cbc:	8b 49 48             	mov    0x48(%ecx),%ecx
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801cc8:	52                   	push   %edx
  801cc9:	50                   	push   %eax
  801cca:	56                   	push   %esi
  801ccb:	50                   	push   %eax
  801ccc:	51                   	push   %ecx
  801ccd:	e8 d1 f1 ff ff       	call   800ea3 <sys_page_map>
					if (r < 0)
  801cd2:	83 c4 20             	add    $0x20,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	0f 88 ae 00 00 00    	js     801d8b <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801cdd:	83 c3 01             	add    $0x1,%ebx
  801ce0:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801ce6:	75 94                	jne    801c7c <spawn+0x40e>
  801ce8:	e9 b3 00 00 00       	jmp    801da0 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801ced:	50                   	push   %eax
  801cee:	68 f2 2f 80 00       	push   $0x802ff2
  801cf3:	68 86 00 00 00       	push   $0x86
  801cf8:	68 c9 2f 80 00       	push   $0x802fc9
  801cfd:	e8 fd e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	6a 02                	push   $0x2
  801d07:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d0d:	e8 15 f2 ff ff       	call   800f27 <sys_env_set_status>
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	79 2b                	jns    801d44 <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801d19:	50                   	push   %eax
  801d1a:	68 0c 30 80 00       	push   $0x80300c
  801d1f:	68 89 00 00 00       	push   $0x89
  801d24:	68 c9 2f 80 00       	push   $0x802fc9
  801d29:	e8 d1 e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d2e:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d34:	e9 a8 00 00 00       	jmp    801de1 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d39:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d3f:	e9 9d 00 00 00       	jmp    801de1 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d44:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d4a:	e9 92 00 00 00       	jmp    801de1 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d4f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d54:	e9 88 00 00 00       	jmp    801de1 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	e9 81 00 00 00       	jmp    801de1 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	eb 06                	jmp    801d6a <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	eb 02                	jmp    801d6a <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d68:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d6a:	83 ec 0c             	sub    $0xc,%esp
  801d6d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d73:	e8 69 f0 ff ff       	call   800de1 <sys_env_destroy>
	close(fd);
  801d78:	83 c4 04             	add    $0x4,%esp
  801d7b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d81:	e8 8a f4 ff ff       	call   801210 <close>
	return r;
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	eb 56                	jmp    801de1 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801d8b:	50                   	push   %eax
  801d8c:	68 23 30 80 00       	push   $0x803023
  801d91:	68 82 00 00 00       	push   $0x82
  801d96:	68 c9 2f 80 00       	push   $0x802fc9
  801d9b:	e8 5f e6 ff ff       	call   8003ff <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801da0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801da7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dba:	e8 aa f1 ff ff       	call   800f69 <sys_env_set_trapframe>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	0f 89 38 ff ff ff    	jns    801d02 <spawn+0x494>
  801dca:	e9 1e ff ff ff       	jmp    801ced <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dcf:	83 ec 08             	sub    $0x8,%esp
  801dd2:	68 00 00 40 00       	push   $0x400000
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 07 f1 ff ff       	call   800ee5 <sys_page_unmap>
  801dde:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801de1:	89 d8                	mov    %ebx,%eax
  801de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df0:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df8:	eb 03                	jmp    801dfd <spawnl+0x12>
		argc++;
  801dfa:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dfd:	83 c2 04             	add    $0x4,%edx
  801e00:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e04:	75 f4                	jne    801dfa <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e06:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e0d:	83 e2 f0             	and    $0xfffffff0,%edx
  801e10:	29 d4                	sub    %edx,%esp
  801e12:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e16:	c1 ea 02             	shr    $0x2,%edx
  801e19:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e20:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e25:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e2c:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e33:	00 
  801e34:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e36:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3b:	eb 0a                	jmp    801e47 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e3d:	83 c0 01             	add    $0x1,%eax
  801e40:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e44:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e47:	39 d0                	cmp    %edx,%eax
  801e49:	75 f2                	jne    801e3d <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	56                   	push   %esi
  801e4f:	ff 75 08             	pushl  0x8(%ebp)
  801e52:	e8 17 fa ff ff       	call   80186e <spawn>
}
  801e57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801e64:	68 64 30 80 00       	push   $0x803064
  801e69:	ff 75 0c             	pushl  0xc(%ebp)
  801e6c:	e8 ec eb ff ff       	call   800a5d <strcpy>
	return 0;
}
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	53                   	push   %ebx
  801e7c:	83 ec 10             	sub    $0x10,%esp
  801e7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e82:	53                   	push   %ebx
  801e83:	e8 dc 08 00 00       	call   802764 <pageref>
  801e88:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e8b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e90:	83 f8 01             	cmp    $0x1,%eax
  801e93:	75 10                	jne    801ea5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	ff 73 0c             	pushl  0xc(%ebx)
  801e9b:	e8 c0 02 00 00       	call   802160 <nsipc_close>
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801eb2:	6a 00                	push   $0x0
  801eb4:	ff 75 10             	pushl  0x10(%ebp)
  801eb7:	ff 75 0c             	pushl  0xc(%ebp)
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	ff 70 0c             	pushl  0xc(%eax)
  801ec0:	e8 78 03 00 00       	call   80223d <nsipc_send>
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ecd:	6a 00                	push   $0x0
  801ecf:	ff 75 10             	pushl  0x10(%ebp)
  801ed2:	ff 75 0c             	pushl  0xc(%ebp)
  801ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed8:	ff 70 0c             	pushl  0xc(%eax)
  801edb:	e8 f1 02 00 00       	call   8021d1 <nsipc_recv>
}
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ee8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801eeb:	52                   	push   %edx
  801eec:	50                   	push   %eax
  801eed:	e8 f4 f1 ff ff       	call   8010e6 <fd_lookup>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 17                	js     801f10 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efc:	8b 0d ac 57 80 00    	mov    0x8057ac,%ecx
  801f02:	39 08                	cmp    %ecx,(%eax)
  801f04:	75 05                	jne    801f0b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f06:	8b 40 0c             	mov    0xc(%eax),%eax
  801f09:	eb 05                	jmp    801f10 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	56                   	push   %esi
  801f16:	53                   	push   %ebx
  801f17:	83 ec 1c             	sub    $0x1c,%esp
  801f1a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1f:	50                   	push   %eax
  801f20:	e8 72 f1 ff ff       	call   801097 <fd_alloc>
  801f25:	89 c3                	mov    %eax,%ebx
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 1b                	js     801f49 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f2e:	83 ec 04             	sub    $0x4,%esp
  801f31:	68 07 04 00 00       	push   $0x407
  801f36:	ff 75 f4             	pushl  -0xc(%ebp)
  801f39:	6a 00                	push   $0x0
  801f3b:	e8 20 ef ff ff       	call   800e60 <sys_page_alloc>
  801f40:	89 c3                	mov    %eax,%ebx
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	79 10                	jns    801f59 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	56                   	push   %esi
  801f4d:	e8 0e 02 00 00       	call   802160 <nsipc_close>
		return r;
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	89 d8                	mov    %ebx,%eax
  801f57:	eb 24                	jmp    801f7d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f59:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f67:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f6e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f71:	83 ec 0c             	sub    $0xc,%esp
  801f74:	50                   	push   %eax
  801f75:	e8 f6 f0 ff ff       	call   801070 <fd2num>
  801f7a:	83 c4 10             	add    $0x10,%esp
}
  801f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5e                   	pop    %esi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8d:	e8 50 ff ff ff       	call   801ee2 <fd2sockid>
		return r;
  801f92:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f94:	85 c0                	test   %eax,%eax
  801f96:	78 1f                	js     801fb7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f98:	83 ec 04             	sub    $0x4,%esp
  801f9b:	ff 75 10             	pushl  0x10(%ebp)
  801f9e:	ff 75 0c             	pushl  0xc(%ebp)
  801fa1:	50                   	push   %eax
  801fa2:	e8 12 01 00 00       	call   8020b9 <nsipc_accept>
  801fa7:	83 c4 10             	add    $0x10,%esp
		return r;
  801faa:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 07                	js     801fb7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801fb0:	e8 5d ff ff ff       	call   801f12 <alloc_sockfd>
  801fb5:	89 c1                	mov    %eax,%ecx
}
  801fb7:	89 c8                	mov    %ecx,%eax
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc4:	e8 19 ff ff ff       	call   801ee2 <fd2sockid>
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 12                	js     801fdf <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801fcd:	83 ec 04             	sub    $0x4,%esp
  801fd0:	ff 75 10             	pushl  0x10(%ebp)
  801fd3:	ff 75 0c             	pushl  0xc(%ebp)
  801fd6:	50                   	push   %eax
  801fd7:	e8 2d 01 00 00       	call   802109 <nsipc_bind>
  801fdc:	83 c4 10             	add    $0x10,%esp
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <shutdown>:

int
shutdown(int s, int how)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fea:	e8 f3 fe ff ff       	call   801ee2 <fd2sockid>
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 0f                	js     802002 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ff3:	83 ec 08             	sub    $0x8,%esp
  801ff6:	ff 75 0c             	pushl  0xc(%ebp)
  801ff9:	50                   	push   %eax
  801ffa:	e8 3f 01 00 00       	call   80213e <nsipc_shutdown>
  801fff:	83 c4 10             	add    $0x10,%esp
}
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	e8 d0 fe ff ff       	call   801ee2 <fd2sockid>
  802012:	85 c0                	test   %eax,%eax
  802014:	78 12                	js     802028 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802016:	83 ec 04             	sub    $0x4,%esp
  802019:	ff 75 10             	pushl  0x10(%ebp)
  80201c:	ff 75 0c             	pushl  0xc(%ebp)
  80201f:	50                   	push   %eax
  802020:	e8 55 01 00 00       	call   80217a <nsipc_connect>
  802025:	83 c4 10             	add    $0x10,%esp
}
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <listen>:

int
listen(int s, int backlog)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802030:	8b 45 08             	mov    0x8(%ebp),%eax
  802033:	e8 aa fe ff ff       	call   801ee2 <fd2sockid>
  802038:	85 c0                	test   %eax,%eax
  80203a:	78 0f                	js     80204b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80203c:	83 ec 08             	sub    $0x8,%esp
  80203f:	ff 75 0c             	pushl  0xc(%ebp)
  802042:	50                   	push   %eax
  802043:	e8 67 01 00 00       	call   8021af <nsipc_listen>
  802048:	83 c4 10             	add    $0x10,%esp
}
  80204b:	c9                   	leave  
  80204c:	c3                   	ret    

0080204d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802053:	ff 75 10             	pushl  0x10(%ebp)
  802056:	ff 75 0c             	pushl  0xc(%ebp)
  802059:	ff 75 08             	pushl  0x8(%ebp)
  80205c:	e8 3a 02 00 00       	call   80229b <nsipc_socket>
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	85 c0                	test   %eax,%eax
  802066:	78 05                	js     80206d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802068:	e8 a5 fe ff ff       	call   801f12 <alloc_sockfd>
}
  80206d:	c9                   	leave  
  80206e:	c3                   	ret    

0080206f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	53                   	push   %ebx
  802073:	83 ec 04             	sub    $0x4,%esp
  802076:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802078:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  80207f:	75 12                	jne    802093 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	6a 02                	push   $0x2
  802086:	e8 a0 06 00 00       	call   80272b <ipc_find_env>
  80208b:	a3 04 60 80 00       	mov    %eax,0x806004
  802090:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802093:	6a 07                	push   $0x7
  802095:	68 00 90 80 00       	push   $0x809000
  80209a:	53                   	push   %ebx
  80209b:	ff 35 04 60 80 00    	pushl  0x806004
  8020a1:	e8 31 06 00 00       	call   8026d7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020a6:	83 c4 0c             	add    $0xc,%esp
  8020a9:	6a 00                	push   $0x0
  8020ab:	6a 00                	push   $0x0
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 bc 05 00 00       	call   802670 <ipc_recv>
}
  8020b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    

008020b9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c4:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020c9:	8b 06                	mov    (%esi),%eax
  8020cb:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d5:	e8 95 ff ff ff       	call   80206f <nsipc>
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	78 20                	js     802100 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020e0:	83 ec 04             	sub    $0x4,%esp
  8020e3:	ff 35 10 90 80 00    	pushl  0x809010
  8020e9:	68 00 90 80 00       	push   $0x809000
  8020ee:	ff 75 0c             	pushl  0xc(%ebp)
  8020f1:	e8 f9 ea ff ff       	call   800bef <memmove>
		*addrlen = ret->ret_addrlen;
  8020f6:	a1 10 90 80 00       	mov    0x809010,%eax
  8020fb:	89 06                	mov    %eax,(%esi)
  8020fd:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802100:	89 d8                	mov    %ebx,%eax
  802102:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802105:	5b                   	pop    %ebx
  802106:	5e                   	pop    %esi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    

00802109 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	53                   	push   %ebx
  80210d:	83 ec 08             	sub    $0x8,%esp
  802110:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
  802116:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80211b:	53                   	push   %ebx
  80211c:	ff 75 0c             	pushl  0xc(%ebp)
  80211f:	68 04 90 80 00       	push   $0x809004
  802124:	e8 c6 ea ff ff       	call   800bef <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802129:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  80212f:	b8 02 00 00 00       	mov    $0x2,%eax
  802134:	e8 36 ff ff ff       	call   80206f <nsipc>
}
  802139:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802144:	8b 45 08             	mov    0x8(%ebp),%eax
  802147:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  80214c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214f:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802154:	b8 03 00 00 00       	mov    $0x3,%eax
  802159:	e8 11 ff ff ff       	call   80206f <nsipc>
}
  80215e:	c9                   	leave  
  80215f:	c3                   	ret    

00802160 <nsipc_close>:

int
nsipc_close(int s)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802166:	8b 45 08             	mov    0x8(%ebp),%eax
  802169:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  80216e:	b8 04 00 00 00       	mov    $0x4,%eax
  802173:	e8 f7 fe ff ff       	call   80206f <nsipc>
}
  802178:	c9                   	leave  
  802179:	c3                   	ret    

0080217a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	53                   	push   %ebx
  80217e:	83 ec 08             	sub    $0x8,%esp
  802181:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802184:	8b 45 08             	mov    0x8(%ebp),%eax
  802187:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80218c:	53                   	push   %ebx
  80218d:	ff 75 0c             	pushl  0xc(%ebp)
  802190:	68 04 90 80 00       	push   $0x809004
  802195:	e8 55 ea ff ff       	call   800bef <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80219a:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  8021a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8021a5:	e8 c5 fe ff ff       	call   80206f <nsipc>
}
  8021aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b8:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  8021bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c0:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  8021c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8021ca:	e8 a0 fe ff ff       	call   80206f <nsipc>
}
  8021cf:	c9                   	leave  
  8021d0:	c3                   	ret    

008021d1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	56                   	push   %esi
  8021d5:	53                   	push   %ebx
  8021d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dc:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  8021e1:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8021e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8021ea:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8021f4:	e8 76 fe ff ff       	call   80206f <nsipc>
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	85 c0                	test   %eax,%eax
  8021fd:	78 35                	js     802234 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8021ff:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802204:	7f 04                	jg     80220a <nsipc_recv+0x39>
  802206:	39 c6                	cmp    %eax,%esi
  802208:	7d 16                	jge    802220 <nsipc_recv+0x4f>
  80220a:	68 70 30 80 00       	push   $0x803070
  80220f:	68 83 2f 80 00       	push   $0x802f83
  802214:	6a 62                	push   $0x62
  802216:	68 85 30 80 00       	push   $0x803085
  80221b:	e8 df e1 ff ff       	call   8003ff <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802220:	83 ec 04             	sub    $0x4,%esp
  802223:	50                   	push   %eax
  802224:	68 00 90 80 00       	push   $0x809000
  802229:	ff 75 0c             	pushl  0xc(%ebp)
  80222c:	e8 be e9 ff ff       	call   800bef <memmove>
  802231:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802234:	89 d8                	mov    %ebx,%eax
  802236:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802239:	5b                   	pop    %ebx
  80223a:	5e                   	pop    %esi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    

0080223d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	53                   	push   %ebx
  802241:	83 ec 04             	sub    $0x4,%esp
  802244:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802247:	8b 45 08             	mov    0x8(%ebp),%eax
  80224a:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  80224f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802255:	7e 16                	jle    80226d <nsipc_send+0x30>
  802257:	68 91 30 80 00       	push   $0x803091
  80225c:	68 83 2f 80 00       	push   $0x802f83
  802261:	6a 6d                	push   $0x6d
  802263:	68 85 30 80 00       	push   $0x803085
  802268:	e8 92 e1 ff ff       	call   8003ff <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80226d:	83 ec 04             	sub    $0x4,%esp
  802270:	53                   	push   %ebx
  802271:	ff 75 0c             	pushl  0xc(%ebp)
  802274:	68 0c 90 80 00       	push   $0x80900c
  802279:	e8 71 e9 ff ff       	call   800bef <memmove>
	nsipcbuf.send.req_size = size;
  80227e:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802284:	8b 45 14             	mov    0x14(%ebp),%eax
  802287:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  80228c:	b8 08 00 00 00       	mov    $0x8,%eax
  802291:	e8 d9 fd ff ff       	call   80206f <nsipc>
}
  802296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a4:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  8022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ac:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  8022b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b4:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  8022b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8022be:	e8 ac fd ff ff       	call   80206f <nsipc>
}
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    

008022c5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	56                   	push   %esi
  8022c9:	53                   	push   %ebx
  8022ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	ff 75 08             	pushl  0x8(%ebp)
  8022d3:	e8 a8 ed ff ff       	call   801080 <fd2data>
  8022d8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022da:	83 c4 08             	add    $0x8,%esp
  8022dd:	68 9d 30 80 00       	push   $0x80309d
  8022e2:	53                   	push   %ebx
  8022e3:	e8 75 e7 ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022e8:	8b 46 04             	mov    0x4(%esi),%eax
  8022eb:	2b 06                	sub    (%esi),%eax
  8022ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022fa:	00 00 00 
	stat->st_dev = &devpipe;
  8022fd:	c7 83 88 00 00 00 c8 	movl   $0x8057c8,0x88(%ebx)
  802304:	57 80 00 
	return 0;
}
  802307:	b8 00 00 00 00       	mov    $0x0,%eax
  80230c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5d                   	pop    %ebp
  802312:	c3                   	ret    

00802313 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802313:	55                   	push   %ebp
  802314:	89 e5                	mov    %esp,%ebp
  802316:	53                   	push   %ebx
  802317:	83 ec 0c             	sub    $0xc,%esp
  80231a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80231d:	53                   	push   %ebx
  80231e:	6a 00                	push   $0x0
  802320:	e8 c0 eb ff ff       	call   800ee5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802325:	89 1c 24             	mov    %ebx,(%esp)
  802328:	e8 53 ed ff ff       	call   801080 <fd2data>
  80232d:	83 c4 08             	add    $0x8,%esp
  802330:	50                   	push   %eax
  802331:	6a 00                	push   $0x0
  802333:	e8 ad eb ff ff       	call   800ee5 <sys_page_unmap>
}
  802338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80233b:	c9                   	leave  
  80233c:	c3                   	ret    

0080233d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	57                   	push   %edi
  802341:	56                   	push   %esi
  802342:	53                   	push   %ebx
  802343:	83 ec 1c             	sub    $0x1c,%esp
  802346:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802349:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80234b:	a1 90 77 80 00       	mov    0x807790,%eax
  802350:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	ff 75 e0             	pushl  -0x20(%ebp)
  802359:	e8 06 04 00 00       	call   802764 <pageref>
  80235e:	89 c3                	mov    %eax,%ebx
  802360:	89 3c 24             	mov    %edi,(%esp)
  802363:	e8 fc 03 00 00       	call   802764 <pageref>
  802368:	83 c4 10             	add    $0x10,%esp
  80236b:	39 c3                	cmp    %eax,%ebx
  80236d:	0f 94 c1             	sete   %cl
  802370:	0f b6 c9             	movzbl %cl,%ecx
  802373:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802376:	8b 15 90 77 80 00    	mov    0x807790,%edx
  80237c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80237f:	39 ce                	cmp    %ecx,%esi
  802381:	74 1b                	je     80239e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802383:	39 c3                	cmp    %eax,%ebx
  802385:	75 c4                	jne    80234b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802387:	8b 42 58             	mov    0x58(%edx),%eax
  80238a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80238d:	50                   	push   %eax
  80238e:	56                   	push   %esi
  80238f:	68 a4 30 80 00       	push   $0x8030a4
  802394:	e8 3f e1 ff ff       	call   8004d8 <cprintf>
  802399:	83 c4 10             	add    $0x10,%esp
  80239c:	eb ad                	jmp    80234b <_pipeisclosed+0xe>
	}
}
  80239e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    

008023a9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	57                   	push   %edi
  8023ad:	56                   	push   %esi
  8023ae:	53                   	push   %ebx
  8023af:	83 ec 28             	sub    $0x28,%esp
  8023b2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023b5:	56                   	push   %esi
  8023b6:	e8 c5 ec ff ff       	call   801080 <fd2data>
  8023bb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023bd:	83 c4 10             	add    $0x10,%esp
  8023c0:	bf 00 00 00 00       	mov    $0x0,%edi
  8023c5:	eb 4b                	jmp    802412 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023c7:	89 da                	mov    %ebx,%edx
  8023c9:	89 f0                	mov    %esi,%eax
  8023cb:	e8 6d ff ff ff       	call   80233d <_pipeisclosed>
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	75 48                	jne    80241c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023d4:	e8 68 ea ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8023dc:	8b 0b                	mov    (%ebx),%ecx
  8023de:	8d 51 20             	lea    0x20(%ecx),%edx
  8023e1:	39 d0                	cmp    %edx,%eax
  8023e3:	73 e2                	jae    8023c7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023ec:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023ef:	89 c2                	mov    %eax,%edx
  8023f1:	c1 fa 1f             	sar    $0x1f,%edx
  8023f4:	89 d1                	mov    %edx,%ecx
  8023f6:	c1 e9 1b             	shr    $0x1b,%ecx
  8023f9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023fc:	83 e2 1f             	and    $0x1f,%edx
  8023ff:	29 ca                	sub    %ecx,%edx
  802401:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802405:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802409:	83 c0 01             	add    $0x1,%eax
  80240c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80240f:	83 c7 01             	add    $0x1,%edi
  802412:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802415:	75 c2                	jne    8023d9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802417:	8b 45 10             	mov    0x10(%ebp),%eax
  80241a:	eb 05                	jmp    802421 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80241c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802421:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    

00802429 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	57                   	push   %edi
  80242d:	56                   	push   %esi
  80242e:	53                   	push   %ebx
  80242f:	83 ec 18             	sub    $0x18,%esp
  802432:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802435:	57                   	push   %edi
  802436:	e8 45 ec ff ff       	call   801080 <fd2data>
  80243b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80243d:	83 c4 10             	add    $0x10,%esp
  802440:	bb 00 00 00 00       	mov    $0x0,%ebx
  802445:	eb 3d                	jmp    802484 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802447:	85 db                	test   %ebx,%ebx
  802449:	74 04                	je     80244f <devpipe_read+0x26>
				return i;
  80244b:	89 d8                	mov    %ebx,%eax
  80244d:	eb 44                	jmp    802493 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80244f:	89 f2                	mov    %esi,%edx
  802451:	89 f8                	mov    %edi,%eax
  802453:	e8 e5 fe ff ff       	call   80233d <_pipeisclosed>
  802458:	85 c0                	test   %eax,%eax
  80245a:	75 32                	jne    80248e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80245c:	e8 e0 e9 ff ff       	call   800e41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802461:	8b 06                	mov    (%esi),%eax
  802463:	3b 46 04             	cmp    0x4(%esi),%eax
  802466:	74 df                	je     802447 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802468:	99                   	cltd   
  802469:	c1 ea 1b             	shr    $0x1b,%edx
  80246c:	01 d0                	add    %edx,%eax
  80246e:	83 e0 1f             	and    $0x1f,%eax
  802471:	29 d0                	sub    %edx,%eax
  802473:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802478:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80247b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80247e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802481:	83 c3 01             	add    $0x1,%ebx
  802484:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802487:	75 d8                	jne    802461 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802489:	8b 45 10             	mov    0x10(%ebp),%eax
  80248c:	eb 05                	jmp    802493 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80248e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802493:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802496:	5b                   	pop    %ebx
  802497:	5e                   	pop    %esi
  802498:	5f                   	pop    %edi
  802499:	5d                   	pop    %ebp
  80249a:	c3                   	ret    

0080249b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	56                   	push   %esi
  80249f:	53                   	push   %ebx
  8024a0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a6:	50                   	push   %eax
  8024a7:	e8 eb eb ff ff       	call   801097 <fd_alloc>
  8024ac:	83 c4 10             	add    $0x10,%esp
  8024af:	89 c2                	mov    %eax,%edx
  8024b1:	85 c0                	test   %eax,%eax
  8024b3:	0f 88 2c 01 00 00    	js     8025e5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b9:	83 ec 04             	sub    $0x4,%esp
  8024bc:	68 07 04 00 00       	push   $0x407
  8024c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024c4:	6a 00                	push   $0x0
  8024c6:	e8 95 e9 ff ff       	call   800e60 <sys_page_alloc>
  8024cb:	83 c4 10             	add    $0x10,%esp
  8024ce:	89 c2                	mov    %eax,%edx
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	0f 88 0d 01 00 00    	js     8025e5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024d8:	83 ec 0c             	sub    $0xc,%esp
  8024db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024de:	50                   	push   %eax
  8024df:	e8 b3 eb ff ff       	call   801097 <fd_alloc>
  8024e4:	89 c3                	mov    %eax,%ebx
  8024e6:	83 c4 10             	add    $0x10,%esp
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	0f 88 e2 00 00 00    	js     8025d3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024f1:	83 ec 04             	sub    $0x4,%esp
  8024f4:	68 07 04 00 00       	push   $0x407
  8024f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8024fc:	6a 00                	push   $0x0
  8024fe:	e8 5d e9 ff ff       	call   800e60 <sys_page_alloc>
  802503:	89 c3                	mov    %eax,%ebx
  802505:	83 c4 10             	add    $0x10,%esp
  802508:	85 c0                	test   %eax,%eax
  80250a:	0f 88 c3 00 00 00    	js     8025d3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802510:	83 ec 0c             	sub    $0xc,%esp
  802513:	ff 75 f4             	pushl  -0xc(%ebp)
  802516:	e8 65 eb ff ff       	call   801080 <fd2data>
  80251b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80251d:	83 c4 0c             	add    $0xc,%esp
  802520:	68 07 04 00 00       	push   $0x407
  802525:	50                   	push   %eax
  802526:	6a 00                	push   $0x0
  802528:	e8 33 e9 ff ff       	call   800e60 <sys_page_alloc>
  80252d:	89 c3                	mov    %eax,%ebx
  80252f:	83 c4 10             	add    $0x10,%esp
  802532:	85 c0                	test   %eax,%eax
  802534:	0f 88 89 00 00 00    	js     8025c3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80253a:	83 ec 0c             	sub    $0xc,%esp
  80253d:	ff 75 f0             	pushl  -0x10(%ebp)
  802540:	e8 3b eb ff ff       	call   801080 <fd2data>
  802545:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80254c:	50                   	push   %eax
  80254d:	6a 00                	push   $0x0
  80254f:	56                   	push   %esi
  802550:	6a 00                	push   $0x0
  802552:	e8 4c e9 ff ff       	call   800ea3 <sys_page_map>
  802557:	89 c3                	mov    %eax,%ebx
  802559:	83 c4 20             	add    $0x20,%esp
  80255c:	85 c0                	test   %eax,%eax
  80255e:	78 55                	js     8025b5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802560:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  802566:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802569:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80256b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802575:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80257b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80257e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802580:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802583:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80258a:	83 ec 0c             	sub    $0xc,%esp
  80258d:	ff 75 f4             	pushl  -0xc(%ebp)
  802590:	e8 db ea ff ff       	call   801070 <fd2num>
  802595:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802598:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80259a:	83 c4 04             	add    $0x4,%esp
  80259d:	ff 75 f0             	pushl  -0x10(%ebp)
  8025a0:	e8 cb ea ff ff       	call   801070 <fd2num>
  8025a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025a8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025ab:	83 c4 10             	add    $0x10,%esp
  8025ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8025b3:	eb 30                	jmp    8025e5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8025b5:	83 ec 08             	sub    $0x8,%esp
  8025b8:	56                   	push   %esi
  8025b9:	6a 00                	push   $0x0
  8025bb:	e8 25 e9 ff ff       	call   800ee5 <sys_page_unmap>
  8025c0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8025c3:	83 ec 08             	sub    $0x8,%esp
  8025c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8025c9:	6a 00                	push   $0x0
  8025cb:	e8 15 e9 ff ff       	call   800ee5 <sys_page_unmap>
  8025d0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8025d3:	83 ec 08             	sub    $0x8,%esp
  8025d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8025d9:	6a 00                	push   $0x0
  8025db:	e8 05 e9 ff ff       	call   800ee5 <sys_page_unmap>
  8025e0:	83 c4 10             	add    $0x10,%esp
  8025e3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8025e5:	89 d0                	mov    %edx,%eax
  8025e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ea:	5b                   	pop    %ebx
  8025eb:	5e                   	pop    %esi
  8025ec:	5d                   	pop    %ebp
  8025ed:	c3                   	ret    

008025ee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025ee:	55                   	push   %ebp
  8025ef:	89 e5                	mov    %esp,%ebp
  8025f1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f7:	50                   	push   %eax
  8025f8:	ff 75 08             	pushl  0x8(%ebp)
  8025fb:	e8 e6 ea ff ff       	call   8010e6 <fd_lookup>
  802600:	83 c4 10             	add    $0x10,%esp
  802603:	85 c0                	test   %eax,%eax
  802605:	78 18                	js     80261f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802607:	83 ec 0c             	sub    $0xc,%esp
  80260a:	ff 75 f4             	pushl  -0xc(%ebp)
  80260d:	e8 6e ea ff ff       	call   801080 <fd2data>
	return _pipeisclosed(fd, p);
  802612:	89 c2                	mov    %eax,%edx
  802614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802617:	e8 21 fd ff ff       	call   80233d <_pipeisclosed>
  80261c:	83 c4 10             	add    $0x10,%esp
}
  80261f:	c9                   	leave  
  802620:	c3                   	ret    

00802621 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802621:	55                   	push   %ebp
  802622:	89 e5                	mov    %esp,%ebp
  802624:	56                   	push   %esi
  802625:	53                   	push   %ebx
  802626:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802629:	85 f6                	test   %esi,%esi
  80262b:	75 16                	jne    802643 <wait+0x22>
  80262d:	68 bc 30 80 00       	push   $0x8030bc
  802632:	68 83 2f 80 00       	push   $0x802f83
  802637:	6a 09                	push   $0x9
  802639:	68 c7 30 80 00       	push   $0x8030c7
  80263e:	e8 bc dd ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  802643:	89 f3                	mov    %esi,%ebx
  802645:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80264b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80264e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802654:	eb 05                	jmp    80265b <wait+0x3a>
		sys_yield();
  802656:	e8 e6 e7 ff ff       	call   800e41 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80265b:	8b 43 48             	mov    0x48(%ebx),%eax
  80265e:	39 c6                	cmp    %eax,%esi
  802660:	75 07                	jne    802669 <wait+0x48>
  802662:	8b 43 54             	mov    0x54(%ebx),%eax
  802665:	85 c0                	test   %eax,%eax
  802667:	75 ed                	jne    802656 <wait+0x35>
		sys_yield();
}
  802669:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80266c:	5b                   	pop    %ebx
  80266d:	5e                   	pop    %esi
  80266e:	5d                   	pop    %ebp
  80266f:	c3                   	ret    

00802670 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	56                   	push   %esi
  802674:	53                   	push   %ebx
  802675:	8b 75 08             	mov    0x8(%ebp),%esi
  802678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80267e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802680:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802685:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802688:	83 ec 0c             	sub    $0xc,%esp
  80268b:	50                   	push   %eax
  80268c:	e8 7f e9 ff ff       	call   801010 <sys_ipc_recv>

	if (from_env_store != NULL)
  802691:	83 c4 10             	add    $0x10,%esp
  802694:	85 f6                	test   %esi,%esi
  802696:	74 14                	je     8026ac <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802698:	ba 00 00 00 00       	mov    $0x0,%edx
  80269d:	85 c0                	test   %eax,%eax
  80269f:	78 09                	js     8026aa <ipc_recv+0x3a>
  8026a1:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8026a7:	8b 52 74             	mov    0x74(%edx),%edx
  8026aa:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8026ac:	85 db                	test   %ebx,%ebx
  8026ae:	74 14                	je     8026c4 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8026b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8026b5:	85 c0                	test   %eax,%eax
  8026b7:	78 09                	js     8026c2 <ipc_recv+0x52>
  8026b9:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8026bf:	8b 52 78             	mov    0x78(%edx),%edx
  8026c2:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8026c4:	85 c0                	test   %eax,%eax
  8026c6:	78 08                	js     8026d0 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8026c8:	a1 90 77 80 00       	mov    0x807790,%eax
  8026cd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5d                   	pop    %ebp
  8026d6:	c3                   	ret    

008026d7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d7:	55                   	push   %ebp
  8026d8:	89 e5                	mov    %esp,%ebp
  8026da:	57                   	push   %edi
  8026db:	56                   	push   %esi
  8026dc:	53                   	push   %ebx
  8026dd:	83 ec 0c             	sub    $0xc,%esp
  8026e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8026e9:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8026eb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026f0:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8026f3:	ff 75 14             	pushl  0x14(%ebp)
  8026f6:	53                   	push   %ebx
  8026f7:	56                   	push   %esi
  8026f8:	57                   	push   %edi
  8026f9:	e8 ef e8 ff ff       	call   800fed <sys_ipc_try_send>

		if (err < 0) {
  8026fe:	83 c4 10             	add    $0x10,%esp
  802701:	85 c0                	test   %eax,%eax
  802703:	79 1e                	jns    802723 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802705:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802708:	75 07                	jne    802711 <ipc_send+0x3a>
				sys_yield();
  80270a:	e8 32 e7 ff ff       	call   800e41 <sys_yield>
  80270f:	eb e2                	jmp    8026f3 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802711:	50                   	push   %eax
  802712:	68 d2 30 80 00       	push   $0x8030d2
  802717:	6a 49                	push   $0x49
  802719:	68 df 30 80 00       	push   $0x8030df
  80271e:	e8 dc dc ff ff       	call   8003ff <_panic>
		}

	} while (err < 0);

}
  802723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802726:	5b                   	pop    %ebx
  802727:	5e                   	pop    %esi
  802728:	5f                   	pop    %edi
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    

0080272b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80272b:	55                   	push   %ebp
  80272c:	89 e5                	mov    %esp,%ebp
  80272e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802731:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802736:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802739:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80273f:	8b 52 50             	mov    0x50(%edx),%edx
  802742:	39 ca                	cmp    %ecx,%edx
  802744:	75 0d                	jne    802753 <ipc_find_env+0x28>
			return envs[i].env_id;
  802746:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802749:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80274e:	8b 40 48             	mov    0x48(%eax),%eax
  802751:	eb 0f                	jmp    802762 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802753:	83 c0 01             	add    $0x1,%eax
  802756:	3d 00 04 00 00       	cmp    $0x400,%eax
  80275b:	75 d9                	jne    802736 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802762:	5d                   	pop    %ebp
  802763:	c3                   	ret    

00802764 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802764:	55                   	push   %ebp
  802765:	89 e5                	mov    %esp,%ebp
  802767:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276a:	89 d0                	mov    %edx,%eax
  80276c:	c1 e8 16             	shr    $0x16,%eax
  80276f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802776:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80277b:	f6 c1 01             	test   $0x1,%cl
  80277e:	74 1d                	je     80279d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802780:	c1 ea 0c             	shr    $0xc,%edx
  802783:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80278a:	f6 c2 01             	test   $0x1,%dl
  80278d:	74 0e                	je     80279d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80278f:	c1 ea 0c             	shr    $0xc,%edx
  802792:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802799:	ef 
  80279a:	0f b7 c0             	movzwl %ax,%eax
}
  80279d:	5d                   	pop    %ebp
  80279e:	c3                   	ret    
  80279f:	90                   	nop

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
