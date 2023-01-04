
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 9f 0c 00 00       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 3c 13 00 00       	call   801395 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 d9 12 00 00       	call   801341 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 61 12 00 00       	call   8012da <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 80 23 80 00       	mov    $0x802380,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 8b 23 80 00       	push   $0x80238b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 a5 23 80 00       	push   $0x8023a5
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 40 25 80 00       	push   $0x802540
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 a5 23 80 00       	push   $0x8023a5
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 b5 23 80 00       	mov    $0x8023b5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 be 23 80 00       	push   $0x8023be
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 a5 23 80 00       	push   $0x8023a5
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 64 25 80 00       	push   $0x802564
  800119:	6a 27                	push   $0x27
  80011b:	68 a5 23 80 00       	push   $0x8023a5
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 d6 23 80 00       	push   $0x8023d6
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 ea 23 80 00       	push   $0x8023ea
  800154:	6a 2b                	push   $0x2b
  800156:	68 a5 23 80 00       	push   $0x8023a5
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 3f 0b 00 00       	call   800cad <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 29 0b 00 00       	call   800cad <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 94 25 80 00       	push   $0x802594
  80018f:	6a 2d                	push   $0x2d
  800191:	68 a5 23 80 00       	push   $0x8023a5
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 f8 23 80 00       	push   $0x8023f8
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 6d 0c 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 0b 24 80 00       	push   $0x80240b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 a5 23 80 00       	push   $0x8023a5
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 90 0b 00 00       	call   800d90 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 19 24 80 00       	push   $0x802419
  80020f:	6a 34                	push   $0x34
  800211:	68 a5 23 80 00       	push   $0x8023a5
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
		// panic("file_read returned wrong data, buf[%d]: %s\n", strlen(buf), buf);
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 37 24 80 00       	push   $0x802437
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 4a 24 80 00       	push   $0x80244a
  800242:	6a 39                	push   $0x39
  800244:	68 a5 23 80 00       	push   $0x8023a5
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 59 24 80 00       	push   $0x802459
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 e4 0e 00 00       	call   80116e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 bc 25 80 00       	push   $0x8025bc
  8002b1:	6a 44                	push   $0x44
  8002b3:	68 a5 23 80 00       	push   $0x8023a5
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 6d 24 80 00       	push   $0x80246d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 83 24 80 00       	mov    $0x802483,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 8d 24 80 00       	push   $0x80248d
  8002e6:	6a 49                	push   $0x49
  8002e8:	68 a5 23 80 00       	push   $0x8023a5
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 a7 09 00 00       	call   800cad <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 86 09 00 00       	call   800cad <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 a6 24 80 00       	push   $0x8024a6
  800334:	6a 4c                	push   $0x4c
  800336:	68 a5 23 80 00       	push   $0x8023a5
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 b5 24 80 00       	push   $0x8024b5
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 be 0a 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 f4 25 80 00       	push   $0x8025f4
  800390:	6a 52                	push   $0x52
  800392:	68 a5 23 80 00       	push   $0x8023a5
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 03 09 00 00       	call   800cad <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 14 26 80 00       	push   $0x802614
  8003b7:	6a 54                	push   $0x54
  8003b9:	68 a5 23 80 00       	push   $0x8023a5
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b8 09 00 00       	call   800d90 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 4c 26 80 00       	push   $0x80264c
  8003e7:	6a 56                	push   $0x56
  8003e9:	68 a5 23 80 00       	push   $0x8023a5
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 7c 26 80 00       	push   $0x80267c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 80 23 80 00       	push   $0x802380
  80040a:	e8 19 17 00 00       	call   801b28 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 91 23 80 00       	push   $0x802391
  800426:	6a 5b                	push   $0x5b
  800428:	68 a5 23 80 00       	push   $0x8023a5
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 c9 24 80 00       	push   $0x8024c9
  80043e:	6a 5d                	push   $0x5d
  800440:	68 a5 23 80 00       	push   $0x8023a5
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 b5 23 80 00       	push   $0x8023b5
  800454:	e8 cf 16 00 00       	call   801b28 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 c4 23 80 00       	push   $0x8023c4
  800466:	6a 60                	push   $0x60
  800468:	68 a5 23 80 00       	push   $0x8023a5
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 a0 26 80 00       	push   $0x8026a0
  800498:	6a 63                	push   $0x63
  80049a:	68 a5 23 80 00       	push   $0x8023a5
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 dc 23 80 00       	push   $0x8023dc
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 e4 24 80 00       	push   $0x8024e4
  8004be:	e8 65 16 00 00       	call   801b28 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 e9 24 80 00       	push   $0x8024e9
  8004d2:	6a 68                	push   $0x68
  8004d4:	68 a5 23 80 00       	push   $0x8023a5
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 37 09 00 00       	call   800e2b <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 6d 12 00 00       	call   801784 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 f8 24 80 00       	push   $0x8024f8
  800528:	6a 6d                	push   $0x6d
  80052a:	68 a5 23 80 00       	push   $0x8023a5
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 22 10 00 00       	call   80156e <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 e4 24 80 00       	push   $0x8024e4
  800556:	e8 cd 15 00 00       	call   801b28 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 0a 25 80 00       	push   $0x80250a
  80056a:	6a 72                	push   $0x72
  80056c:	68 a5 23 80 00       	push   $0x8023a5
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 a5 11 00 00       	call   80173b <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 18 25 80 00       	push   $0x802518
  8005a7:	6a 76                	push   $0x76
  8005a9:	68 a5 23 80 00       	push   $0x8023a5
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 c8 26 80 00       	push   $0x8026c8
  8005c9:	6a 79                	push   $0x79
  8005cb:	68 a5 23 80 00       	push   $0x8023a5
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 f4 26 80 00       	push   $0x8026f4
  8005e9:	6a 7c                	push   $0x7c
  8005eb:	68 a5 23 80 00       	push   $0x8023a5
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 5d 0f 00 00       	call   80156e <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 29 25 80 00 	movl   $0x802529,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 73 0a 00 00       	call   8010ab <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 20 0f 00 00       	call   801599 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 e7 09 00 00       	call   80106a <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 10 0a 00 00       	call   8010ab <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 4c 27 80 00       	push   $0x80274c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 9f 2b 80 00 	movl   $0x802b9f,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 2f 09 00 00       	call   80102d <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 d4 08 00 00       	call   80102d <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 27 19 00 00       	call   8020f0 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 14 1a 00 00       	call   802220 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 89 03 00 00    	je     800c3d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 1a 03 00 00    	ja     800c22 <vprintfmt+0x38a>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800926:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800929:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80092d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800930:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800933:	83 fa 09             	cmp    $0x9,%edx
  800936:	77 39                	ja     800971 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb e9                	jmp    800926 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094e:	eb 27                	jmp    800977 <vprintfmt+0xdf>
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	85 c0                	test   %eax,%eax
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	0f 49 c8             	cmovns %eax,%ecx
  80095d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800963:	eb 8c                	jmp    8008f1 <vprintfmt+0x59>
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800968:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80096f:	eb 80                	jmp    8008f1 <vprintfmt+0x59>
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	0f 89 70 ff ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800981:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800984:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800987:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80098e:	e9 5e ff ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800993:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800999:	e9 53 ff ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	ff 30                	pushl  (%eax)
  8009ad:	ff d6                	call   *%esi
			break;
  8009af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b5:	e9 04 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c3:	8b 00                	mov    (%eax),%eax
  8009c5:	99                   	cltd   
  8009c6:	31 d0                	xor    %edx,%eax
  8009c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ca:	83 f8 0f             	cmp    $0xf,%eax
  8009cd:	7f 0b                	jg     8009da <vprintfmt+0x142>
  8009cf:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 87 27 80 00       	push   $0x802787
  8009e0:	53                   	push   %ebx
  8009e1:	56                   	push   %esi
  8009e2:	e8 94 fe ff ff       	call   80087b <printfmt>
  8009e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009ed:	e9 cc fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f2:	52                   	push   %edx
  8009f3:	68 6d 2b 80 00       	push   $0x802b6d
  8009f8:	53                   	push   %ebx
  8009f9:	56                   	push   %esi
  8009fa:	e8 7c fe ff ff       	call   80087b <printfmt>
  8009ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 b4 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 80 27 80 00       	mov    $0x802780,%eax
  800a1c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a23:	0f 8e 94 00 00 00    	jle    800abd <vprintfmt+0x225>
  800a29:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a2d:	0f 84 98 00 00 00    	je     800acb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	ff 75 d0             	pushl  -0x30(%ebp)
  800a39:	57                   	push   %edi
  800a3a:	e8 86 02 00 00       	call   800cc5 <strnlen>
  800a3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a42:	29 c1                	sub    %eax,%ecx
  800a44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ed                	jg     800a58 <vprintfmt+0x1c0>
  800a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f 49 c1             	cmovns %ecx,%eax
  800a7b:	29 c1                	sub    %eax,%ecx
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	89 cb                	mov    %ecx,%ebx
  800a88:	eb 4d                	jmp    800ad7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8e:	74 1b                	je     800aab <vprintfmt+0x213>
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 20             	sub    $0x20,%eax
  800a96:	83 f8 5e             	cmp    $0x5e,%eax
  800a99:	76 10                	jbe    800aab <vprintfmt+0x213>
					putch('?', putdat);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	6a 3f                	push   $0x3f
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 0d                	jmp    800ab8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	52                   	push   %edx
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	eb 1a                	jmp    800ad7 <vprintfmt+0x23f>
  800abd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac9:	eb 0c                	jmp    800ad7 <vprintfmt+0x23f>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad7:	83 c7 01             	add    $0x1,%edi
  800ada:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ade:	0f be d0             	movsbl %al,%edx
  800ae1:	85 d2                	test   %edx,%edx
  800ae3:	74 23                	je     800b08 <vprintfmt+0x270>
  800ae5:	85 f6                	test   %esi,%esi
  800ae7:	78 a1                	js     800a8a <vprintfmt+0x1f2>
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	79 9c                	jns    800a8a <vprintfmt+0x1f2>
  800aee:	89 df                	mov    %ebx,%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	eb 18                	jmp    800b10 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 08                	jmp    800b10 <vprintfmt+0x278>
  800b08:	89 df                	mov    %ebx,%edi
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	7f e4                	jg     800af8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b17:	e9 a2 fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1c:	83 fa 01             	cmp    $0x1,%edx
  800b1f:	7e 16                	jle    800b37 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 08             	lea    0x8(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2a:	8b 50 04             	mov    0x4(%eax),%edx
  800b2d:	8b 00                	mov    (%eax),%eax
  800b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b32:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b35:	eb 32                	jmp    800b69 <vprintfmt+0x2d1>
	else if (lflag)
  800b37:	85 d2                	test   %edx,%edx
  800b39:	74 18                	je     800b53 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b51:	eb 16                	jmp    800b69 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 04             	lea    0x4(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 00                	mov    (%eax),%eax
  800b5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	c1 f9 1f             	sar    $0x1f,%ecx
  800b66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b78:	79 74                	jns    800bee <vprintfmt+0x356>
				putch('-', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 2d                	push   $0x2d
  800b80:	ff d6                	call   *%esi
				num = -(long long) num;
  800b82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b85:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b88:	f7 d8                	neg    %eax
  800b8a:	83 d2 00             	adc    $0x0,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b92:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b97:	eb 55                	jmp    800bee <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b99:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9c:	e8 83 fc ff ff       	call   800824 <getuint>
			base = 10;
  800ba1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba6:	eb 46                	jmp    800bee <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800ba8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bab:	e8 74 fc ff ff       	call   800824 <getuint>
			base = 8;
  800bb0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bb5:	eb 37                	jmp    800bee <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bb7:	83 ec 08             	sub    $0x8,%esp
  800bba:	53                   	push   %ebx
  800bbb:	6a 30                	push   $0x30
  800bbd:	ff d6                	call   *%esi
			putch('x', putdat);
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	53                   	push   %ebx
  800bc3:	6a 78                	push   $0x78
  800bc5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 50 04             	lea    0x4(%eax),%edx
  800bcd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bda:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bdf:	eb 0d                	jmp    800bee <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be1:	8d 45 14             	lea    0x14(%ebp),%eax
  800be4:	e8 3b fc ff ff       	call   800824 <getuint>
			base = 16;
  800be9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bf5:	57                   	push   %edi
  800bf6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf9:	51                   	push   %ecx
  800bfa:	52                   	push   %edx
  800bfb:	50                   	push   %eax
  800bfc:	89 da                	mov    %ebx,%edx
  800bfe:	89 f0                	mov    %esi,%eax
  800c00:	e8 70 fb ff ff       	call   800775 <printnum>
			break;
  800c05:	83 c4 20             	add    $0x20,%esp
  800c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0b:	e9 ae fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	51                   	push   %ecx
  800c15:	ff d6                	call   *%esi
			break;
  800c17:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c1d:	e9 9c fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	53                   	push   %ebx
  800c26:	6a 25                	push   $0x25
  800c28:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb 03                	jmp    800c32 <vprintfmt+0x39a>
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c36:	75 f7                	jne    800c2f <vprintfmt+0x397>
  800c38:	e9 81 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 18             	sub    $0x18,%esp
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c54:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c58:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	74 26                	je     800c8c <vsnprintf+0x47>
  800c66:	85 d2                	test   %edx,%edx
  800c68:	7e 22                	jle    800c8c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6a:	ff 75 14             	pushl  0x14(%ebp)
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c73:	50                   	push   %eax
  800c74:	68 5e 08 80 00       	push   $0x80085e
  800c79:	e8 1a fc ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c81:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	eb 05                	jmp    800c91 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c99:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c9c:	50                   	push   %eax
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	ff 75 08             	pushl  0x8(%ebp)
  800ca6:	e8 9a ff ff ff       	call   800c45 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	eb 03                	jmp    800cbd <strlen+0x10>
		n++;
  800cba:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc1:	75 f7                	jne    800cba <strlen+0xd>
		n++;
	return n;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	eb 03                	jmp    800cd8 <strnlen+0x13>
		n++;
  800cd5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	39 c2                	cmp    %eax,%edx
  800cda:	74 08                	je     800ce4 <strnlen+0x1f>
  800cdc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ce0:	75 f3                	jne    800cd5 <strnlen+0x10>
  800ce2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	53                   	push   %ebx
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	83 c2 01             	add    $0x1,%edx
  800cf5:	83 c1 01             	add    $0x1,%ecx
  800cf8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cff:	84 db                	test   %bl,%bl
  800d01:	75 ef                	jne    800cf2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0d:	53                   	push   %ebx
  800d0e:	e8 9a ff ff ff       	call   800cad <strlen>
  800d13:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d16:	ff 75 0c             	pushl  0xc(%ebp)
  800d19:	01 d8                	add    %ebx,%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 c5 ff ff ff       	call   800ce6 <strcpy>
	return dst;
}
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	eb 0f                	jmp    800d4b <strncpy+0x23>
		*dst++ = *src;
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	0f b6 01             	movzbl (%ecx),%eax
  800d42:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d45:	80 39 01             	cmpb   $0x1,(%ecx)
  800d48:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4b:	39 da                	cmp    %ebx,%edx
  800d4d:	75 ed                	jne    800d3c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 10             	mov    0x10(%ebp),%edx
  800d63:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d65:	85 d2                	test   %edx,%edx
  800d67:	74 21                	je     800d8a <strlcpy+0x35>
  800d69:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	eb 09                	jmp    800d7a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d7a:	39 c2                	cmp    %eax,%edx
  800d7c:	74 09                	je     800d87 <strlcpy+0x32>
  800d7e:	0f b6 19             	movzbl (%ecx),%ebx
  800d81:	84 db                	test   %bl,%bl
  800d83:	75 ec                	jne    800d71 <strlcpy+0x1c>
  800d85:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d8a:	29 f0                	sub    %esi,%eax
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d99:	eb 06                	jmp    800da1 <strcmp+0x11>
		p++, q++;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800da1:	0f b6 01             	movzbl (%ecx),%eax
  800da4:	84 c0                	test   %al,%al
  800da6:	74 04                	je     800dac <strcmp+0x1c>
  800da8:	3a 02                	cmp    (%edx),%al
  800daa:	74 ef                	je     800d9b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 c0             	movzbl %al,%eax
  800daf:	0f b6 12             	movzbl (%edx),%edx
  800db2:	29 d0                	sub    %edx,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dc5:	eb 06                	jmp    800dcd <strncmp+0x17>
		n--, p++, q++;
  800dc7:	83 c0 01             	add    $0x1,%eax
  800dca:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcd:	39 d8                	cmp    %ebx,%eax
  800dcf:	74 15                	je     800de6 <strncmp+0x30>
  800dd1:	0f b6 08             	movzbl (%eax),%ecx
  800dd4:	84 c9                	test   %cl,%cl
  800dd6:	74 04                	je     800ddc <strncmp+0x26>
  800dd8:	3a 0a                	cmp    (%edx),%cl
  800dda:	74 eb                	je     800dc7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	0f b6 12             	movzbl (%edx),%edx
  800de2:	29 d0                	sub    %edx,%eax
  800de4:	eb 05                	jmp    800deb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800deb:	5b                   	pop    %ebx
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df8:	eb 07                	jmp    800e01 <strchr+0x13>
		if (*s == c)
  800dfa:	38 ca                	cmp    %cl,%dl
  800dfc:	74 0f                	je     800e0d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfe:	83 c0 01             	add    $0x1,%eax
  800e01:	0f b6 10             	movzbl (%eax),%edx
  800e04:	84 d2                	test   %dl,%dl
  800e06:	75 f2                	jne    800dfa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e19:	eb 03                	jmp    800e1e <strfind+0xf>
  800e1b:	83 c0 01             	add    $0x1,%eax
  800e1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e21:	38 ca                	cmp    %cl,%dl
  800e23:	74 04                	je     800e29 <strfind+0x1a>
  800e25:	84 d2                	test   %dl,%dl
  800e27:	75 f2                	jne    800e1b <strfind+0xc>
			break;
	return (char *) s;
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	74 36                	je     800e71 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e41:	75 28                	jne    800e6b <memset+0x40>
  800e43:	f6 c1 03             	test   $0x3,%cl
  800e46:	75 23                	jne    800e6b <memset+0x40>
		c &= 0xFF;
  800e48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4c:	89 d3                	mov    %edx,%ebx
  800e4e:	c1 e3 08             	shl    $0x8,%ebx
  800e51:	89 d6                	mov    %edx,%esi
  800e53:	c1 e6 18             	shl    $0x18,%esi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	c1 e0 10             	shl    $0x10,%eax
  800e5b:	09 f0                	or     %esi,%eax
  800e5d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e5f:	89 d8                	mov    %ebx,%eax
  800e61:	09 d0                	or     %edx,%eax
  800e63:	c1 e9 02             	shr    $0x2,%ecx
  800e66:	fc                   	cld    
  800e67:	f3 ab                	rep stos %eax,%es:(%edi)
  800e69:	eb 06                	jmp    800e71 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	fc                   	cld    
  800e6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e86:	39 c6                	cmp    %eax,%esi
  800e88:	73 35                	jae    800ebf <memmove+0x47>
  800e8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e8d:	39 d0                	cmp    %edx,%eax
  800e8f:	73 2e                	jae    800ebf <memmove+0x47>
		s += n;
		d += n;
  800e91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	09 fe                	or     %edi,%esi
  800e98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e9e:	75 13                	jne    800eb3 <memmove+0x3b>
  800ea0:	f6 c1 03             	test   $0x3,%cl
  800ea3:	75 0e                	jne    800eb3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ea5:	83 ef 04             	sub    $0x4,%edi
  800ea8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eab:	c1 e9 02             	shr    $0x2,%ecx
  800eae:	fd                   	std    
  800eaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb1:	eb 09                	jmp    800ebc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb3:	83 ef 01             	sub    $0x1,%edi
  800eb6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800eb9:	fd                   	std    
  800eba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ebc:	fc                   	cld    
  800ebd:	eb 1d                	jmp    800edc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebf:	89 f2                	mov    %esi,%edx
  800ec1:	09 c2                	or     %eax,%edx
  800ec3:	f6 c2 03             	test   $0x3,%dl
  800ec6:	75 0f                	jne    800ed7 <memmove+0x5f>
  800ec8:	f6 c1 03             	test   $0x3,%cl
  800ecb:	75 0a                	jne    800ed7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ecd:	c1 e9 02             	shr    $0x2,%ecx
  800ed0:	89 c7                	mov    %eax,%edi
  800ed2:	fc                   	cld    
  800ed3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed5:	eb 05                	jmp    800edc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	fc                   	cld    
  800eda:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ee3:	ff 75 10             	pushl  0x10(%ebp)
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	ff 75 08             	pushl  0x8(%ebp)
  800eec:	e8 87 ff ff ff       	call   800e78 <memmove>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efe:	89 c6                	mov    %eax,%esi
  800f00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f03:	eb 1a                	jmp    800f1f <memcmp+0x2c>
		if (*s1 != *s2)
  800f05:	0f b6 08             	movzbl (%eax),%ecx
  800f08:	0f b6 1a             	movzbl (%edx),%ebx
  800f0b:	38 d9                	cmp    %bl,%cl
  800f0d:	74 0a                	je     800f19 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f0f:	0f b6 c1             	movzbl %cl,%eax
  800f12:	0f b6 db             	movzbl %bl,%ebx
  800f15:	29 d8                	sub    %ebx,%eax
  800f17:	eb 0f                	jmp    800f28 <memcmp+0x35>
		s1++, s2++;
  800f19:	83 c0 01             	add    $0x1,%eax
  800f1c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1f:	39 f0                	cmp    %esi,%eax
  800f21:	75 e2                	jne    800f05 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f38:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3c:	eb 0a                	jmp    800f48 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f3e:	0f b6 10             	movzbl (%eax),%edx
  800f41:	39 da                	cmp    %ebx,%edx
  800f43:	74 07                	je     800f4c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	39 c8                	cmp    %ecx,%eax
  800f4a:	72 f2                	jb     800f3e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f4c:	5b                   	pop    %ebx
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5b:	eb 03                	jmp    800f60 <strtol+0x11>
		s++;
  800f5d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f60:	0f b6 01             	movzbl (%ecx),%eax
  800f63:	3c 20                	cmp    $0x20,%al
  800f65:	74 f6                	je     800f5d <strtol+0xe>
  800f67:	3c 09                	cmp    $0x9,%al
  800f69:	74 f2                	je     800f5d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f6b:	3c 2b                	cmp    $0x2b,%al
  800f6d:	75 0a                	jne    800f79 <strtol+0x2a>
		s++;
  800f6f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f72:	bf 00 00 00 00       	mov    $0x0,%edi
  800f77:	eb 11                	jmp    800f8a <strtol+0x3b>
  800f79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f7e:	3c 2d                	cmp    $0x2d,%al
  800f80:	75 08                	jne    800f8a <strtol+0x3b>
		s++, neg = 1;
  800f82:	83 c1 01             	add    $0x1,%ecx
  800f85:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f8a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f90:	75 15                	jne    800fa7 <strtol+0x58>
  800f92:	80 39 30             	cmpb   $0x30,(%ecx)
  800f95:	75 10                	jne    800fa7 <strtol+0x58>
  800f97:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f9b:	75 7c                	jne    801019 <strtol+0xca>
		s += 2, base = 16;
  800f9d:	83 c1 02             	add    $0x2,%ecx
  800fa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fa5:	eb 16                	jmp    800fbd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fa7:	85 db                	test   %ebx,%ebx
  800fa9:	75 12                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 08                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
  800fb5:	83 c1 01             	add    $0x1,%ecx
  800fb8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fc5:	0f b6 11             	movzbl (%ecx),%edx
  800fc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 09             	cmp    $0x9,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x8b>
			dig = *s - '0';
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 30             	sub    $0x30,%edx
  800fd8:	eb 22                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 08                	ja     800fec <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 57             	sub    $0x57,%edx
  800fea:	eb 10                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fec:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fef:	89 f3                	mov    %esi,%ebx
  800ff1:	80 fb 19             	cmp    $0x19,%bl
  800ff4:	77 16                	ja     80100c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ff6:	0f be d2             	movsbl %dl,%edx
  800ff9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ffc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fff:	7d 0b                	jge    80100c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	0f af 45 10          	imul   0x10(%ebp),%eax
  801008:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80100a:	eb b9                	jmp    800fc5 <strtol+0x76>

	if (endptr)
  80100c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801010:	74 0d                	je     80101f <strtol+0xd0>
		*endptr = (char *) s;
  801012:	8b 75 0c             	mov    0xc(%ebp),%esi
  801015:	89 0e                	mov    %ecx,(%esi)
  801017:	eb 06                	jmp    80101f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801019:	85 db                	test   %ebx,%ebx
  80101b:	74 98                	je     800fb5 <strtol+0x66>
  80101d:	eb 9e                	jmp    800fbd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80101f:	89 c2                	mov    %eax,%edx
  801021:	f7 da                	neg    %edx
  801023:	85 ff                	test   %edi,%edi
  801025:	0f 45 c2             	cmovne %edx,%eax
}
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 c7                	mov    %eax,%edi
  801042:	89 c6                	mov    %eax,%esi
  801044:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <sys_cgetc>:

int
sys_cgetc(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	89 d1                	mov    %edx,%ecx
  80105d:	89 d3                	mov    %edx,%ebx
  80105f:	89 d7                	mov    %edx,%edi
  801061:	89 d6                	mov    %edx,%esi
  801063:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801073:	b9 00 00 00 00       	mov    $0x0,%ecx
  801078:	b8 03 00 00 00       	mov    $0x3,%eax
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	89 cb                	mov    %ecx,%ebx
  801082:	89 cf                	mov    %ecx,%edi
  801084:	89 ce                	mov    %ecx,%esi
  801086:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	7e 17                	jle    8010a3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	6a 03                	push   $0x3
  801092:	68 7f 2a 80 00       	push   $0x802a7f
  801097:	6a 23                	push   $0x23
  801099:	68 9c 2a 80 00       	push   $0x802a9c
  80109e:	e8 e5 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	89 d6                	mov    %edx,%esi
  8010c3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_yield>:

void
sys_yield(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	be 00 00 00 00       	mov    $0x0,%esi
  8010f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801105:	89 f7                	mov    %esi,%edi
  801107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	7e 17                	jle    801124 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	50                   	push   %eax
  801111:	6a 04                	push   $0x4
  801113:	68 7f 2a 80 00       	push   $0x802a7f
  801118:	6a 23                	push   $0x23
  80111a:	68 9c 2a 80 00       	push   $0x802a9c
  80111f:	e8 64 f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801135:	b8 05 00 00 00       	mov    $0x5,%eax
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801143:	8b 7d 14             	mov    0x14(%ebp),%edi
  801146:	8b 75 18             	mov    0x18(%ebp),%esi
  801149:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 17                	jle    801166 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	50                   	push   %eax
  801153:	6a 05                	push   $0x5
  801155:	68 7f 2a 80 00       	push   $0x802a7f
  80115a:	6a 23                	push   $0x23
  80115c:	68 9c 2a 80 00       	push   $0x802a9c
  801161:	e8 22 f5 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	b8 06 00 00 00       	mov    $0x6,%eax
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 df                	mov    %ebx,%edi
  801189:	89 de                	mov    %ebx,%esi
  80118b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	7e 17                	jle    8011a8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	50                   	push   %eax
  801195:	6a 06                	push   $0x6
  801197:	68 7f 2a 80 00       	push   $0x802a7f
  80119c:	6a 23                	push   $0x23
  80119e:	68 9c 2a 80 00       	push   $0x802a9c
  8011a3:	e8 e0 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011be:	b8 08 00 00 00       	mov    $0x8,%eax
  8011c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c9:	89 df                	mov    %ebx,%edi
  8011cb:	89 de                	mov    %ebx,%esi
  8011cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	7e 17                	jle    8011ea <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	50                   	push   %eax
  8011d7:	6a 08                	push   $0x8
  8011d9:	68 7f 2a 80 00       	push   $0x802a7f
  8011de:	6a 23                	push   $0x23
  8011e0:	68 9c 2a 80 00       	push   $0x802a9c
  8011e5:	e8 9e f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	b8 09 00 00 00       	mov    $0x9,%eax
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	89 df                	mov    %ebx,%edi
  80120d:	89 de                	mov    %ebx,%esi
  80120f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801211:	85 c0                	test   %eax,%eax
  801213:	7e 17                	jle    80122c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	50                   	push   %eax
  801219:	6a 09                	push   $0x9
  80121b:	68 7f 2a 80 00       	push   $0x802a7f
  801220:	6a 23                	push   $0x23
  801222:	68 9c 2a 80 00       	push   $0x802a9c
  801227:	e8 5c f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	b8 0a 00 00 00       	mov    $0xa,%eax
  801247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	89 df                	mov    %ebx,%edi
  80124f:	89 de                	mov    %ebx,%esi
  801251:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 17                	jle    80126e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	50                   	push   %eax
  80125b:	6a 0a                	push   $0xa
  80125d:	68 7f 2a 80 00       	push   $0x802a7f
  801262:	6a 23                	push   $0x23
  801264:	68 9c 2a 80 00       	push   $0x802a9c
  801269:	e8 1a f4 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80126e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5f                   	pop    %edi
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127c:	be 00 00 00 00       	mov    $0x0,%esi
  801281:	b8 0c 00 00 00       	mov    $0xc,%eax
  801286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801289:	8b 55 08             	mov    0x8(%ebp),%edx
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801292:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8012af:	89 cb                	mov    %ecx,%ebx
  8012b1:	89 cf                	mov    %ecx,%edi
  8012b3:	89 ce                	mov    %ecx,%esi
  8012b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7e 17                	jle    8012d2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	50                   	push   %eax
  8012bf:	6a 0d                	push   $0xd
  8012c1:	68 7f 2a 80 00       	push   $0x802a7f
  8012c6:	6a 23                	push   $0x23
  8012c8:	68 9c 2a 80 00       	push   $0x802a9c
  8012cd:	e8 b6 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8012e8:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8012ea:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012ef:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8012f2:	83 ec 0c             	sub    $0xc,%esp
  8012f5:	50                   	push   %eax
  8012f6:	e8 9e ff ff ff       	call   801299 <sys_ipc_recv>

	if (from_env_store != NULL)
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 f6                	test   %esi,%esi
  801300:	74 14                	je     801316 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801302:	ba 00 00 00 00       	mov    $0x0,%edx
  801307:	85 c0                	test   %eax,%eax
  801309:	78 09                	js     801314 <ipc_recv+0x3a>
  80130b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801311:	8b 52 74             	mov    0x74(%edx),%edx
  801314:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801316:	85 db                	test   %ebx,%ebx
  801318:	74 14                	je     80132e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80131a:	ba 00 00 00 00       	mov    $0x0,%edx
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 09                	js     80132c <ipc_recv+0x52>
  801323:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801329:	8b 52 78             	mov    0x78(%edx),%edx
  80132c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 08                	js     80133a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801332:	a1 04 40 80 00       	mov    0x804004,%eax
  801337:	8b 40 70             	mov    0x70(%eax),%eax
}
  80133a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	57                   	push   %edi
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80134d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801350:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801353:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801355:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80135a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80135d:	ff 75 14             	pushl  0x14(%ebp)
  801360:	53                   	push   %ebx
  801361:	56                   	push   %esi
  801362:	57                   	push   %edi
  801363:	e8 0e ff ff ff       	call   801276 <sys_ipc_try_send>

		if (err < 0) {
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	79 1e                	jns    80138d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80136f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801372:	75 07                	jne    80137b <ipc_send+0x3a>
				sys_yield();
  801374:	e8 51 fd ff ff       	call   8010ca <sys_yield>
  801379:	eb e2                	jmp    80135d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80137b:	50                   	push   %eax
  80137c:	68 aa 2a 80 00       	push   $0x802aaa
  801381:	6a 49                	push   $0x49
  801383:	68 b7 2a 80 00       	push   $0x802ab7
  801388:	e8 fb f2 ff ff       	call   800688 <_panic>
		}

	} while (err < 0);

}
  80138d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80139b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013a0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013a3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013a9:	8b 52 50             	mov    0x50(%edx),%edx
  8013ac:	39 ca                	cmp    %ecx,%edx
  8013ae:	75 0d                	jne    8013bd <ipc_find_env+0x28>
			return envs[i].env_id;
  8013b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013b8:	8b 40 48             	mov    0x48(%eax),%eax
  8013bb:	eb 0f                	jmp    8013cc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013bd:	83 c0 01             	add    $0x1,%eax
  8013c0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013c5:	75 d9                	jne    8013a0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013d9:	c1 e8 0c             	shr    $0xc,%eax
}
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ee:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801400:	89 c2                	mov    %eax,%edx
  801402:	c1 ea 16             	shr    $0x16,%edx
  801405:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80140c:	f6 c2 01             	test   $0x1,%dl
  80140f:	74 11                	je     801422 <fd_alloc+0x2d>
  801411:	89 c2                	mov    %eax,%edx
  801413:	c1 ea 0c             	shr    $0xc,%edx
  801416:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80141d:	f6 c2 01             	test   $0x1,%dl
  801420:	75 09                	jne    80142b <fd_alloc+0x36>
			*fd_store = fd;
  801422:	89 01                	mov    %eax,(%ecx)
			return 0;
  801424:	b8 00 00 00 00       	mov    $0x0,%eax
  801429:	eb 17                	jmp    801442 <fd_alloc+0x4d>
  80142b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801430:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801435:	75 c9                	jne    801400 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801437:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80143d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80144a:	83 f8 1f             	cmp    $0x1f,%eax
  80144d:	77 36                	ja     801485 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80144f:	c1 e0 0c             	shl    $0xc,%eax
  801452:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801457:	89 c2                	mov    %eax,%edx
  801459:	c1 ea 16             	shr    $0x16,%edx
  80145c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801463:	f6 c2 01             	test   $0x1,%dl
  801466:	74 24                	je     80148c <fd_lookup+0x48>
  801468:	89 c2                	mov    %eax,%edx
  80146a:	c1 ea 0c             	shr    $0xc,%edx
  80146d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801474:	f6 c2 01             	test   $0x1,%dl
  801477:	74 1a                	je     801493 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147c:	89 02                	mov    %eax,(%edx)
	return 0;
  80147e:	b8 00 00 00 00       	mov    $0x0,%eax
  801483:	eb 13                	jmp    801498 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148a:	eb 0c                	jmp    801498 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80148c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801491:	eb 05                	jmp    801498 <fd_lookup+0x54>
  801493:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014a3:	ba 44 2b 80 00       	mov    $0x802b44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014a8:	eb 13                	jmp    8014bd <dev_lookup+0x23>
  8014aa:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014ad:	39 08                	cmp    %ecx,(%eax)
  8014af:	75 0c                	jne    8014bd <dev_lookup+0x23>
			*dev = devtab[i];
  8014b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bb:	eb 2e                	jmp    8014eb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014bd:	8b 02                	mov    (%edx),%eax
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	75 e7                	jne    8014aa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c8:	8b 40 48             	mov    0x48(%eax),%eax
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	51                   	push   %ecx
  8014cf:	50                   	push   %eax
  8014d0:	68 c4 2a 80 00       	push   $0x802ac4
  8014d5:	e8 87 f2 ff ff       	call   800761 <cprintf>
	*dev = 0;
  8014da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 10             	sub    $0x10,%esp
  8014f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801505:	c1 e8 0c             	shr    $0xc,%eax
  801508:	50                   	push   %eax
  801509:	e8 36 ff ff ff       	call   801444 <fd_lookup>
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 05                	js     80151a <fd_close+0x2d>
	    || fd != fd2)
  801515:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801518:	74 0c                	je     801526 <fd_close+0x39>
		return (must_exist ? r : 0);
  80151a:	84 db                	test   %bl,%bl
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	0f 44 c2             	cmove  %edx,%eax
  801524:	eb 41                	jmp    801567 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	ff 36                	pushl  (%esi)
  80152f:	e8 66 ff ff ff       	call   80149a <dev_lookup>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 1a                	js     801557 <fd_close+0x6a>
		if (dev->dev_close)
  80153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801540:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801543:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801548:	85 c0                	test   %eax,%eax
  80154a:	74 0b                	je     801557 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80154c:	83 ec 0c             	sub    $0xc,%esp
  80154f:	56                   	push   %esi
  801550:	ff d0                	call   *%eax
  801552:	89 c3                	mov    %eax,%ebx
  801554:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	56                   	push   %esi
  80155b:	6a 00                	push   $0x0
  80155d:	e8 0c fc ff ff       	call   80116e <sys_page_unmap>
	return r;
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	89 d8                	mov    %ebx,%eax
}
  801567:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	ff 75 08             	pushl  0x8(%ebp)
  80157b:	e8 c4 fe ff ff       	call   801444 <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 10                	js     801597 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	6a 01                	push   $0x1
  80158c:	ff 75 f4             	pushl  -0xc(%ebp)
  80158f:	e8 59 ff ff ff       	call   8014ed <fd_close>
  801594:	83 c4 10             	add    $0x10,%esp
}
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <close_all>:

void
close_all(void)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	53                   	push   %ebx
  80159d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	e8 c0 ff ff ff       	call   80156e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ae:	83 c3 01             	add    $0x1,%ebx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	83 fb 20             	cmp    $0x20,%ebx
  8015b7:	75 ec                	jne    8015a5 <close_all+0xc>
		close(i);
}
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	57                   	push   %edi
  8015c2:	56                   	push   %esi
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 2c             	sub    $0x2c,%esp
  8015c7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	ff 75 08             	pushl  0x8(%ebp)
  8015d1:	e8 6e fe ff ff       	call   801444 <fd_lookup>
  8015d6:	83 c4 08             	add    $0x8,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	0f 88 c1 00 00 00    	js     8016a2 <dup+0xe4>
		return r;
	close(newfdnum);
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	56                   	push   %esi
  8015e5:	e8 84 ff ff ff       	call   80156e <close>

	newfd = INDEX2FD(newfdnum);
  8015ea:	89 f3                	mov    %esi,%ebx
  8015ec:	c1 e3 0c             	shl    $0xc,%ebx
  8015ef:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015f5:	83 c4 04             	add    $0x4,%esp
  8015f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fb:	e8 de fd ff ff       	call   8013de <fd2data>
  801600:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801602:	89 1c 24             	mov    %ebx,(%esp)
  801605:	e8 d4 fd ff ff       	call   8013de <fd2data>
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801610:	89 f8                	mov    %edi,%eax
  801612:	c1 e8 16             	shr    $0x16,%eax
  801615:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80161c:	a8 01                	test   $0x1,%al
  80161e:	74 37                	je     801657 <dup+0x99>
  801620:	89 f8                	mov    %edi,%eax
  801622:	c1 e8 0c             	shr    $0xc,%eax
  801625:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80162c:	f6 c2 01             	test   $0x1,%dl
  80162f:	74 26                	je     801657 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801631:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	25 07 0e 00 00       	and    $0xe07,%eax
  801640:	50                   	push   %eax
  801641:	ff 75 d4             	pushl  -0x2c(%ebp)
  801644:	6a 00                	push   $0x0
  801646:	57                   	push   %edi
  801647:	6a 00                	push   $0x0
  801649:	e8 de fa ff ff       	call   80112c <sys_page_map>
  80164e:	89 c7                	mov    %eax,%edi
  801650:	83 c4 20             	add    $0x20,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 2e                	js     801685 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801657:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80165a:	89 d0                	mov    %edx,%eax
  80165c:	c1 e8 0c             	shr    $0xc,%eax
  80165f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	25 07 0e 00 00       	and    $0xe07,%eax
  80166e:	50                   	push   %eax
  80166f:	53                   	push   %ebx
  801670:	6a 00                	push   $0x0
  801672:	52                   	push   %edx
  801673:	6a 00                	push   $0x0
  801675:	e8 b2 fa ff ff       	call   80112c <sys_page_map>
  80167a:	89 c7                	mov    %eax,%edi
  80167c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80167f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801681:	85 ff                	test   %edi,%edi
  801683:	79 1d                	jns    8016a2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	53                   	push   %ebx
  801689:	6a 00                	push   $0x0
  80168b:	e8 de fa ff ff       	call   80116e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	ff 75 d4             	pushl  -0x2c(%ebp)
  801696:	6a 00                	push   $0x0
  801698:	e8 d1 fa ff ff       	call   80116e <sys_page_unmap>
	return r;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	89 f8                	mov    %edi,%eax
}
  8016a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5f                   	pop    %edi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 14             	sub    $0x14,%esp
  8016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	53                   	push   %ebx
  8016b9:	e8 86 fd ff ff       	call   801444 <fd_lookup>
  8016be:	83 c4 08             	add    $0x8,%esp
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 6d                	js     801734 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d1:	ff 30                	pushl  (%eax)
  8016d3:	e8 c2 fd ff ff       	call   80149a <dev_lookup>
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 4c                	js     80172b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016e2:	8b 42 08             	mov    0x8(%edx),%eax
  8016e5:	83 e0 03             	and    $0x3,%eax
  8016e8:	83 f8 01             	cmp    $0x1,%eax
  8016eb:	75 21                	jne    80170e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f2:	8b 40 48             	mov    0x48(%eax),%eax
  8016f5:	83 ec 04             	sub    $0x4,%esp
  8016f8:	53                   	push   %ebx
  8016f9:	50                   	push   %eax
  8016fa:	68 08 2b 80 00       	push   $0x802b08
  8016ff:	e8 5d f0 ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80170c:	eb 26                	jmp    801734 <read+0x8a>
	}
	if (!dev->dev_read)
  80170e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801711:	8b 40 08             	mov    0x8(%eax),%eax
  801714:	85 c0                	test   %eax,%eax
  801716:	74 17                	je     80172f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801718:	83 ec 04             	sub    $0x4,%esp
  80171b:	ff 75 10             	pushl  0x10(%ebp)
  80171e:	ff 75 0c             	pushl  0xc(%ebp)
  801721:	52                   	push   %edx
  801722:	ff d0                	call   *%eax
  801724:	89 c2                	mov    %eax,%edx
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	eb 09                	jmp    801734 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	eb 05                	jmp    801734 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80172f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801734:	89 d0                	mov    %edx,%eax
  801736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	57                   	push   %edi
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	8b 7d 08             	mov    0x8(%ebp),%edi
  801747:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174f:	eb 21                	jmp    801772 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801751:	83 ec 04             	sub    $0x4,%esp
  801754:	89 f0                	mov    %esi,%eax
  801756:	29 d8                	sub    %ebx,%eax
  801758:	50                   	push   %eax
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	03 45 0c             	add    0xc(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	57                   	push   %edi
  801760:	e8 45 ff ff ff       	call   8016aa <read>
		if (m < 0)
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 10                	js     80177c <readn+0x41>
			return m;
		if (m == 0)
  80176c:	85 c0                	test   %eax,%eax
  80176e:	74 0a                	je     80177a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801770:	01 c3                	add    %eax,%ebx
  801772:	39 f3                	cmp    %esi,%ebx
  801774:	72 db                	jb     801751 <readn+0x16>
  801776:	89 d8                	mov    %ebx,%eax
  801778:	eb 02                	jmp    80177c <readn+0x41>
  80177a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80177c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177f:	5b                   	pop    %ebx
  801780:	5e                   	pop    %esi
  801781:	5f                   	pop    %edi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	83 ec 14             	sub    $0x14,%esp
  80178b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801791:	50                   	push   %eax
  801792:	53                   	push   %ebx
  801793:	e8 ac fc ff ff       	call   801444 <fd_lookup>
  801798:	83 c4 08             	add    $0x8,%esp
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 68                	js     801809 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ab:	ff 30                	pushl  (%eax)
  8017ad:	e8 e8 fc ff ff       	call   80149a <dev_lookup>
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 47                	js     801800 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c0:	75 21                	jne    8017e3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c7:	8b 40 48             	mov    0x48(%eax),%eax
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	53                   	push   %ebx
  8017ce:	50                   	push   %eax
  8017cf:	68 24 2b 80 00       	push   $0x802b24
  8017d4:	e8 88 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e1:	eb 26                	jmp    801809 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e9:	85 d2                	test   %edx,%edx
  8017eb:	74 17                	je     801804 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	ff 75 10             	pushl  0x10(%ebp)
  8017f3:	ff 75 0c             	pushl  0xc(%ebp)
  8017f6:	50                   	push   %eax
  8017f7:	ff d2                	call   *%edx
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	eb 09                	jmp    801809 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801800:	89 c2                	mov    %eax,%edx
  801802:	eb 05                	jmp    801809 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801804:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801809:	89 d0                	mov    %edx,%eax
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <seek>:

int
seek(int fdnum, off_t offset)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801816:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	ff 75 08             	pushl  0x8(%ebp)
  80181d:	e8 22 fc ff ff       	call   801444 <fd_lookup>
  801822:	83 c4 08             	add    $0x8,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 0e                	js     801837 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801829:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80182c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	53                   	push   %ebx
  80183d:	83 ec 14             	sub    $0x14,%esp
  801840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801843:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	53                   	push   %ebx
  801848:	e8 f7 fb ff ff       	call   801444 <fd_lookup>
  80184d:	83 c4 08             	add    $0x8,%esp
  801850:	89 c2                	mov    %eax,%edx
  801852:	85 c0                	test   %eax,%eax
  801854:	78 65                	js     8018bb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801860:	ff 30                	pushl  (%eax)
  801862:	e8 33 fc ff ff       	call   80149a <dev_lookup>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 44                	js     8018b2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801875:	75 21                	jne    801898 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801877:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80187c:	8b 40 48             	mov    0x48(%eax),%eax
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	53                   	push   %ebx
  801883:	50                   	push   %eax
  801884:	68 e4 2a 80 00       	push   $0x802ae4
  801889:	e8 d3 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801896:	eb 23                	jmp    8018bb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801898:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189b:	8b 52 18             	mov    0x18(%edx),%edx
  80189e:	85 d2                	test   %edx,%edx
  8018a0:	74 14                	je     8018b6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	ff 75 0c             	pushl  0xc(%ebp)
  8018a8:	50                   	push   %eax
  8018a9:	ff d2                	call   *%edx
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	eb 09                	jmp    8018bb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	eb 05                	jmp    8018bb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018bb:	89 d0                	mov    %edx,%eax
  8018bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 14             	sub    $0x14,%esp
  8018c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cf:	50                   	push   %eax
  8018d0:	ff 75 08             	pushl  0x8(%ebp)
  8018d3:	e8 6c fb ff ff       	call   801444 <fd_lookup>
  8018d8:	83 c4 08             	add    $0x8,%esp
  8018db:	89 c2                	mov    %eax,%edx
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	78 58                	js     801939 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e7:	50                   	push   %eax
  8018e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018eb:	ff 30                	pushl  (%eax)
  8018ed:	e8 a8 fb ff ff       	call   80149a <dev_lookup>
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 37                	js     801930 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801900:	74 32                	je     801934 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801902:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801905:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80190c:	00 00 00 
	stat->st_isdir = 0;
  80190f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801916:	00 00 00 
	stat->st_dev = dev;
  801919:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	53                   	push   %ebx
  801923:	ff 75 f0             	pushl  -0x10(%ebp)
  801926:	ff 50 14             	call   *0x14(%eax)
  801929:	89 c2                	mov    %eax,%edx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	eb 09                	jmp    801939 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801930:	89 c2                	mov    %eax,%edx
  801932:	eb 05                	jmp    801939 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801934:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801939:	89 d0                	mov    %edx,%eax
  80193b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	6a 00                	push   $0x0
  80194a:	ff 75 08             	pushl  0x8(%ebp)
  80194d:	e8 d6 01 00 00       	call   801b28 <open>
  801952:	89 c3                	mov    %eax,%ebx
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	85 c0                	test   %eax,%eax
  801959:	78 1b                	js     801976 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80195b:	83 ec 08             	sub    $0x8,%esp
  80195e:	ff 75 0c             	pushl  0xc(%ebp)
  801961:	50                   	push   %eax
  801962:	e8 5b ff ff ff       	call   8018c2 <fstat>
  801967:	89 c6                	mov    %eax,%esi
	close(fd);
  801969:	89 1c 24             	mov    %ebx,(%esp)
  80196c:	e8 fd fb ff ff       	call   80156e <close>
	return r;
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	89 f0                	mov    %esi,%eax
}
  801976:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801979:	5b                   	pop    %ebx
  80197a:	5e                   	pop    %esi
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	89 c6                	mov    %eax,%esi
  801984:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801986:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80198d:	75 12                	jne    8019a1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	6a 01                	push   $0x1
  801994:	e8 fc f9 ff ff       	call   801395 <ipc_find_env>
  801999:	a3 00 40 80 00       	mov    %eax,0x804000
  80199e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019a1:	6a 07                	push   $0x7
  8019a3:	68 00 50 80 00       	push   $0x805000
  8019a8:	56                   	push   %esi
  8019a9:	ff 35 00 40 80 00    	pushl  0x804000
  8019af:	e8 8d f9 ff ff       	call   801341 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019b4:	83 c4 0c             	add    $0xc,%esp
  8019b7:	6a 00                	push   $0x0
  8019b9:	53                   	push   %ebx
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 19 f9 ff ff       	call   8012da <ipc_recv>
}
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	b8 02 00 00 00       	mov    $0x2,%eax
  8019eb:	e8 8d ff ff ff       	call   80197d <fsipc>
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 06 00 00 00       	mov    $0x6,%eax
  801a0d:	e8 6b ff ff ff       	call   80197d <fsipc>
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	53                   	push   %ebx
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	8b 40 0c             	mov    0xc(%eax),%eax
  801a24:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a29:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a33:	e8 45 ff ff ff       	call   80197d <fsipc>
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 2c                	js     801a68 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a3c:	83 ec 08             	sub    $0x8,%esp
  801a3f:	68 00 50 80 00       	push   $0x805000
  801a44:	53                   	push   %ebx
  801a45:	e8 9c f2 ff ff       	call   800ce6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a4a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a4f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a55:	a1 84 50 80 00       	mov    0x805084,%eax
  801a5a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a76:	8b 55 08             	mov    0x8(%ebp),%edx
  801a79:	8b 52 0c             	mov    0xc(%edx),%edx
  801a7c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a82:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a87:	50                   	push   %eax
  801a88:	ff 75 0c             	pushl  0xc(%ebp)
  801a8b:	68 08 50 80 00       	push   $0x805008
  801a90:	e8 e3 f3 ff ff       	call   800e78 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a95:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9a:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9f:	e8 d9 fe ff ff       	call   80197d <fsipc>

}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ab9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac9:	e8 af fe ff ff       	call   80197d <fsipc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 4b                	js     801b1f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ad4:	39 c6                	cmp    %eax,%esi
  801ad6:	73 16                	jae    801aee <devfile_read+0x48>
  801ad8:	68 54 2b 80 00       	push   $0x802b54
  801add:	68 5b 2b 80 00       	push   $0x802b5b
  801ae2:	6a 7c                	push   $0x7c
  801ae4:	68 70 2b 80 00       	push   $0x802b70
  801ae9:	e8 9a eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801aee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af3:	7e 16                	jle    801b0b <devfile_read+0x65>
  801af5:	68 7b 2b 80 00       	push   $0x802b7b
  801afa:	68 5b 2b 80 00       	push   $0x802b5b
  801aff:	6a 7d                	push   $0x7d
  801b01:	68 70 2b 80 00       	push   $0x802b70
  801b06:	e8 7d eb ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	50                   	push   %eax
  801b0f:	68 00 50 80 00       	push   $0x805000
  801b14:	ff 75 0c             	pushl  0xc(%ebp)
  801b17:	e8 5c f3 ff ff       	call   800e78 <memmove>
	return r;
  801b1c:	83 c4 10             	add    $0x10,%esp
}
  801b1f:	89 d8                	mov    %ebx,%eax
  801b21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 20             	sub    $0x20,%esp
  801b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b32:	53                   	push   %ebx
  801b33:	e8 75 f1 ff ff       	call   800cad <strlen>
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b40:	7f 67                	jg     801ba9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b48:	50                   	push   %eax
  801b49:	e8 a7 f8 ff ff       	call   8013f5 <fd_alloc>
  801b4e:	83 c4 10             	add    $0x10,%esp
		return r;
  801b51:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 57                	js     801bae <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	53                   	push   %ebx
  801b5b:	68 00 50 80 00       	push   $0x805000
  801b60:	e8 81 f1 ff ff       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b68:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b70:	b8 01 00 00 00       	mov    $0x1,%eax
  801b75:	e8 03 fe ff ff       	call   80197d <fsipc>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	79 14                	jns    801b97 <open+0x6f>
		fd_close(fd, 0);
  801b83:	83 ec 08             	sub    $0x8,%esp
  801b86:	6a 00                	push   $0x0
  801b88:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8b:	e8 5d f9 ff ff       	call   8014ed <fd_close>
		return r;
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	89 da                	mov    %ebx,%edx
  801b95:	eb 17                	jmp    801bae <open+0x86>
	}

	return fd2num(fd);
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9d:	e8 2c f8 ff ff       	call   8013ce <fd2num>
  801ba2:	89 c2                	mov    %eax,%edx
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	eb 05                	jmp    801bae <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ba9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bae:	89 d0                	mov    %edx,%eax
  801bb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc5:	e8 b3 fd ff ff       	call   80197d <fsipc>
}
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	ff 75 08             	pushl  0x8(%ebp)
  801bda:	e8 ff f7 ff ff       	call   8013de <fd2data>
  801bdf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801be1:	83 c4 08             	add    $0x8,%esp
  801be4:	68 87 2b 80 00       	push   $0x802b87
  801be9:	53                   	push   %ebx
  801bea:	e8 f7 f0 ff ff       	call   800ce6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bef:	8b 46 04             	mov    0x4(%esi),%eax
  801bf2:	2b 06                	sub    (%esi),%eax
  801bf4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bfa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c01:	00 00 00 
	stat->st_dev = &devpipe;
  801c04:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c0b:	30 80 00 
	return 0;
}
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c24:	53                   	push   %ebx
  801c25:	6a 00                	push   $0x0
  801c27:	e8 42 f5 ff ff       	call   80116e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c2c:	89 1c 24             	mov    %ebx,(%esp)
  801c2f:	e8 aa f7 ff ff       	call   8013de <fd2data>
  801c34:	83 c4 08             	add    $0x8,%esp
  801c37:	50                   	push   %eax
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 2f f5 ff ff       	call   80116e <sys_page_unmap>
}
  801c3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	57                   	push   %edi
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 1c             	sub    $0x1c,%esp
  801c4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c50:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c52:	a1 04 40 80 00       	mov    0x804004,%eax
  801c57:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c60:	e8 46 04 00 00       	call   8020ab <pageref>
  801c65:	89 c3                	mov    %eax,%ebx
  801c67:	89 3c 24             	mov    %edi,(%esp)
  801c6a:	e8 3c 04 00 00       	call   8020ab <pageref>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	39 c3                	cmp    %eax,%ebx
  801c74:	0f 94 c1             	sete   %cl
  801c77:	0f b6 c9             	movzbl %cl,%ecx
  801c7a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c7d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c83:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c86:	39 ce                	cmp    %ecx,%esi
  801c88:	74 1b                	je     801ca5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c8a:	39 c3                	cmp    %eax,%ebx
  801c8c:	75 c4                	jne    801c52 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c8e:	8b 42 58             	mov    0x58(%edx),%eax
  801c91:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c94:	50                   	push   %eax
  801c95:	56                   	push   %esi
  801c96:	68 8e 2b 80 00       	push   $0x802b8e
  801c9b:	e8 c1 ea ff ff       	call   800761 <cprintf>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	eb ad                	jmp    801c52 <_pipeisclosed+0xe>
	}
}
  801ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5f                   	pop    %edi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	57                   	push   %edi
  801cb4:	56                   	push   %esi
  801cb5:	53                   	push   %ebx
  801cb6:	83 ec 28             	sub    $0x28,%esp
  801cb9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cbc:	56                   	push   %esi
  801cbd:	e8 1c f7 ff ff       	call   8013de <fd2data>
  801cc2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ccc:	eb 4b                	jmp    801d19 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cce:	89 da                	mov    %ebx,%edx
  801cd0:	89 f0                	mov    %esi,%eax
  801cd2:	e8 6d ff ff ff       	call   801c44 <_pipeisclosed>
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	75 48                	jne    801d23 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cdb:	e8 ea f3 ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ce0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce3:	8b 0b                	mov    (%ebx),%ecx
  801ce5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ce8:	39 d0                	cmp    %edx,%eax
  801cea:	73 e2                	jae    801cce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cf3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cf6:	89 c2                	mov    %eax,%edx
  801cf8:	c1 fa 1f             	sar    $0x1f,%edx
  801cfb:	89 d1                	mov    %edx,%ecx
  801cfd:	c1 e9 1b             	shr    $0x1b,%ecx
  801d00:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d03:	83 e2 1f             	and    $0x1f,%edx
  801d06:	29 ca                	sub    %ecx,%edx
  801d08:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d0c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d10:	83 c0 01             	add    $0x1,%eax
  801d13:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d16:	83 c7 01             	add    $0x1,%edi
  801d19:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d1c:	75 c2                	jne    801ce0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d21:	eb 05                	jmp    801d28 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	57                   	push   %edi
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	83 ec 18             	sub    $0x18,%esp
  801d39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d3c:	57                   	push   %edi
  801d3d:	e8 9c f6 ff ff       	call   8013de <fd2data>
  801d42:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4c:	eb 3d                	jmp    801d8b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d4e:	85 db                	test   %ebx,%ebx
  801d50:	74 04                	je     801d56 <devpipe_read+0x26>
				return i;
  801d52:	89 d8                	mov    %ebx,%eax
  801d54:	eb 44                	jmp    801d9a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d56:	89 f2                	mov    %esi,%edx
  801d58:	89 f8                	mov    %edi,%eax
  801d5a:	e8 e5 fe ff ff       	call   801c44 <_pipeisclosed>
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	75 32                	jne    801d95 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d63:	e8 62 f3 ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d68:	8b 06                	mov    (%esi),%eax
  801d6a:	3b 46 04             	cmp    0x4(%esi),%eax
  801d6d:	74 df                	je     801d4e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d6f:	99                   	cltd   
  801d70:	c1 ea 1b             	shr    $0x1b,%edx
  801d73:	01 d0                	add    %edx,%eax
  801d75:	83 e0 1f             	and    $0x1f,%eax
  801d78:	29 d0                	sub    %edx,%eax
  801d7a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d82:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d85:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d88:	83 c3 01             	add    $0x1,%ebx
  801d8b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d8e:	75 d8                	jne    801d68 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d90:	8b 45 10             	mov    0x10(%ebp),%eax
  801d93:	eb 05                	jmp    801d9a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    

00801da2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	56                   	push   %esi
  801da6:	53                   	push   %ebx
  801da7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	e8 42 f6 ff ff       	call   8013f5 <fd_alloc>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	85 c0                	test   %eax,%eax
  801dba:	0f 88 2c 01 00 00    	js     801eec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc0:	83 ec 04             	sub    $0x4,%esp
  801dc3:	68 07 04 00 00       	push   $0x407
  801dc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 17 f3 ff ff       	call   8010e9 <sys_page_alloc>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	89 c2                	mov    %eax,%edx
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	0f 88 0d 01 00 00    	js     801eec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	e8 0a f6 ff ff       	call   8013f5 <fd_alloc>
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 88 e2 00 00 00    	js     801eda <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df8:	83 ec 04             	sub    $0x4,%esp
  801dfb:	68 07 04 00 00       	push   $0x407
  801e00:	ff 75 f0             	pushl  -0x10(%ebp)
  801e03:	6a 00                	push   $0x0
  801e05:	e8 df f2 ff ff       	call   8010e9 <sys_page_alloc>
  801e0a:	89 c3                	mov    %eax,%ebx
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	0f 88 c3 00 00 00    	js     801eda <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e17:	83 ec 0c             	sub    $0xc,%esp
  801e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1d:	e8 bc f5 ff ff       	call   8013de <fd2data>
  801e22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e24:	83 c4 0c             	add    $0xc,%esp
  801e27:	68 07 04 00 00       	push   $0x407
  801e2c:	50                   	push   %eax
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 b5 f2 ff ff       	call   8010e9 <sys_page_alloc>
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	0f 88 89 00 00 00    	js     801eca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 f0             	pushl  -0x10(%ebp)
  801e47:	e8 92 f5 ff ff       	call   8013de <fd2data>
  801e4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e53:	50                   	push   %eax
  801e54:	6a 00                	push   $0x0
  801e56:	56                   	push   %esi
  801e57:	6a 00                	push   $0x0
  801e59:	e8 ce f2 ff ff       	call   80112c <sys_page_map>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	83 c4 20             	add    $0x20,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 55                	js     801ebc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e67:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e7c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	ff 75 f4             	pushl  -0xc(%ebp)
  801e97:	e8 32 f5 ff ff       	call   8013ce <fd2num>
  801e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ea1:	83 c4 04             	add    $0x4,%esp
  801ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea7:	e8 22 f5 ff ff       	call   8013ce <fd2num>
  801eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eaf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eba:	eb 30                	jmp    801eec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ebc:	83 ec 08             	sub    $0x8,%esp
  801ebf:	56                   	push   %esi
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 a7 f2 ff ff       	call   80116e <sys_page_unmap>
  801ec7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 97 f2 ff ff       	call   80116e <sys_page_unmap>
  801ed7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801eda:	83 ec 08             	sub    $0x8,%esp
  801edd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 87 f2 ff ff       	call   80116e <sys_page_unmap>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eec:	89 d0                	mov    %edx,%eax
  801eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef1:	5b                   	pop    %ebx
  801ef2:	5e                   	pop    %esi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	ff 75 08             	pushl  0x8(%ebp)
  801f02:	e8 3d f5 ff ff       	call   801444 <fd_lookup>
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 18                	js     801f26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	ff 75 f4             	pushl  -0xc(%ebp)
  801f14:	e8 c5 f4 ff ff       	call   8013de <fd2data>
	return _pipeisclosed(fd, p);
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1e:	e8 21 fd ff ff       	call   801c44 <_pipeisclosed>
  801f23:	83 c4 10             	add    $0x10,%esp
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f38:	68 a6 2b 80 00       	push   $0x802ba6
  801f3d:	ff 75 0c             	pushl  0xc(%ebp)
  801f40:	e8 a1 ed ff ff       	call   800ce6 <strcpy>
	return 0;
}
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	57                   	push   %edi
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
  801f52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f58:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f63:	eb 2d                	jmp    801f92 <devcons_write+0x46>
		m = n - tot;
  801f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f68:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f6a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f6d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f72:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f75:	83 ec 04             	sub    $0x4,%esp
  801f78:	53                   	push   %ebx
  801f79:	03 45 0c             	add    0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	57                   	push   %edi
  801f7e:	e8 f5 ee ff ff       	call   800e78 <memmove>
		sys_cputs(buf, m);
  801f83:	83 c4 08             	add    $0x8,%esp
  801f86:	53                   	push   %ebx
  801f87:	57                   	push   %edi
  801f88:	e8 a0 f0 ff ff       	call   80102d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8d:	01 de                	add    %ebx,%esi
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	89 f0                	mov    %esi,%eax
  801f94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f97:	72 cc                	jb     801f65 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 08             	sub    $0x8,%esp
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb0:	74 2a                	je     801fdc <devcons_read+0x3b>
  801fb2:	eb 05                	jmp    801fb9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fb4:	e8 11 f1 ff ff       	call   8010ca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb9:	e8 8d f0 ff ff       	call   80104b <sys_cgetc>
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	74 f2                	je     801fb4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 16                	js     801fdc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fc6:	83 f8 04             	cmp    $0x4,%eax
  801fc9:	74 0c                	je     801fd7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fce:	88 02                	mov    %al,(%edx)
	return 1;
  801fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd5:	eb 05                	jmp    801fdc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fea:	6a 01                	push   $0x1
  801fec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fef:	50                   	push   %eax
  801ff0:	e8 38 f0 ff ff       	call   80102d <sys_cputs>
}
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <getchar>:

int
getchar(void)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802000:	6a 01                	push   $0x1
  802002:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802005:	50                   	push   %eax
  802006:	6a 00                	push   $0x0
  802008:	e8 9d f6 ff ff       	call   8016aa <read>
	if (r < 0)
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	85 c0                	test   %eax,%eax
  802012:	78 0f                	js     802023 <getchar+0x29>
		return r;
	if (r < 1)
  802014:	85 c0                	test   %eax,%eax
  802016:	7e 06                	jle    80201e <getchar+0x24>
		return -E_EOF;
	return c;
  802018:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80201c:	eb 05                	jmp    802023 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80201e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80202b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202e:	50                   	push   %eax
  80202f:	ff 75 08             	pushl  0x8(%ebp)
  802032:	e8 0d f4 ff ff       	call   801444 <fd_lookup>
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 11                	js     80204f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80203e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802041:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802047:	39 10                	cmp    %edx,(%eax)
  802049:	0f 94 c0             	sete   %al
  80204c:	0f b6 c0             	movzbl %al,%eax
}
  80204f:	c9                   	leave  
  802050:	c3                   	ret    

00802051 <opencons>:

int
opencons(void)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802057:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205a:	50                   	push   %eax
  80205b:	e8 95 f3 ff ff       	call   8013f5 <fd_alloc>
  802060:	83 c4 10             	add    $0x10,%esp
		return r;
  802063:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802065:	85 c0                	test   %eax,%eax
  802067:	78 3e                	js     8020a7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802069:	83 ec 04             	sub    $0x4,%esp
  80206c:	68 07 04 00 00       	push   $0x407
  802071:	ff 75 f4             	pushl  -0xc(%ebp)
  802074:	6a 00                	push   $0x0
  802076:	e8 6e f0 ff ff       	call   8010e9 <sys_page_alloc>
  80207b:	83 c4 10             	add    $0x10,%esp
		return r;
  80207e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802080:	85 c0                	test   %eax,%eax
  802082:	78 23                	js     8020a7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802084:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80208a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802092:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802099:	83 ec 0c             	sub    $0xc,%esp
  80209c:	50                   	push   %eax
  80209d:	e8 2c f3 ff ff       	call   8013ce <fd2num>
  8020a2:	89 c2                	mov    %eax,%edx
  8020a4:	83 c4 10             	add    $0x10,%esp
}
  8020a7:	89 d0                	mov    %edx,%eax
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b1:	89 d0                	mov    %edx,%eax
  8020b3:	c1 e8 16             	shr    $0x16,%eax
  8020b6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c2:	f6 c1 01             	test   $0x1,%cl
  8020c5:	74 1d                	je     8020e4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c7:	c1 ea 0c             	shr    $0xc,%edx
  8020ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d1:	f6 c2 01             	test   $0x1,%dl
  8020d4:	74 0e                	je     8020e4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d6:	c1 ea 0c             	shr    $0xc,%edx
  8020d9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e0:	ef 
  8020e1:	0f b7 c0             	movzwl %ax,%eax
}
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
