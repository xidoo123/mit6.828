
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 62 22 80 00       	push   $0x802262
  80005f:	e8 3f 19 00 00       	call   8019a3 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 c8 22 80 00       	mov    $0x8022c8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 cb 08 00 00       	call   800949 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba c8 22 80 00       	mov    $0x8022c8,%edx
  80008b:	b8 60 22 80 00       	mov    $0x802260,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 6b 22 80 00       	push   $0x80226b
  80009d:	e8 01 19 00 00       	call   8019a3 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 1e 27 80 00       	push   $0x80271e
  8000b0:	e8 ee 18 00 00       	call   8019a3 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 60 22 80 00       	push   $0x802260
  8000cf:	e8 cf 18 00 00       	call   8019a3 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 c7 22 80 00       	push   $0x8022c7
  8000df:	e8 bf 18 00 00       	call   8019a3 <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 00 17 00 00       	call   801805 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 70 22 80 00       	push   $0x802270
  800118:	6a 1d                	push   $0x1d
  80011a:	68 7c 22 80 00       	push   $0x80227c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 d3 12 00 00       	call   801437 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 86 22 80 00       	push   $0x802286
  800178:	6a 22                	push   $0x22
  80017a:	68 7c 22 80 00       	push   $0x80227c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 cc 22 80 00       	push   $0x8022cc
  800192:	6a 24                	push   $0x24
  800194:	68 7c 22 80 00       	push   $0x80227c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 7c 14 00 00       	call   80163c <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 a1 22 80 00       	push   $0x8022a1
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 7c 22 80 00       	push   $0x80227c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 ad 22 80 00       	push   $0x8022ad
  800225:	e8 79 17 00 00       	call   8019a3 <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 29 0d 00 00       	call   800f76 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 2a 0d 00 00       	call   800fa6 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 c8 22 80 00       	push   $0x8022c8
  800296:	68 60 22 80 00       	push   $0x802260
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 73 0a 00 00       	call   800d47 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 80 0f 00 00       	call   801295 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 e7 09 00 00       	call   800d06 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 10 0a 00 00       	call   800d47 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 f8 22 80 00       	push   $0x8022f8
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 c7 22 80 00 	movl   $0x8022c7,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 2f 09 00 00       	call   800cc9 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 d4 08 00 00       	call   800cc9 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 6b 1b 00 00       	call   801fd0 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 58 1c 00 00       	call   802100 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 1b 23 80 00 	movsbl 0x80231b(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 89 03 00 00    	je     8008d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 1a 03 00 00    	ja     8008be <vprintfmt+0x38a>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 39                	ja     80060d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ea:	eb 27                	jmp    800613 <vprintfmt+0xdf>
  8005ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	0f 49 c8             	cmovns %eax,%ecx
  8005f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	eb 8c                	jmp    80058d <vprintfmt+0x59>
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800604:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060b:	eb 80                	jmp    80058d <vprintfmt+0x59>
  80060d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800610:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800613:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800617:	0f 89 70 ff ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  80061d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800620:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800623:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062a:	e9 5e ff ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 53 ff ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800651:	e9 04 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x142>
  80066b:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 33 23 80 00       	push   $0x802333
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 94 fe ff ff       	call   800517 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 cc fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 1e 27 80 00       	push   $0x80271e
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 7c fe ff ff       	call   800517 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 b4 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 2c 23 80 00       	mov    $0x80232c,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x225>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 86 02 00 00       	call   800961 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1c0>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x213>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x213>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x23f>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x270>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1f2>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1f2>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x278>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b3:	e9 a2 fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b8:	83 fa 01             	cmp    $0x1,%edx
  8007bb:	7e 16                	jle    8007d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 08             	lea    0x8(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	eb 32                	jmp    800805 <vprintfmt+0x2d1>
	else if (lflag)
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 18                	je     8007ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800808:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800814:	79 74                	jns    80088a <vprintfmt+0x356>
				putch('-', putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 2d                	push   $0x2d
  80081c:	ff d6                	call   *%esi
				num = -(long long) num;
  80081e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800824:	f7 d8                	neg    %eax
  800826:	83 d2 00             	adc    $0x0,%edx
  800829:	f7 da                	neg    %edx
  80082b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800833:	eb 55                	jmp    80088a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 83 fc ff ff       	call   8004c0 <getuint>
			base = 10;
  80083d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800842:	eb 46                	jmp    80088a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
  800847:	e8 74 fc ff ff       	call   8004c0 <getuint>
			base = 8;
  80084c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800851:	eb 37                	jmp    80088a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 30                	push   $0x30
  800859:	ff d6                	call   *%esi
			putch('x', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 78                	push   $0x78
  800861:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 04             	lea    0x4(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800873:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800876:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087b:	eb 0d                	jmp    80088a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 3b fc ff ff       	call   8004c0 <getuint>
			base = 16;
  800885:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088a:	83 ec 0c             	sub    $0xc,%esp
  80088d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800891:	57                   	push   %edi
  800892:	ff 75 e0             	pushl  -0x20(%ebp)
  800895:	51                   	push   %ecx
  800896:	52                   	push   %edx
  800897:	50                   	push   %eax
  800898:	89 da                	mov    %ebx,%edx
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	e8 70 fb ff ff       	call   800411 <printnum>
			break;
  8008a1:	83 c4 20             	add    $0x20,%esp
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	e9 ae fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	51                   	push   %ecx
  8008b1:	ff d6                	call   *%esi
			break;
  8008b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b9:	e9 9c fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	6a 25                	push   $0x25
  8008c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	eb 03                	jmp    8008ce <vprintfmt+0x39a>
  8008cb:	83 ef 01             	sub    $0x1,%edi
  8008ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d2:	75 f7                	jne    8008cb <vprintfmt+0x397>
  8008d4:	e9 81 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 18             	sub    $0x18,%esp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fe:	85 c0                	test   %eax,%eax
  800900:	74 26                	je     800928 <vsnprintf+0x47>
  800902:	85 d2                	test   %edx,%edx
  800904:	7e 22                	jle    800928 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	ff 75 14             	pushl  0x14(%ebp)
  800909:	ff 75 10             	pushl  0x10(%ebp)
  80090c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	68 fa 04 80 00       	push   $0x8004fa
  800915:	e8 1a fc ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb 05                	jmp    80092d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800938:	50                   	push   %eax
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 9a ff ff ff       	call   8008e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 03                	jmp    800959 <strlen+0x10>
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095d:	75 f7                	jne    800956 <strlen+0xd>
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	eb 03                	jmp    800974 <strnlen+0x13>
		n++;
  800971:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	39 c2                	cmp    %eax,%edx
  800976:	74 08                	je     800980 <strnlen+0x1f>
  800978:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097c:	75 f3                	jne    800971 <strnlen+0x10>
  80097e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800998:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ef                	jne    80098e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a9:	53                   	push   %ebx
  8009aa:	e8 9a ff ff ff       	call   800949 <strlen>
  8009af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	01 d8                	add    %ebx,%eax
  8009b7:	50                   	push   %eax
  8009b8:	e8 c5 ff ff ff       	call   800982 <strcpy>
	return dst;
}
  8009bd:	89 d8                	mov    %ebx,%eax
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	eb 0f                	jmp    8009e7 <strncpy+0x23>
		*dst++ = *src;
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	0f b6 01             	movzbl (%ecx),%eax
  8009de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	75 ed                	jne    8009d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 21                	je     800a26 <strlcpy+0x35>
  800a05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 09                	jmp    800a16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a16:	39 c2                	cmp    %eax,%edx
  800a18:	74 09                	je     800a23 <strlcpy+0x32>
  800a1a:	0f b6 19             	movzbl (%ecx),%ebx
  800a1d:	84 db                	test   %bl,%bl
  800a1f:	75 ec                	jne    800a0d <strlcpy+0x1c>
  800a21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a26:	29 f0                	sub    %esi,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strcmp+0x11>
		p++, q++;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	74 04                	je     800a48 <strcmp+0x1c>
  800a44:	3a 02                	cmp    (%edx),%al
  800a46:	74 ef                	je     800a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 c0             	movzbl %al,%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strncmp+0x17>
		n--, p++, q++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	39 d8                	cmp    %ebx,%eax
  800a6b:	74 15                	je     800a82 <strncmp+0x30>
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	74 04                	je     800a78 <strncmp+0x26>
  800a74:	3a 0a                	cmp    (%edx),%cl
  800a76:	74 eb                	je     800a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
  800a80:	eb 05                	jmp    800a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 07                	jmp    800a9d <strchr+0x13>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0f                	je     800aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	eb 03                	jmp    800aba <strfind+0xf>
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 04                	je     800ac5 <strfind+0x1a>
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 36                	je     800b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800add:	75 28                	jne    800b07 <memset+0x40>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 23                	jne    800b07 <memset+0x40>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	09 d0                	or     %edx,%eax
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 35                	jae    800b5b <memmove+0x47>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 2e                	jae    800b5b <memmove+0x47>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	09 fe                	or     %edi,%esi
  800b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3a:	75 13                	jne    800b4f <memmove+0x3b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 1d                	jmp    800b78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	09 c2                	or     %eax,%edx
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 0f                	jne    800b73 <memmove+0x5f>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 0a                	jne    800b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 05                	jmp    800b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7f:	ff 75 10             	pushl  0x10(%ebp)
  800b82:	ff 75 0c             	pushl  0xc(%ebp)
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 87 ff ff ff       	call   800b14 <memmove>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	eb 1a                	jmp    800bbb <memcmp+0x2c>
		if (*s1 != *s2)
  800ba1:	0f b6 08             	movzbl (%eax),%ecx
  800ba4:	0f b6 1a             	movzbl (%edx),%ebx
  800ba7:	38 d9                	cmp    %bl,%cl
  800ba9:	74 0a                	je     800bb5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bab:	0f b6 c1             	movzbl %cl,%eax
  800bae:	0f b6 db             	movzbl %bl,%ebx
  800bb1:	29 d8                	sub    %ebx,%eax
  800bb3:	eb 0f                	jmp    800bc4 <memcmp+0x35>
		s1++, s2++;
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbb:	39 f0                	cmp    %esi,%eax
  800bbd:	75 e2                	jne    800ba1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcf:	89 c1                	mov    %eax,%ecx
  800bd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd8:	eb 0a                	jmp    800be4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	0f b6 10             	movzbl (%eax),%edx
  800bdd:	39 da                	cmp    %ebx,%edx
  800bdf:	74 07                	je     800be8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	39 c8                	cmp    %ecx,%eax
  800be6:	72 f2                	jb     800bda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf7:	eb 03                	jmp    800bfc <strtol+0x11>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f6                	je     800bf9 <strtol+0xe>
  800c03:	3c 09                	cmp    $0x9,%al
  800c05:	74 f2                	je     800bf9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x2a>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	eb 11                	jmp    800c26 <strtol+0x3b>
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 08                	jne    800c26 <strtol+0x3b>
		s++, neg = 1;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c2c:	75 15                	jne    800c43 <strtol+0x58>
  800c2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c31:	75 10                	jne    800c43 <strtol+0x58>
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	75 7c                	jne    800cb5 <strtol+0xca>
		s += 2, base = 16;
  800c39:	83 c1 02             	add    $0x2,%ecx
  800c3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c41:	eb 16                	jmp    800c59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	75 12                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 08                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c61:	0f b6 11             	movzbl (%ecx),%edx
  800c64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 09             	cmp    $0x9,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x8b>
			dig = *s - '0';
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 30             	sub    $0x30,%edx
  800c74:	eb 22                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 57             	sub    $0x57,%edx
  800c86:	eb 10                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 16                	ja     800ca8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9b:	7d 0b                	jge    800ca8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca6:	eb b9                	jmp    800c61 <strtol+0x76>

	if (endptr)
  800ca8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cac:	74 0d                	je     800cbb <strtol+0xd0>
		*endptr = (char *) s;
  800cae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb1:	89 0e                	mov    %ecx,(%esi)
  800cb3:	eb 06                	jmp    800cbb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 98                	je     800c51 <strtol+0x66>
  800cb9:	eb 9e                	jmp    800c59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	f7 da                	neg    %edx
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	0f 45 c2             	cmovne %edx,%eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	b8 03 00 00 00       	mov    $0x3,%eax
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 03                	push   $0x3
  800d2e:	68 1f 26 80 00       	push   $0x80261f
  800d33:	6a 23                	push   $0x23
  800d35:	68 3c 26 80 00       	push   $0x80263c
  800d3a:	e8 e5 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 02 00 00 00       	mov    $0x2,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_yield>:

void
sys_yield(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	b8 04 00 00 00       	mov    $0x4,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da1:	89 f7                	mov    %esi,%edi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 04                	push   $0x4
  800daf:	68 1f 26 80 00       	push   $0x80261f
  800db4:	6a 23                	push   $0x23
  800db6:	68 3c 26 80 00       	push   $0x80263c
  800dbb:	e8 64 f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	8b 75 18             	mov    0x18(%ebp),%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 05                	push   $0x5
  800df1:	68 1f 26 80 00       	push   $0x80261f
  800df6:	6a 23                	push   $0x23
  800df8:	68 3c 26 80 00       	push   $0x80263c
  800dfd:	e8 22 f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 06                	push   $0x6
  800e33:	68 1f 26 80 00       	push   $0x80261f
  800e38:	6a 23                	push   $0x23
  800e3a:	68 3c 26 80 00       	push   $0x80263c
  800e3f:	e8 e0 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 08                	push   $0x8
  800e75:	68 1f 26 80 00       	push   $0x80261f
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 3c 26 80 00       	push   $0x80263c
  800e81:	e8 9e f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 09                	push   $0x9
  800eb7:	68 1f 26 80 00       	push   $0x80261f
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 3c 26 80 00       	push   $0x80263c
  800ec3:	e8 5c f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 17                	jle    800f0a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	50                   	push   %eax
  800ef7:	6a 0a                	push   $0xa
  800ef9:	68 1f 26 80 00       	push   $0x80261f
  800efe:	6a 23                	push   $0x23
  800f00:	68 3c 26 80 00       	push   $0x80263c
  800f05:	e8 1a f4 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	be 00 00 00 00       	mov    $0x0,%esi
  800f1d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7e 17                	jle    800f6e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	50                   	push   %eax
  800f5b:	6a 0d                	push   $0xd
  800f5d:	68 1f 26 80 00       	push   $0x80261f
  800f62:	6a 23                	push   $0x23
  800f64:	68 3c 26 80 00       	push   $0x80263c
  800f69:	e8 b6 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800f82:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800f84:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800f87:	83 3a 01             	cmpl   $0x1,(%edx)
  800f8a:	7e 09                	jle    800f95 <argstart+0x1f>
  800f8c:	ba c8 22 80 00       	mov    $0x8022c8,%edx
  800f91:	85 c9                	test   %ecx,%ecx
  800f93:	75 05                	jne    800f9a <argstart+0x24>
  800f95:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9a:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800f9d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <argnext>:

int
argnext(struct Argstate *args)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fb0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fb7:	8b 43 08             	mov    0x8(%ebx),%eax
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	74 6f                	je     80102d <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800fbe:	80 38 00             	cmpb   $0x0,(%eax)
  800fc1:	75 4e                	jne    801011 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fc3:	8b 0b                	mov    (%ebx),%ecx
  800fc5:	83 39 01             	cmpl   $0x1,(%ecx)
  800fc8:	74 55                	je     80101f <argnext+0x79>
		    || args->argv[1][0] != '-'
  800fca:	8b 53 04             	mov    0x4(%ebx),%edx
  800fcd:	8b 42 04             	mov    0x4(%edx),%eax
  800fd0:	80 38 2d             	cmpb   $0x2d,(%eax)
  800fd3:	75 4a                	jne    80101f <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800fd5:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800fd9:	74 44                	je     80101f <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800fdb:	83 c0 01             	add    $0x1,%eax
  800fde:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	8b 01                	mov    (%ecx),%eax
  800fe6:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800fed:	50                   	push   %eax
  800fee:	8d 42 08             	lea    0x8(%edx),%eax
  800ff1:	50                   	push   %eax
  800ff2:	83 c2 04             	add    $0x4,%edx
  800ff5:	52                   	push   %edx
  800ff6:	e8 19 fb ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  800ffb:	8b 03                	mov    (%ebx),%eax
  800ffd:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801000:	8b 43 08             	mov    0x8(%ebx),%eax
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	80 38 2d             	cmpb   $0x2d,(%eax)
  801009:	75 06                	jne    801011 <argnext+0x6b>
  80100b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80100f:	74 0e                	je     80101f <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801011:	8b 53 08             	mov    0x8(%ebx),%edx
  801014:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801017:	83 c2 01             	add    $0x1,%edx
  80101a:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80101d:	eb 13                	jmp    801032 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80101f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80102b:	eb 05                	jmp    801032 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80102d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801032:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	53                   	push   %ebx
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801041:	8b 43 08             	mov    0x8(%ebx),%eax
  801044:	85 c0                	test   %eax,%eax
  801046:	74 58                	je     8010a0 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801048:	80 38 00             	cmpb   $0x0,(%eax)
  80104b:	74 0c                	je     801059 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80104d:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801050:	c7 43 08 c8 22 80 00 	movl   $0x8022c8,0x8(%ebx)
  801057:	eb 42                	jmp    80109b <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801059:	8b 13                	mov    (%ebx),%edx
  80105b:	83 3a 01             	cmpl   $0x1,(%edx)
  80105e:	7e 2d                	jle    80108d <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801060:	8b 43 04             	mov    0x4(%ebx),%eax
  801063:	8b 48 04             	mov    0x4(%eax),%ecx
  801066:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801069:	83 ec 04             	sub    $0x4,%esp
  80106c:	8b 12                	mov    (%edx),%edx
  80106e:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801075:	52                   	push   %edx
  801076:	8d 50 08             	lea    0x8(%eax),%edx
  801079:	52                   	push   %edx
  80107a:	83 c0 04             	add    $0x4,%eax
  80107d:	50                   	push   %eax
  80107e:	e8 91 fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  801083:	8b 03                	mov    (%ebx),%eax
  801085:	83 28 01             	subl   $0x1,(%eax)
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	eb 0e                	jmp    80109b <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80108d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801094:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80109b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80109e:	eb 05                	jmp    8010a5 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010a0:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 08             	sub    $0x8,%esp
  8010b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010b3:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010b6:	89 d0                	mov    %edx,%eax
  8010b8:	85 d2                	test   %edx,%edx
  8010ba:	75 0c                	jne    8010c8 <argvalue+0x1e>
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	51                   	push   %ecx
  8010c0:	e8 72 ff ff ff       	call   801037 <argnextvalue>
  8010c5:	83 c4 10             	add    $0x10,%esp
}
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d5:	c1 e8 0c             	shr    $0xc,%eax
}
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	c1 ea 16             	shr    $0x16,%edx
  801101:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801108:	f6 c2 01             	test   $0x1,%dl
  80110b:	74 11                	je     80111e <fd_alloc+0x2d>
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	c1 ea 0c             	shr    $0xc,%edx
  801112:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801119:	f6 c2 01             	test   $0x1,%dl
  80111c:	75 09                	jne    801127 <fd_alloc+0x36>
			*fd_store = fd;
  80111e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
  801125:	eb 17                	jmp    80113e <fd_alloc+0x4d>
  801127:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80112c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801131:	75 c9                	jne    8010fc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801133:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801139:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801146:	83 f8 1f             	cmp    $0x1f,%eax
  801149:	77 36                	ja     801181 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80114b:	c1 e0 0c             	shl    $0xc,%eax
  80114e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801153:	89 c2                	mov    %eax,%edx
  801155:	c1 ea 16             	shr    $0x16,%edx
  801158:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115f:	f6 c2 01             	test   $0x1,%dl
  801162:	74 24                	je     801188 <fd_lookup+0x48>
  801164:	89 c2                	mov    %eax,%edx
  801166:	c1 ea 0c             	shr    $0xc,%edx
  801169:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801170:	f6 c2 01             	test   $0x1,%dl
  801173:	74 1a                	je     80118f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801175:	8b 55 0c             	mov    0xc(%ebp),%edx
  801178:	89 02                	mov    %eax,(%edx)
	return 0;
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	eb 13                	jmp    801194 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801181:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801186:	eb 0c                	jmp    801194 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118d:	eb 05                	jmp    801194 <fd_lookup+0x54>
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119f:	ba cc 26 80 00       	mov    $0x8026cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011a4:	eb 13                	jmp    8011b9 <dev_lookup+0x23>
  8011a6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011a9:	39 08                	cmp    %ecx,(%eax)
  8011ab:	75 0c                	jne    8011b9 <dev_lookup+0x23>
			*dev = devtab[i];
  8011ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 2e                	jmp    8011e7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b9:	8b 02                	mov    (%edx),%eax
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	75 e7                	jne    8011a6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011bf:	a1 20 44 80 00       	mov    0x804420,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	51                   	push   %ecx
  8011cb:	50                   	push   %eax
  8011cc:	68 4c 26 80 00       	push   $0x80264c
  8011d1:	e8 27 f2 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  8011d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	56                   	push   %esi
  8011ed:	53                   	push   %ebx
  8011ee:	83 ec 10             	sub    $0x10,%esp
  8011f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801201:	c1 e8 0c             	shr    $0xc,%eax
  801204:	50                   	push   %eax
  801205:	e8 36 ff ff ff       	call   801140 <fd_lookup>
  80120a:	83 c4 08             	add    $0x8,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 05                	js     801216 <fd_close+0x2d>
	    || fd != fd2)
  801211:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801214:	74 0c                	je     801222 <fd_close+0x39>
		return (must_exist ? r : 0);
  801216:	84 db                	test   %bl,%bl
  801218:	ba 00 00 00 00       	mov    $0x0,%edx
  80121d:	0f 44 c2             	cmove  %edx,%eax
  801220:	eb 41                	jmp    801263 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	ff 36                	pushl  (%esi)
  80122b:	e8 66 ff ff ff       	call   801196 <dev_lookup>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 1a                	js     801253 <fd_close+0x6a>
		if (dev->dev_close)
  801239:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80123f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801244:	85 c0                	test   %eax,%eax
  801246:	74 0b                	je     801253 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	56                   	push   %esi
  80124c:	ff d0                	call   *%eax
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801253:	83 ec 08             	sub    $0x8,%esp
  801256:	56                   	push   %esi
  801257:	6a 00                	push   $0x0
  801259:	e8 ac fb ff ff       	call   800e0a <sys_page_unmap>
	return r;
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	89 d8                	mov    %ebx,%eax
}
  801263:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	ff 75 08             	pushl  0x8(%ebp)
  801277:	e8 c4 fe ff ff       	call   801140 <fd_lookup>
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 10                	js     801293 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	6a 01                	push   $0x1
  801288:	ff 75 f4             	pushl  -0xc(%ebp)
  80128b:	e8 59 ff ff ff       	call   8011e9 <fd_close>
  801290:	83 c4 10             	add    $0x10,%esp
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <close_all>:

void
close_all(void)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	53                   	push   %ebx
  801299:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80129c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	53                   	push   %ebx
  8012a5:	e8 c0 ff ff ff       	call   80126a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012aa:	83 c3 01             	add    $0x1,%ebx
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	83 fb 20             	cmp    $0x20,%ebx
  8012b3:	75 ec                	jne    8012a1 <close_all+0xc>
		close(i);
}
  8012b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	57                   	push   %edi
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 2c             	sub    $0x2c,%esp
  8012c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 6e fe ff ff       	call   801140 <fd_lookup>
  8012d2:	83 c4 08             	add    $0x8,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	0f 88 c1 00 00 00    	js     80139e <dup+0xe4>
		return r;
	close(newfdnum);
  8012dd:	83 ec 0c             	sub    $0xc,%esp
  8012e0:	56                   	push   %esi
  8012e1:	e8 84 ff ff ff       	call   80126a <close>

	newfd = INDEX2FD(newfdnum);
  8012e6:	89 f3                	mov    %esi,%ebx
  8012e8:	c1 e3 0c             	shl    $0xc,%ebx
  8012eb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f1:	83 c4 04             	add    $0x4,%esp
  8012f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f7:	e8 de fd ff ff       	call   8010da <fd2data>
  8012fc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012fe:	89 1c 24             	mov    %ebx,(%esp)
  801301:	e8 d4 fd ff ff       	call   8010da <fd2data>
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80130c:	89 f8                	mov    %edi,%eax
  80130e:	c1 e8 16             	shr    $0x16,%eax
  801311:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801318:	a8 01                	test   $0x1,%al
  80131a:	74 37                	je     801353 <dup+0x99>
  80131c:	89 f8                	mov    %edi,%eax
  80131e:	c1 e8 0c             	shr    $0xc,%eax
  801321:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801328:	f6 c2 01             	test   $0x1,%dl
  80132b:	74 26                	je     801353 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80132d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	25 07 0e 00 00       	and    $0xe07,%eax
  80133c:	50                   	push   %eax
  80133d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801340:	6a 00                	push   $0x0
  801342:	57                   	push   %edi
  801343:	6a 00                	push   $0x0
  801345:	e8 7e fa ff ff       	call   800dc8 <sys_page_map>
  80134a:	89 c7                	mov    %eax,%edi
  80134c:	83 c4 20             	add    $0x20,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 2e                	js     801381 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801353:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801356:	89 d0                	mov    %edx,%eax
  801358:	c1 e8 0c             	shr    $0xc,%eax
  80135b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	25 07 0e 00 00       	and    $0xe07,%eax
  80136a:	50                   	push   %eax
  80136b:	53                   	push   %ebx
  80136c:	6a 00                	push   $0x0
  80136e:	52                   	push   %edx
  80136f:	6a 00                	push   $0x0
  801371:	e8 52 fa ff ff       	call   800dc8 <sys_page_map>
  801376:	89 c7                	mov    %eax,%edi
  801378:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80137b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80137d:	85 ff                	test   %edi,%edi
  80137f:	79 1d                	jns    80139e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	6a 00                	push   $0x0
  801387:	e8 7e fa ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801392:	6a 00                	push   $0x0
  801394:	e8 71 fa ff ff       	call   800e0a <sys_page_unmap>
	return r;
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	89 f8                	mov    %edi,%eax
}
  80139e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 14             	sub    $0x14,%esp
  8013ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	53                   	push   %ebx
  8013b5:	e8 86 fd ff ff       	call   801140 <fd_lookup>
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 6d                	js     801430 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	ff 30                	pushl  (%eax)
  8013cf:	e8 c2 fd ff ff       	call   801196 <dev_lookup>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 4c                	js     801427 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013de:	8b 42 08             	mov    0x8(%edx),%eax
  8013e1:	83 e0 03             	and    $0x3,%eax
  8013e4:	83 f8 01             	cmp    $0x1,%eax
  8013e7:	75 21                	jne    80140a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e9:	a1 20 44 80 00       	mov    0x804420,%eax
  8013ee:	8b 40 48             	mov    0x48(%eax),%eax
  8013f1:	83 ec 04             	sub    $0x4,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	50                   	push   %eax
  8013f6:	68 90 26 80 00       	push   $0x802690
  8013fb:	e8 fd ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801408:	eb 26                	jmp    801430 <read+0x8a>
	}
	if (!dev->dev_read)
  80140a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140d:	8b 40 08             	mov    0x8(%eax),%eax
  801410:	85 c0                	test   %eax,%eax
  801412:	74 17                	je     80142b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	ff 75 10             	pushl  0x10(%ebp)
  80141a:	ff 75 0c             	pushl  0xc(%ebp)
  80141d:	52                   	push   %edx
  80141e:	ff d0                	call   *%eax
  801420:	89 c2                	mov    %eax,%edx
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb 09                	jmp    801430 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801427:	89 c2                	mov    %eax,%edx
  801429:	eb 05                	jmp    801430 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80142b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801430:	89 d0                	mov    %edx,%eax
  801432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	57                   	push   %edi
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	83 ec 0c             	sub    $0xc,%esp
  801440:	8b 7d 08             	mov    0x8(%ebp),%edi
  801443:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801446:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144b:	eb 21                	jmp    80146e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	89 f0                	mov    %esi,%eax
  801452:	29 d8                	sub    %ebx,%eax
  801454:	50                   	push   %eax
  801455:	89 d8                	mov    %ebx,%eax
  801457:	03 45 0c             	add    0xc(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	57                   	push   %edi
  80145c:	e8 45 ff ff ff       	call   8013a6 <read>
		if (m < 0)
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 10                	js     801478 <readn+0x41>
			return m;
		if (m == 0)
  801468:	85 c0                	test   %eax,%eax
  80146a:	74 0a                	je     801476 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146c:	01 c3                	add    %eax,%ebx
  80146e:	39 f3                	cmp    %esi,%ebx
  801470:	72 db                	jb     80144d <readn+0x16>
  801472:	89 d8                	mov    %ebx,%eax
  801474:	eb 02                	jmp    801478 <readn+0x41>
  801476:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	53                   	push   %ebx
  801484:	83 ec 14             	sub    $0x14,%esp
  801487:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	53                   	push   %ebx
  80148f:	e8 ac fc ff ff       	call   801140 <fd_lookup>
  801494:	83 c4 08             	add    $0x8,%esp
  801497:	89 c2                	mov    %eax,%edx
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 68                	js     801505 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a7:	ff 30                	pushl  (%eax)
  8014a9:	e8 e8 fc ff ff       	call   801196 <dev_lookup>
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 47                	js     8014fc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014bc:	75 21                	jne    8014df <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014be:	a1 20 44 80 00       	mov    0x804420,%eax
  8014c3:	8b 40 48             	mov    0x48(%eax),%eax
  8014c6:	83 ec 04             	sub    $0x4,%esp
  8014c9:	53                   	push   %ebx
  8014ca:	50                   	push   %eax
  8014cb:	68 ac 26 80 00       	push   $0x8026ac
  8014d0:	e8 28 ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014dd:	eb 26                	jmp    801505 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e5:	85 d2                	test   %edx,%edx
  8014e7:	74 17                	je     801500 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e9:	83 ec 04             	sub    $0x4,%esp
  8014ec:	ff 75 10             	pushl  0x10(%ebp)
  8014ef:	ff 75 0c             	pushl  0xc(%ebp)
  8014f2:	50                   	push   %eax
  8014f3:	ff d2                	call   *%edx
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	eb 09                	jmp    801505 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	eb 05                	jmp    801505 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801500:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801505:	89 d0                	mov    %edx,%eax
  801507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <seek>:

int
seek(int fdnum, off_t offset)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801512:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	ff 75 08             	pushl  0x8(%ebp)
  801519:	e8 22 fc ff ff       	call   801140 <fd_lookup>
  80151e:	83 c4 08             	add    $0x8,%esp
  801521:	85 c0                	test   %eax,%eax
  801523:	78 0e                	js     801533 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801525:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801528:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80152e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	53                   	push   %ebx
  801539:	83 ec 14             	sub    $0x14,%esp
  80153c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	53                   	push   %ebx
  801544:	e8 f7 fb ff ff       	call   801140 <fd_lookup>
  801549:	83 c4 08             	add    $0x8,%esp
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 65                	js     8015b7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155c:	ff 30                	pushl  (%eax)
  80155e:	e8 33 fc ff ff       	call   801196 <dev_lookup>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 44                	js     8015ae <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801571:	75 21                	jne    801594 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801573:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801578:	8b 40 48             	mov    0x48(%eax),%eax
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	53                   	push   %ebx
  80157f:	50                   	push   %eax
  801580:	68 6c 26 80 00       	push   $0x80266c
  801585:	e8 73 ee ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801592:	eb 23                	jmp    8015b7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801597:	8b 52 18             	mov    0x18(%edx),%edx
  80159a:	85 d2                	test   %edx,%edx
  80159c:	74 14                	je     8015b2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	50                   	push   %eax
  8015a5:	ff d2                	call   *%edx
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	eb 09                	jmp    8015b7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	eb 05                	jmp    8015b7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b7:	89 d0                	mov    %edx,%eax
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 6c fb ff ff       	call   801140 <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 58                	js     801635 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e7:	ff 30                	pushl  (%eax)
  8015e9:	e8 a8 fb ff ff       	call   801196 <dev_lookup>
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 37                	js     80162c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fc:	74 32                	je     801630 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801601:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801608:	00 00 00 
	stat->st_isdir = 0;
  80160b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801612:	00 00 00 
	stat->st_dev = dev;
  801615:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	53                   	push   %ebx
  80161f:	ff 75 f0             	pushl  -0x10(%ebp)
  801622:	ff 50 14             	call   *0x14(%eax)
  801625:	89 c2                	mov    %eax,%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 09                	jmp    801635 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	eb 05                	jmp    801635 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801630:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	6a 00                	push   $0x0
  801646:	ff 75 08             	pushl  0x8(%ebp)
  801649:	e8 b7 01 00 00       	call   801805 <open>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 1b                	js     801672 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	50                   	push   %eax
  80165e:	e8 5b ff ff ff       	call   8015be <fstat>
  801663:	89 c6                	mov    %eax,%esi
	close(fd);
  801665:	89 1c 24             	mov    %ebx,(%esp)
  801668:	e8 fd fb ff ff       	call   80126a <close>
	return r;
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	89 f0                	mov    %esi,%eax
}
  801672:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	56                   	push   %esi
  80167d:	53                   	push   %ebx
  80167e:	89 c6                	mov    %eax,%esi
  801680:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801682:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801689:	75 12                	jne    80169d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	6a 01                	push   $0x1
  801690:	e8 be 08 00 00       	call   801f53 <ipc_find_env>
  801695:	a3 00 40 80 00       	mov    %eax,0x804000
  80169a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80169d:	6a 07                	push   $0x7
  80169f:	68 00 50 80 00       	push   $0x805000
  8016a4:	56                   	push   %esi
  8016a5:	ff 35 00 40 80 00    	pushl  0x804000
  8016ab:	e8 4f 08 00 00       	call   801eff <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b0:	83 c4 0c             	add    $0xc,%esp
  8016b3:	6a 00                	push   $0x0
  8016b5:	53                   	push   %ebx
  8016b6:	6a 00                	push   $0x0
  8016b8:	e8 db 07 00 00       	call   801e98 <ipc_recv>
}
  8016bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e7:	e8 8d ff ff ff       	call   801679 <fsipc>
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 06 00 00 00       	mov    $0x6,%eax
  801709:	e8 6b ff ff ff       	call   801679 <fsipc>
}
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	53                   	push   %ebx
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	8b 40 0c             	mov    0xc(%eax),%eax
  801720:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	b8 05 00 00 00       	mov    $0x5,%eax
  80172f:	e8 45 ff ff ff       	call   801679 <fsipc>
  801734:	85 c0                	test   %eax,%eax
  801736:	78 2c                	js     801764 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	68 00 50 80 00       	push   $0x805000
  801740:	53                   	push   %ebx
  801741:	e8 3c f2 ff ff       	call   800982 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801746:	a1 80 50 80 00       	mov    0x805080,%eax
  80174b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801751:	a1 84 50 80 00       	mov    0x805084,%eax
  801756:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80176f:	68 dc 26 80 00       	push   $0x8026dc
  801774:	68 90 00 00 00       	push   $0x90
  801779:	68 fa 26 80 00       	push   $0x8026fa
  80177e:	e8 a1 eb ff ff       	call   800324 <_panic>

00801783 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
  801788:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178b:	8b 45 08             	mov    0x8(%ebp),%eax
  80178e:	8b 40 0c             	mov    0xc(%eax),%eax
  801791:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801796:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179c:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a1:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a6:	e8 ce fe ff ff       	call   801679 <fsipc>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 4b                	js     8017fc <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b1:	39 c6                	cmp    %eax,%esi
  8017b3:	73 16                	jae    8017cb <devfile_read+0x48>
  8017b5:	68 05 27 80 00       	push   $0x802705
  8017ba:	68 0c 27 80 00       	push   $0x80270c
  8017bf:	6a 7c                	push   $0x7c
  8017c1:	68 fa 26 80 00       	push   $0x8026fa
  8017c6:	e8 59 eb ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  8017cb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d0:	7e 16                	jle    8017e8 <devfile_read+0x65>
  8017d2:	68 21 27 80 00       	push   $0x802721
  8017d7:	68 0c 27 80 00       	push   $0x80270c
  8017dc:	6a 7d                	push   $0x7d
  8017de:	68 fa 26 80 00       	push   $0x8026fa
  8017e3:	e8 3c eb ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e8:	83 ec 04             	sub    $0x4,%esp
  8017eb:	50                   	push   %eax
  8017ec:	68 00 50 80 00       	push   $0x805000
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	e8 1b f3 ff ff       	call   800b14 <memmove>
	return r;
  8017f9:	83 c4 10             	add    $0x10,%esp
}
  8017fc:	89 d8                	mov    %ebx,%eax
  8017fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801801:	5b                   	pop    %ebx
  801802:	5e                   	pop    %esi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	53                   	push   %ebx
  801809:	83 ec 20             	sub    $0x20,%esp
  80180c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180f:	53                   	push   %ebx
  801810:	e8 34 f1 ff ff       	call   800949 <strlen>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181d:	7f 67                	jg     801886 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	e8 c6 f8 ff ff       	call   8010f1 <fd_alloc>
  80182b:	83 c4 10             	add    $0x10,%esp
		return r;
  80182e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801830:	85 c0                	test   %eax,%eax
  801832:	78 57                	js     80188b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	53                   	push   %ebx
  801838:	68 00 50 80 00       	push   $0x805000
  80183d:	e8 40 f1 ff ff       	call   800982 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801842:	8b 45 0c             	mov    0xc(%ebp),%eax
  801845:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184d:	b8 01 00 00 00       	mov    $0x1,%eax
  801852:	e8 22 fe ff ff       	call   801679 <fsipc>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	85 c0                	test   %eax,%eax
  80185e:	79 14                	jns    801874 <open+0x6f>
		fd_close(fd, 0);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	6a 00                	push   $0x0
  801865:	ff 75 f4             	pushl  -0xc(%ebp)
  801868:	e8 7c f9 ff ff       	call   8011e9 <fd_close>
		return r;
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	89 da                	mov    %ebx,%edx
  801872:	eb 17                	jmp    80188b <open+0x86>
	}

	return fd2num(fd);
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	ff 75 f4             	pushl  -0xc(%ebp)
  80187a:	e8 4b f8 ff ff       	call   8010ca <fd2num>
  80187f:	89 c2                	mov    %eax,%edx
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	eb 05                	jmp    80188b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801886:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a2:	e8 d2 fd ff ff       	call   801679 <fsipc>
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018a9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018ad:	7e 37                	jle    8018e6 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018b8:	ff 70 04             	pushl  0x4(%eax)
  8018bb:	8d 40 10             	lea    0x10(%eax),%eax
  8018be:	50                   	push   %eax
  8018bf:	ff 33                	pushl  (%ebx)
  8018c1:	e8 ba fb ff ff       	call   801480 <write>
		if (result > 0)
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	7e 03                	jle    8018d0 <writebuf+0x27>
			b->result += result;
  8018cd:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018d0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018d3:	74 0d                	je     8018e2 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	0f 4f c2             	cmovg  %edx,%eax
  8018df:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e5:	c9                   	leave  
  8018e6:	f3 c3                	repz ret 

008018e8 <putch>:

static void
putch(int ch, void *thunk)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 04             	sub    $0x4,%esp
  8018ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018f2:	8b 53 04             	mov    0x4(%ebx),%edx
  8018f5:	8d 42 01             	lea    0x1(%edx),%eax
  8018f8:	89 43 04             	mov    %eax,0x4(%ebx)
  8018fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fe:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801902:	3d 00 01 00 00       	cmp    $0x100,%eax
  801907:	75 0e                	jne    801917 <putch+0x2f>
		writebuf(b);
  801909:	89 d8                	mov    %ebx,%eax
  80190b:	e8 99 ff ff ff       	call   8018a9 <writebuf>
		b->idx = 0;
  801910:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801917:	83 c4 04             	add    $0x4,%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80192f:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801936:	00 00 00 
	b.result = 0;
  801939:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801940:	00 00 00 
	b.error = 1;
  801943:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80194a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80194d:	ff 75 10             	pushl  0x10(%ebp)
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	68 e8 18 80 00       	push   $0x8018e8
  80195f:	e8 d0 eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80196e:	7e 0b                	jle    80197b <vfprintf+0x5e>
		writebuf(&b);
  801970:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801976:	e8 2e ff ff ff       	call   8018a9 <writebuf>

	return (b.result ? b.result : b.error);
  80197b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801981:	85 c0                	test   %eax,%eax
  801983:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801992:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801995:	50                   	push   %eax
  801996:	ff 75 0c             	pushl  0xc(%ebp)
  801999:	ff 75 08             	pushl  0x8(%ebp)
  80199c:	e8 7c ff ff ff       	call   80191d <vfprintf>
	va_end(ap);

	return cnt;
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <printf>:

int
printf(const char *fmt, ...)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019a9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019ac:	50                   	push   %eax
  8019ad:	ff 75 08             	pushl  0x8(%ebp)
  8019b0:	6a 01                	push   $0x1
  8019b2:	e8 66 ff ff ff       	call   80191d <vfprintf>
	va_end(ap);

	return cnt;
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	56                   	push   %esi
  8019bd:	53                   	push   %ebx
  8019be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	ff 75 08             	pushl  0x8(%ebp)
  8019c7:	e8 0e f7 ff ff       	call   8010da <fd2data>
  8019cc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ce:	83 c4 08             	add    $0x8,%esp
  8019d1:	68 2d 27 80 00       	push   $0x80272d
  8019d6:	53                   	push   %ebx
  8019d7:	e8 a6 ef ff ff       	call   800982 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019dc:	8b 46 04             	mov    0x4(%esi),%eax
  8019df:	2b 06                	sub    (%esi),%eax
  8019e1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ee:	00 00 00 
	stat->st_dev = &devpipe;
  8019f1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019f8:	30 80 00 
	return 0;
}
  8019fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a11:	53                   	push   %ebx
  801a12:	6a 00                	push   $0x0
  801a14:	e8 f1 f3 ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a19:	89 1c 24             	mov    %ebx,(%esp)
  801a1c:	e8 b9 f6 ff ff       	call   8010da <fd2data>
  801a21:	83 c4 08             	add    $0x8,%esp
  801a24:	50                   	push   %eax
  801a25:	6a 00                	push   $0x0
  801a27:	e8 de f3 ff ff       	call   800e0a <sys_page_unmap>
}
  801a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	57                   	push   %edi
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	83 ec 1c             	sub    $0x1c,%esp
  801a3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a3d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a3f:	a1 20 44 80 00       	mov    0x804420,%eax
  801a44:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a4d:	e8 3a 05 00 00       	call   801f8c <pageref>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	89 3c 24             	mov    %edi,(%esp)
  801a57:	e8 30 05 00 00       	call   801f8c <pageref>
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	39 c3                	cmp    %eax,%ebx
  801a61:	0f 94 c1             	sete   %cl
  801a64:	0f b6 c9             	movzbl %cl,%ecx
  801a67:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a6a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a70:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a73:	39 ce                	cmp    %ecx,%esi
  801a75:	74 1b                	je     801a92 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a77:	39 c3                	cmp    %eax,%ebx
  801a79:	75 c4                	jne    801a3f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7b:	8b 42 58             	mov    0x58(%edx),%eax
  801a7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a81:	50                   	push   %eax
  801a82:	56                   	push   %esi
  801a83:	68 34 27 80 00       	push   $0x802734
  801a88:	e8 70 e9 ff ff       	call   8003fd <cprintf>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb ad                	jmp    801a3f <_pipeisclosed+0xe>
	}
}
  801a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5f                   	pop    %edi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 28             	sub    $0x28,%esp
  801aa6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa9:	56                   	push   %esi
  801aaa:	e8 2b f6 ff ff       	call   8010da <fd2data>
  801aaf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab9:	eb 4b                	jmp    801b06 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801abb:	89 da                	mov    %ebx,%edx
  801abd:	89 f0                	mov    %esi,%eax
  801abf:	e8 6d ff ff ff       	call   801a31 <_pipeisclosed>
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	75 48                	jne    801b10 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac8:	e8 99 f2 ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801acd:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad0:	8b 0b                	mov    (%ebx),%ecx
  801ad2:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad5:	39 d0                	cmp    %edx,%eax
  801ad7:	73 e2                	jae    801abb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801adc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ae3:	89 c2                	mov    %eax,%edx
  801ae5:	c1 fa 1f             	sar    $0x1f,%edx
  801ae8:	89 d1                	mov    %edx,%ecx
  801aea:	c1 e9 1b             	shr    $0x1b,%ecx
  801aed:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af0:	83 e2 1f             	and    $0x1f,%edx
  801af3:	29 ca                	sub    %ecx,%edx
  801af5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801af9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801afd:	83 c0 01             	add    $0x1,%eax
  801b00:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b03:	83 c7 01             	add    $0x1,%edi
  801b06:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b09:	75 c2                	jne    801acd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0e:	eb 05                	jmp    801b15 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	57                   	push   %edi
  801b21:	56                   	push   %esi
  801b22:	53                   	push   %ebx
  801b23:	83 ec 18             	sub    $0x18,%esp
  801b26:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b29:	57                   	push   %edi
  801b2a:	e8 ab f5 ff ff       	call   8010da <fd2data>
  801b2f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b39:	eb 3d                	jmp    801b78 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b3b:	85 db                	test   %ebx,%ebx
  801b3d:	74 04                	je     801b43 <devpipe_read+0x26>
				return i;
  801b3f:	89 d8                	mov    %ebx,%eax
  801b41:	eb 44                	jmp    801b87 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b43:	89 f2                	mov    %esi,%edx
  801b45:	89 f8                	mov    %edi,%eax
  801b47:	e8 e5 fe ff ff       	call   801a31 <_pipeisclosed>
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	75 32                	jne    801b82 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b50:	e8 11 f2 ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b55:	8b 06                	mov    (%esi),%eax
  801b57:	3b 46 04             	cmp    0x4(%esi),%eax
  801b5a:	74 df                	je     801b3b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b5c:	99                   	cltd   
  801b5d:	c1 ea 1b             	shr    $0x1b,%edx
  801b60:	01 d0                	add    %edx,%eax
  801b62:	83 e0 1f             	and    $0x1f,%eax
  801b65:	29 d0                	sub    %edx,%eax
  801b67:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b72:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b75:	83 c3 01             	add    $0x1,%ebx
  801b78:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b7b:	75 d8                	jne    801b55 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b80:	eb 05                	jmp    801b87 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b82:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5e                   	pop    %esi
  801b8c:	5f                   	pop    %edi
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    

00801b8f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9a:	50                   	push   %eax
  801b9b:	e8 51 f5 ff ff       	call   8010f1 <fd_alloc>
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	89 c2                	mov    %eax,%edx
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	0f 88 2c 01 00 00    	js     801cd9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	68 07 04 00 00       	push   $0x407
  801bb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 c6 f1 ff ff       	call   800d85 <sys_page_alloc>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	89 c2                	mov    %eax,%edx
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	0f 88 0d 01 00 00    	js     801cd9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd2:	50                   	push   %eax
  801bd3:	e8 19 f5 ff ff       	call   8010f1 <fd_alloc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 e2 00 00 00    	js     801cc7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	68 07 04 00 00       	push   $0x407
  801bed:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 8e f1 ff ff       	call   800d85 <sys_page_alloc>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 c3 00 00 00    	js     801cc7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c04:	83 ec 0c             	sub    $0xc,%esp
  801c07:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0a:	e8 cb f4 ff ff       	call   8010da <fd2data>
  801c0f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c11:	83 c4 0c             	add    $0xc,%esp
  801c14:	68 07 04 00 00       	push   $0x407
  801c19:	50                   	push   %eax
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 64 f1 ff ff       	call   800d85 <sys_page_alloc>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	0f 88 89 00 00 00    	js     801cb7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	ff 75 f0             	pushl  -0x10(%ebp)
  801c34:	e8 a1 f4 ff ff       	call   8010da <fd2data>
  801c39:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c40:	50                   	push   %eax
  801c41:	6a 00                	push   $0x0
  801c43:	56                   	push   %esi
  801c44:	6a 00                	push   $0x0
  801c46:	e8 7d f1 ff ff       	call   800dc8 <sys_page_map>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	83 c4 20             	add    $0x20,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 55                	js     801ca9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c54:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c62:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c72:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c77:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	ff 75 f4             	pushl  -0xc(%ebp)
  801c84:	e8 41 f4 ff ff       	call   8010ca <fd2num>
  801c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c8e:	83 c4 04             	add    $0x4,%esp
  801c91:	ff 75 f0             	pushl  -0x10(%ebp)
  801c94:	e8 31 f4 ff ff       	call   8010ca <fd2num>
  801c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca7:	eb 30                	jmp    801cd9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ca9:	83 ec 08             	sub    $0x8,%esp
  801cac:	56                   	push   %esi
  801cad:	6a 00                	push   $0x0
  801caf:	e8 56 f1 ff ff       	call   800e0a <sys_page_unmap>
  801cb4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbd:	6a 00                	push   $0x0
  801cbf:	e8 46 f1 ff ff       	call   800e0a <sys_page_unmap>
  801cc4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cc7:	83 ec 08             	sub    $0x8,%esp
  801cca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 36 f1 ff ff       	call   800e0a <sys_page_unmap>
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	ff 75 08             	pushl  0x8(%ebp)
  801cef:	e8 4c f4 ff ff       	call   801140 <fd_lookup>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 18                	js     801d13 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801d01:	e8 d4 f3 ff ff       	call   8010da <fd2data>
	return _pipeisclosed(fd, p);
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0b:	e8 21 fd ff ff       	call   801a31 <_pipeisclosed>
  801d10:	83 c4 10             	add    $0x10,%esp
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d25:	68 4c 27 80 00       	push   $0x80274c
  801d2a:	ff 75 0c             	pushl  0xc(%ebp)
  801d2d:	e8 50 ec ff ff       	call   800982 <strcpy>
	return 0;
}
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	57                   	push   %edi
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
  801d3f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d45:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d4a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d50:	eb 2d                	jmp    801d7f <devcons_write+0x46>
		m = n - tot;
  801d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d55:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d57:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d5a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d5f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d62:	83 ec 04             	sub    $0x4,%esp
  801d65:	53                   	push   %ebx
  801d66:	03 45 0c             	add    0xc(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	57                   	push   %edi
  801d6b:	e8 a4 ed ff ff       	call   800b14 <memmove>
		sys_cputs(buf, m);
  801d70:	83 c4 08             	add    $0x8,%esp
  801d73:	53                   	push   %ebx
  801d74:	57                   	push   %edi
  801d75:	e8 4f ef ff ff       	call   800cc9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7a:	01 de                	add    %ebx,%esi
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	89 f0                	mov    %esi,%eax
  801d81:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d84:	72 cc                	jb     801d52 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9d:	74 2a                	je     801dc9 <devcons_read+0x3b>
  801d9f:	eb 05                	jmp    801da6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da1:	e8 c0 ef ff ff       	call   800d66 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801da6:	e8 3c ef ff ff       	call   800ce7 <sys_cgetc>
  801dab:	85 c0                	test   %eax,%eax
  801dad:	74 f2                	je     801da1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 16                	js     801dc9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801db3:	83 f8 04             	cmp    $0x4,%eax
  801db6:	74 0c                	je     801dc4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbb:	88 02                	mov    %al,(%edx)
	return 1;
  801dbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc2:	eb 05                	jmp    801dc9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dd7:	6a 01                	push   $0x1
  801dd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	e8 e7 ee ff ff       	call   800cc9 <sys_cputs>
}
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <getchar>:

int
getchar(void)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ded:	6a 01                	push   $0x1
  801def:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	6a 00                	push   $0x0
  801df5:	e8 ac f5 ff ff       	call   8013a6 <read>
	if (r < 0)
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 0f                	js     801e10 <getchar+0x29>
		return r;
	if (r < 1)
  801e01:	85 c0                	test   %eax,%eax
  801e03:	7e 06                	jle    801e0b <getchar+0x24>
		return -E_EOF;
	return c;
  801e05:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e09:	eb 05                	jmp    801e10 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e0b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	ff 75 08             	pushl  0x8(%ebp)
  801e1f:	e8 1c f3 ff ff       	call   801140 <fd_lookup>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	78 11                	js     801e3c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e34:	39 10                	cmp    %edx,(%eax)
  801e36:	0f 94 c0             	sete   %al
  801e39:	0f b6 c0             	movzbl %al,%eax
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <opencons>:

int
opencons(void)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 a4 f2 ff ff       	call   8010f1 <fd_alloc>
  801e4d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e50:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 3e                	js     801e94 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e56:	83 ec 04             	sub    $0x4,%esp
  801e59:	68 07 04 00 00       	push   $0x407
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 1d ef ff ff       	call   800d85 <sys_page_alloc>
  801e68:	83 c4 10             	add    $0x10,%esp
		return r;
  801e6b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 23                	js     801e94 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e71:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	50                   	push   %eax
  801e8a:	e8 3b f2 ff ff       	call   8010ca <fd2num>
  801e8f:	89 c2                	mov    %eax,%edx
  801e91:	83 c4 10             	add    $0x10,%esp
}
  801e94:	89 d0                	mov    %edx,%eax
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	56                   	push   %esi
  801e9c:	53                   	push   %ebx
  801e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ea6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ea8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ead:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	50                   	push   %eax
  801eb4:	e8 7c f0 ff ff       	call   800f35 <sys_ipc_recv>

	if (from_env_store != NULL)
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 f6                	test   %esi,%esi
  801ebe:	74 14                	je     801ed4 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ec0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 09                	js     801ed2 <ipc_recv+0x3a>
  801ec9:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ecf:	8b 52 74             	mov    0x74(%edx),%edx
  801ed2:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ed4:	85 db                	test   %ebx,%ebx
  801ed6:	74 14                	je     801eec <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ed8:	ba 00 00 00 00       	mov    $0x0,%edx
  801edd:	85 c0                	test   %eax,%eax
  801edf:	78 09                	js     801eea <ipc_recv+0x52>
  801ee1:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ee7:	8b 52 78             	mov    0x78(%edx),%edx
  801eea:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 08                	js     801ef8 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ef0:	a1 20 44 80 00       	mov    0x804420,%eax
  801ef5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efb:	5b                   	pop    %ebx
  801efc:	5e                   	pop    %esi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	57                   	push   %edi
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 0c             	sub    $0xc,%esp
  801f08:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f11:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f13:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f18:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f1b:	ff 75 14             	pushl  0x14(%ebp)
  801f1e:	53                   	push   %ebx
  801f1f:	56                   	push   %esi
  801f20:	57                   	push   %edi
  801f21:	e8 ec ef ff ff       	call   800f12 <sys_ipc_try_send>

		if (err < 0) {
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	79 1e                	jns    801f4b <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f2d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f30:	75 07                	jne    801f39 <ipc_send+0x3a>
				sys_yield();
  801f32:	e8 2f ee ff ff       	call   800d66 <sys_yield>
  801f37:	eb e2                	jmp    801f1b <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f39:	50                   	push   %eax
  801f3a:	68 58 27 80 00       	push   $0x802758
  801f3f:	6a 49                	push   $0x49
  801f41:	68 65 27 80 00       	push   $0x802765
  801f46:	e8 d9 e3 ff ff       	call   800324 <_panic>
		}

	} while (err < 0);

}
  801f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f61:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f67:	8b 52 50             	mov    0x50(%edx),%edx
  801f6a:	39 ca                	cmp    %ecx,%edx
  801f6c:	75 0d                	jne    801f7b <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f71:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f76:	8b 40 48             	mov    0x48(%eax),%eax
  801f79:	eb 0f                	jmp    801f8a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7b:	83 c0 01             	add    $0x1,%eax
  801f7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f83:	75 d9                	jne    801f5e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    

00801f8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f92:	89 d0                	mov    %edx,%eax
  801f94:	c1 e8 16             	shr    $0x16,%eax
  801f97:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa3:	f6 c1 01             	test   $0x1,%cl
  801fa6:	74 1d                	je     801fc5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa8:	c1 ea 0c             	shr    $0xc,%edx
  801fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb2:	f6 c2 01             	test   $0x1,%dl
  801fb5:	74 0e                	je     801fc5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb7:	c1 ea 0c             	shr    $0xc,%edx
  801fba:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc1:	ef 
  801fc2:	0f b7 c0             	movzwl %ax,%eax
}
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
