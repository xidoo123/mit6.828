
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 bd 0d 00 00       	call   800e01 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 5e 11 00 00       	call   8011b1 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 20 20 80 00       	push   $0x802020
  800065:	6a 0f                	push   $0xf
  800067:	68 2d 20 80 00       	push   $0x80202d
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 3c 20 80 00       	push   $0x80203c
  80007b:	6a 11                	push   $0x11
  80007d:	68 2d 20 80 00       	push   $0x80202d
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 6e 11 00 00       	call   801201 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 56 20 80 00       	push   $0x802056
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 2d 20 80 00       	push   $0x80202d
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 5e 20 80 00       	push   $0x80205e
  8000b4:	e8 38 08 00 00       	call   8008f1 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 6c 20 80 00       	push   $0x80206c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 03 18 00 00       	call   8018d3 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 70 20 80 00       	push   $0x802070
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 ef 17 00 00       	call   8018d3 <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 88 20 80 00       	push   $0x802088
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 17 09 00 00       	call   800a1d <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 6b 0a 00 00       	call   800baf <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 16 0c 00 00       	call   800d64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 87 0c 00 00       	call   800e01 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 03 0c 00 00       	call   800d82 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 ae 0b 00 00       	call   800d64 <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 1f 11 00 00       	call   8012ed <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 8f 0e 00 00       	call   801087 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 17 0e 00 00       	call   801038 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 e4 0b 00 00       	call   800e20 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 ae 0d 00 00       	call   801011 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 66 0b 00 00       	call   800de2 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 1f 0f 00 00       	call   8011dc <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 da 0a 00 00       	call   800da1 <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 03 0b 00 00       	call   800de2 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 a0 20 80 00       	push   $0x8020a0
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 86 20 80 00 	movl   $0x802086,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 22 0a 00 00       	call   800d64 <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 54 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 c7 09 00 00       	call   800d64 <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 83 19 00 00       	call   801d90 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 70 1a 00 00       	call   801ec0 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 c3 20 80 00 	movsbl 0x8020c3(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
  80047c:	eb 22                	jmp    8004a0 <getuint+0x38>
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 10                	je     800492 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 0e                	jmp    8004a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	pushl  0x10(%ebp)
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
	va_end(ap);
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 2c             	sub    $0x2c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 12                	jmp    800502 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 89 03 00 00    	je     800881 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e2                	jne    8004f0 <vprintfmt+0x14>
  80050e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800512:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800519:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800527:	ba 00 00 00 00       	mov    $0x0,%edx
  80052c:	eb 07                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800531:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053b:	0f b6 07             	movzbl (%edi),%eax
  80053e:	0f b6 c8             	movzbl %al,%ecx
  800541:	83 e8 23             	sub    $0x23,%eax
  800544:	3c 55                	cmp    $0x55,%al
  800546:	0f 87 1a 03 00 00    	ja     800866 <vprintfmt+0x38a>
  80054c:	0f b6 c0             	movzbl %al,%eax
  80054f:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80055d:	eb d6                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80056a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800571:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800574:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800577:	83 fa 09             	cmp    $0x9,%edx
  80057a:	77 39                	ja     8005b5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057f:	eb e9                	jmp    80056a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 48 04             	lea    0x4(%eax),%ecx
  800587:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800592:	eb 27                	jmp    8005bb <vprintfmt+0xdf>
  800594:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	0f 49 c8             	cmovns %eax,%ecx
  8005a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	eb 8c                	jmp    800535 <vprintfmt+0x59>
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b3:	eb 80                	jmp    800535 <vprintfmt+0x59>
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bf:	0f 89 70 ff ff ff    	jns    800535 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d2:	e9 5e ff ff ff       	jmp    800535 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005dd:	e9 53 ff ff ff       	jmp    800535 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	ff 30                	pushl  (%eax)
  8005f1:	ff d6                	call   *%esi
			break;
  8005f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f9:	e9 04 ff ff ff       	jmp    800502 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	99                   	cltd   
  80060a:	31 d0                	xor    %edx,%eax
  80060c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060e:	83 f8 0f             	cmp    $0xf,%eax
  800611:	7f 0b                	jg     80061e <vprintfmt+0x142>
  800613:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  80061a:	85 d2                	test   %edx,%edx
  80061c:	75 18                	jne    800636 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 db 20 80 00       	push   $0x8020db
  800624:	53                   	push   %ebx
  800625:	56                   	push   %esi
  800626:	e8 94 fe ff ff       	call   8004bf <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800631:	e9 cc fe ff ff       	jmp    800502 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800636:	52                   	push   %edx
  800637:	68 ce 24 80 00       	push   $0x8024ce
  80063c:	53                   	push   %ebx
  80063d:	56                   	push   %esi
  80063e:	e8 7c fe ff ff       	call   8004bf <printfmt>
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800649:	e9 b4 fe ff ff       	jmp    800502 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800659:	85 ff                	test   %edi,%edi
  80065b:	b8 d4 20 80 00       	mov    $0x8020d4,%eax
  800660:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800663:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800667:	0f 8e 94 00 00 00    	jle    800701 <vprintfmt+0x225>
  80066d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800671:	0f 84 98 00 00 00    	je     80070f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 d0             	pushl  -0x30(%ebp)
  80067d:	57                   	push   %edi
  80067e:	e8 79 03 00 00       	call   8009fc <strnlen>
  800683:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800686:	29 c1                	sub    %eax,%ecx
  800688:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800695:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800698:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	eb 0f                	jmp    8006ab <vprintfmt+0x1cf>
					putch(padc, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 ff                	test   %edi,%edi
  8006ad:	7f ed                	jg     80069c <vprintfmt+0x1c0>
  8006af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c1             	cmovns %ecx,%eax
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	89 cb                	mov    %ecx,%ebx
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	74 1b                	je     8006ef <vprintfmt+0x213>
  8006d4:	0f be c0             	movsbl %al,%eax
  8006d7:	83 e8 20             	sub    $0x20,%eax
  8006da:	83 f8 5e             	cmp    $0x5e,%eax
  8006dd:	76 10                	jbe    8006ef <vprintfmt+0x213>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 eb 01             	sub    $0x1,%ebx
  8006ff:	eb 1a                	jmp    80071b <vprintfmt+0x23f>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	eb 0c                	jmp    80071b <vprintfmt+0x23f>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071b:	83 c7 01             	add    $0x1,%edi
  80071e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800722:	0f be d0             	movsbl %al,%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 23                	je     80074c <vprintfmt+0x270>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 a1                	js     8006ce <vprintfmt+0x1f2>
  80072d:	83 ee 01             	sub    $0x1,%esi
  800730:	79 9c                	jns    8006ce <vprintfmt+0x1f2>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb 18                	jmp    800754 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 20                	push   $0x20
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x278>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e4                	jg     80073c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 a2 fd ff ff       	jmp    800502 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 fa 01             	cmp    $0x1,%edx
  800763:	7e 16                	jle    80077b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 08             	lea    0x8(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	eb 32                	jmp    8007ad <vprintfmt+0x2d1>
	else if (lflag)
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 18                	je     800797 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 c1                	mov    %eax,%ecx
  80078f:	c1 f9 1f             	sar    $0x1f,%ecx
  800792:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800795:	eb 16                	jmp    8007ad <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bc:	79 74                	jns    800832 <vprintfmt+0x356>
				putch('-', putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	6a 2d                	push   $0x2d
  8007c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007cc:	f7 d8                	neg    %eax
  8007ce:	83 d2 00             	adc    $0x0,%edx
  8007d1:	f7 da                	neg    %edx
  8007d3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007db:	eb 55                	jmp    800832 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	e8 83 fc ff ff       	call   800468 <getuint>
			base = 10;
  8007e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ea:	eb 46                	jmp    800832 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ef:	e8 74 fc ff ff       	call   800468 <getuint>
			base = 8;
  8007f4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007f9:	eb 37                	jmp    800832 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 30                	push   $0x30
  800801:	ff d6                	call   *%esi
			putch('x', putdat);
  800803:	83 c4 08             	add    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	6a 78                	push   $0x78
  800809:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800814:	8b 00                	mov    (%eax),%eax
  800816:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800823:	eb 0d                	jmp    800832 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 3b fc ff ff       	call   800468 <getuint>
			base = 16;
  80082d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800832:	83 ec 0c             	sub    $0xc,%esp
  800835:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800839:	57                   	push   %edi
  80083a:	ff 75 e0             	pushl  -0x20(%ebp)
  80083d:	51                   	push   %ecx
  80083e:	52                   	push   %edx
  80083f:	50                   	push   %eax
  800840:	89 da                	mov    %ebx,%edx
  800842:	89 f0                	mov    %esi,%eax
  800844:	e8 70 fb ff ff       	call   8003b9 <printnum>
			break;
  800849:	83 c4 20             	add    $0x20,%esp
  80084c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084f:	e9 ae fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	53                   	push   %ebx
  800858:	51                   	push   %ecx
  800859:	ff d6                	call   *%esi
			break;
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800861:	e9 9c fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 25                	push   $0x25
  80086c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	eb 03                	jmp    800876 <vprintfmt+0x39a>
  800873:	83 ef 01             	sub    $0x1,%edi
  800876:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087a:	75 f7                	jne    800873 <vprintfmt+0x397>
  80087c:	e9 81 fc ff ff       	jmp    800502 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800881:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5f                   	pop    %edi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800898:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	74 26                	je     8008d0 <vsnprintf+0x47>
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	7e 22                	jle    8008d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ae:	ff 75 14             	pushl  0x14(%ebp)
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	68 a2 04 80 00       	push   $0x8004a2
  8008bd:	e8 1a fc ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 05                	jmp    8008d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	50                   	push   %eax
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 9a ff ff ff       	call   800889 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	83 ec 0c             	sub    $0xc,%esp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	74 13                	je     800914 <readline+0x23>
		fprintf(1, "%s", prompt);
  800901:	83 ec 04             	sub    $0x4,%esp
  800904:	50                   	push   %eax
  800905:	68 ce 24 80 00       	push   $0x8024ce
  80090a:	6a 01                	push   $0x1
  80090c:	e8 c2 0f 00 00       	call   8018d3 <fprintf>
  800911:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	6a 00                	push   $0x0
  800919:	e8 c8 f8 ff ff       	call   8001e6 <iscons>
  80091e:	89 c7                	mov    %eax,%edi
  800920:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800923:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800928:	e8 8e f8 ff ff       	call   8001bb <getchar>
  80092d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80092f:	85 c0                	test   %eax,%eax
  800931:	79 29                	jns    80095c <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800938:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80093b:	0f 84 9b 00 00 00    	je     8009dc <readline+0xeb>
				cprintf("read error: %e\n", c);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	53                   	push   %ebx
  800945:	68 bf 23 80 00       	push   $0x8023bf
  80094a:	e8 56 fa ff ff       	call   8003a5 <cprintf>
  80094f:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	e9 80 00 00 00       	jmp    8009dc <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80095c:	83 f8 08             	cmp    $0x8,%eax
  80095f:	0f 94 c2             	sete   %dl
  800962:	83 f8 7f             	cmp    $0x7f,%eax
  800965:	0f 94 c0             	sete   %al
  800968:	08 c2                	or     %al,%dl
  80096a:	74 1a                	je     800986 <readline+0x95>
  80096c:	85 f6                	test   %esi,%esi
  80096e:	7e 16                	jle    800986 <readline+0x95>
			if (echoing)
  800970:	85 ff                	test   %edi,%edi
  800972:	74 0d                	je     800981 <readline+0x90>
				cputchar('\b');
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	6a 08                	push   $0x8
  800979:	e8 21 f8 ff ff       	call   80019f <cputchar>
  80097e:	83 c4 10             	add    $0x10,%esp
			i--;
  800981:	83 ee 01             	sub    $0x1,%esi
  800984:	eb a2                	jmp    800928 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800986:	83 fb 1f             	cmp    $0x1f,%ebx
  800989:	7e 26                	jle    8009b1 <readline+0xc0>
  80098b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800991:	7f 1e                	jg     8009b1 <readline+0xc0>
			if (echoing)
  800993:	85 ff                	test   %edi,%edi
  800995:	74 0c                	je     8009a3 <readline+0xb2>
				cputchar(c);
  800997:	83 ec 0c             	sub    $0xc,%esp
  80099a:	53                   	push   %ebx
  80099b:	e8 ff f7 ff ff       	call   80019f <cputchar>
  8009a0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009a3:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009a9:	8d 76 01             	lea    0x1(%esi),%esi
  8009ac:	e9 77 ff ff ff       	jmp    800928 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009b1:	83 fb 0a             	cmp    $0xa,%ebx
  8009b4:	74 09                	je     8009bf <readline+0xce>
  8009b6:	83 fb 0d             	cmp    $0xd,%ebx
  8009b9:	0f 85 69 ff ff ff    	jne    800928 <readline+0x37>
			if (echoing)
  8009bf:	85 ff                	test   %edi,%edi
  8009c1:	74 0d                	je     8009d0 <readline+0xdf>
				cputchar('\n');
  8009c3:	83 ec 0c             	sub    $0xc,%esp
  8009c6:	6a 0a                	push   $0xa
  8009c8:	e8 d2 f7 ff ff       	call   80019f <cputchar>
  8009cd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009d0:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009d7:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 03                	jmp    8009f4 <strlen+0x10>
		n++;
  8009f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f8:	75 f7                	jne    8009f1 <strlen+0xd>
		n++;
	return n;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	eb 03                	jmp    800a0f <strnlen+0x13>
		n++;
  800a0c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	39 c2                	cmp    %eax,%edx
  800a11:	74 08                	je     800a1b <strnlen+0x1f>
  800a13:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a17:	75 f3                	jne    800a0c <strnlen+0x10>
  800a19:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a33:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a36:	84 db                	test   %bl,%bl
  800a38:	75 ef                	jne    800a29 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a44:	53                   	push   %ebx
  800a45:	e8 9a ff ff ff       	call   8009e4 <strlen>
  800a4a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	01 d8                	add    %ebx,%eax
  800a52:	50                   	push   %eax
  800a53:	e8 c5 ff ff ff       	call   800a1d <strcpy>
	return dst;
}
  800a58:	89 d8                	mov    %ebx,%eax
  800a5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 75 08             	mov    0x8(%ebp),%esi
  800a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	eb 0f                	jmp    800a82 <strncpy+0x23>
		*dst++ = *src;
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a7c:	80 39 01             	cmpb   $0x1,(%ecx)
  800a7f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a82:	39 da                	cmp    %ebx,%edx
  800a84:	75 ed                	jne    800a73 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a86:	89 f0                	mov    %esi,%eax
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 75 08             	mov    0x8(%ebp),%esi
  800a94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a97:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a9c:	85 d2                	test   %edx,%edx
  800a9e:	74 21                	je     800ac1 <strlcpy+0x35>
  800aa0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa4:	89 f2                	mov    %esi,%edx
  800aa6:	eb 09                	jmp    800ab1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab1:	39 c2                	cmp    %eax,%edx
  800ab3:	74 09                	je     800abe <strlcpy+0x32>
  800ab5:	0f b6 19             	movzbl (%ecx),%ebx
  800ab8:	84 db                	test   %bl,%bl
  800aba:	75 ec                	jne    800aa8 <strlcpy+0x1c>
  800abc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800abe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac1:	29 f0                	sub    %esi,%eax
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad0:	eb 06                	jmp    800ad8 <strcmp+0x11>
		p++, q++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad8:	0f b6 01             	movzbl (%ecx),%eax
  800adb:	84 c0                	test   %al,%al
  800add:	74 04                	je     800ae3 <strcmp+0x1c>
  800adf:	3a 02                	cmp    (%edx),%al
  800ae1:	74 ef                	je     800ad2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae3:	0f b6 c0             	movzbl %al,%eax
  800ae6:	0f b6 12             	movzbl (%edx),%edx
  800ae9:	29 d0                	sub    %edx,%eax
}
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	53                   	push   %ebx
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800afc:	eb 06                	jmp    800b04 <strncmp+0x17>
		n--, p++, q++;
  800afe:	83 c0 01             	add    $0x1,%eax
  800b01:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b04:	39 d8                	cmp    %ebx,%eax
  800b06:	74 15                	je     800b1d <strncmp+0x30>
  800b08:	0f b6 08             	movzbl (%eax),%ecx
  800b0b:	84 c9                	test   %cl,%cl
  800b0d:	74 04                	je     800b13 <strncmp+0x26>
  800b0f:	3a 0a                	cmp    (%edx),%cl
  800b11:	74 eb                	je     800afe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b13:	0f b6 00             	movzbl (%eax),%eax
  800b16:	0f b6 12             	movzbl (%edx),%edx
  800b19:	29 d0                	sub    %edx,%eax
  800b1b:	eb 05                	jmp    800b22 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2f:	eb 07                	jmp    800b38 <strchr+0x13>
		if (*s == c)
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 0f                	je     800b44 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	0f b6 10             	movzbl (%eax),%edx
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f2                	jne    800b31 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b50:	eb 03                	jmp    800b55 <strfind+0xf>
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b58:	38 ca                	cmp    %cl,%dl
  800b5a:	74 04                	je     800b60 <strfind+0x1a>
  800b5c:	84 d2                	test   %dl,%dl
  800b5e:	75 f2                	jne    800b52 <strfind+0xc>
			break;
	return (char *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b6e:	85 c9                	test   %ecx,%ecx
  800b70:	74 36                	je     800ba8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b72:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b78:	75 28                	jne    800ba2 <memset+0x40>
  800b7a:	f6 c1 03             	test   $0x3,%cl
  800b7d:	75 23                	jne    800ba2 <memset+0x40>
		c &= 0xFF;
  800b7f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	c1 e3 08             	shl    $0x8,%ebx
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	c1 e6 18             	shl    $0x18,%esi
  800b8d:	89 d0                	mov    %edx,%eax
  800b8f:	c1 e0 10             	shl    $0x10,%eax
  800b92:	09 f0                	or     %esi,%eax
  800b94:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b96:	89 d8                	mov    %ebx,%eax
  800b98:	09 d0                	or     %edx,%eax
  800b9a:	c1 e9 02             	shr    $0x2,%ecx
  800b9d:	fc                   	cld    
  800b9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba0:	eb 06                	jmp    800ba8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	fc                   	cld    
  800ba6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba8:	89 f8                	mov    %edi,%eax
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbd:	39 c6                	cmp    %eax,%esi
  800bbf:	73 35                	jae    800bf6 <memmove+0x47>
  800bc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc4:	39 d0                	cmp    %edx,%eax
  800bc6:	73 2e                	jae    800bf6 <memmove+0x47>
		s += n;
		d += n;
  800bc8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	09 fe                	or     %edi,%esi
  800bcf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd5:	75 13                	jne    800bea <memmove+0x3b>
  800bd7:	f6 c1 03             	test   $0x3,%cl
  800bda:	75 0e                	jne    800bea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bdc:	83 ef 04             	sub    $0x4,%edi
  800bdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be2:	c1 e9 02             	shr    $0x2,%ecx
  800be5:	fd                   	std    
  800be6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be8:	eb 09                	jmp    800bf3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bea:	83 ef 01             	sub    $0x1,%edi
  800bed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf0:	fd                   	std    
  800bf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf3:	fc                   	cld    
  800bf4:	eb 1d                	jmp    800c13 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf6:	89 f2                	mov    %esi,%edx
  800bf8:	09 c2                	or     %eax,%edx
  800bfa:	f6 c2 03             	test   $0x3,%dl
  800bfd:	75 0f                	jne    800c0e <memmove+0x5f>
  800bff:	f6 c1 03             	test   $0x3,%cl
  800c02:	75 0a                	jne    800c0e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c04:	c1 e9 02             	shr    $0x2,%ecx
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	fc                   	cld    
  800c0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0c:	eb 05                	jmp    800c13 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1a:	ff 75 10             	pushl  0x10(%ebp)
  800c1d:	ff 75 0c             	pushl  0xc(%ebp)
  800c20:	ff 75 08             	pushl  0x8(%ebp)
  800c23:	e8 87 ff ff ff       	call   800baf <memmove>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c35:	89 c6                	mov    %eax,%esi
  800c37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	eb 1a                	jmp    800c56 <memcmp+0x2c>
		if (*s1 != *s2)
  800c3c:	0f b6 08             	movzbl (%eax),%ecx
  800c3f:	0f b6 1a             	movzbl (%edx),%ebx
  800c42:	38 d9                	cmp    %bl,%cl
  800c44:	74 0a                	je     800c50 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c46:	0f b6 c1             	movzbl %cl,%eax
  800c49:	0f b6 db             	movzbl %bl,%ebx
  800c4c:	29 d8                	sub    %ebx,%eax
  800c4e:	eb 0f                	jmp    800c5f <memcmp+0x35>
		s1++, s2++;
  800c50:	83 c0 01             	add    $0x1,%eax
  800c53:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c56:	39 f0                	cmp    %esi,%eax
  800c58:	75 e2                	jne    800c3c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	53                   	push   %ebx
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6a:	89 c1                	mov    %eax,%ecx
  800c6c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c73:	eb 0a                	jmp    800c7f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	39 da                	cmp    %ebx,%edx
  800c7a:	74 07                	je     800c83 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7c:	83 c0 01             	add    $0x1,%eax
  800c7f:	39 c8                	cmp    %ecx,%eax
  800c81:	72 f2                	jb     800c75 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c83:	5b                   	pop    %ebx
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c92:	eb 03                	jmp    800c97 <strtol+0x11>
		s++;
  800c94:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c97:	0f b6 01             	movzbl (%ecx),%eax
  800c9a:	3c 20                	cmp    $0x20,%al
  800c9c:	74 f6                	je     800c94 <strtol+0xe>
  800c9e:	3c 09                	cmp    $0x9,%al
  800ca0:	74 f2                	je     800c94 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca2:	3c 2b                	cmp    $0x2b,%al
  800ca4:	75 0a                	jne    800cb0 <strtol+0x2a>
		s++;
  800ca6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cae:	eb 11                	jmp    800cc1 <strtol+0x3b>
  800cb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb5:	3c 2d                	cmp    $0x2d,%al
  800cb7:	75 08                	jne    800cc1 <strtol+0x3b>
		s++, neg = 1;
  800cb9:	83 c1 01             	add    $0x1,%ecx
  800cbc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc7:	75 15                	jne    800cde <strtol+0x58>
  800cc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccc:	75 10                	jne    800cde <strtol+0x58>
  800cce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd2:	75 7c                	jne    800d50 <strtol+0xca>
		s += 2, base = 16;
  800cd4:	83 c1 02             	add    $0x2,%ecx
  800cd7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cdc:	eb 16                	jmp    800cf4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cde:	85 db                	test   %ebx,%ebx
  800ce0:	75 12                	jne    800cf4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce7:	80 39 30             	cmpb   $0x30,(%ecx)
  800cea:	75 08                	jne    800cf4 <strtol+0x6e>
		s++, base = 8;
  800cec:	83 c1 01             	add    $0x1,%ecx
  800cef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfc:	0f b6 11             	movzbl (%ecx),%edx
  800cff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d02:	89 f3                	mov    %esi,%ebx
  800d04:	80 fb 09             	cmp    $0x9,%bl
  800d07:	77 08                	ja     800d11 <strtol+0x8b>
			dig = *s - '0';
  800d09:	0f be d2             	movsbl %dl,%edx
  800d0c:	83 ea 30             	sub    $0x30,%edx
  800d0f:	eb 22                	jmp    800d33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d14:	89 f3                	mov    %esi,%ebx
  800d16:	80 fb 19             	cmp    $0x19,%bl
  800d19:	77 08                	ja     800d23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d1b:	0f be d2             	movsbl %dl,%edx
  800d1e:	83 ea 57             	sub    $0x57,%edx
  800d21:	eb 10                	jmp    800d33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d26:	89 f3                	mov    %esi,%ebx
  800d28:	80 fb 19             	cmp    $0x19,%bl
  800d2b:	77 16                	ja     800d43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d2d:	0f be d2             	movsbl %dl,%edx
  800d30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d36:	7d 0b                	jge    800d43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d38:	83 c1 01             	add    $0x1,%ecx
  800d3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d41:	eb b9                	jmp    800cfc <strtol+0x76>

	if (endptr)
  800d43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d47:	74 0d                	je     800d56 <strtol+0xd0>
		*endptr = (char *) s;
  800d49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4c:	89 0e                	mov    %ecx,(%esi)
  800d4e:	eb 06                	jmp    800d56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d50:	85 db                	test   %ebx,%ebx
  800d52:	74 98                	je     800cec <strtol+0x66>
  800d54:	eb 9e                	jmp    800cf4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d56:	89 c2                	mov    %eax,%edx
  800d58:	f7 da                	neg    %edx
  800d5a:	85 ff                	test   %edi,%edi
  800d5c:	0f 45 c2             	cmovne %edx,%eax
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	89 c7                	mov    %eax,%edi
  800d79:	89 c6                	mov    %eax,%esi
  800d7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 d3                	mov    %edx,%ebx
  800d96:	89 d7                	mov    %edx,%edi
  800d98:	89 d6                	mov    %edx,%esi
  800d9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daf:	b8 03 00 00 00       	mov    $0x3,%eax
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 cb                	mov    %ecx,%ebx
  800db9:	89 cf                	mov    %ecx,%edi
  800dbb:	89 ce                	mov    %ecx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 03                	push   $0x3
  800dc9:	68 cf 23 80 00       	push   $0x8023cf
  800dce:	6a 23                	push   $0x23
  800dd0:	68 ec 23 80 00       	push   $0x8023ec
  800dd5:	e8 f2 f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ded:	b8 02 00 00 00       	mov    $0x2,%eax
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	89 d3                	mov    %edx,%ebx
  800df6:	89 d7                	mov    %edx,%edi
  800df8:	89 d6                	mov    %edx,%esi
  800dfa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_yield>:

void
sys_yield(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 d7                	mov    %edx,%edi
  800e17:	89 d6                	mov    %edx,%esi
  800e19:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	be 00 00 00 00       	mov    $0x0,%esi
  800e2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3c:	89 f7                	mov    %esi,%edi
  800e3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 17                	jle    800e5b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	50                   	push   %eax
  800e48:	6a 04                	push   $0x4
  800e4a:	68 cf 23 80 00       	push   $0x8023cf
  800e4f:	6a 23                	push   $0x23
  800e51:	68 ec 23 80 00       	push   $0x8023ec
  800e56:	e8 71 f4 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800e80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	7e 17                	jle    800e9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	50                   	push   %eax
  800e8a:	6a 05                	push   $0x5
  800e8c:	68 cf 23 80 00       	push   $0x8023cf
  800e91:	6a 23                	push   $0x23
  800e93:	68 ec 23 80 00       	push   $0x8023ec
  800e98:	e8 2f f4 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb3:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 df                	mov    %ebx,%edi
  800ec0:	89 de                	mov    %ebx,%esi
  800ec2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 17                	jle    800edf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 06                	push   $0x6
  800ece:	68 cf 23 80 00       	push   $0x8023cf
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 ec 23 80 00       	push   $0x8023ec
  800eda:	e8 ed f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef5:	b8 08 00 00 00       	mov    $0x8,%eax
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	89 df                	mov    %ebx,%edi
  800f02:	89 de                	mov    %ebx,%esi
  800f04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f06:	85 c0                	test   %eax,%eax
  800f08:	7e 17                	jle    800f21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	50                   	push   %eax
  800f0e:	6a 08                	push   $0x8
  800f10:	68 cf 23 80 00       	push   $0x8023cf
  800f15:	6a 23                	push   $0x23
  800f17:	68 ec 23 80 00       	push   $0x8023ec
  800f1c:	e8 ab f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f37:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	89 df                	mov    %ebx,%edi
  800f44:	89 de                	mov    %ebx,%esi
  800f46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	7e 17                	jle    800f63 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	50                   	push   %eax
  800f50:	6a 09                	push   $0x9
  800f52:	68 cf 23 80 00       	push   $0x8023cf
  800f57:	6a 23                	push   $0x23
  800f59:	68 ec 23 80 00       	push   $0x8023ec
  800f5e:	e8 69 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 df                	mov    %ebx,%edi
  800f86:	89 de                	mov    %ebx,%esi
  800f88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	7e 17                	jle    800fa5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 0a                	push   $0xa
  800f94:	68 cf 23 80 00       	push   $0x8023cf
  800f99:	6a 23                	push   $0x23
  800f9b:	68 ec 23 80 00       	push   $0x8023ec
  800fa0:	e8 27 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	be 00 00 00 00       	mov    $0x0,%esi
  800fb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fde:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 cb                	mov    %ecx,%ebx
  800fe8:	89 cf                	mov    %ecx,%edi
  800fea:	89 ce                	mov    %ecx,%esi
  800fec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 17                	jle    801009 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	50                   	push   %eax
  800ff6:	6a 0d                	push   $0xd
  800ff8:	68 cf 23 80 00       	push   $0x8023cf
  800ffd:	6a 23                	push   $0x23
  800fff:	68 ec 23 80 00       	push   $0x8023ec
  801004:	e8 c3 f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801009:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	05 00 00 00 30       	add    $0x30000000,%eax
  80101c:	c1 e8 0c             	shr    $0xc,%eax
}
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	05 00 00 00 30       	add    $0x30000000,%eax
  80102c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801031:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801043:	89 c2                	mov    %eax,%edx
  801045:	c1 ea 16             	shr    $0x16,%edx
  801048:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 11                	je     801065 <fd_alloc+0x2d>
  801054:	89 c2                	mov    %eax,%edx
  801056:	c1 ea 0c             	shr    $0xc,%edx
  801059:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801060:	f6 c2 01             	test   $0x1,%dl
  801063:	75 09                	jne    80106e <fd_alloc+0x36>
			*fd_store = fd;
  801065:	89 01                	mov    %eax,(%ecx)
			return 0;
  801067:	b8 00 00 00 00       	mov    $0x0,%eax
  80106c:	eb 17                	jmp    801085 <fd_alloc+0x4d>
  80106e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801073:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801078:	75 c9                	jne    801043 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80107a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801080:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80108d:	83 f8 1f             	cmp    $0x1f,%eax
  801090:	77 36                	ja     8010c8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801092:	c1 e0 0c             	shl    $0xc,%eax
  801095:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80109a:	89 c2                	mov    %eax,%edx
  80109c:	c1 ea 16             	shr    $0x16,%edx
  80109f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a6:	f6 c2 01             	test   $0x1,%dl
  8010a9:	74 24                	je     8010cf <fd_lookup+0x48>
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	c1 ea 0c             	shr    $0xc,%edx
  8010b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 1a                	je     8010d6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010bf:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	eb 13                	jmp    8010db <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cd:	eb 0c                	jmp    8010db <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d4:	eb 05                	jmp    8010db <fd_lookup+0x54>
  8010d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e6:	ba 7c 24 80 00       	mov    $0x80247c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010eb:	eb 13                	jmp    801100 <dev_lookup+0x23>
  8010ed:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010f0:	39 08                	cmp    %ecx,(%eax)
  8010f2:	75 0c                	jne    801100 <dev_lookup+0x23>
			*dev = devtab[i];
  8010f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fe:	eb 2e                	jmp    80112e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801100:	8b 02                	mov    (%edx),%eax
  801102:	85 c0                	test   %eax,%eax
  801104:	75 e7                	jne    8010ed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801106:	a1 04 44 80 00       	mov    0x804404,%eax
  80110b:	8b 40 48             	mov    0x48(%eax),%eax
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	51                   	push   %ecx
  801112:	50                   	push   %eax
  801113:	68 fc 23 80 00       	push   $0x8023fc
  801118:	e8 88 f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  80111d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801120:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 10             	sub    $0x10,%esp
  801138:	8b 75 08             	mov    0x8(%ebp),%esi
  80113b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80113e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801148:	c1 e8 0c             	shr    $0xc,%eax
  80114b:	50                   	push   %eax
  80114c:	e8 36 ff ff ff       	call   801087 <fd_lookup>
  801151:	83 c4 08             	add    $0x8,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 05                	js     80115d <fd_close+0x2d>
	    || fd != fd2)
  801158:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80115b:	74 0c                	je     801169 <fd_close+0x39>
		return (must_exist ? r : 0);
  80115d:	84 db                	test   %bl,%bl
  80115f:	ba 00 00 00 00       	mov    $0x0,%edx
  801164:	0f 44 c2             	cmove  %edx,%eax
  801167:	eb 41                	jmp    8011aa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	ff 36                	pushl  (%esi)
  801172:	e8 66 ff ff ff       	call   8010dd <dev_lookup>
  801177:	89 c3                	mov    %eax,%ebx
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 1a                	js     80119a <fd_close+0x6a>
		if (dev->dev_close)
  801180:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801183:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80118b:	85 c0                	test   %eax,%eax
  80118d:	74 0b                	je     80119a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80118f:	83 ec 0c             	sub    $0xc,%esp
  801192:	56                   	push   %esi
  801193:	ff d0                	call   *%eax
  801195:	89 c3                	mov    %eax,%ebx
  801197:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	56                   	push   %esi
  80119e:	6a 00                	push   $0x0
  8011a0:	e8 00 fd ff ff       	call   800ea5 <sys_page_unmap>
	return r;
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	89 d8                	mov    %ebx,%eax
}
  8011aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	ff 75 08             	pushl  0x8(%ebp)
  8011be:	e8 c4 fe ff ff       	call   801087 <fd_lookup>
  8011c3:	83 c4 08             	add    $0x8,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 10                	js     8011da <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	6a 01                	push   $0x1
  8011cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d2:	e8 59 ff ff ff       	call   801130 <fd_close>
  8011d7:	83 c4 10             	add    $0x10,%esp
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <close_all>:

void
close_all(void)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	e8 c0 ff ff ff       	call   8011b1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f1:	83 c3 01             	add    $0x1,%ebx
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	83 fb 20             	cmp    $0x20,%ebx
  8011fa:	75 ec                	jne    8011e8 <close_all+0xc>
		close(i);
}
  8011fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 2c             	sub    $0x2c,%esp
  80120a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80120d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	ff 75 08             	pushl  0x8(%ebp)
  801214:	e8 6e fe ff ff       	call   801087 <fd_lookup>
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	0f 88 c1 00 00 00    	js     8012e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	56                   	push   %esi
  801228:	e8 84 ff ff ff       	call   8011b1 <close>

	newfd = INDEX2FD(newfdnum);
  80122d:	89 f3                	mov    %esi,%ebx
  80122f:	c1 e3 0c             	shl    $0xc,%ebx
  801232:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801238:	83 c4 04             	add    $0x4,%esp
  80123b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123e:	e8 de fd ff ff       	call   801021 <fd2data>
  801243:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801245:	89 1c 24             	mov    %ebx,(%esp)
  801248:	e8 d4 fd ff ff       	call   801021 <fd2data>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801253:	89 f8                	mov    %edi,%eax
  801255:	c1 e8 16             	shr    $0x16,%eax
  801258:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80125f:	a8 01                	test   $0x1,%al
  801261:	74 37                	je     80129a <dup+0x99>
  801263:	89 f8                	mov    %edi,%eax
  801265:	c1 e8 0c             	shr    $0xc,%eax
  801268:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 26                	je     80129a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801274:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	25 07 0e 00 00       	and    $0xe07,%eax
  801283:	50                   	push   %eax
  801284:	ff 75 d4             	pushl  -0x2c(%ebp)
  801287:	6a 00                	push   $0x0
  801289:	57                   	push   %edi
  80128a:	6a 00                	push   $0x0
  80128c:	e8 d2 fb ff ff       	call   800e63 <sys_page_map>
  801291:	89 c7                	mov    %eax,%edi
  801293:	83 c4 20             	add    $0x20,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 2e                	js     8012c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80129a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80129d:	89 d0                	mov    %edx,%eax
  80129f:	c1 e8 0c             	shr    $0xc,%eax
  8012a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b1:	50                   	push   %eax
  8012b2:	53                   	push   %ebx
  8012b3:	6a 00                	push   $0x0
  8012b5:	52                   	push   %edx
  8012b6:	6a 00                	push   $0x0
  8012b8:	e8 a6 fb ff ff       	call   800e63 <sys_page_map>
  8012bd:	89 c7                	mov    %eax,%edi
  8012bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c4:	85 ff                	test   %edi,%edi
  8012c6:	79 1d                	jns    8012e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	6a 00                	push   $0x0
  8012ce:	e8 d2 fb ff ff       	call   800ea5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 c5 fb ff ff       	call   800ea5 <sys_page_unmap>
	return r;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 f8                	mov    %edi,%eax
}
  8012e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 14             	sub    $0x14,%esp
  8012f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	53                   	push   %ebx
  8012fc:	e8 86 fd ff ff       	call   801087 <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	89 c2                	mov    %eax,%edx
  801306:	85 c0                	test   %eax,%eax
  801308:	78 6d                	js     801377 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	ff 30                	pushl  (%eax)
  801316:	e8 c2 fd ff ff       	call   8010dd <dev_lookup>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 4c                	js     80136e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801322:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801325:	8b 42 08             	mov    0x8(%edx),%eax
  801328:	83 e0 03             	and    $0x3,%eax
  80132b:	83 f8 01             	cmp    $0x1,%eax
  80132e:	75 21                	jne    801351 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801330:	a1 04 44 80 00       	mov    0x804404,%eax
  801335:	8b 40 48             	mov    0x48(%eax),%eax
  801338:	83 ec 04             	sub    $0x4,%esp
  80133b:	53                   	push   %ebx
  80133c:	50                   	push   %eax
  80133d:	68 40 24 80 00       	push   $0x802440
  801342:	e8 5e f0 ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80134f:	eb 26                	jmp    801377 <read+0x8a>
	}
	if (!dev->dev_read)
  801351:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801354:	8b 40 08             	mov    0x8(%eax),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	74 17                	je     801372 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80135b:	83 ec 04             	sub    $0x4,%esp
  80135e:	ff 75 10             	pushl  0x10(%ebp)
  801361:	ff 75 0c             	pushl  0xc(%ebp)
  801364:	52                   	push   %edx
  801365:	ff d0                	call   *%eax
  801367:	89 c2                	mov    %eax,%edx
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	eb 09                	jmp    801377 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136e:	89 c2                	mov    %eax,%edx
  801370:	eb 05                	jmp    801377 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801372:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801377:	89 d0                	mov    %edx,%eax
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801392:	eb 21                	jmp    8013b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	89 f0                	mov    %esi,%eax
  801399:	29 d8                	sub    %ebx,%eax
  80139b:	50                   	push   %eax
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	03 45 0c             	add    0xc(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	57                   	push   %edi
  8013a3:	e8 45 ff ff ff       	call   8012ed <read>
		if (m < 0)
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 10                	js     8013bf <readn+0x41>
			return m;
		if (m == 0)
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	74 0a                	je     8013bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b3:	01 c3                	add    %eax,%ebx
  8013b5:	39 f3                	cmp    %esi,%ebx
  8013b7:	72 db                	jb     801394 <readn+0x16>
  8013b9:	89 d8                	mov    %ebx,%eax
  8013bb:	eb 02                	jmp    8013bf <readn+0x41>
  8013bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5f                   	pop    %edi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 14             	sub    $0x14,%esp
  8013ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	53                   	push   %ebx
  8013d6:	e8 ac fc ff ff       	call   801087 <fd_lookup>
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 68                	js     80144c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ee:	ff 30                	pushl  (%eax)
  8013f0:	e8 e8 fc ff ff       	call   8010dd <dev_lookup>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 47                	js     801443 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801403:	75 21                	jne    801426 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801405:	a1 04 44 80 00       	mov    0x804404,%eax
  80140a:	8b 40 48             	mov    0x48(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	53                   	push   %ebx
  801411:	50                   	push   %eax
  801412:	68 5c 24 80 00       	push   $0x80245c
  801417:	e8 89 ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801424:	eb 26                	jmp    80144c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801426:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801429:	8b 52 0c             	mov    0xc(%edx),%edx
  80142c:	85 d2                	test   %edx,%edx
  80142e:	74 17                	je     801447 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	ff 75 10             	pushl  0x10(%ebp)
  801436:	ff 75 0c             	pushl  0xc(%ebp)
  801439:	50                   	push   %eax
  80143a:	ff d2                	call   *%edx
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	eb 09                	jmp    80144c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	89 c2                	mov    %eax,%edx
  801445:	eb 05                	jmp    80144c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801447:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80144c:	89 d0                	mov    %edx,%eax
  80144e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <seek>:

int
seek(int fdnum, off_t offset)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801459:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 22 fc ff ff       	call   801087 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 0e                	js     80147a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80146c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80146f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801472:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 14             	sub    $0x14,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	53                   	push   %ebx
  80148b:	e8 f7 fb ff ff       	call   801087 <fd_lookup>
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	89 c2                	mov    %eax,%edx
  801495:	85 c0                	test   %eax,%eax
  801497:	78 65                	js     8014fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a3:	ff 30                	pushl  (%eax)
  8014a5:	e8 33 fc ff ff       	call   8010dd <dev_lookup>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 44                	js     8014f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b8:	75 21                	jne    8014db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ba:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014bf:	8b 40 48             	mov    0x48(%eax),%eax
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	53                   	push   %ebx
  8014c6:	50                   	push   %eax
  8014c7:	68 1c 24 80 00       	push   $0x80241c
  8014cc:	e8 d4 ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d9:	eb 23                	jmp    8014fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014de:	8b 52 18             	mov    0x18(%edx),%edx
  8014e1:	85 d2                	test   %edx,%edx
  8014e3:	74 14                	je     8014f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	ff 75 0c             	pushl  0xc(%ebp)
  8014eb:	50                   	push   %eax
  8014ec:	ff d2                	call   *%edx
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 09                	jmp    8014fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	eb 05                	jmp    8014fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014fe:	89 d0                	mov    %edx,%eax
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
  80150c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	ff 75 08             	pushl  0x8(%ebp)
  801516:	e8 6c fb ff ff       	call   801087 <fd_lookup>
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	89 c2                	mov    %eax,%edx
  801520:	85 c0                	test   %eax,%eax
  801522:	78 58                	js     80157c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	ff 30                	pushl  (%eax)
  801530:	e8 a8 fb ff ff       	call   8010dd <dev_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 37                	js     801573 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80153c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801543:	74 32                	je     801577 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801545:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801548:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80154f:	00 00 00 
	stat->st_isdir = 0;
  801552:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801559:	00 00 00 
	stat->st_dev = dev;
  80155c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	53                   	push   %ebx
  801566:	ff 75 f0             	pushl  -0x10(%ebp)
  801569:	ff 50 14             	call   *0x14(%eax)
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 09                	jmp    80157c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801573:	89 c2                	mov    %eax,%edx
  801575:	eb 05                	jmp    80157c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801577:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80157c:	89 d0                	mov    %edx,%eax
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	6a 00                	push   $0x0
  80158d:	ff 75 08             	pushl  0x8(%ebp)
  801590:	e8 b7 01 00 00       	call   80174c <open>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 1b                	js     8015b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	50                   	push   %eax
  8015a5:	e8 5b ff ff ff       	call   801505 <fstat>
  8015aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ac:	89 1c 24             	mov    %ebx,(%esp)
  8015af:	e8 fd fb ff ff       	call   8011b1 <close>
	return r;
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	89 f0                	mov    %esi,%eax
}
  8015b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5e                   	pop    %esi
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	89 c6                	mov    %eax,%esi
  8015c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015c9:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8015d0:	75 12                	jne    8015e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	6a 01                	push   $0x1
  8015d7:	e8 3b 07 00 00       	call   801d17 <ipc_find_env>
  8015dc:	a3 00 44 80 00       	mov    %eax,0x804400
  8015e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015e4:	6a 07                	push   $0x7
  8015e6:	68 00 50 80 00       	push   $0x805000
  8015eb:	56                   	push   %esi
  8015ec:	ff 35 00 44 80 00    	pushl  0x804400
  8015f2:	e8 cc 06 00 00       	call   801cc3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015f7:	83 c4 0c             	add    $0xc,%esp
  8015fa:	6a 00                	push   $0x0
  8015fc:	53                   	push   %ebx
  8015fd:	6a 00                	push   $0x0
  8015ff:	e8 58 06 00 00       	call   801c5c <ipc_recv>
}
  801604:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 40 0c             	mov    0xc(%eax),%eax
  801617:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80161c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801624:	ba 00 00 00 00       	mov    $0x0,%edx
  801629:	b8 02 00 00 00       	mov    $0x2,%eax
  80162e:	e8 8d ff ff ff       	call   8015c0 <fsipc>
}
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	8b 40 0c             	mov    0xc(%eax),%eax
  801641:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	b8 06 00 00 00       	mov    $0x6,%eax
  801650:	e8 6b ff ff ff       	call   8015c0 <fsipc>
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	8b 40 0c             	mov    0xc(%eax),%eax
  801667:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	b8 05 00 00 00       	mov    $0x5,%eax
  801676:	e8 45 ff ff ff       	call   8015c0 <fsipc>
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 2c                	js     8016ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	68 00 50 80 00       	push   $0x805000
  801687:	53                   	push   %ebx
  801688:	e8 90 f3 ff ff       	call   800a1d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80168d:	a1 80 50 80 00       	mov    0x805080,%eax
  801692:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801698:	a1 84 50 80 00       	mov    0x805084,%eax
  80169d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016b6:	68 8c 24 80 00       	push   $0x80248c
  8016bb:	68 90 00 00 00       	push   $0x90
  8016c0:	68 aa 24 80 00       	push   $0x8024aa
  8016c5:	e8 02 ec ff ff       	call   8002cc <_panic>

008016ca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016dd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ed:	e8 ce fe ff ff       	call   8015c0 <fsipc>
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 4b                	js     801743 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8016f8:	39 c6                	cmp    %eax,%esi
  8016fa:	73 16                	jae    801712 <devfile_read+0x48>
  8016fc:	68 b5 24 80 00       	push   $0x8024b5
  801701:	68 bc 24 80 00       	push   $0x8024bc
  801706:	6a 7c                	push   $0x7c
  801708:	68 aa 24 80 00       	push   $0x8024aa
  80170d:	e8 ba eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  801712:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801717:	7e 16                	jle    80172f <devfile_read+0x65>
  801719:	68 d1 24 80 00       	push   $0x8024d1
  80171e:	68 bc 24 80 00       	push   $0x8024bc
  801723:	6a 7d                	push   $0x7d
  801725:	68 aa 24 80 00       	push   $0x8024aa
  80172a:	e8 9d eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80172f:	83 ec 04             	sub    $0x4,%esp
  801732:	50                   	push   %eax
  801733:	68 00 50 80 00       	push   $0x805000
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	e8 6f f4 ff ff       	call   800baf <memmove>
	return r;
  801740:	83 c4 10             	add    $0x10,%esp
}
  801743:	89 d8                	mov    %ebx,%eax
  801745:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 20             	sub    $0x20,%esp
  801753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801756:	53                   	push   %ebx
  801757:	e8 88 f2 ff ff       	call   8009e4 <strlen>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801764:	7f 67                	jg     8017cd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	e8 c6 f8 ff ff       	call   801038 <fd_alloc>
  801772:	83 c4 10             	add    $0x10,%esp
		return r;
  801775:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801777:	85 c0                	test   %eax,%eax
  801779:	78 57                	js     8017d2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	53                   	push   %ebx
  80177f:	68 00 50 80 00       	push   $0x805000
  801784:	e8 94 f2 ff ff       	call   800a1d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801791:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801794:	b8 01 00 00 00       	mov    $0x1,%eax
  801799:	e8 22 fe ff ff       	call   8015c0 <fsipc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	79 14                	jns    8017bb <open+0x6f>
		fd_close(fd, 0);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	6a 00                	push   $0x0
  8017ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8017af:	e8 7c f9 ff ff       	call   801130 <fd_close>
		return r;
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	89 da                	mov    %ebx,%edx
  8017b9:	eb 17                	jmp    8017d2 <open+0x86>
	}

	return fd2num(fd);
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c1:	e8 4b f8 ff ff       	call   801011 <fd2num>
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	eb 05                	jmp    8017d2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017cd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017d2:	89 d0                	mov    %edx,%eax
  8017d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8017e9:	e8 d2 fd ff ff       	call   8015c0 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8017f0:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017f4:	7e 37                	jle    80182d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017ff:	ff 70 04             	pushl  0x4(%eax)
  801802:	8d 40 10             	lea    0x10(%eax),%eax
  801805:	50                   	push   %eax
  801806:	ff 33                	pushl  (%ebx)
  801808:	e8 ba fb ff ff       	call   8013c7 <write>
		if (result > 0)
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	7e 03                	jle    801817 <writebuf+0x27>
			b->result += result;
  801814:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801817:	3b 43 04             	cmp    0x4(%ebx),%eax
  80181a:	74 0d                	je     801829 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80181c:	85 c0                	test   %eax,%eax
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	0f 4f c2             	cmovg  %edx,%eax
  801826:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	f3 c3                	repz ret 

0080182f <putch>:

static void
putch(int ch, void *thunk)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	83 ec 04             	sub    $0x4,%esp
  801836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801839:	8b 53 04             	mov    0x4(%ebx),%edx
  80183c:	8d 42 01             	lea    0x1(%edx),%eax
  80183f:	89 43 04             	mov    %eax,0x4(%ebx)
  801842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801845:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801849:	3d 00 01 00 00       	cmp    $0x100,%eax
  80184e:	75 0e                	jne    80185e <putch+0x2f>
		writebuf(b);
  801850:	89 d8                	mov    %ebx,%eax
  801852:	e8 99 ff ff ff       	call   8017f0 <writebuf>
		b->idx = 0;
  801857:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80185e:	83 c4 04             	add    $0x4,%esp
  801861:	5b                   	pop    %ebx
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801876:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80187d:	00 00 00 
	b.result = 0;
  801880:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801887:	00 00 00 
	b.error = 1;
  80188a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801891:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801894:	ff 75 10             	pushl  0x10(%ebp)
  801897:	ff 75 0c             	pushl  0xc(%ebp)
  80189a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018a0:	50                   	push   %eax
  8018a1:	68 2f 18 80 00       	push   $0x80182f
  8018a6:	e8 31 ec ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018b5:	7e 0b                	jle    8018c2 <vfprintf+0x5e>
		writebuf(&b);
  8018b7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018bd:	e8 2e ff ff ff       	call   8017f0 <writebuf>

	return (b.result ? b.result : b.error);
  8018c2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018d9:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018dc:	50                   	push   %eax
  8018dd:	ff 75 0c             	pushl  0xc(%ebp)
  8018e0:	ff 75 08             	pushl  0x8(%ebp)
  8018e3:	e8 7c ff ff ff       	call   801864 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <printf>:

int
printf(const char *fmt, ...)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018f3:	50                   	push   %eax
  8018f4:	ff 75 08             	pushl  0x8(%ebp)
  8018f7:	6a 01                	push   $0x1
  8018f9:	e8 66 ff ff ff       	call   801864 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 08             	pushl  0x8(%ebp)
  80190e:	e8 0e f7 ff ff       	call   801021 <fd2data>
  801913:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801915:	83 c4 08             	add    $0x8,%esp
  801918:	68 dd 24 80 00       	push   $0x8024dd
  80191d:	53                   	push   %ebx
  80191e:	e8 fa f0 ff ff       	call   800a1d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801923:	8b 46 04             	mov    0x4(%esi),%eax
  801926:	2b 06                	sub    (%esi),%eax
  801928:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80192e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801935:	00 00 00 
	stat->st_dev = &devpipe;
  801938:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80193f:	30 80 00 
	return 0;
}
  801942:	b8 00 00 00 00       	mov    $0x0,%eax
  801947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801958:	53                   	push   %ebx
  801959:	6a 00                	push   $0x0
  80195b:	e8 45 f5 ff ff       	call   800ea5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801960:	89 1c 24             	mov    %ebx,(%esp)
  801963:	e8 b9 f6 ff ff       	call   801021 <fd2data>
  801968:	83 c4 08             	add    $0x8,%esp
  80196b:	50                   	push   %eax
  80196c:	6a 00                	push   $0x0
  80196e:	e8 32 f5 ff ff       	call   800ea5 <sys_page_unmap>
}
  801973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	57                   	push   %edi
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
  80197e:	83 ec 1c             	sub    $0x1c,%esp
  801981:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801984:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801986:	a1 04 44 80 00       	mov    0x804404,%eax
  80198b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	ff 75 e0             	pushl  -0x20(%ebp)
  801994:	e8 b7 03 00 00       	call   801d50 <pageref>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	89 3c 24             	mov    %edi,(%esp)
  80199e:	e8 ad 03 00 00       	call   801d50 <pageref>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	39 c3                	cmp    %eax,%ebx
  8019a8:	0f 94 c1             	sete   %cl
  8019ab:	0f b6 c9             	movzbl %cl,%ecx
  8019ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019b1:	8b 15 04 44 80 00    	mov    0x804404,%edx
  8019b7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ba:	39 ce                	cmp    %ecx,%esi
  8019bc:	74 1b                	je     8019d9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019be:	39 c3                	cmp    %eax,%ebx
  8019c0:	75 c4                	jne    801986 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019c2:	8b 42 58             	mov    0x58(%edx),%eax
  8019c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c8:	50                   	push   %eax
  8019c9:	56                   	push   %esi
  8019ca:	68 e4 24 80 00       	push   $0x8024e4
  8019cf:	e8 d1 e9 ff ff       	call   8003a5 <cprintf>
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	eb ad                	jmp    801986 <_pipeisclosed+0xe>
	}
}
  8019d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5f                   	pop    %edi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 28             	sub    $0x28,%esp
  8019ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019f0:	56                   	push   %esi
  8019f1:	e8 2b f6 ff ff       	call   801021 <fd2data>
  8019f6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801a00:	eb 4b                	jmp    801a4d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a02:	89 da                	mov    %ebx,%edx
  801a04:	89 f0                	mov    %esi,%eax
  801a06:	e8 6d ff ff ff       	call   801978 <_pipeisclosed>
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	75 48                	jne    801a57 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a0f:	e8 ed f3 ff ff       	call   800e01 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a14:	8b 43 04             	mov    0x4(%ebx),%eax
  801a17:	8b 0b                	mov    (%ebx),%ecx
  801a19:	8d 51 20             	lea    0x20(%ecx),%edx
  801a1c:	39 d0                	cmp    %edx,%eax
  801a1e:	73 e2                	jae    801a02 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a23:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a27:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	c1 fa 1f             	sar    $0x1f,%edx
  801a2f:	89 d1                	mov    %edx,%ecx
  801a31:	c1 e9 1b             	shr    $0x1b,%ecx
  801a34:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a37:	83 e2 1f             	and    $0x1f,%edx
  801a3a:	29 ca                	sub    %ecx,%edx
  801a3c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a40:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a44:	83 c0 01             	add    $0x1,%eax
  801a47:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4a:	83 c7 01             	add    $0x1,%edi
  801a4d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a50:	75 c2                	jne    801a14 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a52:	8b 45 10             	mov    0x10(%ebp),%eax
  801a55:	eb 05                	jmp    801a5c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a57:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5f                   	pop    %edi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	57                   	push   %edi
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 18             	sub    $0x18,%esp
  801a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a70:	57                   	push   %edi
  801a71:	e8 ab f5 ff ff       	call   801021 <fd2data>
  801a76:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a80:	eb 3d                	jmp    801abf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a82:	85 db                	test   %ebx,%ebx
  801a84:	74 04                	je     801a8a <devpipe_read+0x26>
				return i;
  801a86:	89 d8                	mov    %ebx,%eax
  801a88:	eb 44                	jmp    801ace <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a8a:	89 f2                	mov    %esi,%edx
  801a8c:	89 f8                	mov    %edi,%eax
  801a8e:	e8 e5 fe ff ff       	call   801978 <_pipeisclosed>
  801a93:	85 c0                	test   %eax,%eax
  801a95:	75 32                	jne    801ac9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a97:	e8 65 f3 ff ff       	call   800e01 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a9c:	8b 06                	mov    (%esi),%eax
  801a9e:	3b 46 04             	cmp    0x4(%esi),%eax
  801aa1:	74 df                	je     801a82 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aa3:	99                   	cltd   
  801aa4:	c1 ea 1b             	shr    $0x1b,%edx
  801aa7:	01 d0                	add    %edx,%eax
  801aa9:	83 e0 1f             	and    $0x1f,%eax
  801aac:	29 d0                	sub    %edx,%eax
  801aae:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ab9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abc:	83 c3 01             	add    $0x1,%ebx
  801abf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ac2:	75 d8                	jne    801a9c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ac4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac7:	eb 05                	jmp    801ace <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae1:	50                   	push   %eax
  801ae2:	e8 51 f5 ff ff       	call   801038 <fd_alloc>
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	85 c0                	test   %eax,%eax
  801aee:	0f 88 2c 01 00 00    	js     801c20 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af4:	83 ec 04             	sub    $0x4,%esp
  801af7:	68 07 04 00 00       	push   $0x407
  801afc:	ff 75 f4             	pushl  -0xc(%ebp)
  801aff:	6a 00                	push   $0x0
  801b01:	e8 1a f3 ff ff       	call   800e20 <sys_page_alloc>
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	89 c2                	mov    %eax,%edx
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	0f 88 0d 01 00 00    	js     801c20 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b19:	50                   	push   %eax
  801b1a:	e8 19 f5 ff ff       	call   801038 <fd_alloc>
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	0f 88 e2 00 00 00    	js     801c0e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2c:	83 ec 04             	sub    $0x4,%esp
  801b2f:	68 07 04 00 00       	push   $0x407
  801b34:	ff 75 f0             	pushl  -0x10(%ebp)
  801b37:	6a 00                	push   $0x0
  801b39:	e8 e2 f2 ff ff       	call   800e20 <sys_page_alloc>
  801b3e:	89 c3                	mov    %eax,%ebx
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	85 c0                	test   %eax,%eax
  801b45:	0f 88 c3 00 00 00    	js     801c0e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b51:	e8 cb f4 ff ff       	call   801021 <fd2data>
  801b56:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b58:	83 c4 0c             	add    $0xc,%esp
  801b5b:	68 07 04 00 00       	push   $0x407
  801b60:	50                   	push   %eax
  801b61:	6a 00                	push   $0x0
  801b63:	e8 b8 f2 ff ff       	call   800e20 <sys_page_alloc>
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	0f 88 89 00 00 00    	js     801bfe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b75:	83 ec 0c             	sub    $0xc,%esp
  801b78:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7b:	e8 a1 f4 ff ff       	call   801021 <fd2data>
  801b80:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b87:	50                   	push   %eax
  801b88:	6a 00                	push   $0x0
  801b8a:	56                   	push   %esi
  801b8b:	6a 00                	push   $0x0
  801b8d:	e8 d1 f2 ff ff       	call   800e63 <sys_page_map>
  801b92:	89 c3                	mov    %eax,%ebx
  801b94:	83 c4 20             	add    $0x20,%esp
  801b97:	85 c0                	test   %eax,%eax
  801b99:	78 55                	js     801bf0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcb:	e8 41 f4 ff ff       	call   801011 <fd2num>
  801bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd5:	83 c4 04             	add    $0x4,%esp
  801bd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdb:	e8 31 f4 ff ff       	call   801011 <fd2num>
  801be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bee:	eb 30                	jmp    801c20 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	56                   	push   %esi
  801bf4:	6a 00                	push   $0x0
  801bf6:	e8 aa f2 ff ff       	call   800ea5 <sys_page_unmap>
  801bfb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bfe:	83 ec 08             	sub    $0x8,%esp
  801c01:	ff 75 f0             	pushl  -0x10(%ebp)
  801c04:	6a 00                	push   $0x0
  801c06:	e8 9a f2 ff ff       	call   800ea5 <sys_page_unmap>
  801c0b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c0e:	83 ec 08             	sub    $0x8,%esp
  801c11:	ff 75 f4             	pushl  -0xc(%ebp)
  801c14:	6a 00                	push   $0x0
  801c16:	e8 8a f2 ff ff       	call   800ea5 <sys_page_unmap>
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c20:	89 d0                	mov    %edx,%eax
  801c22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c32:	50                   	push   %eax
  801c33:	ff 75 08             	pushl  0x8(%ebp)
  801c36:	e8 4c f4 ff ff       	call   801087 <fd_lookup>
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 18                	js     801c5a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	ff 75 f4             	pushl  -0xc(%ebp)
  801c48:	e8 d4 f3 ff ff       	call   801021 <fd2data>
	return _pipeisclosed(fd, p);
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c52:	e8 21 fd ff ff       	call   801978 <_pipeisclosed>
  801c57:	83 c4 10             	add    $0x10,%esp
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	8b 75 08             	mov    0x8(%ebp),%esi
  801c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801c6a:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801c6c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c71:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	50                   	push   %eax
  801c78:	e8 53 f3 ff ff       	call   800fd0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 f6                	test   %esi,%esi
  801c82:	74 14                	je     801c98 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801c84:	ba 00 00 00 00       	mov    $0x0,%edx
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 09                	js     801c96 <ipc_recv+0x3a>
  801c8d:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801c93:	8b 52 74             	mov    0x74(%edx),%edx
  801c96:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801c98:	85 db                	test   %ebx,%ebx
  801c9a:	74 14                	je     801cb0 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 09                	js     801cae <ipc_recv+0x52>
  801ca5:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801cab:	8b 52 78             	mov    0x78(%edx),%edx
  801cae:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	78 08                	js     801cbc <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801cb4:	a1 04 44 80 00       	mov    0x804404,%eax
  801cb9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	57                   	push   %edi
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ccf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801cd5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801cd7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cdc:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801cdf:	ff 75 14             	pushl  0x14(%ebp)
  801ce2:	53                   	push   %ebx
  801ce3:	56                   	push   %esi
  801ce4:	57                   	push   %edi
  801ce5:	e8 c3 f2 ff ff       	call   800fad <sys_ipc_try_send>

		if (err < 0) {
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	79 1e                	jns    801d0f <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801cf1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cf4:	75 07                	jne    801cfd <ipc_send+0x3a>
				sys_yield();
  801cf6:	e8 06 f1 ff ff       	call   800e01 <sys_yield>
  801cfb:	eb e2                	jmp    801cdf <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801cfd:	50                   	push   %eax
  801cfe:	68 fc 24 80 00       	push   $0x8024fc
  801d03:	6a 49                	push   $0x49
  801d05:	68 09 25 80 00       	push   $0x802509
  801d0a:	e8 bd e5 ff ff       	call   8002cc <_panic>
		}

	} while (err < 0);

}
  801d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d12:	5b                   	pop    %ebx
  801d13:	5e                   	pop    %esi
  801d14:	5f                   	pop    %edi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d22:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d25:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d2b:	8b 52 50             	mov    0x50(%edx),%edx
  801d2e:	39 ca                	cmp    %ecx,%edx
  801d30:	75 0d                	jne    801d3f <ipc_find_env+0x28>
			return envs[i].env_id;
  801d32:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d3a:	8b 40 48             	mov    0x48(%eax),%eax
  801d3d:	eb 0f                	jmp    801d4e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d3f:	83 c0 01             	add    $0x1,%eax
  801d42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d47:	75 d9                	jne    801d22 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	c1 e8 16             	shr    $0x16,%eax
  801d5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d67:	f6 c1 01             	test   $0x1,%cl
  801d6a:	74 1d                	je     801d89 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d6c:	c1 ea 0c             	shr    $0xc,%edx
  801d6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d76:	f6 c2 01             	test   $0x1,%dl
  801d79:	74 0e                	je     801d89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d7b:	c1 ea 0c             	shr    $0xc,%edx
  801d7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d85:	ef 
  801d86:	0f b7 c0             	movzwl %ax,%eax
}
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    
  801d8b:	66 90                	xchg   %ax,%ax
  801d8d:	66 90                	xchg   %ax,%ax
  801d8f:	90                   	nop

00801d90 <__udivdi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	85 f6                	test   %esi,%esi
  801da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dad:	89 ca                	mov    %ecx,%edx
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	75 3d                	jne    801df0 <__udivdi3+0x60>
  801db3:	39 cf                	cmp    %ecx,%edi
  801db5:	0f 87 c5 00 00 00    	ja     801e80 <__udivdi3+0xf0>
  801dbb:	85 ff                	test   %edi,%edi
  801dbd:	89 fd                	mov    %edi,%ebp
  801dbf:	75 0b                	jne    801dcc <__udivdi3+0x3c>
  801dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc6:	31 d2                	xor    %edx,%edx
  801dc8:	f7 f7                	div    %edi
  801dca:	89 c5                	mov    %eax,%ebp
  801dcc:	89 c8                	mov    %ecx,%eax
  801dce:	31 d2                	xor    %edx,%edx
  801dd0:	f7 f5                	div    %ebp
  801dd2:	89 c1                	mov    %eax,%ecx
  801dd4:	89 d8                	mov    %ebx,%eax
  801dd6:	89 cf                	mov    %ecx,%edi
  801dd8:	f7 f5                	div    %ebp
  801dda:	89 c3                	mov    %eax,%ebx
  801ddc:	89 d8                	mov    %ebx,%eax
  801dde:	89 fa                	mov    %edi,%edx
  801de0:	83 c4 1c             	add    $0x1c,%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    
  801de8:	90                   	nop
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	39 ce                	cmp    %ecx,%esi
  801df2:	77 74                	ja     801e68 <__udivdi3+0xd8>
  801df4:	0f bd fe             	bsr    %esi,%edi
  801df7:	83 f7 1f             	xor    $0x1f,%edi
  801dfa:	0f 84 98 00 00 00    	je     801e98 <__udivdi3+0x108>
  801e00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	89 c5                	mov    %eax,%ebp
  801e09:	29 fb                	sub    %edi,%ebx
  801e0b:	d3 e6                	shl    %cl,%esi
  801e0d:	89 d9                	mov    %ebx,%ecx
  801e0f:	d3 ed                	shr    %cl,%ebp
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	d3 e0                	shl    %cl,%eax
  801e15:	09 ee                	or     %ebp,%esi
  801e17:	89 d9                	mov    %ebx,%ecx
  801e19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e1d:	89 d5                	mov    %edx,%ebp
  801e1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e23:	d3 ed                	shr    %cl,%ebp
  801e25:	89 f9                	mov    %edi,%ecx
  801e27:	d3 e2                	shl    %cl,%edx
  801e29:	89 d9                	mov    %ebx,%ecx
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	09 c2                	or     %eax,%edx
  801e2f:	89 d0                	mov    %edx,%eax
  801e31:	89 ea                	mov    %ebp,%edx
  801e33:	f7 f6                	div    %esi
  801e35:	89 d5                	mov    %edx,%ebp
  801e37:	89 c3                	mov    %eax,%ebx
  801e39:	f7 64 24 0c          	mull   0xc(%esp)
  801e3d:	39 d5                	cmp    %edx,%ebp
  801e3f:	72 10                	jb     801e51 <__udivdi3+0xc1>
  801e41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	d3 e6                	shl    %cl,%esi
  801e49:	39 c6                	cmp    %eax,%esi
  801e4b:	73 07                	jae    801e54 <__udivdi3+0xc4>
  801e4d:	39 d5                	cmp    %edx,%ebp
  801e4f:	75 03                	jne    801e54 <__udivdi3+0xc4>
  801e51:	83 eb 01             	sub    $0x1,%ebx
  801e54:	31 ff                	xor    %edi,%edi
  801e56:	89 d8                	mov    %ebx,%eax
  801e58:	89 fa                	mov    %edi,%edx
  801e5a:	83 c4 1c             	add    $0x1c,%esp
  801e5d:	5b                   	pop    %ebx
  801e5e:	5e                   	pop    %esi
  801e5f:	5f                   	pop    %edi
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    
  801e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e68:	31 ff                	xor    %edi,%edi
  801e6a:	31 db                	xor    %ebx,%ebx
  801e6c:	89 d8                	mov    %ebx,%eax
  801e6e:	89 fa                	mov    %edi,%edx
  801e70:	83 c4 1c             	add    $0x1c,%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    
  801e78:	90                   	nop
  801e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e80:	89 d8                	mov    %ebx,%eax
  801e82:	f7 f7                	div    %edi
  801e84:	31 ff                	xor    %edi,%edi
  801e86:	89 c3                	mov    %eax,%ebx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 fa                	mov    %edi,%edx
  801e8c:	83 c4 1c             	add    $0x1c,%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5e                   	pop    %esi
  801e91:	5f                   	pop    %edi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    
  801e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e98:	39 ce                	cmp    %ecx,%esi
  801e9a:	72 0c                	jb     801ea8 <__udivdi3+0x118>
  801e9c:	31 db                	xor    %ebx,%ebx
  801e9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ea2:	0f 87 34 ff ff ff    	ja     801ddc <__udivdi3+0x4c>
  801ea8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ead:	e9 2a ff ff ff       	jmp    801ddc <__udivdi3+0x4c>
  801eb2:	66 90                	xchg   %ax,%ax
  801eb4:	66 90                	xchg   %ax,%ax
  801eb6:	66 90                	xchg   %ax,%ax
  801eb8:	66 90                	xchg   %ax,%ax
  801eba:	66 90                	xchg   %ax,%ax
  801ebc:	66 90                	xchg   %ax,%ax
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <__umoddi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 1c             	sub    $0x1c,%esp
  801ec7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ecb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ecf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ed7:	85 d2                	test   %edx,%edx
  801ed9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee1:	89 f3                	mov    %esi,%ebx
  801ee3:	89 3c 24             	mov    %edi,(%esp)
  801ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eea:	75 1c                	jne    801f08 <__umoddi3+0x48>
  801eec:	39 f7                	cmp    %esi,%edi
  801eee:	76 50                	jbe    801f40 <__umoddi3+0x80>
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	f7 f7                	div    %edi
  801ef6:	89 d0                	mov    %edx,%eax
  801ef8:	31 d2                	xor    %edx,%edx
  801efa:	83 c4 1c             	add    $0x1c,%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5f                   	pop    %edi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    
  801f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f08:	39 f2                	cmp    %esi,%edx
  801f0a:	89 d0                	mov    %edx,%eax
  801f0c:	77 52                	ja     801f60 <__umoddi3+0xa0>
  801f0e:	0f bd ea             	bsr    %edx,%ebp
  801f11:	83 f5 1f             	xor    $0x1f,%ebp
  801f14:	75 5a                	jne    801f70 <__umoddi3+0xb0>
  801f16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f1a:	0f 82 e0 00 00 00    	jb     802000 <__umoddi3+0x140>
  801f20:	39 0c 24             	cmp    %ecx,(%esp)
  801f23:	0f 86 d7 00 00 00    	jbe    802000 <__umoddi3+0x140>
  801f29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f31:	83 c4 1c             	add    $0x1c,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	85 ff                	test   %edi,%edi
  801f42:	89 fd                	mov    %edi,%ebp
  801f44:	75 0b                	jne    801f51 <__umoddi3+0x91>
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	f7 f7                	div    %edi
  801f4f:	89 c5                	mov    %eax,%ebp
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	31 d2                	xor    %edx,%edx
  801f55:	f7 f5                	div    %ebp
  801f57:	89 c8                	mov    %ecx,%eax
  801f59:	f7 f5                	div    %ebp
  801f5b:	89 d0                	mov    %edx,%eax
  801f5d:	eb 99                	jmp    801ef8 <__umoddi3+0x38>
  801f5f:	90                   	nop
  801f60:	89 c8                	mov    %ecx,%eax
  801f62:	89 f2                	mov    %esi,%edx
  801f64:	83 c4 1c             	add    $0x1c,%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    
  801f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f70:	8b 34 24             	mov    (%esp),%esi
  801f73:	bf 20 00 00 00       	mov    $0x20,%edi
  801f78:	89 e9                	mov    %ebp,%ecx
  801f7a:	29 ef                	sub    %ebp,%edi
  801f7c:	d3 e0                	shl    %cl,%eax
  801f7e:	89 f9                	mov    %edi,%ecx
  801f80:	89 f2                	mov    %esi,%edx
  801f82:	d3 ea                	shr    %cl,%edx
  801f84:	89 e9                	mov    %ebp,%ecx
  801f86:	09 c2                	or     %eax,%edx
  801f88:	89 d8                	mov    %ebx,%eax
  801f8a:	89 14 24             	mov    %edx,(%esp)
  801f8d:	89 f2                	mov    %esi,%edx
  801f8f:	d3 e2                	shl    %cl,%edx
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f9b:	d3 e8                	shr    %cl,%eax
  801f9d:	89 e9                	mov    %ebp,%ecx
  801f9f:	89 c6                	mov    %eax,%esi
  801fa1:	d3 e3                	shl    %cl,%ebx
  801fa3:	89 f9                	mov    %edi,%ecx
  801fa5:	89 d0                	mov    %edx,%eax
  801fa7:	d3 e8                	shr    %cl,%eax
  801fa9:	89 e9                	mov    %ebp,%ecx
  801fab:	09 d8                	or     %ebx,%eax
  801fad:	89 d3                	mov    %edx,%ebx
  801faf:	89 f2                	mov    %esi,%edx
  801fb1:	f7 34 24             	divl   (%esp)
  801fb4:	89 d6                	mov    %edx,%esi
  801fb6:	d3 e3                	shl    %cl,%ebx
  801fb8:	f7 64 24 04          	mull   0x4(%esp)
  801fbc:	39 d6                	cmp    %edx,%esi
  801fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc2:	89 d1                	mov    %edx,%ecx
  801fc4:	89 c3                	mov    %eax,%ebx
  801fc6:	72 08                	jb     801fd0 <__umoddi3+0x110>
  801fc8:	75 11                	jne    801fdb <__umoddi3+0x11b>
  801fca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fce:	73 0b                	jae    801fdb <__umoddi3+0x11b>
  801fd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801fd4:	1b 14 24             	sbb    (%esp),%edx
  801fd7:	89 d1                	mov    %edx,%ecx
  801fd9:	89 c3                	mov    %eax,%ebx
  801fdb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fdf:	29 da                	sub    %ebx,%edx
  801fe1:	19 ce                	sbb    %ecx,%esi
  801fe3:	89 f9                	mov    %edi,%ecx
  801fe5:	89 f0                	mov    %esi,%eax
  801fe7:	d3 e0                	shl    %cl,%eax
  801fe9:	89 e9                	mov    %ebp,%ecx
  801feb:	d3 ea                	shr    %cl,%edx
  801fed:	89 e9                	mov    %ebp,%ecx
  801fef:	d3 ee                	shr    %cl,%esi
  801ff1:	09 d0                	or     %edx,%eax
  801ff3:	89 f2                	mov    %esi,%edx
  801ff5:	83 c4 1c             	add    $0x1c,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    
  801ffd:	8d 76 00             	lea    0x0(%esi),%esi
  802000:	29 f9                	sub    %edi,%ecx
  802002:	19 d6                	sbb    %edx,%esi
  802004:	89 74 24 04          	mov    %esi,0x4(%esp)
  802008:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80200c:	e9 18 ff ff ff       	jmp    801f29 <__umoddi3+0x69>
