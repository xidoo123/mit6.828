
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 6b 16 00 00       	call   80169c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 40 34 80 00       	push   $0x803440
  8000b7:	e8 19 17 00 00       	call   8017d5 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 57 34 80 00       	push   $0x803457
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 67 34 80 00       	push   $0x803467
  8000e0:	e8 17 16 00 00       	call   8016fc <_panic>
	diskno = d;
  8000e5:	a3 00 40 80 00       	mov    %eax,0x804000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 70 34 80 00       	push   $0x803470
  80010b:	68 7d 34 80 00       	push   $0x80347d
  800110:	6a 44                	push   $0x44
  800112:	68 67 34 80 00       	push   $0x803467
  800117:	e8 e0 15 00 00       	call   8016fc <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 70 34 80 00       	push   $0x803470
  8001cf:	68 7d 34 80 00       	push   $0x80347d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 67 34 80 00       	push   $0x803467
  8001db:	e8 1c 15 00 00       	call   8016fc <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800280:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800282:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800288:	89 c6                	mov    %eax,%esi
  80028a:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800292:	76 1b                	jbe    8002af <bc_pgfault+0x3b>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	ff 72 04             	pushl  0x4(%edx)
  80029a:	53                   	push   %ebx
  80029b:	ff 72 28             	pushl  0x28(%edx)
  80029e:	68 94 34 80 00       	push   $0x803494
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 70 35 80 00       	push   $0x803570
  8002aa:	e8 4d 14 00 00       	call   8016fc <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 90 80 00       	mov    0x809008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 c4 34 80 00       	push   $0x8034c4
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 70 35 80 00       	push   $0x803570
  8002ca:	e8 2d 14 00 00       	call   8016fc <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:

	void* base_addr = ROUNDDOWN(addr, PGSIZE);
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	r = sys_page_alloc(0, base_addr, PTE_P|PTE_W|PTE_U);
  8002d7:	83 ec 04             	sub    $0x4,%esp
  8002da:	6a 07                	push   $0x7
  8002dc:	57                   	push   %edi
  8002dd:	6a 00                	push   $0x0
  8002df:	e8 79 1e 00 00       	call   80215d <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 e8 34 80 00       	push   $0x8034e8
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 70 35 80 00       	push   $0x803570
  8002f8:	e8 ff 13 00 00       	call   8016fc <_panic>

	r =	ide_read(blockno * 8, base_addr, 8);
  8002fd:	83 ec 04             	sub    $0x4,%esp
  800300:	6a 08                	push   $0x8
  800302:	57                   	push   %edi
  800303:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  80030a:	50                   	push   %eax
  80030b:	e8 dc fd ff ff       	call   8000ec <ide_read>
	if (r < 0)
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	85 c0                	test   %eax,%eax
  800315:	79 12                	jns    800329 <bc_pgfault+0xb5>
		panic("bc_pgfault: ide_read: %e", r);
  800317:	50                   	push   %eax
  800318:	68 78 35 80 00       	push   $0x803578
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 70 35 80 00       	push   $0x803570
  800324:	e8 d3 13 00 00       	call   8016fc <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800329:	89 d8                	mov    %ebx,%eax
  80032b:	c1 e8 0c             	shr    $0xc,%eax
  80032e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	25 07 0e 00 00       	and    $0xe07,%eax
  80033d:	50                   	push   %eax
  80033e:	53                   	push   %ebx
  80033f:	6a 00                	push   $0x0
  800341:	53                   	push   %ebx
  800342:	6a 00                	push   $0x0
  800344:	e8 57 1e 00 00       	call   8021a0 <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 08 35 80 00       	push   $0x803508
  800356:	6a 41                	push   $0x41
  800358:	68 70 35 80 00       	push   $0x803570
  80035d:	e8 9a 13 00 00       	call   8016fc <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800362:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  800369:	74 22                	je     80038d <bc_pgfault+0x119>
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	56                   	push   %esi
  80036f:	e8 36 06 00 00       	call   8009aa <block_is_free>
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	84 c0                	test   %al,%al
  800379:	74 12                	je     80038d <bc_pgfault+0x119>
		panic("reading free block %08x\n", blockno);
  80037b:	56                   	push   %esi
  80037c:	68 91 35 80 00       	push   $0x803591
  800381:	6a 47                	push   $0x47
  800383:	68 70 35 80 00       	push   $0x803570
  800388:	e8 6f 13 00 00       	call   8016fc <_panic>
}
  80038d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	74 0f                	je     8003b1 <diskaddr+0x1c>
  8003a2:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 17                	je     8003c3 <diskaddr+0x2e>
  8003ac:	3b 42 04             	cmp    0x4(%edx),%eax
  8003af:	72 12                	jb     8003c3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003b1:	50                   	push   %eax
  8003b2:	68 28 35 80 00       	push   $0x803528
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 70 35 80 00       	push   $0x803570
  8003be:	e8 39 13 00 00       	call   8016fc <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c3:	05 00 00 01 00       	add    $0x10000,%eax
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d3:	89 d0                	mov    %edx,%eax
  8003d5:	c1 e8 16             	shr    $0x16,%eax
  8003d8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003df:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e4:	f6 c1 01             	test   $0x1,%cl
  8003e7:	74 0d                	je     8003f6 <va_is_mapped+0x29>
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f3:	83 e0 01             	and    $0x1,%eax
  8003f6:	83 e0 01             	and    $0x1,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	c1 e8 0c             	shr    $0xc,%eax
  800404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80040b:	c1 e8 06             	shr    $0x6,%eax
  80040e:	83 e0 01             	and    $0x1,%eax
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80041b:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800421:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800426:	76 12                	jbe    80043a <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800428:	53                   	push   %ebx
  800429:	68 aa 35 80 00       	push   $0x8035aa
  80042e:	6a 57                	push   $0x57
  800430:	68 70 35 80 00       	push   $0x803570
  800435:	e8 c2 12 00 00       	call   8016fc <_panic>

	// LAB 5: Your code here.
	// panic("flush_block not implemented");

	if (!va_is_mapped(addr) || !va_is_dirty(addr))
  80043a:	83 ec 0c             	sub    $0xc,%esp
  80043d:	53                   	push   %ebx
  80043e:	e8 8a ff ff ff       	call   8003cd <va_is_mapped>
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	84 c0                	test   %al,%al
  800448:	0f 84 80 00 00 00    	je     8004ce <flush_block+0xbb>
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	53                   	push   %ebx
  800452:	e8 a4 ff ff ff       	call   8003fb <va_is_dirty>
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	84 c0                	test   %al,%al
  80045c:	74 70                	je     8004ce <flush_block+0xbb>
		return;
	
	void* base_addr = ROUNDDOWN(addr, PGSIZE);
  80045e:	89 de                	mov    %ebx,%esi
  800460:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	int r = ide_write(blockno * 8, base_addr, 8);
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	6a 08                	push   $0x8
  80046b:	56                   	push   %esi
  80046c:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800472:	c1 e8 0c             	shr    $0xc,%eax
  800475:	c1 e0 03             	shl    $0x3,%eax
  800478:	50                   	push   %eax
  800479:	e8 32 fd ff ff       	call   8001b0 <ide_write>
	if (r < 0)
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	85 c0                	test   %eax,%eax
  800483:	79 12                	jns    800497 <flush_block+0x84>
		panic("flush_block: ide_write: %e", r);
  800485:	50                   	push   %eax
  800486:	68 c5 35 80 00       	push   $0x8035c5
  80048b:	6a 63                	push   $0x63
  80048d:	68 70 35 80 00       	push   $0x803570
  800492:	e8 65 12 00 00       	call   8016fc <_panic>

	r = sys_page_map(0, base_addr, 0, base_addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  800497:	c1 eb 0c             	shr    $0xc,%ebx
  80049a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a9:	50                   	push   %eax
  8004aa:	56                   	push   %esi
  8004ab:	6a 00                	push   $0x0
  8004ad:	56                   	push   %esi
  8004ae:	6a 00                	push   $0x0
  8004b0:	e8 eb 1c 00 00       	call   8021a0 <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 e0 35 80 00       	push   $0x8035e0
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 70 35 80 00       	push   $0x803570
  8004c9:	e8 2e 12 00 00       	call   8016fc <_panic>

}
  8004ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	53                   	push   %ebx
  8004d9:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004df:	68 74 02 80 00       	push   $0x800274
  8004e4:	e8 65 1e 00 00       	call   80234e <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f0:	e8 a0 fe ff ff       	call   800395 <diskaddr>
  8004f5:	83 c4 0c             	add    $0xc,%esp
  8004f8:	68 08 01 00 00       	push   $0x108
  8004fd:	50                   	push   %eax
  8004fe:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	e8 e2 19 00 00       	call   801eec <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 fe 35 80 00       	push   $0x8035fe
  80051e:	50                   	push   %eax
  80051f:	e8 36 18 00 00       	call   801d5a <strcpy>
	flush_block(diskaddr(1));
  800524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052b:	e8 65 fe ff ff       	call   800395 <diskaddr>
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 db fe ff ff       	call   800413 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800538:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80053f:	e8 51 fe ff ff       	call   800395 <diskaddr>
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	e8 81 fe ff ff       	call   8003cd <va_is_mapped>
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	84 c0                	test   %al,%al
  800551:	75 16                	jne    800569 <bc_init+0x94>
  800553:	68 20 36 80 00       	push   $0x803620
  800558:	68 7d 34 80 00       	push   $0x80347d
  80055d:	6a 78                	push   $0x78
  80055f:	68 70 35 80 00       	push   $0x803570
  800564:	e8 93 11 00 00       	call   8016fc <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 05 36 80 00       	push   $0x803605
  800587:	68 7d 34 80 00       	push   $0x80347d
  80058c:	6a 79                	push   $0x79
  80058e:	68 70 35 80 00       	push   $0x803570
  800593:	e8 64 11 00 00       	call   8016fc <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 35 1c 00 00       	call   8021e2 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 1f 36 80 00       	push   $0x80361f
  8005cd:	68 7d 34 80 00       	push   $0x80347d
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 70 35 80 00       	push   $0x803570
  8005d9:	e8 1e 11 00 00       	call   8016fc <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 fe 35 80 00       	push   $0x8035fe
  8005f0:	50                   	push   %eax
  8005f1:	e8 0e 18 00 00       	call   801e04 <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 4c 35 80 00       	push   $0x80354c
  800602:	68 7d 34 80 00       	push   $0x80347d
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 70 35 80 00       	push   $0x803570
  800611:	e8 e6 10 00 00       	call   8016fc <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	6a 01                	push   $0x1
  80061b:	e8 75 fd ff ff       	call   800395 <diskaddr>
  800620:	83 c4 0c             	add    $0xc,%esp
  800623:	68 08 01 00 00       	push   $0x108
  800628:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	e8 b7 18 00 00       	call   801eec <memmove>
	flush_block(diskaddr(1));
  800635:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063c:	e8 54 fd ff ff       	call   800395 <diskaddr>
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	e8 ca fd ff ff       	call   800413 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800649:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800650:	e8 40 fd ff ff       	call   800395 <diskaddr>
  800655:	83 c4 0c             	add    $0xc,%esp
  800658:	68 08 01 00 00       	push   $0x108
  80065d:	50                   	push   %eax
  80065e:	53                   	push   %ebx
  80065f:	e8 88 18 00 00       	call   801eec <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 fe 35 80 00       	push   $0x8035fe
  800678:	50                   	push   %eax
  800679:	e8 dc 16 00 00       	call   801d5a <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  80067e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800685:	e8 0b fd ff ff       	call   800395 <diskaddr>
  80068a:	83 c0 14             	add    $0x14,%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	e8 7e fd ff ff       	call   800413 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800695:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80069c:	e8 f4 fc ff ff       	call   800395 <diskaddr>
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 24 fd ff ff       	call   8003cd <va_is_mapped>
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	84 c0                	test   %al,%al
  8006ae:	75 19                	jne    8006c9 <bc_init+0x1f4>
  8006b0:	68 20 36 80 00       	push   $0x803620
  8006b5:	68 7d 34 80 00       	push   $0x80347d
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 70 35 80 00       	push   $0x803570
  8006c4:	e8 33 10 00 00       	call   8016fc <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	6a 01                	push   $0x1
  8006ce:	e8 c2 fc ff ff       	call   800395 <diskaddr>
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	50                   	push   %eax
  8006d7:	6a 00                	push   $0x0
  8006d9:	e8 04 1b 00 00       	call   8021e2 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 1f 36 80 00       	push   $0x80361f
  8006fe:	68 7d 34 80 00       	push   $0x80347d
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 70 35 80 00       	push   $0x803570
  80070d:	e8 ea 0f 00 00       	call   8016fc <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 fe 35 80 00       	push   $0x8035fe
  800724:	50                   	push   %eax
  800725:	e8 da 16 00 00       	call   801e04 <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 4c 35 80 00       	push   $0x80354c
  800736:	68 7d 34 80 00       	push   $0x80347d
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 70 35 80 00       	push   $0x803570
  800745:	e8 b2 0f 00 00       	call   8016fc <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80074a:	83 ec 0c             	sub    $0xc,%esp
  80074d:	6a 01                	push   $0x1
  80074f:	e8 41 fc ff ff       	call   800395 <diskaddr>
  800754:	83 c4 0c             	add    $0xc,%esp
  800757:	68 08 01 00 00       	push   $0x108
  80075c:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800762:	52                   	push   %edx
  800763:	50                   	push   %eax
  800764:	e8 83 17 00 00       	call   801eec <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 3a 36 80 00 	movl   $0x80363a,(%esp)
  800784:	e8 4c 10 00 00       	call   8017d5 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800789:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800790:	e8 00 fc ff ff       	call   800395 <diskaddr>
  800795:	83 c4 0c             	add    $0xc,%esp
  800798:	68 08 01 00 00       	push   $0x108
  80079d:	50                   	push   %eax
  80079e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 42 17 00 00       	call   801eec <memmove>
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	57                   	push   %edi
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8007be:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
  8007c4:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  8007ca:	eb 03                	jmp    8007cf <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8007cc:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8007cf:	80 38 2f             	cmpb   $0x2f,(%eax)
  8007d2:	74 f8                	je     8007cc <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8007d4:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  8007da:	8d 4f 08             	lea    0x8(%edi),%ecx
  8007dd:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  8007e3:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8007ea:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	0f 84 3d 01 00 00    	je     800935 <walk_path+0x183>
		*pdir = 0;
  8007f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8007fe:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  800804:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  80080a:	80 38 00             	cmpb   $0x0,(%eax)
  80080d:	0f 84 f3 00 00 00    	je     800906 <walk_path+0x154>
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800813:	89 c3                	mov    %eax,%ebx
  800815:	eb 03                	jmp    80081a <walk_path+0x68>
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800817:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  80081a:	0f b6 13             	movzbl (%ebx),%edx
  80081d:	80 fa 2f             	cmp    $0x2f,%dl
  800820:	74 04                	je     800826 <walk_path+0x74>
  800822:	84 d2                	test   %dl,%dl
  800824:	75 f1                	jne    800817 <walk_path+0x65>
			path++;
		if (path - p >= MAXNAMELEN)
  800826:	89 de                	mov    %ebx,%esi
  800828:	29 c6                	sub    %eax,%esi
  80082a:	83 fe 7f             	cmp    $0x7f,%esi
  80082d:	0f 8f f4 00 00 00    	jg     800927 <walk_path+0x175>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800833:	83 ec 04             	sub    $0x4,%esp
  800836:	56                   	push   %esi
  800837:	50                   	push   %eax
  800838:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80083e:	50                   	push   %eax
  80083f:	e8 a8 16 00 00       	call   801eec <memmove>
		name[path - p] = '\0';
  800844:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  80084b:	00 
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb 03                	jmp    800854 <walk_path+0xa2>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800851:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800854:	0f b6 13             	movzbl (%ebx),%edx
  800857:	80 fa 2f             	cmp    $0x2f,%dl
  80085a:	74 f5                	je     800851 <walk_path+0x9f>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  80085c:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  800863:	0f 85 c5 00 00 00    	jne    80092e <walk_path+0x17c>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800869:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
  80086f:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  800875:	74 19                	je     800890 <walk_path+0xde>
  800877:	68 4f 36 80 00       	push   $0x80364f
  80087c:	68 7d 34 80 00       	push   $0x80347d
  800881:	68 bb 00 00 00       	push   $0xbb
  800886:	68 6c 36 80 00       	push   $0x80366c
  80088b:	e8 6c 0e 00 00       	call   8016fc <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800890:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  800896:	85 c9                	test   %ecx,%ecx
  800898:	0f 49 c1             	cmovns %ecx,%eax
  80089b:	c1 f8 0c             	sar    $0xc,%eax
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	74 17                	je     8008b9 <walk_path+0x107>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8008a2:	83 ec 04             	sub    $0x4,%esp
  8008a5:	68 24 37 80 00       	push   $0x803724
  8008aa:	68 a9 00 00 00       	push   $0xa9
  8008af:	68 6c 36 80 00       	push   $0x80366c
  8008b4:	e8 43 0e 00 00       	call   8016fc <_panic>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  8008b9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8008be:	84 d2                	test   %dl,%dl
  8008c0:	0f 85 86 00 00 00    	jne    80094c <walk_path+0x19a>
				if (pdir)
  8008c6:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	74 08                	je     8008d8 <walk_path+0x126>
					*pdir = dir;
  8008d0:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8008d6:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  8008d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008dc:	74 15                	je     8008f3 <walk_path+0x141>
					strcpy(lastelem, name);
  8008de:	83 ec 08             	sub    $0x8,%esp
  8008e1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8008e7:	50                   	push   %eax
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 6a 14 00 00       	call   801d5a <strcpy>
  8008f0:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  8008f3:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8008f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8008ff:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800904:	eb 46                	jmp    80094c <walk_path+0x19a>
		}
	}

	if (pdir)
		*pdir = dir;
  800906:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  80090c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = f;
  800912:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800918:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  80091e:	89 08                	mov    %ecx,(%eax)
	return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
  800925:	eb 25                	jmp    80094c <walk_path+0x19a>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800927:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80092c:	eb 1e                	jmp    80094c <walk_path+0x19a>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  80092e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800933:	eb 17                	jmp    80094c <walk_path+0x19a>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800935:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  80093b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  800941:	80 38 00             	cmpb   $0x0,(%eax)
  800944:	0f 85 c9 fe ff ff    	jne    800813 <walk_path+0x61>
  80094a:	eb c6                	jmp    800912 <walk_path+0x160>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  80094c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80095a:	a1 08 90 80 00       	mov    0x809008,%eax
  80095f:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800965:	74 14                	je     80097b <check_super+0x27>
		panic("bad file system magic number");
  800967:	83 ec 04             	sub    $0x4,%esp
  80096a:	68 74 36 80 00       	push   $0x803674
  80096f:	6a 0f                	push   $0xf
  800971:	68 6c 36 80 00       	push   $0x80366c
  800976:	e8 81 0d 00 00       	call   8016fc <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80097b:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800982:	76 14                	jbe    800998 <check_super+0x44>
		panic("file system is too large");
  800984:	83 ec 04             	sub    $0x4,%esp
  800987:	68 91 36 80 00       	push   $0x803691
  80098c:	6a 12                	push   $0x12
  80098e:	68 6c 36 80 00       	push   $0x80366c
  800993:	e8 64 0d 00 00       	call   8016fc <_panic>

	cprintf("superblock is good\n");
  800998:	83 ec 0c             	sub    $0xc,%esp
  80099b:	68 aa 36 80 00       	push   $0x8036aa
  8009a0:	e8 30 0e 00 00       	call   8017d5 <cprintf>
}
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8009b1:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	74 24                	je     8009df <block_is_free+0x35>
		return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8009c0:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8009c3:	76 1f                	jbe    8009e4 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8009c5:	89 cb                	mov    %ecx,%ebx
  8009c7:	c1 eb 05             	shr    $0x5,%ebx
  8009ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8009cf:	d3 e0                	shl    %cl,%eax
  8009d1:	8b 15 04 90 80 00    	mov    0x809004,%edx
  8009d7:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8009da:	0f 95 c0             	setne  %al
  8009dd:	eb 05                	jmp    8009e4 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	83 ec 04             	sub    $0x4,%esp
  8009ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	75 14                	jne    800a09 <free_block+0x22>
		panic("attempt to free zero block");
  8009f5:	83 ec 04             	sub    $0x4,%esp
  8009f8:	68 be 36 80 00       	push   $0x8036be
  8009fd:	6a 2d                	push   $0x2d
  8009ff:	68 6c 36 80 00       	push   $0x80366c
  800a04:	e8 f3 0c 00 00       	call   8016fc <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800a09:	89 cb                	mov    %ecx,%ebx
  800a0b:	c1 eb 05             	shr    $0x5,%ebx
  800a0e:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800a14:	b8 01 00 00 00       	mov    $0x1,%eax
  800a19:	d3 e0                	shl    %cl,%eax
  800a1b:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  800a28:	a1 08 90 80 00       	mov    0x809008,%eax
  800a2d:	8b 70 04             	mov    0x4(%eax),%esi
  800a30:	bb 01 00 00 00       	mov    $0x1,%ebx
  800a35:	eb 55                	jmp    800a8c <alloc_block+0x69>
		
		// find a free block
		if (block_is_free(i)) {
  800a37:	53                   	push   %ebx
  800a38:	e8 6d ff ff ff       	call   8009aa <block_is_free>
  800a3d:	83 c4 04             	add    $0x4,%esp
  800a40:	84 c0                	test   %al,%al
  800a42:	74 45                	je     800a89 <alloc_block+0x66>

			// mark as used in bitmap
			bitmap[i/32] ^= (1<<(i%32));
  800a44:	8d 43 1f             	lea    0x1f(%ebx),%eax
  800a47:	85 db                	test   %ebx,%ebx
  800a49:	0f 49 c3             	cmovns %ebx,%eax
  800a4c:	c1 f8 05             	sar    $0x5,%eax
  800a4f:	c1 e0 02             	shl    $0x2,%eax
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	03 15 04 90 80 00    	add    0x809004,%edx
  800a5a:	89 de                	mov    %ebx,%esi
  800a5c:	c1 fe 1f             	sar    $0x1f,%esi
  800a5f:	c1 ee 1b             	shr    $0x1b,%esi
  800a62:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  800a65:	83 e1 1f             	and    $0x1f,%ecx
  800a68:	29 f1                	sub    %esi,%ecx
  800a6a:	be 01 00 00 00       	mov    $0x1,%esi
  800a6f:	d3 e6                	shl    %cl,%esi
  800a71:	31 32                	xor    %esi,(%edx)
	
			// flush to disk
			flush_block(&bitmap[i/32]);
  800a73:	83 ec 0c             	sub    $0xc,%esp
  800a76:	03 05 04 90 80 00    	add    0x809004,%eax
  800a7c:	50                   	push   %eax
  800a7d:	e8 91 f9 ff ff       	call   800413 <flush_block>

			return i;
  800a82:	83 c4 10             	add    $0x10,%esp
  800a85:	89 d8                	mov    %ebx,%eax
  800a87:	eb 0c                	jmp    800a95 <alloc_block+0x72>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  800a89:	83 c3 01             	add    $0x1,%ebx
  800a8c:	39 de                	cmp    %ebx,%esi
  800a8e:	77 a7                	ja     800a37 <alloc_block+0x14>

			return i;
		}
	}

	return -E_NO_DISK;
  800a90:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800aa1:	a1 08 90 80 00       	mov    0x809008,%eax
  800aa6:	8b 70 04             	mov    0x4(%eax),%esi
  800aa9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aae:	eb 29                	jmp    800ad9 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800ab0:	8d 43 02             	lea    0x2(%ebx),%eax
  800ab3:	50                   	push   %eax
  800ab4:	e8 f1 fe ff ff       	call   8009aa <block_is_free>
  800ab9:	83 c4 04             	add    $0x4,%esp
  800abc:	84 c0                	test   %al,%al
  800abe:	74 16                	je     800ad6 <check_bitmap+0x3a>
  800ac0:	68 d9 36 80 00       	push   $0x8036d9
  800ac5:	68 7d 34 80 00       	push   $0x80347d
  800aca:	6a 60                	push   $0x60
  800acc:	68 6c 36 80 00       	push   $0x80366c
  800ad1:	e8 26 0c 00 00       	call   8016fc <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800ad6:	83 c3 01             	add    $0x1,%ebx
  800ad9:	89 d8                	mov    %ebx,%eax
  800adb:	c1 e0 0f             	shl    $0xf,%eax
  800ade:	39 f0                	cmp    %esi,%eax
  800ae0:	72 ce                	jb     800ab0 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	6a 00                	push   $0x0
  800ae7:	e8 be fe ff ff       	call   8009aa <block_is_free>
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	84 c0                	test   %al,%al
  800af1:	74 16                	je     800b09 <check_bitmap+0x6d>
  800af3:	68 ed 36 80 00       	push   $0x8036ed
  800af8:	68 7d 34 80 00       	push   $0x80347d
  800afd:	6a 63                	push   $0x63
  800aff:	68 6c 36 80 00       	push   $0x80366c
  800b04:	e8 f3 0b 00 00       	call   8016fc <_panic>
	assert(!block_is_free(1));
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	6a 01                	push   $0x1
  800b0e:	e8 97 fe ff ff       	call   8009aa <block_is_free>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	84 c0                	test   %al,%al
  800b18:	74 16                	je     800b30 <check_bitmap+0x94>
  800b1a:	68 ff 36 80 00       	push   $0x8036ff
  800b1f:	68 7d 34 80 00       	push   $0x80347d
  800b24:	6a 64                	push   $0x64
  800b26:	68 6c 36 80 00       	push   $0x80366c
  800b2b:	e8 cc 0b 00 00       	call   8016fc <_panic>

	cprintf("bitmap is good\n");
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	68 11 37 80 00       	push   $0x803711
  800b38:	e8 98 0c 00 00       	call   8017d5 <cprintf>
}
  800b3d:	83 c4 10             	add    $0x10,%esp
  800b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800b4d:	e8 0d f5 ff ff       	call   80005f <ide_probe_disk1>
  800b52:	84 c0                	test   %al,%al
  800b54:	74 0f                	je     800b65 <fs_init+0x1e>
		ide_set_disk(1);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	6a 01                	push   $0x1
  800b5b:	e8 63 f5 ff ff       	call   8000c3 <ide_set_disk>
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	eb 0d                	jmp    800b72 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	6a 00                	push   $0x0
  800b6a:	e8 54 f5 ff ff       	call   8000c3 <ide_set_disk>
  800b6f:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800b72:	e8 5e f9 ff ff       	call   8004d5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	6a 01                	push   $0x1
  800b7c:	e8 14 f8 ff ff       	call   800395 <diskaddr>
  800b81:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  800b86:	e8 c9 fd ff ff       	call   800954 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800b8b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b92:	e8 fe f7 ff ff       	call   800395 <diskaddr>
  800b97:	a3 04 90 80 00       	mov    %eax,0x809004
	check_bitmap();
  800b9c:	e8 fb fe ff ff       	call   800a9c <check_bitmap>
	
}
  800ba1:	83 c4 10             	add    $0x10,%esp
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 0c             	sub    $0xc,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800bac:	68 24 37 80 00       	push   $0x803724
  800bb1:	68 a9 00 00 00       	push   $0xa9
  800bb6:	68 6c 36 80 00       	push   $0x80366c
  800bbb:	e8 3c 0b 00 00       	call   8016fc <_panic>

00800bc0 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800bcb:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800bd1:	50                   	push   %eax
  800bd2:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  800bd8:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	e8 cc fb ff ff       	call   8007b2 <walk_path>
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	85 c0                	test   %eax,%eax
  800beb:	0f 84 82 00 00 00    	je     800c73 <file_create+0xb3>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800bf1:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800bf4:	0f 85 85 00 00 00    	jne    800c7f <file_create+0xbf>
  800bfa:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	74 76                	je     800c7a <file_create+0xba>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800c04:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800c0a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  800c10:	74 19                	je     800c2b <file_create+0x6b>
  800c12:	68 4f 36 80 00       	push   $0x80364f
  800c17:	68 7d 34 80 00       	push   $0x80347d
  800c1c:	68 d4 00 00 00       	push   $0xd4
  800c21:	68 6c 36 80 00       	push   $0x80366c
  800c26:	e8 d1 0a 00 00       	call   8016fc <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c2b:	be 00 10 00 00       	mov    $0x1000,%esi
  800c30:	89 d8                	mov    %ebx,%eax
  800c32:	99                   	cltd   
  800c33:	f7 fe                	idiv   %esi
  800c35:	85 c0                	test   %eax,%eax
  800c37:	74 17                	je     800c50 <file_create+0x90>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800c39:	83 ec 04             	sub    $0x4,%esp
  800c3c:	68 24 37 80 00       	push   $0x803724
  800c41:	68 a9 00 00 00       	push   $0xa9
  800c46:	68 6c 36 80 00       	push   $0x80366c
  800c4b:	e8 ac 0a 00 00       	call   8016fc <_panic>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800c50:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800c56:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800c5c:	83 ec 04             	sub    $0x4,%esp
  800c5f:	68 24 37 80 00       	push   $0x803724
  800c64:	68 a9 00 00 00       	push   $0xa9
  800c69:	68 6c 36 80 00       	push   $0x80366c
  800c6e:	e8 89 0a 00 00       	call   8016fc <_panic>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800c73:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800c78:	eb 05                	jmp    800c7f <file_create+0xbf>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800c7a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  800c7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c8c:	6a 00                	push   $0x0
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	ba 00 00 00 00       	mov    $0x0,%edx
  800c96:	8b 45 08             	mov    0x8(%ebp),%eax
  800c99:	e8 14 fb ff ff       	call   8007b2 <walk_path>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 08             	sub    $0x8,%esp
  800ca6:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800cb2:	39 d0                	cmp    %edx,%eax
  800cb4:	7e 27                	jle    800cdd <file_read+0x3d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800cb6:	29 d0                	sub    %edx,%eax
  800cb8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cbb:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800cbf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800cc2:	39 ca                	cmp    %ecx,%edx
  800cc4:	73 1c                	jae    800ce2 <file_read+0x42>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800cc6:	83 ec 04             	sub    $0x4,%esp
  800cc9:	68 24 37 80 00       	push   $0x803724
  800cce:	68 a9 00 00 00       	push   $0xa9
  800cd3:	68 6c 36 80 00       	push   $0x80366c
  800cd8:	e8 1f 0a 00 00       	call   8016fc <_panic>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cec:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800cef:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800cf5:	39 f0                	cmp    %esi,%eax
  800cf7:	7e 65                	jle    800d5e <file_set_size+0x7a>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800cf9:	8d 96 fe 1f 00 00    	lea    0x1ffe(%esi),%edx
  800cff:	89 f1                	mov    %esi,%ecx
  800d01:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  800d07:	0f 49 d1             	cmovns %ecx,%edx
  800d0a:	c1 fa 0c             	sar    $0xc,%edx
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d0d:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  800d13:	05 ff 0f 00 00       	add    $0xfff,%eax
  800d18:	0f 48 c1             	cmovs  %ecx,%eax
  800d1b:	c1 f8 0c             	sar    $0xc,%eax
  800d1e:	39 d0                	cmp    %edx,%eax
  800d20:	76 17                	jbe    800d39 <file_set_size+0x55>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	68 44 37 80 00       	push   $0x803744
  800d2a:	68 9a 00 00 00       	push   $0x9a
  800d2f:	68 6c 36 80 00       	push   $0x80366c
  800d34:	e8 c3 09 00 00       	call   8016fc <_panic>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d39:	83 fa 0a             	cmp    $0xa,%edx
  800d3c:	77 20                	ja     800d5e <file_set_size+0x7a>
  800d3e:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800d44:	85 c0                	test   %eax,%eax
  800d46:	74 16                	je     800d5e <file_set_size+0x7a>
		free_block(f->f_indirect);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	e8 96 fc ff ff       	call   8009e7 <free_block>
		f->f_indirect = 0;
  800d51:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  800d58:	00 00 00 
  800d5b:	83 c4 10             	add    $0x10,%esp
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d5e:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	53                   	push   %ebx
  800d68:	e8 a6 f6 ff ff       	call   800413 <flush_block>
	return 0;
}
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d88:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800d8b:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  800d8e:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
  800d94:	76 11                	jbe    800da7 <file_write+0x2e>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d96:	83 ec 08             	sub    $0x8,%esp
  800d99:	56                   	push   %esi
  800d9a:	50                   	push   %eax
  800d9b:	e8 44 ff ff ff       	call   800ce4 <file_set_size>
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	78 1d                	js     800dc4 <file_write+0x4b>
			return r;

	for (pos = offset; pos < offset + count; ) {
  800da7:	39 f7                	cmp    %esi,%edi
  800da9:	73 17                	jae    800dc2 <file_write+0x49>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	68 24 37 80 00       	push   $0x803724
  800db3:	68 a9 00 00 00       	push   $0xa9
  800db8:	68 6c 36 80 00       	push   $0x80366c
  800dbd:	e8 3a 09 00 00       	call   8016fc <_panic>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800dc2:	89 d8                	mov    %ebx,%eax
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800dd6:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800ddc:	05 ff 0f 00 00       	add    $0xfff,%eax
  800de1:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800de6:	7e 17                	jle    800dff <file_flush+0x33>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	68 44 37 80 00       	push   $0x803744
  800df0:	68 9a 00 00 00       	push   $0x9a
  800df5:	68 6c 36 80 00       	push   $0x80366c
  800dfa:	e8 fd 08 00 00       	call   8016fc <_panic>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	53                   	push   %ebx
  800e03:	e8 0b f6 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  800e08:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	74 14                	je     800e29 <file_flush+0x5d>
		flush_block(diskaddr(f->f_indirect));
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	e8 77 f5 ff ff       	call   800395 <diskaddr>
  800e1e:	89 04 24             	mov    %eax,(%esp)
  800e21:	e8 ed f5 ff ff       	call   800413 <flush_block>
  800e26:	83 c4 10             	add    $0x10,%esp
}
  800e29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	53                   	push   %ebx
  800e32:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800e35:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3a:	eb 17                	jmp    800e53 <fs_sync+0x25>
		flush_block(diskaddr(i));
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	53                   	push   %ebx
  800e40:	e8 50 f5 ff ff       	call   800395 <diskaddr>
  800e45:	89 04 24             	mov    %eax,(%esp)
  800e48:	e8 c6 f5 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800e4d:	83 c3 01             	add    $0x1,%ebx
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	a1 08 90 80 00       	mov    0x809008,%eax
  800e58:	39 58 04             	cmp    %ebx,0x4(%eax)
  800e5b:	77 df                	ja     800e3c <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800e5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    

00800e62 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 0c             	sub    $0xc,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800e72:	68 64 37 80 00       	push   $0x803764
  800e77:	68 e8 00 00 00       	push   $0xe8
  800e7c:	68 80 37 80 00       	push   $0x803780
  800e81:	e8 76 08 00 00       	call   8016fc <_panic>

00800e86 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800e8c:	e8 9d ff ff ff       	call   800e2e <fs_sync>
	return 0;
}
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	ba 60 40 80 00       	mov    $0x804060,%edx
	int i;
	uintptr_t va = FILEVA;
  800ea0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800eaa:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800eac:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800eaf:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800eb5:	83 c0 01             	add    $0x1,%eax
  800eb8:	83 c2 10             	add    $0x10,%edx
  800ebb:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ec0:	75 e8                	jne    800eaa <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	c1 e0 04             	shl    $0x4,%eax
  800ed9:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800edf:	e8 a8 1d 00 00       	call   802c8c <pageref>
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	74 07                	je     800ef2 <openfile_alloc+0x2e>
  800eeb:	83 f8 01             	cmp    $0x1,%eax
  800eee:	74 20                	je     800f10 <openfile_alloc+0x4c>
  800ef0:	eb 51                	jmp    800f43 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	6a 07                	push   $0x7
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	c1 e0 04             	shl    $0x4,%eax
  800efc:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800f02:	6a 00                	push   $0x0
  800f04:	e8 54 12 00 00       	call   80215d <sys_page_alloc>
  800f09:	83 c4 10             	add    $0x10,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	78 43                	js     800f53 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800f10:	c1 e3 04             	shl    $0x4,%ebx
  800f13:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800f19:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800f20:	04 00 00 
			*o = &opentab[i];
  800f23:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	68 00 10 00 00       	push   $0x1000
  800f2d:	6a 00                	push   $0x0
  800f2f:	ff b3 6c 40 80 00    	pushl  0x80406c(%ebx)
  800f35:	e8 65 0f 00 00       	call   801e9f <memset>
			return (*o)->o_fileid;
  800f3a:	8b 06                	mov    (%esi),%eax
  800f3c:	8b 00                	mov    (%eax),%eax
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	eb 10                	jmp    800f53 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800f43:	83 c3 01             	add    $0x1,%ebx
  800f46:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f4c:	75 83                	jne    800ed1 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800f4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 18             	sub    $0x18,%esp
  800f63:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800f66:	89 fb                	mov    %edi,%ebx
  800f68:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800f73:	ff b6 6c 40 80 00    	pushl  0x80406c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800f79:	81 c6 60 40 80 00    	add    $0x804060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800f7f:	e8 08 1d 00 00       	call   802c8c <pageref>
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	83 f8 01             	cmp    $0x1,%eax
  800f8a:	7e 17                	jle    800fa3 <openfile_lookup+0x49>
  800f8c:	c1 e3 04             	shl    $0x4,%ebx
  800f8f:	3b bb 60 40 80 00    	cmp    0x804060(%ebx),%edi
  800f95:	75 13                	jne    800faa <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  800f97:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9a:	89 30                	mov    %esi,(%eax)
	return 0;
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	eb 0c                	jmp    800faf <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800fa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa8:	eb 05                	jmp    800faf <openfile_lookup+0x55>
  800faa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 18             	sub    $0x18,%esp
  800fbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	ff 33                	pushl  (%ebx)
  800fc7:	ff 75 08             	pushl  0x8(%ebp)
  800fca:	e8 8b ff ff ff       	call   800f5a <openfile_lookup>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 14                	js     800fea <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	ff 73 04             	pushl  0x4(%ebx)
  800fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdf:	ff 70 04             	pushl  0x4(%eax)
  800fe2:	e8 fd fc ff ff       	call   800ce4 <file_set_size>
  800fe7:	83 c4 10             	add    $0x10,%esp
}
  800fea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 18             	sub    $0x18,%esp
  800ff6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 33                	pushl  (%ebx)
  800fff:	ff 75 08             	pushl  0x8(%ebp)
  801002:	e8 53 ff ff ff       	call   800f5a <openfile_lookup>
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 3f                	js     80104d <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	ff 70 04             	pushl  0x4(%eax)
  801017:	53                   	push   %ebx
  801018:	e8 3d 0d 00 00       	call   801d5a <strcpy>
	ret->ret_size = o->o_file->f_size;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	8b 50 04             	mov    0x4(%eax),%edx
  801023:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801029:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80102f:	8b 40 04             	mov    0x4(%eax),%eax
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80103c:	0f 94 c0             	sete   %al
  80103f:	0f b6 c0             	movzbl %al,%eax
  801042:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80104d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801058:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105b:	50                   	push   %eax
  80105c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105f:	ff 30                	pushl  (%eax)
  801061:	ff 75 08             	pushl  0x8(%ebp)
  801064:	e8 f1 fe ff ff       	call   800f5a <openfile_lookup>
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 16                	js     801086 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801076:	ff 70 04             	pushl  0x4(%eax)
  801079:	e8 4e fd ff ff       	call   800dcc <file_flush>
	return 0;
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801086:	c9                   	leave  
  801087:	c3                   	ret    

00801088 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801092:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801095:	68 00 04 00 00       	push   $0x400
  80109a:	53                   	push   %ebx
  80109b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	e8 45 0e 00 00       	call   801eec <memmove>
	path[MAXPATHLEN-1] = 0;
  8010a7:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8010ab:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8010b1:	89 04 24             	mov    %eax,(%esp)
  8010b4:	e8 0b fe ff ff       	call   800ec4 <openfile_alloc>
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	0f 88 f0 00 00 00    	js     8011b4 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8010c4:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8010cb:	74 33                	je     801100 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	e8 dd fa ff ff       	call   800bc0 <file_create>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 37                	jns    801121 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8010ea:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8010f1:	0f 85 bd 00 00 00    	jne    8011b4 <serve_open+0x12c>
  8010f7:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8010fa:	0f 85 b4 00 00 00    	jne    8011b4 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	e8 70 fb ff ff       	call   800c86 <file_open>
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	0f 88 93 00 00 00    	js     8011b4 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801121:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801128:	74 17                	je     801141 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	6a 00                	push   $0x0
  80112f:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801135:	e8 aa fb ff ff       	call   800ce4 <file_set_size>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 73                	js     8011b4 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	e8 2f fb ff ff       	call   800c86 <file_open>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 56                	js     8011b4 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80115e:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801164:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80116a:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  80116d:	8b 50 0c             	mov    0xc(%eax),%edx
  801170:	8b 08                	mov    (%eax),%ecx
  801172:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801175:	8b 48 0c             	mov    0xc(%eax),%ecx
  801178:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80117e:	83 e2 03             	and    $0x3,%edx
  801181:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801184:	8b 40 0c             	mov    0xc(%eax),%eax
  801187:	8b 15 64 80 80 00    	mov    0x808064,%edx
  80118d:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80118f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801195:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80119b:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80119e:	8b 50 0c             	mov    0xc(%eax),%edx
  8011a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a4:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8011a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a9:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8011c1:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8011c4:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8011c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	53                   	push   %ebx
  8011d2:	ff 35 44 40 80 00    	pushl  0x804044
  8011d8:	56                   	push   %esi
  8011d9:	e8 db 11 00 00       	call   8023b9 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8011e5:	75 15                	jne    8011fc <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ed:	68 ac 37 80 00       	push   $0x8037ac
  8011f2:	e8 de 05 00 00       	call   8017d5 <cprintf>
				whom);
			continue; // just leave it hanging...
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	eb cb                	jmp    8011c7 <serve+0xe>
		}

		pg = NULL;
  8011fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801203:	83 f8 01             	cmp    $0x1,%eax
  801206:	75 18                	jne    801220 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801208:	53                   	push   %ebx
  801209:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	ff 35 44 40 80 00    	pushl  0x804044
  801213:	ff 75 f4             	pushl  -0xc(%ebp)
  801216:	e8 6d fe ff ff       	call   801088 <serve_open>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	eb 3c                	jmp    80125c <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801220:	83 f8 08             	cmp    $0x8,%eax
  801223:	77 1e                	ja     801243 <serve+0x8a>
  801225:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 13                	je     801243 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	ff 35 44 40 80 00    	pushl  0x804044
  801239:	ff 75 f4             	pushl  -0xc(%ebp)
  80123c:	ff d2                	call   *%edx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	eb 19                	jmp    80125c <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	ff 75 f4             	pushl  -0xc(%ebp)
  801249:	50                   	push   %eax
  80124a:	68 dc 37 80 00       	push   $0x8037dc
  80124f:	e8 81 05 00 00       	call   8017d5 <cprintf>
  801254:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801257:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80125c:	ff 75 f0             	pushl  -0x10(%ebp)
  80125f:	ff 75 ec             	pushl  -0x14(%ebp)
  801262:	50                   	push   %eax
  801263:	ff 75 f4             	pushl  -0xc(%ebp)
  801266:	e8 b5 11 00 00       	call   802420 <ipc_send>
		sys_page_unmap(0, fsreq);
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	ff 35 44 40 80 00    	pushl  0x804044
  801274:	6a 00                	push   $0x0
  801276:	e8 67 0f 00 00       	call   8021e2 <sys_page_unmap>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	e9 44 ff ff ff       	jmp    8011c7 <serve+0xe>

00801283 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801289:	c7 05 60 80 80 00 8a 	movl   $0x80378a,0x808060
  801290:	37 80 00 
	cprintf("FS is running\n");
  801293:	68 8d 37 80 00       	push   $0x80378d
  801298:	e8 38 05 00 00       	call   8017d5 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80129d:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8012a2:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8012a7:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8012a9:	c7 04 24 9c 37 80 00 	movl   $0x80379c,(%esp)
  8012b0:	e8 20 05 00 00       	call   8017d5 <cprintf>

	serve_init();
  8012b5:	e8 de fb ff ff       	call   800e98 <serve_init>
	fs_init();
  8012ba:	e8 88 f8 ff ff       	call   800b47 <fs_init>
        fs_test();
  8012bf:	e8 05 00 00 00       	call   8012c9 <fs_test>
	serve();
  8012c4:	e8 f0 fe ff ff       	call   8011b9 <serve>

008012c9 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8012d0:	6a 07                	push   $0x7
  8012d2:	68 00 10 00 00       	push   $0x1000
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 7f 0e 00 00       	call   80215d <sys_page_alloc>
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	79 12                	jns    8012f7 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  8012e5:	50                   	push   %eax
  8012e6:	68 ff 37 80 00       	push   $0x8037ff
  8012eb:	6a 12                	push   $0x12
  8012ed:	68 12 38 80 00       	push   $0x803812
  8012f2:	e8 05 04 00 00       	call   8016fc <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	68 00 10 00 00       	push   $0x1000
  8012ff:	ff 35 04 90 80 00    	pushl  0x809004
  801305:	68 00 10 00 00       	push   $0x1000
  80130a:	e8 dd 0b 00 00       	call   801eec <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80130f:	e8 0f f7 ff ff       	call   800a23 <alloc_block>
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	79 12                	jns    80132d <fs_test+0x64>
		panic("alloc_block: %e", r);
  80131b:	50                   	push   %eax
  80131c:	68 1c 38 80 00       	push   $0x80381c
  801321:	6a 17                	push   $0x17
  801323:	68 12 38 80 00       	push   $0x803812
  801328:	e8 cf 03 00 00       	call   8016fc <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  80132d:	8d 50 1f             	lea    0x1f(%eax),%edx
  801330:	85 c0                	test   %eax,%eax
  801332:	0f 49 d0             	cmovns %eax,%edx
  801335:	c1 fa 05             	sar    $0x5,%edx
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	c1 fb 1f             	sar    $0x1f,%ebx
  80133d:	c1 eb 1b             	shr    $0x1b,%ebx
  801340:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801343:	83 e1 1f             	and    $0x1f,%ecx
  801346:	29 d9                	sub    %ebx,%ecx
  801348:	b8 01 00 00 00       	mov    $0x1,%eax
  80134d:	d3 e0                	shl    %cl,%eax
  80134f:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801356:	75 16                	jne    80136e <fs_test+0xa5>
  801358:	68 2c 38 80 00       	push   $0x80382c
  80135d:	68 7d 34 80 00       	push   $0x80347d
  801362:	6a 19                	push   $0x19
  801364:	68 12 38 80 00       	push   $0x803812
  801369:	e8 8e 03 00 00       	call   8016fc <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80136e:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
  801374:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801377:	74 16                	je     80138f <fs_test+0xc6>
  801379:	68 a4 39 80 00       	push   $0x8039a4
  80137e:	68 7d 34 80 00       	push   $0x80347d
  801383:	6a 1b                	push   $0x1b
  801385:	68 12 38 80 00       	push   $0x803812
  80138a:	e8 6d 03 00 00       	call   8016fc <_panic>
	cprintf("alloc_block is good\n");
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	68 47 38 80 00       	push   $0x803847
  801397:	e8 39 04 00 00       	call   8017d5 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80139c:	83 c4 08             	add    $0x8,%esp
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	68 5c 38 80 00       	push   $0x80385c
  8013a8:	e8 d9 f8 ff ff       	call   800c86 <file_open>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8013b3:	74 1b                	je     8013d0 <fs_test+0x107>
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	c1 ea 1f             	shr    $0x1f,%edx
  8013ba:	84 d2                	test   %dl,%dl
  8013bc:	74 12                	je     8013d0 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  8013be:	50                   	push   %eax
  8013bf:	68 67 38 80 00       	push   $0x803867
  8013c4:	6a 1f                	push   $0x1f
  8013c6:	68 12 38 80 00       	push   $0x803812
  8013cb:	e8 2c 03 00 00       	call   8016fc <_panic>
	else if (r == 0)
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	75 14                	jne    8013e8 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  8013d4:	83 ec 04             	sub    $0x4,%esp
  8013d7:	68 c4 39 80 00       	push   $0x8039c4
  8013dc:	6a 21                	push   $0x21
  8013de:	68 12 38 80 00       	push   $0x803812
  8013e3:	e8 14 03 00 00       	call   8016fc <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	68 80 38 80 00       	push   $0x803880
  8013f4:	e8 8d f8 ff ff       	call   800c86 <file_open>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	79 12                	jns    801412 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801400:	50                   	push   %eax
  801401:	68 89 38 80 00       	push   $0x803889
  801406:	6a 23                	push   $0x23
  801408:	68 12 38 80 00       	push   $0x803812
  80140d:	e8 ea 02 00 00       	call   8016fc <_panic>
	cprintf("file_open is good\n");
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	68 a0 38 80 00       	push   $0x8038a0
  80141a:	e8 b6 03 00 00       	call   8017d5 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80141f:	83 c4 0c             	add    $0xc,%esp
  801422:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	6a 00                	push   $0x0
  801428:	ff 75 f4             	pushl  -0xc(%ebp)
  80142b:	e8 76 f7 ff ff       	call   800ba6 <file_get_block>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	79 12                	jns    801449 <fs_test+0x180>
		panic("file_get_block: %e", r);
  801437:	50                   	push   %eax
  801438:	68 b3 38 80 00       	push   $0x8038b3
  80143d:	6a 27                	push   $0x27
  80143f:	68 12 38 80 00       	push   $0x803812
  801444:	e8 b3 02 00 00       	call   8016fc <_panic>
	if (strcmp(blk, msg) != 0)
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	68 e4 39 80 00       	push   $0x8039e4
  801451:	ff 75 f0             	pushl  -0x10(%ebp)
  801454:	e8 ab 09 00 00       	call   801e04 <strcmp>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	74 14                	je     801474 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	68 0c 3a 80 00       	push   $0x803a0c
  801468:	6a 29                	push   $0x29
  80146a:	68 12 38 80 00       	push   $0x803812
  80146f:	e8 88 02 00 00       	call   8016fc <_panic>
	cprintf("file_get_block is good\n");
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	68 c6 38 80 00       	push   $0x8038c6
  80147c:	e8 54 03 00 00       	call   8017d5 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801481:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801484:	0f b6 10             	movzbl (%eax),%edx
  801487:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801489:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148c:	c1 e8 0c             	shr    $0xc,%eax
  80148f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	a8 40                	test   $0x40,%al
  80149b:	75 16                	jne    8014b3 <fs_test+0x1ea>
  80149d:	68 df 38 80 00       	push   $0x8038df
  8014a2:	68 7d 34 80 00       	push   $0x80347d
  8014a7:	6a 2d                	push   $0x2d
  8014a9:	68 12 38 80 00       	push   $0x803812
  8014ae:	e8 49 02 00 00       	call   8016fc <_panic>
	file_flush(f);
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b9:	e8 0e f9 ff ff       	call   800dcc <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	c1 e8 0c             	shr    $0xc,%eax
  8014c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	a8 40                	test   $0x40,%al
  8014d0:	74 16                	je     8014e8 <fs_test+0x21f>
  8014d2:	68 de 38 80 00       	push   $0x8038de
  8014d7:	68 7d 34 80 00       	push   $0x80347d
  8014dc:	6a 2f                	push   $0x2f
  8014de:	68 12 38 80 00       	push   $0x803812
  8014e3:	e8 14 02 00 00       	call   8016fc <_panic>
	cprintf("file_flush is good\n");
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	68 fa 38 80 00       	push   $0x8038fa
  8014f0:	e8 e0 02 00 00       	call   8017d5 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	6a 00                	push   $0x0
  8014fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fd:	e8 e2 f7 ff ff       	call   800ce4 <file_set_size>
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	85 c0                	test   %eax,%eax
  801507:	79 12                	jns    80151b <fs_test+0x252>
		panic("file_set_size: %e", r);
  801509:	50                   	push   %eax
  80150a:	68 0e 39 80 00       	push   $0x80390e
  80150f:	6a 33                	push   $0x33
  801511:	68 12 38 80 00       	push   $0x803812
  801516:	e8 e1 01 00 00       	call   8016fc <_panic>
	assert(f->f_direct[0] == 0);
  80151b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151e:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801525:	74 16                	je     80153d <fs_test+0x274>
  801527:	68 20 39 80 00       	push   $0x803920
  80152c:	68 7d 34 80 00       	push   $0x80347d
  801531:	6a 34                	push   $0x34
  801533:	68 12 38 80 00       	push   $0x803812
  801538:	e8 bf 01 00 00       	call   8016fc <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80153d:	c1 e8 0c             	shr    $0xc,%eax
  801540:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801547:	a8 40                	test   $0x40,%al
  801549:	74 16                	je     801561 <fs_test+0x298>
  80154b:	68 34 39 80 00       	push   $0x803934
  801550:	68 7d 34 80 00       	push   $0x80347d
  801555:	6a 35                	push   $0x35
  801557:	68 12 38 80 00       	push   $0x803812
  80155c:	e8 9b 01 00 00       	call   8016fc <_panic>
	cprintf("file_truncate is good\n");
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	68 4e 39 80 00       	push   $0x80394e
  801569:	e8 67 02 00 00       	call   8017d5 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80156e:	c7 04 24 e4 39 80 00 	movl   $0x8039e4,(%esp)
  801575:	e8 a7 07 00 00       	call   801d21 <strlen>
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	50                   	push   %eax
  80157e:	ff 75 f4             	pushl  -0xc(%ebp)
  801581:	e8 5e f7 ff ff       	call   800ce4 <file_set_size>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	79 12                	jns    80159f <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80158d:	50                   	push   %eax
  80158e:	68 65 39 80 00       	push   $0x803965
  801593:	6a 39                	push   $0x39
  801595:	68 12 38 80 00       	push   $0x803812
  80159a:	e8 5d 01 00 00       	call   8016fc <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	c1 ea 0c             	shr    $0xc,%edx
  8015a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ae:	f6 c2 40             	test   $0x40,%dl
  8015b1:	74 16                	je     8015c9 <fs_test+0x300>
  8015b3:	68 34 39 80 00       	push   $0x803934
  8015b8:	68 7d 34 80 00       	push   $0x80347d
  8015bd:	6a 3a                	push   $0x3a
  8015bf:	68 12 38 80 00       	push   $0x803812
  8015c4:	e8 33 01 00 00       	call   8016fc <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8015cf:	52                   	push   %edx
  8015d0:	6a 00                	push   $0x0
  8015d2:	50                   	push   %eax
  8015d3:	e8 ce f5 ff ff       	call   800ba6 <file_get_block>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	79 12                	jns    8015f1 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  8015df:	50                   	push   %eax
  8015e0:	68 79 39 80 00       	push   $0x803979
  8015e5:	6a 3c                	push   $0x3c
  8015e7:	68 12 38 80 00       	push   $0x803812
  8015ec:	e8 0b 01 00 00       	call   8016fc <_panic>
	strcpy(blk, msg);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	68 e4 39 80 00       	push   $0x8039e4
  8015f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fc:	e8 59 07 00 00       	call   801d5a <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	c1 e8 0c             	shr    $0xc,%eax
  801607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	a8 40                	test   $0x40,%al
  801613:	75 16                	jne    80162b <fs_test+0x362>
  801615:	68 df 38 80 00       	push   $0x8038df
  80161a:	68 7d 34 80 00       	push   $0x80347d
  80161f:	6a 3e                	push   $0x3e
  801621:	68 12 38 80 00       	push   $0x803812
  801626:	e8 d1 00 00 00       	call   8016fc <_panic>
	file_flush(f);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 96 f7 ff ff       	call   800dcc <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	c1 e8 0c             	shr    $0xc,%eax
  80163c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	a8 40                	test   $0x40,%al
  801648:	74 16                	je     801660 <fs_test+0x397>
  80164a:	68 de 38 80 00       	push   $0x8038de
  80164f:	68 7d 34 80 00       	push   $0x80347d
  801654:	6a 40                	push   $0x40
  801656:	68 12 38 80 00       	push   $0x803812
  80165b:	e8 9c 00 00 00       	call   8016fc <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	c1 e8 0c             	shr    $0xc,%eax
  801666:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80166d:	a8 40                	test   $0x40,%al
  80166f:	74 16                	je     801687 <fs_test+0x3be>
  801671:	68 34 39 80 00       	push   $0x803934
  801676:	68 7d 34 80 00       	push   $0x80347d
  80167b:	6a 41                	push   $0x41
  80167d:	68 12 38 80 00       	push   $0x803812
  801682:	e8 75 00 00 00       	call   8016fc <_panic>
	cprintf("file rewrite is good\n");
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	68 8e 39 80 00       	push   $0x80398e
  80168f:	e8 41 01 00 00       	call   8017d5 <cprintf>
}
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8016a7:	e8 73 0a 00 00       	call   80211f <sys_getenvid>
  8016ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016b1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016b9:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8016be:	85 db                	test   %ebx,%ebx
  8016c0:	7e 07                	jle    8016c9 <libmain+0x2d>
		binaryname = argv[0];
  8016c2:	8b 06                	mov    (%esi),%eax
  8016c4:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	e8 b0 fb ff ff       	call   801283 <umain>

	// exit gracefully
	exit();
  8016d3:	e8 0a 00 00 00       	call   8016e2 <exit>
}
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8016e8:	e8 8b 0f 00 00       	call   802678 <close_all>
	sys_env_destroy(0);
  8016ed:	83 ec 0c             	sub    $0xc,%esp
  8016f0:	6a 00                	push   $0x0
  8016f2:	e8 e7 09 00 00       	call   8020de <sys_env_destroy>
}
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801701:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801704:	8b 35 60 80 80 00    	mov    0x808060,%esi
  80170a:	e8 10 0a 00 00       	call   80211f <sys_getenvid>
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	ff 75 0c             	pushl  0xc(%ebp)
  801715:	ff 75 08             	pushl  0x8(%ebp)
  801718:	56                   	push   %esi
  801719:	50                   	push   %eax
  80171a:	68 3c 3a 80 00       	push   $0x803a3c
  80171f:	e8 b1 00 00 00       	call   8017d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801724:	83 c4 18             	add    $0x18,%esp
  801727:	53                   	push   %ebx
  801728:	ff 75 10             	pushl  0x10(%ebp)
  80172b:	e8 54 00 00 00       	call   801784 <vcprintf>
	cprintf("\n");
  801730:	c7 04 24 03 36 80 00 	movl   $0x803603,(%esp)
  801737:	e8 99 00 00 00       	call   8017d5 <cprintf>
  80173c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80173f:	cc                   	int3   
  801740:	eb fd                	jmp    80173f <_panic+0x43>

00801742 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80174c:	8b 13                	mov    (%ebx),%edx
  80174e:	8d 42 01             	lea    0x1(%edx),%eax
  801751:	89 03                	mov    %eax,(%ebx)
  801753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801756:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80175a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80175f:	75 1a                	jne    80177b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	68 ff 00 00 00       	push   $0xff
  801769:	8d 43 08             	lea    0x8(%ebx),%eax
  80176c:	50                   	push   %eax
  80176d:	e8 2f 09 00 00       	call   8020a1 <sys_cputs>
		b->idx = 0;
  801772:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801778:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80177b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80177f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80178d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801794:	00 00 00 
	b.cnt = 0;
  801797:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80179e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	ff 75 08             	pushl  0x8(%ebp)
  8017a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017ad:	50                   	push   %eax
  8017ae:	68 42 17 80 00       	push   $0x801742
  8017b3:	e8 54 01 00 00       	call   80190c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017b8:	83 c4 08             	add    $0x8,%esp
  8017bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8017c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017c7:	50                   	push   %eax
  8017c8:	e8 d4 08 00 00       	call   8020a1 <sys_cputs>

	return b.cnt;
}
  8017cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8017de:	50                   	push   %eax
  8017df:	ff 75 08             	pushl  0x8(%ebp)
  8017e2:	e8 9d ff ff ff       	call   801784 <vcprintf>
	va_end(ap);

	return cnt;
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	57                   	push   %edi
  8017ed:	56                   	push   %esi
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 1c             	sub    $0x1c,%esp
  8017f2:	89 c7                	mov    %eax,%edi
  8017f4:	89 d6                	mov    %edx,%esi
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801802:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801805:	bb 00 00 00 00       	mov    $0x0,%ebx
  80180a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80180d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801810:	39 d3                	cmp    %edx,%ebx
  801812:	72 05                	jb     801819 <printnum+0x30>
  801814:	39 45 10             	cmp    %eax,0x10(%ebp)
  801817:	77 45                	ja     80185e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	ff 75 18             	pushl  0x18(%ebp)
  80181f:	8b 45 14             	mov    0x14(%ebp),%eax
  801822:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801825:	53                   	push   %ebx
  801826:	ff 75 10             	pushl  0x10(%ebp)
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80182f:	ff 75 e0             	pushl  -0x20(%ebp)
  801832:	ff 75 dc             	pushl  -0x24(%ebp)
  801835:	ff 75 d8             	pushl  -0x28(%ebp)
  801838:	e8 73 19 00 00       	call   8031b0 <__udivdi3>
  80183d:	83 c4 18             	add    $0x18,%esp
  801840:	52                   	push   %edx
  801841:	50                   	push   %eax
  801842:	89 f2                	mov    %esi,%edx
  801844:	89 f8                	mov    %edi,%eax
  801846:	e8 9e ff ff ff       	call   8017e9 <printnum>
  80184b:	83 c4 20             	add    $0x20,%esp
  80184e:	eb 18                	jmp    801868 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	56                   	push   %esi
  801854:	ff 75 18             	pushl  0x18(%ebp)
  801857:	ff d7                	call   *%edi
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	eb 03                	jmp    801861 <printnum+0x78>
  80185e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801861:	83 eb 01             	sub    $0x1,%ebx
  801864:	85 db                	test   %ebx,%ebx
  801866:	7f e8                	jg     801850 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	56                   	push   %esi
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801872:	ff 75 e0             	pushl  -0x20(%ebp)
  801875:	ff 75 dc             	pushl  -0x24(%ebp)
  801878:	ff 75 d8             	pushl  -0x28(%ebp)
  80187b:	e8 60 1a 00 00       	call   8032e0 <__umoddi3>
  801880:	83 c4 14             	add    $0x14,%esp
  801883:	0f be 80 5f 3a 80 00 	movsbl 0x803a5f(%eax),%eax
  80188a:	50                   	push   %eax
  80188b:	ff d7                	call   *%edi
}
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801893:	5b                   	pop    %ebx
  801894:	5e                   	pop    %esi
  801895:	5f                   	pop    %edi
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80189b:	83 fa 01             	cmp    $0x1,%edx
  80189e:	7e 0e                	jle    8018ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018a0:	8b 10                	mov    (%eax),%edx
  8018a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018a5:	89 08                	mov    %ecx,(%eax)
  8018a7:	8b 02                	mov    (%edx),%eax
  8018a9:	8b 52 04             	mov    0x4(%edx),%edx
  8018ac:	eb 22                	jmp    8018d0 <getuint+0x38>
	else if (lflag)
  8018ae:	85 d2                	test   %edx,%edx
  8018b0:	74 10                	je     8018c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018b2:	8b 10                	mov    (%eax),%edx
  8018b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018b7:	89 08                	mov    %ecx,(%eax)
  8018b9:	8b 02                	mov    (%edx),%eax
  8018bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c0:	eb 0e                	jmp    8018d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8018c2:	8b 10                	mov    (%eax),%edx
  8018c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018c7:	89 08                	mov    %ecx,(%eax)
  8018c9:	8b 02                	mov    (%edx),%eax
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8018d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8018dc:	8b 10                	mov    (%eax),%edx
  8018de:	3b 50 04             	cmp    0x4(%eax),%edx
  8018e1:	73 0a                	jae    8018ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8018e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8018e6:	89 08                	mov    %ecx,(%eax)
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	88 02                	mov    %al,(%edx)
}
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8018f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8018f8:	50                   	push   %eax
  8018f9:	ff 75 10             	pushl  0x10(%ebp)
  8018fc:	ff 75 0c             	pushl  0xc(%ebp)
  8018ff:	ff 75 08             	pushl  0x8(%ebp)
  801902:	e8 05 00 00 00       	call   80190c <vprintfmt>
	va_end(ap);
}
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 2c             	sub    $0x2c,%esp
  801915:	8b 75 08             	mov    0x8(%ebp),%esi
  801918:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80191b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80191e:	eb 12                	jmp    801932 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801920:	85 c0                	test   %eax,%eax
  801922:	0f 84 89 03 00 00    	je     801cb1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	53                   	push   %ebx
  80192c:	50                   	push   %eax
  80192d:	ff d6                	call   *%esi
  80192f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801932:	83 c7 01             	add    $0x1,%edi
  801935:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801939:	83 f8 25             	cmp    $0x25,%eax
  80193c:	75 e2                	jne    801920 <vprintfmt+0x14>
  80193e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801942:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801949:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801950:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801957:	ba 00 00 00 00       	mov    $0x0,%edx
  80195c:	eb 07                	jmp    801965 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801961:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801965:	8d 47 01             	lea    0x1(%edi),%eax
  801968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80196b:	0f b6 07             	movzbl (%edi),%eax
  80196e:	0f b6 c8             	movzbl %al,%ecx
  801971:	83 e8 23             	sub    $0x23,%eax
  801974:	3c 55                	cmp    $0x55,%al
  801976:	0f 87 1a 03 00 00    	ja     801c96 <vprintfmt+0x38a>
  80197c:	0f b6 c0             	movzbl %al,%eax
  80197f:	ff 24 85 a0 3b 80 00 	jmp    *0x803ba0(,%eax,4)
  801986:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801989:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80198d:	eb d6                	jmp    801965 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80198f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
  801997:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80199a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80199d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8019a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8019a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8019a7:	83 fa 09             	cmp    $0x9,%edx
  8019aa:	77 39                	ja     8019e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8019ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8019af:	eb e9                	jmp    80199a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8019b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8019b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8019ba:	8b 00                	mov    (%eax),%eax
  8019bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8019c2:	eb 27                	jmp    8019eb <vprintfmt+0xdf>
  8019c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ce:	0f 49 c8             	cmovns %eax,%ecx
  8019d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019d7:	eb 8c                	jmp    801965 <vprintfmt+0x59>
  8019d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8019dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8019e3:	eb 80                	jmp    801965 <vprintfmt+0x59>
  8019e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8019eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019ef:	0f 89 70 ff ff ff    	jns    801965 <vprintfmt+0x59>
				width = precision, precision = -1;
  8019f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8019f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801a02:	e9 5e ff ff ff       	jmp    801965 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a07:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a0d:	e9 53 ff ff ff       	jmp    801965 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a12:	8b 45 14             	mov    0x14(%ebp),%eax
  801a15:	8d 50 04             	lea    0x4(%eax),%edx
  801a18:	89 55 14             	mov    %edx,0x14(%ebp)
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	ff 30                	pushl  (%eax)
  801a21:	ff d6                	call   *%esi
			break;
  801a23:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a29:	e9 04 ff ff ff       	jmp    801932 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a31:	8d 50 04             	lea    0x4(%eax),%edx
  801a34:	89 55 14             	mov    %edx,0x14(%ebp)
  801a37:	8b 00                	mov    (%eax),%eax
  801a39:	99                   	cltd   
  801a3a:	31 d0                	xor    %edx,%eax
  801a3c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a3e:	83 f8 0f             	cmp    $0xf,%eax
  801a41:	7f 0b                	jg     801a4e <vprintfmt+0x142>
  801a43:	8b 14 85 00 3d 80 00 	mov    0x803d00(,%eax,4),%edx
  801a4a:	85 d2                	test   %edx,%edx
  801a4c:	75 18                	jne    801a66 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801a4e:	50                   	push   %eax
  801a4f:	68 77 3a 80 00       	push   $0x803a77
  801a54:	53                   	push   %ebx
  801a55:	56                   	push   %esi
  801a56:	e8 94 fe ff ff       	call   8018ef <printfmt>
  801a5b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a61:	e9 cc fe ff ff       	jmp    801932 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801a66:	52                   	push   %edx
  801a67:	68 8f 34 80 00       	push   $0x80348f
  801a6c:	53                   	push   %ebx
  801a6d:	56                   	push   %esi
  801a6e:	e8 7c fe ff ff       	call   8018ef <printfmt>
  801a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a79:	e9 b4 fe ff ff       	jmp    801932 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a81:	8d 50 04             	lea    0x4(%eax),%edx
  801a84:	89 55 14             	mov    %edx,0x14(%ebp)
  801a87:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801a89:	85 ff                	test   %edi,%edi
  801a8b:	b8 70 3a 80 00       	mov    $0x803a70,%eax
  801a90:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801a93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801a97:	0f 8e 94 00 00 00    	jle    801b31 <vprintfmt+0x225>
  801a9d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801aa1:	0f 84 98 00 00 00    	je     801b3f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801aa7:	83 ec 08             	sub    $0x8,%esp
  801aaa:	ff 75 d0             	pushl  -0x30(%ebp)
  801aad:	57                   	push   %edi
  801aae:	e8 86 02 00 00       	call   801d39 <strnlen>
  801ab3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ab6:	29 c1                	sub    %eax,%ecx
  801ab8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801abb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801abe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801ac2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801ac8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801aca:	eb 0f                	jmp    801adb <vprintfmt+0x1cf>
					putch(padc, putdat);
  801acc:	83 ec 08             	sub    $0x8,%esp
  801acf:	53                   	push   %ebx
  801ad0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ad5:	83 ef 01             	sub    $0x1,%edi
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 ff                	test   %edi,%edi
  801add:	7f ed                	jg     801acc <vprintfmt+0x1c0>
  801adf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801ae2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801ae5:	85 c9                	test   %ecx,%ecx
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aec:	0f 49 c1             	cmovns %ecx,%eax
  801aef:	29 c1                	sub    %eax,%ecx
  801af1:	89 75 08             	mov    %esi,0x8(%ebp)
  801af4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801af7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801afa:	89 cb                	mov    %ecx,%ebx
  801afc:	eb 4d                	jmp    801b4b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801afe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801b02:	74 1b                	je     801b1f <vprintfmt+0x213>
  801b04:	0f be c0             	movsbl %al,%eax
  801b07:	83 e8 20             	sub    $0x20,%eax
  801b0a:	83 f8 5e             	cmp    $0x5e,%eax
  801b0d:	76 10                	jbe    801b1f <vprintfmt+0x213>
					putch('?', putdat);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	ff 75 0c             	pushl  0xc(%ebp)
  801b15:	6a 3f                	push   $0x3f
  801b17:	ff 55 08             	call   *0x8(%ebp)
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	eb 0d                	jmp    801b2c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801b1f:	83 ec 08             	sub    $0x8,%esp
  801b22:	ff 75 0c             	pushl  0xc(%ebp)
  801b25:	52                   	push   %edx
  801b26:	ff 55 08             	call   *0x8(%ebp)
  801b29:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b2c:	83 eb 01             	sub    $0x1,%ebx
  801b2f:	eb 1a                	jmp    801b4b <vprintfmt+0x23f>
  801b31:	89 75 08             	mov    %esi,0x8(%ebp)
  801b34:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801b37:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801b3a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801b3d:	eb 0c                	jmp    801b4b <vprintfmt+0x23f>
  801b3f:	89 75 08             	mov    %esi,0x8(%ebp)
  801b42:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801b45:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801b48:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801b4b:	83 c7 01             	add    $0x1,%edi
  801b4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b52:	0f be d0             	movsbl %al,%edx
  801b55:	85 d2                	test   %edx,%edx
  801b57:	74 23                	je     801b7c <vprintfmt+0x270>
  801b59:	85 f6                	test   %esi,%esi
  801b5b:	78 a1                	js     801afe <vprintfmt+0x1f2>
  801b5d:	83 ee 01             	sub    $0x1,%esi
  801b60:	79 9c                	jns    801afe <vprintfmt+0x1f2>
  801b62:	89 df                	mov    %ebx,%edi
  801b64:	8b 75 08             	mov    0x8(%ebp),%esi
  801b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b6a:	eb 18                	jmp    801b84 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b6c:	83 ec 08             	sub    $0x8,%esp
  801b6f:	53                   	push   %ebx
  801b70:	6a 20                	push   $0x20
  801b72:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b74:	83 ef 01             	sub    $0x1,%edi
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	eb 08                	jmp    801b84 <vprintfmt+0x278>
  801b7c:	89 df                	mov    %ebx,%edi
  801b7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b84:	85 ff                	test   %edi,%edi
  801b86:	7f e4                	jg     801b6c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b8b:	e9 a2 fd ff ff       	jmp    801932 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b90:	83 fa 01             	cmp    $0x1,%edx
  801b93:	7e 16                	jle    801bab <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801b95:	8b 45 14             	mov    0x14(%ebp),%eax
  801b98:	8d 50 08             	lea    0x8(%eax),%edx
  801b9b:	89 55 14             	mov    %edx,0x14(%ebp)
  801b9e:	8b 50 04             	mov    0x4(%eax),%edx
  801ba1:	8b 00                	mov    (%eax),%eax
  801ba3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ba6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801ba9:	eb 32                	jmp    801bdd <vprintfmt+0x2d1>
	else if (lflag)
  801bab:	85 d2                	test   %edx,%edx
  801bad:	74 18                	je     801bc7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801baf:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb2:	8d 50 04             	lea    0x4(%eax),%edx
  801bb5:	89 55 14             	mov    %edx,0x14(%ebp)
  801bb8:	8b 00                	mov    (%eax),%eax
  801bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bbd:	89 c1                	mov    %eax,%ecx
  801bbf:	c1 f9 1f             	sar    $0x1f,%ecx
  801bc2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801bc5:	eb 16                	jmp    801bdd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  801bca:	8d 50 04             	lea    0x4(%eax),%edx
  801bcd:	89 55 14             	mov    %edx,0x14(%ebp)
  801bd0:	8b 00                	mov    (%eax),%eax
  801bd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bd5:	89 c1                	mov    %eax,%ecx
  801bd7:	c1 f9 1f             	sar    $0x1f,%ecx
  801bda:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801bdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801be0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801be3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801be8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801bec:	79 74                	jns    801c62 <vprintfmt+0x356>
				putch('-', putdat);
  801bee:	83 ec 08             	sub    $0x8,%esp
  801bf1:	53                   	push   %ebx
  801bf2:	6a 2d                	push   $0x2d
  801bf4:	ff d6                	call   *%esi
				num = -(long long) num;
  801bf6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801bf9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801bfc:	f7 d8                	neg    %eax
  801bfe:	83 d2 00             	adc    $0x0,%edx
  801c01:	f7 da                	neg    %edx
  801c03:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801c06:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801c0b:	eb 55                	jmp    801c62 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c0d:	8d 45 14             	lea    0x14(%ebp),%eax
  801c10:	e8 83 fc ff ff       	call   801898 <getuint>
			base = 10;
  801c15:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801c1a:	eb 46                	jmp    801c62 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801c1c:	8d 45 14             	lea    0x14(%ebp),%eax
  801c1f:	e8 74 fc ff ff       	call   801898 <getuint>
			base = 8;
  801c24:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801c29:	eb 37                	jmp    801c62 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801c2b:	83 ec 08             	sub    $0x8,%esp
  801c2e:	53                   	push   %ebx
  801c2f:	6a 30                	push   $0x30
  801c31:	ff d6                	call   *%esi
			putch('x', putdat);
  801c33:	83 c4 08             	add    $0x8,%esp
  801c36:	53                   	push   %ebx
  801c37:	6a 78                	push   $0x78
  801c39:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801c3e:	8d 50 04             	lea    0x4(%eax),%edx
  801c41:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c44:	8b 00                	mov    (%eax),%eax
  801c46:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801c4b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c4e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801c53:	eb 0d                	jmp    801c62 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c55:	8d 45 14             	lea    0x14(%ebp),%eax
  801c58:	e8 3b fc ff ff       	call   801898 <getuint>
			base = 16;
  801c5d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801c69:	57                   	push   %edi
  801c6a:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6d:	51                   	push   %ecx
  801c6e:	52                   	push   %edx
  801c6f:	50                   	push   %eax
  801c70:	89 da                	mov    %ebx,%edx
  801c72:	89 f0                	mov    %esi,%eax
  801c74:	e8 70 fb ff ff       	call   8017e9 <printnum>
			break;
  801c79:	83 c4 20             	add    $0x20,%esp
  801c7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c7f:	e9 ae fc ff ff       	jmp    801932 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c84:	83 ec 08             	sub    $0x8,%esp
  801c87:	53                   	push   %ebx
  801c88:	51                   	push   %ecx
  801c89:	ff d6                	call   *%esi
			break;
  801c8b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801c91:	e9 9c fc ff ff       	jmp    801932 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	53                   	push   %ebx
  801c9a:	6a 25                	push   $0x25
  801c9c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	eb 03                	jmp    801ca6 <vprintfmt+0x39a>
  801ca3:	83 ef 01             	sub    $0x1,%edi
  801ca6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801caa:	75 f7                	jne    801ca3 <vprintfmt+0x397>
  801cac:	e9 81 fc ff ff       	jmp    801932 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 18             	sub    $0x18,%esp
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801cc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cc8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ccc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ccf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	74 26                	je     801d00 <vsnprintf+0x47>
  801cda:	85 d2                	test   %edx,%edx
  801cdc:	7e 22                	jle    801d00 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801cde:	ff 75 14             	pushl  0x14(%ebp)
  801ce1:	ff 75 10             	pushl  0x10(%ebp)
  801ce4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ce7:	50                   	push   %eax
  801ce8:	68 d2 18 80 00       	push   $0x8018d2
  801ced:	e8 1a fc ff ff       	call   80190c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801cf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cf5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	eb 05                	jmp    801d05 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d10:	50                   	push   %eax
  801d11:	ff 75 10             	pushl  0x10(%ebp)
  801d14:	ff 75 0c             	pushl  0xc(%ebp)
  801d17:	ff 75 08             	pushl  0x8(%ebp)
  801d1a:	e8 9a ff ff ff       	call   801cb9 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2c:	eb 03                	jmp    801d31 <strlen+0x10>
		n++;
  801d2e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d31:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d35:	75 f7                	jne    801d2e <strlen+0xd>
		n++;
	return n;
}
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d42:	ba 00 00 00 00       	mov    $0x0,%edx
  801d47:	eb 03                	jmp    801d4c <strnlen+0x13>
		n++;
  801d49:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d4c:	39 c2                	cmp    %eax,%edx
  801d4e:	74 08                	je     801d58 <strnlen+0x1f>
  801d50:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801d54:	75 f3                	jne    801d49 <strnlen+0x10>
  801d56:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	53                   	push   %ebx
  801d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801d64:	89 c2                	mov    %eax,%edx
  801d66:	83 c2 01             	add    $0x1,%edx
  801d69:	83 c1 01             	add    $0x1,%ecx
  801d6c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801d70:	88 5a ff             	mov    %bl,-0x1(%edx)
  801d73:	84 db                	test   %bl,%bl
  801d75:	75 ef                	jne    801d66 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801d77:	5b                   	pop    %ebx
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	53                   	push   %ebx
  801d7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801d81:	53                   	push   %ebx
  801d82:	e8 9a ff ff ff       	call   801d21 <strlen>
  801d87:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801d8a:	ff 75 0c             	pushl  0xc(%ebp)
  801d8d:	01 d8                	add    %ebx,%eax
  801d8f:	50                   	push   %eax
  801d90:	e8 c5 ff ff ff       	call   801d5a <strcpy>
	return dst;
}
  801d95:	89 d8                	mov    %ebx,%eax
  801d97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	8b 75 08             	mov    0x8(%ebp),%esi
  801da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da7:	89 f3                	mov    %esi,%ebx
  801da9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801dac:	89 f2                	mov    %esi,%edx
  801dae:	eb 0f                	jmp    801dbf <strncpy+0x23>
		*dst++ = *src;
  801db0:	83 c2 01             	add    $0x1,%edx
  801db3:	0f b6 01             	movzbl (%ecx),%eax
  801db6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801db9:	80 39 01             	cmpb   $0x1,(%ecx)
  801dbc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801dbf:	39 da                	cmp    %ebx,%edx
  801dc1:	75 ed                	jne    801db0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801dc3:	89 f0                	mov    %esi,%eax
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	56                   	push   %esi
  801dcd:	53                   	push   %ebx
  801dce:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd4:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801dd9:	85 d2                	test   %edx,%edx
  801ddb:	74 21                	je     801dfe <strlcpy+0x35>
  801ddd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801de1:	89 f2                	mov    %esi,%edx
  801de3:	eb 09                	jmp    801dee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801de5:	83 c2 01             	add    $0x1,%edx
  801de8:	83 c1 01             	add    $0x1,%ecx
  801deb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801dee:	39 c2                	cmp    %eax,%edx
  801df0:	74 09                	je     801dfb <strlcpy+0x32>
  801df2:	0f b6 19             	movzbl (%ecx),%ebx
  801df5:	84 db                	test   %bl,%bl
  801df7:	75 ec                	jne    801de5 <strlcpy+0x1c>
  801df9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801dfb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801dfe:	29 f0                	sub    %esi,%eax
}
  801e00:	5b                   	pop    %ebx
  801e01:	5e                   	pop    %esi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e0d:	eb 06                	jmp    801e15 <strcmp+0x11>
		p++, q++;
  801e0f:	83 c1 01             	add    $0x1,%ecx
  801e12:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e15:	0f b6 01             	movzbl (%ecx),%eax
  801e18:	84 c0                	test   %al,%al
  801e1a:	74 04                	je     801e20 <strcmp+0x1c>
  801e1c:	3a 02                	cmp    (%edx),%al
  801e1e:	74 ef                	je     801e0f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e20:	0f b6 c0             	movzbl %al,%eax
  801e23:	0f b6 12             	movzbl (%edx),%edx
  801e26:	29 d0                	sub    %edx,%eax
}
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	53                   	push   %ebx
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801e39:	eb 06                	jmp    801e41 <strncmp+0x17>
		n--, p++, q++;
  801e3b:	83 c0 01             	add    $0x1,%eax
  801e3e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e41:	39 d8                	cmp    %ebx,%eax
  801e43:	74 15                	je     801e5a <strncmp+0x30>
  801e45:	0f b6 08             	movzbl (%eax),%ecx
  801e48:	84 c9                	test   %cl,%cl
  801e4a:	74 04                	je     801e50 <strncmp+0x26>
  801e4c:	3a 0a                	cmp    (%edx),%cl
  801e4e:	74 eb                	je     801e3b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e50:	0f b6 00             	movzbl (%eax),%eax
  801e53:	0f b6 12             	movzbl (%edx),%edx
  801e56:	29 d0                	sub    %edx,%eax
  801e58:	eb 05                	jmp    801e5f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e5a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e5f:	5b                   	pop    %ebx
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    

00801e62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e6c:	eb 07                	jmp    801e75 <strchr+0x13>
		if (*s == c)
  801e6e:	38 ca                	cmp    %cl,%dl
  801e70:	74 0f                	je     801e81 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801e72:	83 c0 01             	add    $0x1,%eax
  801e75:	0f b6 10             	movzbl (%eax),%edx
  801e78:	84 d2                	test   %dl,%dl
  801e7a:	75 f2                	jne    801e6e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	8b 45 08             	mov    0x8(%ebp),%eax
  801e89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e8d:	eb 03                	jmp    801e92 <strfind+0xf>
  801e8f:	83 c0 01             	add    $0x1,%eax
  801e92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801e95:	38 ca                	cmp    %cl,%dl
  801e97:	74 04                	je     801e9d <strfind+0x1a>
  801e99:	84 d2                	test   %dl,%dl
  801e9b:	75 f2                	jne    801e8f <strfind+0xc>
			break;
	return (char *) s;
}
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	57                   	push   %edi
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801eab:	85 c9                	test   %ecx,%ecx
  801ead:	74 36                	je     801ee5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801eaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801eb5:	75 28                	jne    801edf <memset+0x40>
  801eb7:	f6 c1 03             	test   $0x3,%cl
  801eba:	75 23                	jne    801edf <memset+0x40>
		c &= 0xFF;
  801ebc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ec0:	89 d3                	mov    %edx,%ebx
  801ec2:	c1 e3 08             	shl    $0x8,%ebx
  801ec5:	89 d6                	mov    %edx,%esi
  801ec7:	c1 e6 18             	shl    $0x18,%esi
  801eca:	89 d0                	mov    %edx,%eax
  801ecc:	c1 e0 10             	shl    $0x10,%eax
  801ecf:	09 f0                	or     %esi,%eax
  801ed1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ed3:	89 d8                	mov    %ebx,%eax
  801ed5:	09 d0                	or     %edx,%eax
  801ed7:	c1 e9 02             	shr    $0x2,%ecx
  801eda:	fc                   	cld    
  801edb:	f3 ab                	rep stos %eax,%es:(%edi)
  801edd:	eb 06                	jmp    801ee5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	fc                   	cld    
  801ee3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ee5:	89 f8                	mov    %edi,%eax
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801efa:	39 c6                	cmp    %eax,%esi
  801efc:	73 35                	jae    801f33 <memmove+0x47>
  801efe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f01:	39 d0                	cmp    %edx,%eax
  801f03:	73 2e                	jae    801f33 <memmove+0x47>
		s += n;
		d += n;
  801f05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f08:	89 d6                	mov    %edx,%esi
  801f0a:	09 fe                	or     %edi,%esi
  801f0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f12:	75 13                	jne    801f27 <memmove+0x3b>
  801f14:	f6 c1 03             	test   $0x3,%cl
  801f17:	75 0e                	jne    801f27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801f19:	83 ef 04             	sub    $0x4,%edi
  801f1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f1f:	c1 e9 02             	shr    $0x2,%ecx
  801f22:	fd                   	std    
  801f23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f25:	eb 09                	jmp    801f30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f27:	83 ef 01             	sub    $0x1,%edi
  801f2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  801f2d:	fd                   	std    
  801f2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f30:	fc                   	cld    
  801f31:	eb 1d                	jmp    801f50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f33:	89 f2                	mov    %esi,%edx
  801f35:	09 c2                	or     %eax,%edx
  801f37:	f6 c2 03             	test   $0x3,%dl
  801f3a:	75 0f                	jne    801f4b <memmove+0x5f>
  801f3c:	f6 c1 03             	test   $0x3,%cl
  801f3f:	75 0a                	jne    801f4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801f41:	c1 e9 02             	shr    $0x2,%ecx
  801f44:	89 c7                	mov    %eax,%edi
  801f46:	fc                   	cld    
  801f47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f49:	eb 05                	jmp    801f50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f4b:	89 c7                	mov    %eax,%edi
  801f4d:	fc                   	cld    
  801f4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801f57:	ff 75 10             	pushl  0x10(%ebp)
  801f5a:	ff 75 0c             	pushl  0xc(%ebp)
  801f5d:	ff 75 08             	pushl  0x8(%ebp)
  801f60:	e8 87 ff ff ff       	call   801eec <memmove>
}
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    

00801f67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f72:	89 c6                	mov    %eax,%esi
  801f74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f77:	eb 1a                	jmp    801f93 <memcmp+0x2c>
		if (*s1 != *s2)
  801f79:	0f b6 08             	movzbl (%eax),%ecx
  801f7c:	0f b6 1a             	movzbl (%edx),%ebx
  801f7f:	38 d9                	cmp    %bl,%cl
  801f81:	74 0a                	je     801f8d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801f83:	0f b6 c1             	movzbl %cl,%eax
  801f86:	0f b6 db             	movzbl %bl,%ebx
  801f89:	29 d8                	sub    %ebx,%eax
  801f8b:	eb 0f                	jmp    801f9c <memcmp+0x35>
		s1++, s2++;
  801f8d:	83 c0 01             	add    $0x1,%eax
  801f90:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f93:	39 f0                	cmp    %esi,%eax
  801f95:	75 e2                	jne    801f79 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	53                   	push   %ebx
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801fa7:	89 c1                	mov    %eax,%ecx
  801fa9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801fac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801fb0:	eb 0a                	jmp    801fbc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801fb2:	0f b6 10             	movzbl (%eax),%edx
  801fb5:	39 da                	cmp    %ebx,%edx
  801fb7:	74 07                	je     801fc0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801fb9:	83 c0 01             	add    $0x1,%eax
  801fbc:	39 c8                	cmp    %ecx,%eax
  801fbe:	72 f2                	jb     801fb2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801fc0:	5b                   	pop    %ebx
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	57                   	push   %edi
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801fcf:	eb 03                	jmp    801fd4 <strtol+0x11>
		s++;
  801fd1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801fd4:	0f b6 01             	movzbl (%ecx),%eax
  801fd7:	3c 20                	cmp    $0x20,%al
  801fd9:	74 f6                	je     801fd1 <strtol+0xe>
  801fdb:	3c 09                	cmp    $0x9,%al
  801fdd:	74 f2                	je     801fd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801fdf:	3c 2b                	cmp    $0x2b,%al
  801fe1:	75 0a                	jne    801fed <strtol+0x2a>
		s++;
  801fe3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801fe6:	bf 00 00 00 00       	mov    $0x0,%edi
  801feb:	eb 11                	jmp    801ffe <strtol+0x3b>
  801fed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ff2:	3c 2d                	cmp    $0x2d,%al
  801ff4:	75 08                	jne    801ffe <strtol+0x3b>
		s++, neg = 1;
  801ff6:	83 c1 01             	add    $0x1,%ecx
  801ff9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ffe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802004:	75 15                	jne    80201b <strtol+0x58>
  802006:	80 39 30             	cmpb   $0x30,(%ecx)
  802009:	75 10                	jne    80201b <strtol+0x58>
  80200b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80200f:	75 7c                	jne    80208d <strtol+0xca>
		s += 2, base = 16;
  802011:	83 c1 02             	add    $0x2,%ecx
  802014:	bb 10 00 00 00       	mov    $0x10,%ebx
  802019:	eb 16                	jmp    802031 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80201b:	85 db                	test   %ebx,%ebx
  80201d:	75 12                	jne    802031 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80201f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802024:	80 39 30             	cmpb   $0x30,(%ecx)
  802027:	75 08                	jne    802031 <strtol+0x6e>
		s++, base = 8;
  802029:	83 c1 01             	add    $0x1,%ecx
  80202c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802031:	b8 00 00 00 00       	mov    $0x0,%eax
  802036:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802039:	0f b6 11             	movzbl (%ecx),%edx
  80203c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80203f:	89 f3                	mov    %esi,%ebx
  802041:	80 fb 09             	cmp    $0x9,%bl
  802044:	77 08                	ja     80204e <strtol+0x8b>
			dig = *s - '0';
  802046:	0f be d2             	movsbl %dl,%edx
  802049:	83 ea 30             	sub    $0x30,%edx
  80204c:	eb 22                	jmp    802070 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80204e:	8d 72 9f             	lea    -0x61(%edx),%esi
  802051:	89 f3                	mov    %esi,%ebx
  802053:	80 fb 19             	cmp    $0x19,%bl
  802056:	77 08                	ja     802060 <strtol+0x9d>
			dig = *s - 'a' + 10;
  802058:	0f be d2             	movsbl %dl,%edx
  80205b:	83 ea 57             	sub    $0x57,%edx
  80205e:	eb 10                	jmp    802070 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802060:	8d 72 bf             	lea    -0x41(%edx),%esi
  802063:	89 f3                	mov    %esi,%ebx
  802065:	80 fb 19             	cmp    $0x19,%bl
  802068:	77 16                	ja     802080 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80206a:	0f be d2             	movsbl %dl,%edx
  80206d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802070:	3b 55 10             	cmp    0x10(%ebp),%edx
  802073:	7d 0b                	jge    802080 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802075:	83 c1 01             	add    $0x1,%ecx
  802078:	0f af 45 10          	imul   0x10(%ebp),%eax
  80207c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80207e:	eb b9                	jmp    802039 <strtol+0x76>

	if (endptr)
  802080:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802084:	74 0d                	je     802093 <strtol+0xd0>
		*endptr = (char *) s;
  802086:	8b 75 0c             	mov    0xc(%ebp),%esi
  802089:	89 0e                	mov    %ecx,(%esi)
  80208b:	eb 06                	jmp    802093 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80208d:	85 db                	test   %ebx,%ebx
  80208f:	74 98                	je     802029 <strtol+0x66>
  802091:	eb 9e                	jmp    802031 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802093:	89 c2                	mov    %eax,%edx
  802095:	f7 da                	neg    %edx
  802097:	85 ff                	test   %edi,%edi
  802099:	0f 45 c2             	cmovne %edx,%eax
}
  80209c:	5b                   	pop    %ebx
  80209d:	5e                   	pop    %esi
  80209e:	5f                   	pop    %edi
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    

008020a1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	57                   	push   %edi
  8020a5:	56                   	push   %esi
  8020a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020af:	8b 55 08             	mov    0x8(%ebp),%edx
  8020b2:	89 c3                	mov    %eax,%ebx
  8020b4:	89 c7                	mov    %eax,%edi
  8020b6:	89 c6                	mov    %eax,%esi
  8020b8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8020ba:	5b                   	pop    %ebx
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    

008020bf <sys_cgetc>:

int
sys_cgetc(void)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	57                   	push   %edi
  8020c3:	56                   	push   %esi
  8020c4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cf:	89 d1                	mov    %edx,%ecx
  8020d1:	89 d3                	mov    %edx,%ebx
  8020d3:	89 d7                	mov    %edx,%edi
  8020d5:	89 d6                	mov    %edx,%esi
  8020d7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8020d9:	5b                   	pop    %ebx
  8020da:	5e                   	pop    %esi
  8020db:	5f                   	pop    %edi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8020f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8020f4:	89 cb                	mov    %ecx,%ebx
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	89 ce                	mov    %ecx,%esi
  8020fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	7e 17                	jle    802117 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802100:	83 ec 0c             	sub    $0xc,%esp
  802103:	50                   	push   %eax
  802104:	6a 03                	push   $0x3
  802106:	68 5f 3d 80 00       	push   $0x803d5f
  80210b:	6a 23                	push   $0x23
  80210d:	68 7c 3d 80 00       	push   $0x803d7c
  802112:	e8 e5 f5 ff ff       	call   8016fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211a:	5b                   	pop    %ebx
  80211b:	5e                   	pop    %esi
  80211c:	5f                   	pop    %edi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	57                   	push   %edi
  802123:	56                   	push   %esi
  802124:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802125:	ba 00 00 00 00       	mov    $0x0,%edx
  80212a:	b8 02 00 00 00       	mov    $0x2,%eax
  80212f:	89 d1                	mov    %edx,%ecx
  802131:	89 d3                	mov    %edx,%ebx
  802133:	89 d7                	mov    %edx,%edi
  802135:	89 d6                	mov    %edx,%esi
  802137:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802139:	5b                   	pop    %ebx
  80213a:	5e                   	pop    %esi
  80213b:	5f                   	pop    %edi
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    

0080213e <sys_yield>:

void
sys_yield(void)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802144:	ba 00 00 00 00       	mov    $0x0,%edx
  802149:	b8 0b 00 00 00       	mov    $0xb,%eax
  80214e:	89 d1                	mov    %edx,%ecx
  802150:	89 d3                	mov    %edx,%ebx
  802152:	89 d7                	mov    %edx,%edi
  802154:	89 d6                	mov    %edx,%esi
  802156:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    

0080215d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	57                   	push   %edi
  802161:	56                   	push   %esi
  802162:	53                   	push   %ebx
  802163:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802166:	be 00 00 00 00       	mov    $0x0,%esi
  80216b:	b8 04 00 00 00       	mov    $0x4,%eax
  802170:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802173:	8b 55 08             	mov    0x8(%ebp),%edx
  802176:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802179:	89 f7                	mov    %esi,%edi
  80217b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80217d:	85 c0                	test   %eax,%eax
  80217f:	7e 17                	jle    802198 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802181:	83 ec 0c             	sub    $0xc,%esp
  802184:	50                   	push   %eax
  802185:	6a 04                	push   $0x4
  802187:	68 5f 3d 80 00       	push   $0x803d5f
  80218c:	6a 23                	push   $0x23
  80218e:	68 7c 3d 80 00       	push   $0x803d7c
  802193:	e8 64 f5 ff ff       	call   8016fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219b:	5b                   	pop    %ebx
  80219c:	5e                   	pop    %esi
  80219d:	5f                   	pop    %edi
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	53                   	push   %ebx
  8021a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8021a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8021ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8021ba:	8b 75 18             	mov    0x18(%ebp),%esi
  8021bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	7e 17                	jle    8021da <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8021c3:	83 ec 0c             	sub    $0xc,%esp
  8021c6:	50                   	push   %eax
  8021c7:	6a 05                	push   $0x5
  8021c9:	68 5f 3d 80 00       	push   $0x803d5f
  8021ce:	6a 23                	push   $0x23
  8021d0:	68 7c 3d 80 00       	push   $0x803d7c
  8021d5:	e8 22 f5 ff ff       	call   8016fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8021da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	57                   	push   %edi
  8021e6:	56                   	push   %esi
  8021e7:	53                   	push   %ebx
  8021e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8021eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8021f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8021fb:	89 df                	mov    %ebx,%edi
  8021fd:	89 de                	mov    %ebx,%esi
  8021ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802201:	85 c0                	test   %eax,%eax
  802203:	7e 17                	jle    80221c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802205:	83 ec 0c             	sub    $0xc,%esp
  802208:	50                   	push   %eax
  802209:	6a 06                	push   $0x6
  80220b:	68 5f 3d 80 00       	push   $0x803d5f
  802210:	6a 23                	push   $0x23
  802212:	68 7c 3d 80 00       	push   $0x803d7c
  802217:	e8 e0 f4 ff ff       	call   8016fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80221c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    

00802224 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	57                   	push   %edi
  802228:	56                   	push   %esi
  802229:	53                   	push   %ebx
  80222a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80222d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802232:	b8 08 00 00 00       	mov    $0x8,%eax
  802237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80223a:	8b 55 08             	mov    0x8(%ebp),%edx
  80223d:	89 df                	mov    %ebx,%edi
  80223f:	89 de                	mov    %ebx,%esi
  802241:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802243:	85 c0                	test   %eax,%eax
  802245:	7e 17                	jle    80225e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802247:	83 ec 0c             	sub    $0xc,%esp
  80224a:	50                   	push   %eax
  80224b:	6a 08                	push   $0x8
  80224d:	68 5f 3d 80 00       	push   $0x803d5f
  802252:	6a 23                	push   $0x23
  802254:	68 7c 3d 80 00       	push   $0x803d7c
  802259:	e8 9e f4 ff ff       	call   8016fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80225e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	57                   	push   %edi
  80226a:	56                   	push   %esi
  80226b:	53                   	push   %ebx
  80226c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80226f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802274:	b8 09 00 00 00       	mov    $0x9,%eax
  802279:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80227c:	8b 55 08             	mov    0x8(%ebp),%edx
  80227f:	89 df                	mov    %ebx,%edi
  802281:	89 de                	mov    %ebx,%esi
  802283:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802285:	85 c0                	test   %eax,%eax
  802287:	7e 17                	jle    8022a0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802289:	83 ec 0c             	sub    $0xc,%esp
  80228c:	50                   	push   %eax
  80228d:	6a 09                	push   $0x9
  80228f:	68 5f 3d 80 00       	push   $0x803d5f
  802294:	6a 23                	push   $0x23
  802296:	68 7c 3d 80 00       	push   $0x803d7c
  80229b:	e8 5c f4 ff ff       	call   8016fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8022a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	57                   	push   %edi
  8022ac:	56                   	push   %esi
  8022ad:	53                   	push   %ebx
  8022ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8022b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8022bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022be:	8b 55 08             	mov    0x8(%ebp),%edx
  8022c1:	89 df                	mov    %ebx,%edi
  8022c3:	89 de                	mov    %ebx,%esi
  8022c5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8022c7:	85 c0                	test   %eax,%eax
  8022c9:	7e 17                	jle    8022e2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8022cb:	83 ec 0c             	sub    $0xc,%esp
  8022ce:	50                   	push   %eax
  8022cf:	6a 0a                	push   $0xa
  8022d1:	68 5f 3d 80 00       	push   $0x803d5f
  8022d6:	6a 23                	push   $0x23
  8022d8:	68 7c 3d 80 00       	push   $0x803d7c
  8022dd:	e8 1a f4 ff ff       	call   8016fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8022e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	57                   	push   %edi
  8022ee:	56                   	push   %esi
  8022ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8022f0:	be 00 00 00 00       	mov    $0x0,%esi
  8022f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8022fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022fd:	8b 55 08             	mov    0x8(%ebp),%edx
  802300:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802303:	8b 7d 14             	mov    0x14(%ebp),%edi
  802306:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	57                   	push   %edi
  802311:	56                   	push   %esi
  802312:	53                   	push   %ebx
  802313:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802316:	b9 00 00 00 00       	mov    $0x0,%ecx
  80231b:	b8 0d 00 00 00       	mov    $0xd,%eax
  802320:	8b 55 08             	mov    0x8(%ebp),%edx
  802323:	89 cb                	mov    %ecx,%ebx
  802325:	89 cf                	mov    %ecx,%edi
  802327:	89 ce                	mov    %ecx,%esi
  802329:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80232b:	85 c0                	test   %eax,%eax
  80232d:	7e 17                	jle    802346 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80232f:	83 ec 0c             	sub    $0xc,%esp
  802332:	50                   	push   %eax
  802333:	6a 0d                	push   $0xd
  802335:	68 5f 3d 80 00       	push   $0x803d5f
  80233a:	6a 23                	push   $0x23
  80233c:	68 7c 3d 80 00       	push   $0x803d7c
  802341:	e8 b6 f3 ff ff       	call   8016fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802349:	5b                   	pop    %ebx
  80234a:	5e                   	pop    %esi
  80234b:	5f                   	pop    %edi
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    

0080234e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802354:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  80235b:	75 2e                	jne    80238b <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80235d:	e8 bd fd ff ff       	call   80211f <sys_getenvid>
  802362:	83 ec 04             	sub    $0x4,%esp
  802365:	68 07 0e 00 00       	push   $0xe07
  80236a:	68 00 f0 bf ee       	push   $0xeebff000
  80236f:	50                   	push   %eax
  802370:	e8 e8 fd ff ff       	call   80215d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802375:	e8 a5 fd ff ff       	call   80211f <sys_getenvid>
  80237a:	83 c4 08             	add    $0x8,%esp
  80237d:	68 95 23 80 00       	push   $0x802395
  802382:	50                   	push   %eax
  802383:	e8 20 ff ff ff       	call   8022a8 <sys_env_set_pgfault_upcall>
  802388:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
  80238e:	a3 10 90 80 00       	mov    %eax,0x809010
}
  802393:	c9                   	leave  
  802394:	c3                   	ret    

00802395 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802395:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802396:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  80239b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80239d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8023a0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8023a4:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8023a8:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8023ab:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8023ae:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8023af:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8023b2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8023b3:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8023b4:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8023b8:	c3                   	ret    

008023b9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023b9:	55                   	push   %ebp
  8023ba:	89 e5                	mov    %esp,%ebp
  8023bc:	56                   	push   %esi
  8023bd:	53                   	push   %ebx
  8023be:	8b 75 08             	mov    0x8(%ebp),%esi
  8023c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8023c7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8023c9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023ce:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8023d1:	83 ec 0c             	sub    $0xc,%esp
  8023d4:	50                   	push   %eax
  8023d5:	e8 33 ff ff ff       	call   80230d <sys_ipc_recv>

	if (from_env_store != NULL)
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	85 f6                	test   %esi,%esi
  8023df:	74 14                	je     8023f5 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8023e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	78 09                	js     8023f3 <ipc_recv+0x3a>
  8023ea:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  8023f0:	8b 52 74             	mov    0x74(%edx),%edx
  8023f3:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8023f5:	85 db                	test   %ebx,%ebx
  8023f7:	74 14                	je     80240d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8023f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fe:	85 c0                	test   %eax,%eax
  802400:	78 09                	js     80240b <ipc_recv+0x52>
  802402:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802408:	8b 52 78             	mov    0x78(%edx),%edx
  80240b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 08                	js     802419 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802411:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802416:	8b 40 70             	mov    0x70(%eax),%eax
}
  802419:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80241c:	5b                   	pop    %ebx
  80241d:	5e                   	pop    %esi
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	57                   	push   %edi
  802424:	56                   	push   %esi
  802425:	53                   	push   %ebx
  802426:	83 ec 0c             	sub    $0xc,%esp
  802429:	8b 7d 08             	mov    0x8(%ebp),%edi
  80242c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80242f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802432:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802434:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802439:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80243c:	ff 75 14             	pushl  0x14(%ebp)
  80243f:	53                   	push   %ebx
  802440:	56                   	push   %esi
  802441:	57                   	push   %edi
  802442:	e8 a3 fe ff ff       	call   8022ea <sys_ipc_try_send>

		if (err < 0) {
  802447:	83 c4 10             	add    $0x10,%esp
  80244a:	85 c0                	test   %eax,%eax
  80244c:	79 1e                	jns    80246c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80244e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802451:	75 07                	jne    80245a <ipc_send+0x3a>
				sys_yield();
  802453:	e8 e6 fc ff ff       	call   80213e <sys_yield>
  802458:	eb e2                	jmp    80243c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80245a:	50                   	push   %eax
  80245b:	68 8a 3d 80 00       	push   $0x803d8a
  802460:	6a 49                	push   $0x49
  802462:	68 97 3d 80 00       	push   $0x803d97
  802467:	e8 90 f2 ff ff       	call   8016fc <_panic>
		}

	} while (err < 0);

}
  80246c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80246f:	5b                   	pop    %ebx
  802470:	5e                   	pop    %esi
  802471:	5f                   	pop    %edi
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    

00802474 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802474:	55                   	push   %ebp
  802475:	89 e5                	mov    %esp,%ebp
  802477:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80247a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80247f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802482:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802488:	8b 52 50             	mov    0x50(%edx),%edx
  80248b:	39 ca                	cmp    %ecx,%edx
  80248d:	75 0d                	jne    80249c <ipc_find_env+0x28>
			return envs[i].env_id;
  80248f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802492:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802497:	8b 40 48             	mov    0x48(%eax),%eax
  80249a:	eb 0f                	jmp    8024ab <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80249c:	83 c0 01             	add    $0x1,%eax
  80249f:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024a4:	75 d9                	jne    80247f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    

008024ad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8024b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8024b8:	c1 e8 0c             	shr    $0xc,%eax
}
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    

008024bd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8024bd:	55                   	push   %ebp
  8024be:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8024c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8024c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8024cd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    

008024d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024da:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8024df:	89 c2                	mov    %eax,%edx
  8024e1:	c1 ea 16             	shr    $0x16,%edx
  8024e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024eb:	f6 c2 01             	test   $0x1,%dl
  8024ee:	74 11                	je     802501 <fd_alloc+0x2d>
  8024f0:	89 c2                	mov    %eax,%edx
  8024f2:	c1 ea 0c             	shr    $0xc,%edx
  8024f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8024fc:	f6 c2 01             	test   $0x1,%dl
  8024ff:	75 09                	jne    80250a <fd_alloc+0x36>
			*fd_store = fd;
  802501:	89 01                	mov    %eax,(%ecx)
			return 0;
  802503:	b8 00 00 00 00       	mov    $0x0,%eax
  802508:	eb 17                	jmp    802521 <fd_alloc+0x4d>
  80250a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80250f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802514:	75 c9                	jne    8024df <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802516:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80251c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802521:	5d                   	pop    %ebp
  802522:	c3                   	ret    

00802523 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802523:	55                   	push   %ebp
  802524:	89 e5                	mov    %esp,%ebp
  802526:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802529:	83 f8 1f             	cmp    $0x1f,%eax
  80252c:	77 36                	ja     802564 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80252e:	c1 e0 0c             	shl    $0xc,%eax
  802531:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802536:	89 c2                	mov    %eax,%edx
  802538:	c1 ea 16             	shr    $0x16,%edx
  80253b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802542:	f6 c2 01             	test   $0x1,%dl
  802545:	74 24                	je     80256b <fd_lookup+0x48>
  802547:	89 c2                	mov    %eax,%edx
  802549:	c1 ea 0c             	shr    $0xc,%edx
  80254c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802553:	f6 c2 01             	test   $0x1,%dl
  802556:	74 1a                	je     802572 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802558:	8b 55 0c             	mov    0xc(%ebp),%edx
  80255b:	89 02                	mov    %eax,(%edx)
	return 0;
  80255d:	b8 00 00 00 00       	mov    $0x0,%eax
  802562:	eb 13                	jmp    802577 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802569:	eb 0c                	jmp    802577 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80256b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802570:	eb 05                	jmp    802577 <fd_lookup+0x54>
  802572:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    

00802579 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802579:	55                   	push   %ebp
  80257a:	89 e5                	mov    %esp,%ebp
  80257c:	83 ec 08             	sub    $0x8,%esp
  80257f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802582:	ba 24 3e 80 00       	mov    $0x803e24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802587:	eb 13                	jmp    80259c <dev_lookup+0x23>
  802589:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80258c:	39 08                	cmp    %ecx,(%eax)
  80258e:	75 0c                	jne    80259c <dev_lookup+0x23>
			*dev = devtab[i];
  802590:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802593:	89 01                	mov    %eax,(%ecx)
			return 0;
  802595:	b8 00 00 00 00       	mov    $0x0,%eax
  80259a:	eb 2e                	jmp    8025ca <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80259c:	8b 02                	mov    (%edx),%eax
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	75 e7                	jne    802589 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8025a2:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8025a7:	8b 40 48             	mov    0x48(%eax),%eax
  8025aa:	83 ec 04             	sub    $0x4,%esp
  8025ad:	51                   	push   %ecx
  8025ae:	50                   	push   %eax
  8025af:	68 a4 3d 80 00       	push   $0x803da4
  8025b4:	e8 1c f2 ff ff       	call   8017d5 <cprintf>
	*dev = 0;
  8025b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8025c2:	83 c4 10             	add    $0x10,%esp
  8025c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8025ca:	c9                   	leave  
  8025cb:	c3                   	ret    

008025cc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
  8025cf:	56                   	push   %esi
  8025d0:	53                   	push   %ebx
  8025d1:	83 ec 10             	sub    $0x10,%esp
  8025d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8025d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8025da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025dd:	50                   	push   %eax
  8025de:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8025e4:	c1 e8 0c             	shr    $0xc,%eax
  8025e7:	50                   	push   %eax
  8025e8:	e8 36 ff ff ff       	call   802523 <fd_lookup>
  8025ed:	83 c4 08             	add    $0x8,%esp
  8025f0:	85 c0                	test   %eax,%eax
  8025f2:	78 05                	js     8025f9 <fd_close+0x2d>
	    || fd != fd2)
  8025f4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8025f7:	74 0c                	je     802605 <fd_close+0x39>
		return (must_exist ? r : 0);
  8025f9:	84 db                	test   %bl,%bl
  8025fb:	ba 00 00 00 00       	mov    $0x0,%edx
  802600:	0f 44 c2             	cmove  %edx,%eax
  802603:	eb 41                	jmp    802646 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802605:	83 ec 08             	sub    $0x8,%esp
  802608:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80260b:	50                   	push   %eax
  80260c:	ff 36                	pushl  (%esi)
  80260e:	e8 66 ff ff ff       	call   802579 <dev_lookup>
  802613:	89 c3                	mov    %eax,%ebx
  802615:	83 c4 10             	add    $0x10,%esp
  802618:	85 c0                	test   %eax,%eax
  80261a:	78 1a                	js     802636 <fd_close+0x6a>
		if (dev->dev_close)
  80261c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80261f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802622:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802627:	85 c0                	test   %eax,%eax
  802629:	74 0b                	je     802636 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80262b:	83 ec 0c             	sub    $0xc,%esp
  80262e:	56                   	push   %esi
  80262f:	ff d0                	call   *%eax
  802631:	89 c3                	mov    %eax,%ebx
  802633:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802636:	83 ec 08             	sub    $0x8,%esp
  802639:	56                   	push   %esi
  80263a:	6a 00                	push   $0x0
  80263c:	e8 a1 fb ff ff       	call   8021e2 <sys_page_unmap>
	return r;
  802641:	83 c4 10             	add    $0x10,%esp
  802644:	89 d8                	mov    %ebx,%eax
}
  802646:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802649:	5b                   	pop    %ebx
  80264a:	5e                   	pop    %esi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    

0080264d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80264d:	55                   	push   %ebp
  80264e:	89 e5                	mov    %esp,%ebp
  802650:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802656:	50                   	push   %eax
  802657:	ff 75 08             	pushl  0x8(%ebp)
  80265a:	e8 c4 fe ff ff       	call   802523 <fd_lookup>
  80265f:	83 c4 08             	add    $0x8,%esp
  802662:	85 c0                	test   %eax,%eax
  802664:	78 10                	js     802676 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802666:	83 ec 08             	sub    $0x8,%esp
  802669:	6a 01                	push   $0x1
  80266b:	ff 75 f4             	pushl  -0xc(%ebp)
  80266e:	e8 59 ff ff ff       	call   8025cc <fd_close>
  802673:	83 c4 10             	add    $0x10,%esp
}
  802676:	c9                   	leave  
  802677:	c3                   	ret    

00802678 <close_all>:

void
close_all(void)
{
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	53                   	push   %ebx
  80267c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80267f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802684:	83 ec 0c             	sub    $0xc,%esp
  802687:	53                   	push   %ebx
  802688:	e8 c0 ff ff ff       	call   80264d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80268d:	83 c3 01             	add    $0x1,%ebx
  802690:	83 c4 10             	add    $0x10,%esp
  802693:	83 fb 20             	cmp    $0x20,%ebx
  802696:	75 ec                	jne    802684 <close_all+0xc>
		close(i);
}
  802698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80269b:	c9                   	leave  
  80269c:	c3                   	ret    

0080269d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80269d:	55                   	push   %ebp
  80269e:	89 e5                	mov    %esp,%ebp
  8026a0:	57                   	push   %edi
  8026a1:	56                   	push   %esi
  8026a2:	53                   	push   %ebx
  8026a3:	83 ec 2c             	sub    $0x2c,%esp
  8026a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8026a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8026ac:	50                   	push   %eax
  8026ad:	ff 75 08             	pushl  0x8(%ebp)
  8026b0:	e8 6e fe ff ff       	call   802523 <fd_lookup>
  8026b5:	83 c4 08             	add    $0x8,%esp
  8026b8:	85 c0                	test   %eax,%eax
  8026ba:	0f 88 c1 00 00 00    	js     802781 <dup+0xe4>
		return r;
	close(newfdnum);
  8026c0:	83 ec 0c             	sub    $0xc,%esp
  8026c3:	56                   	push   %esi
  8026c4:	e8 84 ff ff ff       	call   80264d <close>

	newfd = INDEX2FD(newfdnum);
  8026c9:	89 f3                	mov    %esi,%ebx
  8026cb:	c1 e3 0c             	shl    $0xc,%ebx
  8026ce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8026d4:	83 c4 04             	add    $0x4,%esp
  8026d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8026da:	e8 de fd ff ff       	call   8024bd <fd2data>
  8026df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8026e1:	89 1c 24             	mov    %ebx,(%esp)
  8026e4:	e8 d4 fd ff ff       	call   8024bd <fd2data>
  8026e9:	83 c4 10             	add    $0x10,%esp
  8026ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8026ef:	89 f8                	mov    %edi,%eax
  8026f1:	c1 e8 16             	shr    $0x16,%eax
  8026f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8026fb:	a8 01                	test   $0x1,%al
  8026fd:	74 37                	je     802736 <dup+0x99>
  8026ff:	89 f8                	mov    %edi,%eax
  802701:	c1 e8 0c             	shr    $0xc,%eax
  802704:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80270b:	f6 c2 01             	test   $0x1,%dl
  80270e:	74 26                	je     802736 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802710:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802717:	83 ec 0c             	sub    $0xc,%esp
  80271a:	25 07 0e 00 00       	and    $0xe07,%eax
  80271f:	50                   	push   %eax
  802720:	ff 75 d4             	pushl  -0x2c(%ebp)
  802723:	6a 00                	push   $0x0
  802725:	57                   	push   %edi
  802726:	6a 00                	push   $0x0
  802728:	e8 73 fa ff ff       	call   8021a0 <sys_page_map>
  80272d:	89 c7                	mov    %eax,%edi
  80272f:	83 c4 20             	add    $0x20,%esp
  802732:	85 c0                	test   %eax,%eax
  802734:	78 2e                	js     802764 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802736:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802739:	89 d0                	mov    %edx,%eax
  80273b:	c1 e8 0c             	shr    $0xc,%eax
  80273e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802745:	83 ec 0c             	sub    $0xc,%esp
  802748:	25 07 0e 00 00       	and    $0xe07,%eax
  80274d:	50                   	push   %eax
  80274e:	53                   	push   %ebx
  80274f:	6a 00                	push   $0x0
  802751:	52                   	push   %edx
  802752:	6a 00                	push   $0x0
  802754:	e8 47 fa ff ff       	call   8021a0 <sys_page_map>
  802759:	89 c7                	mov    %eax,%edi
  80275b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80275e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802760:	85 ff                	test   %edi,%edi
  802762:	79 1d                	jns    802781 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802764:	83 ec 08             	sub    $0x8,%esp
  802767:	53                   	push   %ebx
  802768:	6a 00                	push   $0x0
  80276a:	e8 73 fa ff ff       	call   8021e2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80276f:	83 c4 08             	add    $0x8,%esp
  802772:	ff 75 d4             	pushl  -0x2c(%ebp)
  802775:	6a 00                	push   $0x0
  802777:	e8 66 fa ff ff       	call   8021e2 <sys_page_unmap>
	return r;
  80277c:	83 c4 10             	add    $0x10,%esp
  80277f:	89 f8                	mov    %edi,%eax
}
  802781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802784:	5b                   	pop    %ebx
  802785:	5e                   	pop    %esi
  802786:	5f                   	pop    %edi
  802787:	5d                   	pop    %ebp
  802788:	c3                   	ret    

00802789 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802789:	55                   	push   %ebp
  80278a:	89 e5                	mov    %esp,%ebp
  80278c:	53                   	push   %ebx
  80278d:	83 ec 14             	sub    $0x14,%esp
  802790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802793:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802796:	50                   	push   %eax
  802797:	53                   	push   %ebx
  802798:	e8 86 fd ff ff       	call   802523 <fd_lookup>
  80279d:	83 c4 08             	add    $0x8,%esp
  8027a0:	89 c2                	mov    %eax,%edx
  8027a2:	85 c0                	test   %eax,%eax
  8027a4:	78 6d                	js     802813 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8027a6:	83 ec 08             	sub    $0x8,%esp
  8027a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ac:	50                   	push   %eax
  8027ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027b0:	ff 30                	pushl  (%eax)
  8027b2:	e8 c2 fd ff ff       	call   802579 <dev_lookup>
  8027b7:	83 c4 10             	add    $0x10,%esp
  8027ba:	85 c0                	test   %eax,%eax
  8027bc:	78 4c                	js     80280a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8027be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027c1:	8b 42 08             	mov    0x8(%edx),%eax
  8027c4:	83 e0 03             	and    $0x3,%eax
  8027c7:	83 f8 01             	cmp    $0x1,%eax
  8027ca:	75 21                	jne    8027ed <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8027cc:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8027d1:	8b 40 48             	mov    0x48(%eax),%eax
  8027d4:	83 ec 04             	sub    $0x4,%esp
  8027d7:	53                   	push   %ebx
  8027d8:	50                   	push   %eax
  8027d9:	68 e8 3d 80 00       	push   $0x803de8
  8027de:	e8 f2 ef ff ff       	call   8017d5 <cprintf>
		return -E_INVAL;
  8027e3:	83 c4 10             	add    $0x10,%esp
  8027e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8027eb:	eb 26                	jmp    802813 <read+0x8a>
	}
	if (!dev->dev_read)
  8027ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027f0:	8b 40 08             	mov    0x8(%eax),%eax
  8027f3:	85 c0                	test   %eax,%eax
  8027f5:	74 17                	je     80280e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8027f7:	83 ec 04             	sub    $0x4,%esp
  8027fa:	ff 75 10             	pushl  0x10(%ebp)
  8027fd:	ff 75 0c             	pushl  0xc(%ebp)
  802800:	52                   	push   %edx
  802801:	ff d0                	call   *%eax
  802803:	89 c2                	mov    %eax,%edx
  802805:	83 c4 10             	add    $0x10,%esp
  802808:	eb 09                	jmp    802813 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80280a:	89 c2                	mov    %eax,%edx
  80280c:	eb 05                	jmp    802813 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80280e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802813:	89 d0                	mov    %edx,%eax
  802815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802818:	c9                   	leave  
  802819:	c3                   	ret    

0080281a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80281a:	55                   	push   %ebp
  80281b:	89 e5                	mov    %esp,%ebp
  80281d:	57                   	push   %edi
  80281e:	56                   	push   %esi
  80281f:	53                   	push   %ebx
  802820:	83 ec 0c             	sub    $0xc,%esp
  802823:	8b 7d 08             	mov    0x8(%ebp),%edi
  802826:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802829:	bb 00 00 00 00       	mov    $0x0,%ebx
  80282e:	eb 21                	jmp    802851 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802830:	83 ec 04             	sub    $0x4,%esp
  802833:	89 f0                	mov    %esi,%eax
  802835:	29 d8                	sub    %ebx,%eax
  802837:	50                   	push   %eax
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	03 45 0c             	add    0xc(%ebp),%eax
  80283d:	50                   	push   %eax
  80283e:	57                   	push   %edi
  80283f:	e8 45 ff ff ff       	call   802789 <read>
		if (m < 0)
  802844:	83 c4 10             	add    $0x10,%esp
  802847:	85 c0                	test   %eax,%eax
  802849:	78 10                	js     80285b <readn+0x41>
			return m;
		if (m == 0)
  80284b:	85 c0                	test   %eax,%eax
  80284d:	74 0a                	je     802859 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80284f:	01 c3                	add    %eax,%ebx
  802851:	39 f3                	cmp    %esi,%ebx
  802853:	72 db                	jb     802830 <readn+0x16>
  802855:	89 d8                	mov    %ebx,%eax
  802857:	eb 02                	jmp    80285b <readn+0x41>
  802859:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80285b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80285e:	5b                   	pop    %ebx
  80285f:	5e                   	pop    %esi
  802860:	5f                   	pop    %edi
  802861:	5d                   	pop    %ebp
  802862:	c3                   	ret    

00802863 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802863:	55                   	push   %ebp
  802864:	89 e5                	mov    %esp,%ebp
  802866:	53                   	push   %ebx
  802867:	83 ec 14             	sub    $0x14,%esp
  80286a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80286d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802870:	50                   	push   %eax
  802871:	53                   	push   %ebx
  802872:	e8 ac fc ff ff       	call   802523 <fd_lookup>
  802877:	83 c4 08             	add    $0x8,%esp
  80287a:	89 c2                	mov    %eax,%edx
  80287c:	85 c0                	test   %eax,%eax
  80287e:	78 68                	js     8028e8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802880:	83 ec 08             	sub    $0x8,%esp
  802883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802886:	50                   	push   %eax
  802887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80288a:	ff 30                	pushl  (%eax)
  80288c:	e8 e8 fc ff ff       	call   802579 <dev_lookup>
  802891:	83 c4 10             	add    $0x10,%esp
  802894:	85 c0                	test   %eax,%eax
  802896:	78 47                	js     8028df <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80289b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80289f:	75 21                	jne    8028c2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8028a1:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8028a6:	8b 40 48             	mov    0x48(%eax),%eax
  8028a9:	83 ec 04             	sub    $0x4,%esp
  8028ac:	53                   	push   %ebx
  8028ad:	50                   	push   %eax
  8028ae:	68 04 3e 80 00       	push   $0x803e04
  8028b3:	e8 1d ef ff ff       	call   8017d5 <cprintf>
		return -E_INVAL;
  8028b8:	83 c4 10             	add    $0x10,%esp
  8028bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8028c0:	eb 26                	jmp    8028e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8028c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8028c8:	85 d2                	test   %edx,%edx
  8028ca:	74 17                	je     8028e3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8028cc:	83 ec 04             	sub    $0x4,%esp
  8028cf:	ff 75 10             	pushl  0x10(%ebp)
  8028d2:	ff 75 0c             	pushl  0xc(%ebp)
  8028d5:	50                   	push   %eax
  8028d6:	ff d2                	call   *%edx
  8028d8:	89 c2                	mov    %eax,%edx
  8028da:	83 c4 10             	add    $0x10,%esp
  8028dd:	eb 09                	jmp    8028e8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8028df:	89 c2                	mov    %eax,%edx
  8028e1:	eb 05                	jmp    8028e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8028e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8028e8:	89 d0                	mov    %edx,%eax
  8028ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8028ed:	c9                   	leave  
  8028ee:	c3                   	ret    

008028ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8028ef:	55                   	push   %ebp
  8028f0:	89 e5                	mov    %esp,%ebp
  8028f2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028f5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8028f8:	50                   	push   %eax
  8028f9:	ff 75 08             	pushl  0x8(%ebp)
  8028fc:	e8 22 fc ff ff       	call   802523 <fd_lookup>
  802901:	83 c4 08             	add    $0x8,%esp
  802904:	85 c0                	test   %eax,%eax
  802906:	78 0e                	js     802916 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802908:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80290b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80290e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802916:	c9                   	leave  
  802917:	c3                   	ret    

00802918 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802918:	55                   	push   %ebp
  802919:	89 e5                	mov    %esp,%ebp
  80291b:	53                   	push   %ebx
  80291c:	83 ec 14             	sub    $0x14,%esp
  80291f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802922:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802925:	50                   	push   %eax
  802926:	53                   	push   %ebx
  802927:	e8 f7 fb ff ff       	call   802523 <fd_lookup>
  80292c:	83 c4 08             	add    $0x8,%esp
  80292f:	89 c2                	mov    %eax,%edx
  802931:	85 c0                	test   %eax,%eax
  802933:	78 65                	js     80299a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802935:	83 ec 08             	sub    $0x8,%esp
  802938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80293b:	50                   	push   %eax
  80293c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80293f:	ff 30                	pushl  (%eax)
  802941:	e8 33 fc ff ff       	call   802579 <dev_lookup>
  802946:	83 c4 10             	add    $0x10,%esp
  802949:	85 c0                	test   %eax,%eax
  80294b:	78 44                	js     802991 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80294d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802950:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802954:	75 21                	jne    802977 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802956:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80295b:	8b 40 48             	mov    0x48(%eax),%eax
  80295e:	83 ec 04             	sub    $0x4,%esp
  802961:	53                   	push   %ebx
  802962:	50                   	push   %eax
  802963:	68 c4 3d 80 00       	push   $0x803dc4
  802968:	e8 68 ee ff ff       	call   8017d5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80296d:	83 c4 10             	add    $0x10,%esp
  802970:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802975:	eb 23                	jmp    80299a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802977:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80297a:	8b 52 18             	mov    0x18(%edx),%edx
  80297d:	85 d2                	test   %edx,%edx
  80297f:	74 14                	je     802995 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802981:	83 ec 08             	sub    $0x8,%esp
  802984:	ff 75 0c             	pushl  0xc(%ebp)
  802987:	50                   	push   %eax
  802988:	ff d2                	call   *%edx
  80298a:	89 c2                	mov    %eax,%edx
  80298c:	83 c4 10             	add    $0x10,%esp
  80298f:	eb 09                	jmp    80299a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802991:	89 c2                	mov    %eax,%edx
  802993:	eb 05                	jmp    80299a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802995:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80299a:	89 d0                	mov    %edx,%eax
  80299c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80299f:	c9                   	leave  
  8029a0:	c3                   	ret    

008029a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8029a1:	55                   	push   %ebp
  8029a2:	89 e5                	mov    %esp,%ebp
  8029a4:	53                   	push   %ebx
  8029a5:	83 ec 14             	sub    $0x14,%esp
  8029a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8029ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8029ae:	50                   	push   %eax
  8029af:	ff 75 08             	pushl  0x8(%ebp)
  8029b2:	e8 6c fb ff ff       	call   802523 <fd_lookup>
  8029b7:	83 c4 08             	add    $0x8,%esp
  8029ba:	89 c2                	mov    %eax,%edx
  8029bc:	85 c0                	test   %eax,%eax
  8029be:	78 58                	js     802a18 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8029c0:	83 ec 08             	sub    $0x8,%esp
  8029c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029c6:	50                   	push   %eax
  8029c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029ca:	ff 30                	pushl  (%eax)
  8029cc:	e8 a8 fb ff ff       	call   802579 <dev_lookup>
  8029d1:	83 c4 10             	add    $0x10,%esp
  8029d4:	85 c0                	test   %eax,%eax
  8029d6:	78 37                	js     802a0f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8029d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029db:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8029df:	74 32                	je     802a13 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8029e1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8029e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8029eb:	00 00 00 
	stat->st_isdir = 0;
  8029ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8029f5:	00 00 00 
	stat->st_dev = dev;
  8029f8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8029fe:	83 ec 08             	sub    $0x8,%esp
  802a01:	53                   	push   %ebx
  802a02:	ff 75 f0             	pushl  -0x10(%ebp)
  802a05:	ff 50 14             	call   *0x14(%eax)
  802a08:	89 c2                	mov    %eax,%edx
  802a0a:	83 c4 10             	add    $0x10,%esp
  802a0d:	eb 09                	jmp    802a18 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a0f:	89 c2                	mov    %eax,%edx
  802a11:	eb 05                	jmp    802a18 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802a13:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802a18:	89 d0                	mov    %edx,%eax
  802a1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a1d:	c9                   	leave  
  802a1e:	c3                   	ret    

00802a1f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802a1f:	55                   	push   %ebp
  802a20:	89 e5                	mov    %esp,%ebp
  802a22:	56                   	push   %esi
  802a23:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802a24:	83 ec 08             	sub    $0x8,%esp
  802a27:	6a 00                	push   $0x0
  802a29:	ff 75 08             	pushl  0x8(%ebp)
  802a2c:	e8 b7 01 00 00       	call   802be8 <open>
  802a31:	89 c3                	mov    %eax,%ebx
  802a33:	83 c4 10             	add    $0x10,%esp
  802a36:	85 c0                	test   %eax,%eax
  802a38:	78 1b                	js     802a55 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802a3a:	83 ec 08             	sub    $0x8,%esp
  802a3d:	ff 75 0c             	pushl  0xc(%ebp)
  802a40:	50                   	push   %eax
  802a41:	e8 5b ff ff ff       	call   8029a1 <fstat>
  802a46:	89 c6                	mov    %eax,%esi
	close(fd);
  802a48:	89 1c 24             	mov    %ebx,(%esp)
  802a4b:	e8 fd fb ff ff       	call   80264d <close>
	return r;
  802a50:	83 c4 10             	add    $0x10,%esp
  802a53:	89 f0                	mov    %esi,%eax
}
  802a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a58:	5b                   	pop    %ebx
  802a59:	5e                   	pop    %esi
  802a5a:	5d                   	pop    %ebp
  802a5b:	c3                   	ret    

00802a5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802a5c:	55                   	push   %ebp
  802a5d:	89 e5                	mov    %esp,%ebp
  802a5f:	56                   	push   %esi
  802a60:	53                   	push   %ebx
  802a61:	89 c6                	mov    %eax,%esi
  802a63:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802a65:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802a6c:	75 12                	jne    802a80 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802a6e:	83 ec 0c             	sub    $0xc,%esp
  802a71:	6a 01                	push   $0x1
  802a73:	e8 fc f9 ff ff       	call   802474 <ipc_find_env>
  802a78:	a3 00 90 80 00       	mov    %eax,0x809000
  802a7d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802a80:	6a 07                	push   $0x7
  802a82:	68 00 a0 80 00       	push   $0x80a000
  802a87:	56                   	push   %esi
  802a88:	ff 35 00 90 80 00    	pushl  0x809000
  802a8e:	e8 8d f9 ff ff       	call   802420 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802a93:	83 c4 0c             	add    $0xc,%esp
  802a96:	6a 00                	push   $0x0
  802a98:	53                   	push   %ebx
  802a99:	6a 00                	push   $0x0
  802a9b:	e8 19 f9 ff ff       	call   8023b9 <ipc_recv>
}
  802aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aa3:	5b                   	pop    %ebx
  802aa4:	5e                   	pop    %esi
  802aa5:	5d                   	pop    %ebp
  802aa6:	c3                   	ret    

00802aa7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802aa7:	55                   	push   %ebp
  802aa8:	89 e5                	mov    %esp,%ebp
  802aaa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802aad:	8b 45 08             	mov    0x8(%ebp),%eax
  802ab0:	8b 40 0c             	mov    0xc(%eax),%eax
  802ab3:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  802ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  802abb:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  802ac5:	b8 02 00 00 00       	mov    $0x2,%eax
  802aca:	e8 8d ff ff ff       	call   802a5c <fsipc>
}
  802acf:	c9                   	leave  
  802ad0:	c3                   	ret    

00802ad1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802ad1:	55                   	push   %ebp
  802ad2:	89 e5                	mov    %esp,%ebp
  802ad4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  802ada:	8b 40 0c             	mov    0xc(%eax),%eax
  802add:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  802ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  802ae7:	b8 06 00 00 00       	mov    $0x6,%eax
  802aec:	e8 6b ff ff ff       	call   802a5c <fsipc>
}
  802af1:	c9                   	leave  
  802af2:	c3                   	ret    

00802af3 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802af3:	55                   	push   %ebp
  802af4:	89 e5                	mov    %esp,%ebp
  802af6:	53                   	push   %ebx
  802af7:	83 ec 04             	sub    $0x4,%esp
  802afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802afd:	8b 45 08             	mov    0x8(%ebp),%eax
  802b00:	8b 40 0c             	mov    0xc(%eax),%eax
  802b03:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802b08:	ba 00 00 00 00       	mov    $0x0,%edx
  802b0d:	b8 05 00 00 00       	mov    $0x5,%eax
  802b12:	e8 45 ff ff ff       	call   802a5c <fsipc>
  802b17:	85 c0                	test   %eax,%eax
  802b19:	78 2c                	js     802b47 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802b1b:	83 ec 08             	sub    $0x8,%esp
  802b1e:	68 00 a0 80 00       	push   $0x80a000
  802b23:	53                   	push   %ebx
  802b24:	e8 31 f2 ff ff       	call   801d5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802b29:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802b2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802b34:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802b39:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802b3f:	83 c4 10             	add    $0x10,%esp
  802b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b4a:	c9                   	leave  
  802b4b:	c3                   	ret    

00802b4c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802b4c:	55                   	push   %ebp
  802b4d:	89 e5                	mov    %esp,%ebp
  802b4f:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802b52:	68 34 3e 80 00       	push   $0x803e34
  802b57:	68 90 00 00 00       	push   $0x90
  802b5c:	68 52 3e 80 00       	push   $0x803e52
  802b61:	e8 96 eb ff ff       	call   8016fc <_panic>

00802b66 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802b66:	55                   	push   %ebp
  802b67:	89 e5                	mov    %esp,%ebp
  802b69:	56                   	push   %esi
  802b6a:	53                   	push   %ebx
  802b6b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  802b71:	8b 40 0c             	mov    0xc(%eax),%eax
  802b74:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  802b79:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  802b84:	b8 03 00 00 00       	mov    $0x3,%eax
  802b89:	e8 ce fe ff ff       	call   802a5c <fsipc>
  802b8e:	89 c3                	mov    %eax,%ebx
  802b90:	85 c0                	test   %eax,%eax
  802b92:	78 4b                	js     802bdf <devfile_read+0x79>
		return r;
	assert(r <= n);
  802b94:	39 c6                	cmp    %eax,%esi
  802b96:	73 16                	jae    802bae <devfile_read+0x48>
  802b98:	68 5d 3e 80 00       	push   $0x803e5d
  802b9d:	68 7d 34 80 00       	push   $0x80347d
  802ba2:	6a 7c                	push   $0x7c
  802ba4:	68 52 3e 80 00       	push   $0x803e52
  802ba9:	e8 4e eb ff ff       	call   8016fc <_panic>
	assert(r <= PGSIZE);
  802bae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802bb3:	7e 16                	jle    802bcb <devfile_read+0x65>
  802bb5:	68 64 3e 80 00       	push   $0x803e64
  802bba:	68 7d 34 80 00       	push   $0x80347d
  802bbf:	6a 7d                	push   $0x7d
  802bc1:	68 52 3e 80 00       	push   $0x803e52
  802bc6:	e8 31 eb ff ff       	call   8016fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802bcb:	83 ec 04             	sub    $0x4,%esp
  802bce:	50                   	push   %eax
  802bcf:	68 00 a0 80 00       	push   $0x80a000
  802bd4:	ff 75 0c             	pushl  0xc(%ebp)
  802bd7:	e8 10 f3 ff ff       	call   801eec <memmove>
	return r;
  802bdc:	83 c4 10             	add    $0x10,%esp
}
  802bdf:	89 d8                	mov    %ebx,%eax
  802be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802be4:	5b                   	pop    %ebx
  802be5:	5e                   	pop    %esi
  802be6:	5d                   	pop    %ebp
  802be7:	c3                   	ret    

00802be8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802be8:	55                   	push   %ebp
  802be9:	89 e5                	mov    %esp,%ebp
  802beb:	53                   	push   %ebx
  802bec:	83 ec 20             	sub    $0x20,%esp
  802bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802bf2:	53                   	push   %ebx
  802bf3:	e8 29 f1 ff ff       	call   801d21 <strlen>
  802bf8:	83 c4 10             	add    $0x10,%esp
  802bfb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802c00:	7f 67                	jg     802c69 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802c02:	83 ec 0c             	sub    $0xc,%esp
  802c05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c08:	50                   	push   %eax
  802c09:	e8 c6 f8 ff ff       	call   8024d4 <fd_alloc>
  802c0e:	83 c4 10             	add    $0x10,%esp
		return r;
  802c11:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802c13:	85 c0                	test   %eax,%eax
  802c15:	78 57                	js     802c6e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802c17:	83 ec 08             	sub    $0x8,%esp
  802c1a:	53                   	push   %ebx
  802c1b:	68 00 a0 80 00       	push   $0x80a000
  802c20:	e8 35 f1 ff ff       	call   801d5a <strcpy>
	fsipcbuf.open.req_omode = mode;
  802c25:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c28:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c30:	b8 01 00 00 00       	mov    $0x1,%eax
  802c35:	e8 22 fe ff ff       	call   802a5c <fsipc>
  802c3a:	89 c3                	mov    %eax,%ebx
  802c3c:	83 c4 10             	add    $0x10,%esp
  802c3f:	85 c0                	test   %eax,%eax
  802c41:	79 14                	jns    802c57 <open+0x6f>
		fd_close(fd, 0);
  802c43:	83 ec 08             	sub    $0x8,%esp
  802c46:	6a 00                	push   $0x0
  802c48:	ff 75 f4             	pushl  -0xc(%ebp)
  802c4b:	e8 7c f9 ff ff       	call   8025cc <fd_close>
		return r;
  802c50:	83 c4 10             	add    $0x10,%esp
  802c53:	89 da                	mov    %ebx,%edx
  802c55:	eb 17                	jmp    802c6e <open+0x86>
	}

	return fd2num(fd);
  802c57:	83 ec 0c             	sub    $0xc,%esp
  802c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  802c5d:	e8 4b f8 ff ff       	call   8024ad <fd2num>
  802c62:	89 c2                	mov    %eax,%edx
  802c64:	83 c4 10             	add    $0x10,%esp
  802c67:	eb 05                	jmp    802c6e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802c69:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802c6e:	89 d0                	mov    %edx,%eax
  802c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c73:	c9                   	leave  
  802c74:	c3                   	ret    

00802c75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802c75:	55                   	push   %ebp
  802c76:	89 e5                	mov    %esp,%ebp
  802c78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  802c80:	b8 08 00 00 00       	mov    $0x8,%eax
  802c85:	e8 d2 fd ff ff       	call   802a5c <fsipc>
}
  802c8a:	c9                   	leave  
  802c8b:	c3                   	ret    

00802c8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802c8c:	55                   	push   %ebp
  802c8d:	89 e5                	mov    %esp,%ebp
  802c8f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c92:	89 d0                	mov    %edx,%eax
  802c94:	c1 e8 16             	shr    $0x16,%eax
  802c97:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802c9e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ca3:	f6 c1 01             	test   $0x1,%cl
  802ca6:	74 1d                	je     802cc5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ca8:	c1 ea 0c             	shr    $0xc,%edx
  802cab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802cb2:	f6 c2 01             	test   $0x1,%dl
  802cb5:	74 0e                	je     802cc5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802cb7:	c1 ea 0c             	shr    $0xc,%edx
  802cba:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802cc1:	ef 
  802cc2:	0f b7 c0             	movzwl %ax,%eax
}
  802cc5:	5d                   	pop    %ebp
  802cc6:	c3                   	ret    

00802cc7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802cc7:	55                   	push   %ebp
  802cc8:	89 e5                	mov    %esp,%ebp
  802cca:	56                   	push   %esi
  802ccb:	53                   	push   %ebx
  802ccc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ccf:	83 ec 0c             	sub    $0xc,%esp
  802cd2:	ff 75 08             	pushl  0x8(%ebp)
  802cd5:	e8 e3 f7 ff ff       	call   8024bd <fd2data>
  802cda:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802cdc:	83 c4 08             	add    $0x8,%esp
  802cdf:	68 70 3e 80 00       	push   $0x803e70
  802ce4:	53                   	push   %ebx
  802ce5:	e8 70 f0 ff ff       	call   801d5a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802cea:	8b 46 04             	mov    0x4(%esi),%eax
  802ced:	2b 06                	sub    (%esi),%eax
  802cef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802cf5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cfc:	00 00 00 
	stat->st_dev = &devpipe;
  802cff:	c7 83 88 00 00 00 80 	movl   $0x808080,0x88(%ebx)
  802d06:	80 80 00 
	return 0;
}
  802d09:	b8 00 00 00 00       	mov    $0x0,%eax
  802d0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d11:	5b                   	pop    %ebx
  802d12:	5e                   	pop    %esi
  802d13:	5d                   	pop    %ebp
  802d14:	c3                   	ret    

00802d15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802d15:	55                   	push   %ebp
  802d16:	89 e5                	mov    %esp,%ebp
  802d18:	53                   	push   %ebx
  802d19:	83 ec 0c             	sub    $0xc,%esp
  802d1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802d1f:	53                   	push   %ebx
  802d20:	6a 00                	push   $0x0
  802d22:	e8 bb f4 ff ff       	call   8021e2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802d27:	89 1c 24             	mov    %ebx,(%esp)
  802d2a:	e8 8e f7 ff ff       	call   8024bd <fd2data>
  802d2f:	83 c4 08             	add    $0x8,%esp
  802d32:	50                   	push   %eax
  802d33:	6a 00                	push   $0x0
  802d35:	e8 a8 f4 ff ff       	call   8021e2 <sys_page_unmap>
}
  802d3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d3d:	c9                   	leave  
  802d3e:	c3                   	ret    

00802d3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802d3f:	55                   	push   %ebp
  802d40:	89 e5                	mov    %esp,%ebp
  802d42:	57                   	push   %edi
  802d43:	56                   	push   %esi
  802d44:	53                   	push   %ebx
  802d45:	83 ec 1c             	sub    $0x1c,%esp
  802d48:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802d4b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802d4d:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802d52:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802d55:	83 ec 0c             	sub    $0xc,%esp
  802d58:	ff 75 e0             	pushl  -0x20(%ebp)
  802d5b:	e8 2c ff ff ff       	call   802c8c <pageref>
  802d60:	89 c3                	mov    %eax,%ebx
  802d62:	89 3c 24             	mov    %edi,(%esp)
  802d65:	e8 22 ff ff ff       	call   802c8c <pageref>
  802d6a:	83 c4 10             	add    $0x10,%esp
  802d6d:	39 c3                	cmp    %eax,%ebx
  802d6f:	0f 94 c1             	sete   %cl
  802d72:	0f b6 c9             	movzbl %cl,%ecx
  802d75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802d78:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802d7e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802d81:	39 ce                	cmp    %ecx,%esi
  802d83:	74 1b                	je     802da0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802d85:	39 c3                	cmp    %eax,%ebx
  802d87:	75 c4                	jne    802d4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802d89:	8b 42 58             	mov    0x58(%edx),%eax
  802d8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  802d8f:	50                   	push   %eax
  802d90:	56                   	push   %esi
  802d91:	68 77 3e 80 00       	push   $0x803e77
  802d96:	e8 3a ea ff ff       	call   8017d5 <cprintf>
  802d9b:	83 c4 10             	add    $0x10,%esp
  802d9e:	eb ad                	jmp    802d4d <_pipeisclosed+0xe>
	}
}
  802da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802da6:	5b                   	pop    %ebx
  802da7:	5e                   	pop    %esi
  802da8:	5f                   	pop    %edi
  802da9:	5d                   	pop    %ebp
  802daa:	c3                   	ret    

00802dab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802dab:	55                   	push   %ebp
  802dac:	89 e5                	mov    %esp,%ebp
  802dae:	57                   	push   %edi
  802daf:	56                   	push   %esi
  802db0:	53                   	push   %ebx
  802db1:	83 ec 28             	sub    $0x28,%esp
  802db4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802db7:	56                   	push   %esi
  802db8:	e8 00 f7 ff ff       	call   8024bd <fd2data>
  802dbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802dbf:	83 c4 10             	add    $0x10,%esp
  802dc2:	bf 00 00 00 00       	mov    $0x0,%edi
  802dc7:	eb 4b                	jmp    802e14 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802dc9:	89 da                	mov    %ebx,%edx
  802dcb:	89 f0                	mov    %esi,%eax
  802dcd:	e8 6d ff ff ff       	call   802d3f <_pipeisclosed>
  802dd2:	85 c0                	test   %eax,%eax
  802dd4:	75 48                	jne    802e1e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802dd6:	e8 63 f3 ff ff       	call   80213e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ddb:	8b 43 04             	mov    0x4(%ebx),%eax
  802dde:	8b 0b                	mov    (%ebx),%ecx
  802de0:	8d 51 20             	lea    0x20(%ecx),%edx
  802de3:	39 d0                	cmp    %edx,%eax
  802de5:	73 e2                	jae    802dc9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802dea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802dee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802df1:	89 c2                	mov    %eax,%edx
  802df3:	c1 fa 1f             	sar    $0x1f,%edx
  802df6:	89 d1                	mov    %edx,%ecx
  802df8:	c1 e9 1b             	shr    $0x1b,%ecx
  802dfb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802dfe:	83 e2 1f             	and    $0x1f,%edx
  802e01:	29 ca                	sub    %ecx,%edx
  802e03:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802e07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802e0b:	83 c0 01             	add    $0x1,%eax
  802e0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e11:	83 c7 01             	add    $0x1,%edi
  802e14:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802e17:	75 c2                	jne    802ddb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802e19:	8b 45 10             	mov    0x10(%ebp),%eax
  802e1c:	eb 05                	jmp    802e23 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802e1e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e26:	5b                   	pop    %ebx
  802e27:	5e                   	pop    %esi
  802e28:	5f                   	pop    %edi
  802e29:	5d                   	pop    %ebp
  802e2a:	c3                   	ret    

00802e2b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802e2b:	55                   	push   %ebp
  802e2c:	89 e5                	mov    %esp,%ebp
  802e2e:	57                   	push   %edi
  802e2f:	56                   	push   %esi
  802e30:	53                   	push   %ebx
  802e31:	83 ec 18             	sub    $0x18,%esp
  802e34:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802e37:	57                   	push   %edi
  802e38:	e8 80 f6 ff ff       	call   8024bd <fd2data>
  802e3d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e3f:	83 c4 10             	add    $0x10,%esp
  802e42:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e47:	eb 3d                	jmp    802e86 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802e49:	85 db                	test   %ebx,%ebx
  802e4b:	74 04                	je     802e51 <devpipe_read+0x26>
				return i;
  802e4d:	89 d8                	mov    %ebx,%eax
  802e4f:	eb 44                	jmp    802e95 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802e51:	89 f2                	mov    %esi,%edx
  802e53:	89 f8                	mov    %edi,%eax
  802e55:	e8 e5 fe ff ff       	call   802d3f <_pipeisclosed>
  802e5a:	85 c0                	test   %eax,%eax
  802e5c:	75 32                	jne    802e90 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802e5e:	e8 db f2 ff ff       	call   80213e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802e63:	8b 06                	mov    (%esi),%eax
  802e65:	3b 46 04             	cmp    0x4(%esi),%eax
  802e68:	74 df                	je     802e49 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802e6a:	99                   	cltd   
  802e6b:	c1 ea 1b             	shr    $0x1b,%edx
  802e6e:	01 d0                	add    %edx,%eax
  802e70:	83 e0 1f             	and    $0x1f,%eax
  802e73:	29 d0                	sub    %edx,%eax
  802e75:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e7d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802e80:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e83:	83 c3 01             	add    $0x1,%ebx
  802e86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802e89:	75 d8                	jne    802e63 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802e8b:	8b 45 10             	mov    0x10(%ebp),%eax
  802e8e:	eb 05                	jmp    802e95 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802e90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e98:	5b                   	pop    %ebx
  802e99:	5e                   	pop    %esi
  802e9a:	5f                   	pop    %edi
  802e9b:	5d                   	pop    %ebp
  802e9c:	c3                   	ret    

00802e9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802e9d:	55                   	push   %ebp
  802e9e:	89 e5                	mov    %esp,%ebp
  802ea0:	56                   	push   %esi
  802ea1:	53                   	push   %ebx
  802ea2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802ea5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ea8:	50                   	push   %eax
  802ea9:	e8 26 f6 ff ff       	call   8024d4 <fd_alloc>
  802eae:	83 c4 10             	add    $0x10,%esp
  802eb1:	89 c2                	mov    %eax,%edx
  802eb3:	85 c0                	test   %eax,%eax
  802eb5:	0f 88 2c 01 00 00    	js     802fe7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ebb:	83 ec 04             	sub    $0x4,%esp
  802ebe:	68 07 04 00 00       	push   $0x407
  802ec3:	ff 75 f4             	pushl  -0xc(%ebp)
  802ec6:	6a 00                	push   $0x0
  802ec8:	e8 90 f2 ff ff       	call   80215d <sys_page_alloc>
  802ecd:	83 c4 10             	add    $0x10,%esp
  802ed0:	89 c2                	mov    %eax,%edx
  802ed2:	85 c0                	test   %eax,%eax
  802ed4:	0f 88 0d 01 00 00    	js     802fe7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802eda:	83 ec 0c             	sub    $0xc,%esp
  802edd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ee0:	50                   	push   %eax
  802ee1:	e8 ee f5 ff ff       	call   8024d4 <fd_alloc>
  802ee6:	89 c3                	mov    %eax,%ebx
  802ee8:	83 c4 10             	add    $0x10,%esp
  802eeb:	85 c0                	test   %eax,%eax
  802eed:	0f 88 e2 00 00 00    	js     802fd5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ef3:	83 ec 04             	sub    $0x4,%esp
  802ef6:	68 07 04 00 00       	push   $0x407
  802efb:	ff 75 f0             	pushl  -0x10(%ebp)
  802efe:	6a 00                	push   $0x0
  802f00:	e8 58 f2 ff ff       	call   80215d <sys_page_alloc>
  802f05:	89 c3                	mov    %eax,%ebx
  802f07:	83 c4 10             	add    $0x10,%esp
  802f0a:	85 c0                	test   %eax,%eax
  802f0c:	0f 88 c3 00 00 00    	js     802fd5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802f12:	83 ec 0c             	sub    $0xc,%esp
  802f15:	ff 75 f4             	pushl  -0xc(%ebp)
  802f18:	e8 a0 f5 ff ff       	call   8024bd <fd2data>
  802f1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f1f:	83 c4 0c             	add    $0xc,%esp
  802f22:	68 07 04 00 00       	push   $0x407
  802f27:	50                   	push   %eax
  802f28:	6a 00                	push   $0x0
  802f2a:	e8 2e f2 ff ff       	call   80215d <sys_page_alloc>
  802f2f:	89 c3                	mov    %eax,%ebx
  802f31:	83 c4 10             	add    $0x10,%esp
  802f34:	85 c0                	test   %eax,%eax
  802f36:	0f 88 89 00 00 00    	js     802fc5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f3c:	83 ec 0c             	sub    $0xc,%esp
  802f3f:	ff 75 f0             	pushl  -0x10(%ebp)
  802f42:	e8 76 f5 ff ff       	call   8024bd <fd2data>
  802f47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802f4e:	50                   	push   %eax
  802f4f:	6a 00                	push   $0x0
  802f51:	56                   	push   %esi
  802f52:	6a 00                	push   $0x0
  802f54:	e8 47 f2 ff ff       	call   8021a0 <sys_page_map>
  802f59:	89 c3                	mov    %eax,%ebx
  802f5b:	83 c4 20             	add    $0x20,%esp
  802f5e:	85 c0                	test   %eax,%eax
  802f60:	78 55                	js     802fb7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802f62:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f6b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f70:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802f77:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f80:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802f8c:	83 ec 0c             	sub    $0xc,%esp
  802f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  802f92:	e8 16 f5 ff ff       	call   8024ad <fd2num>
  802f97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802f9c:	83 c4 04             	add    $0x4,%esp
  802f9f:	ff 75 f0             	pushl  -0x10(%ebp)
  802fa2:	e8 06 f5 ff ff       	call   8024ad <fd2num>
  802fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802faa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802fad:	83 c4 10             	add    $0x10,%esp
  802fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  802fb5:	eb 30                	jmp    802fe7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802fb7:	83 ec 08             	sub    $0x8,%esp
  802fba:	56                   	push   %esi
  802fbb:	6a 00                	push   $0x0
  802fbd:	e8 20 f2 ff ff       	call   8021e2 <sys_page_unmap>
  802fc2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802fc5:	83 ec 08             	sub    $0x8,%esp
  802fc8:	ff 75 f0             	pushl  -0x10(%ebp)
  802fcb:	6a 00                	push   $0x0
  802fcd:	e8 10 f2 ff ff       	call   8021e2 <sys_page_unmap>
  802fd2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802fd5:	83 ec 08             	sub    $0x8,%esp
  802fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  802fdb:	6a 00                	push   $0x0
  802fdd:	e8 00 f2 ff ff       	call   8021e2 <sys_page_unmap>
  802fe2:	83 c4 10             	add    $0x10,%esp
  802fe5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802fe7:	89 d0                	mov    %edx,%eax
  802fe9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fec:	5b                   	pop    %ebx
  802fed:	5e                   	pop    %esi
  802fee:	5d                   	pop    %ebp
  802fef:	c3                   	ret    

00802ff0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802ff0:	55                   	push   %ebp
  802ff1:	89 e5                	mov    %esp,%ebp
  802ff3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ff9:	50                   	push   %eax
  802ffa:	ff 75 08             	pushl  0x8(%ebp)
  802ffd:	e8 21 f5 ff ff       	call   802523 <fd_lookup>
  803002:	83 c4 10             	add    $0x10,%esp
  803005:	85 c0                	test   %eax,%eax
  803007:	78 18                	js     803021 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803009:	83 ec 0c             	sub    $0xc,%esp
  80300c:	ff 75 f4             	pushl  -0xc(%ebp)
  80300f:	e8 a9 f4 ff ff       	call   8024bd <fd2data>
	return _pipeisclosed(fd, p);
  803014:	89 c2                	mov    %eax,%edx
  803016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803019:	e8 21 fd ff ff       	call   802d3f <_pipeisclosed>
  80301e:	83 c4 10             	add    $0x10,%esp
}
  803021:	c9                   	leave  
  803022:	c3                   	ret    

00803023 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803023:	55                   	push   %ebp
  803024:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803026:	b8 00 00 00 00       	mov    $0x0,%eax
  80302b:	5d                   	pop    %ebp
  80302c:	c3                   	ret    

0080302d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80302d:	55                   	push   %ebp
  80302e:	89 e5                	mov    %esp,%ebp
  803030:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803033:	68 8f 3e 80 00       	push   $0x803e8f
  803038:	ff 75 0c             	pushl  0xc(%ebp)
  80303b:	e8 1a ed ff ff       	call   801d5a <strcpy>
	return 0;
}
  803040:	b8 00 00 00 00       	mov    $0x0,%eax
  803045:	c9                   	leave  
  803046:	c3                   	ret    

00803047 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803047:	55                   	push   %ebp
  803048:	89 e5                	mov    %esp,%ebp
  80304a:	57                   	push   %edi
  80304b:	56                   	push   %esi
  80304c:	53                   	push   %ebx
  80304d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803053:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803058:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80305e:	eb 2d                	jmp    80308d <devcons_write+0x46>
		m = n - tot;
  803060:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803063:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803065:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803068:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80306d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803070:	83 ec 04             	sub    $0x4,%esp
  803073:	53                   	push   %ebx
  803074:	03 45 0c             	add    0xc(%ebp),%eax
  803077:	50                   	push   %eax
  803078:	57                   	push   %edi
  803079:	e8 6e ee ff ff       	call   801eec <memmove>
		sys_cputs(buf, m);
  80307e:	83 c4 08             	add    $0x8,%esp
  803081:	53                   	push   %ebx
  803082:	57                   	push   %edi
  803083:	e8 19 f0 ff ff       	call   8020a1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803088:	01 de                	add    %ebx,%esi
  80308a:	83 c4 10             	add    $0x10,%esp
  80308d:	89 f0                	mov    %esi,%eax
  80308f:	3b 75 10             	cmp    0x10(%ebp),%esi
  803092:	72 cc                	jb     803060 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803097:	5b                   	pop    %ebx
  803098:	5e                   	pop    %esi
  803099:	5f                   	pop    %edi
  80309a:	5d                   	pop    %ebp
  80309b:	c3                   	ret    

0080309c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80309c:	55                   	push   %ebp
  80309d:	89 e5                	mov    %esp,%ebp
  80309f:	83 ec 08             	sub    $0x8,%esp
  8030a2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8030a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8030ab:	74 2a                	je     8030d7 <devcons_read+0x3b>
  8030ad:	eb 05                	jmp    8030b4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8030af:	e8 8a f0 ff ff       	call   80213e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8030b4:	e8 06 f0 ff ff       	call   8020bf <sys_cgetc>
  8030b9:	85 c0                	test   %eax,%eax
  8030bb:	74 f2                	je     8030af <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8030bd:	85 c0                	test   %eax,%eax
  8030bf:	78 16                	js     8030d7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8030c1:	83 f8 04             	cmp    $0x4,%eax
  8030c4:	74 0c                	je     8030d2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8030c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030c9:	88 02                	mov    %al,(%edx)
	return 1;
  8030cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8030d0:	eb 05                	jmp    8030d7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8030d2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8030d7:	c9                   	leave  
  8030d8:	c3                   	ret    

008030d9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8030d9:	55                   	push   %ebp
  8030da:	89 e5                	mov    %esp,%ebp
  8030dc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8030df:	8b 45 08             	mov    0x8(%ebp),%eax
  8030e2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8030e5:	6a 01                	push   $0x1
  8030e7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8030ea:	50                   	push   %eax
  8030eb:	e8 b1 ef ff ff       	call   8020a1 <sys_cputs>
}
  8030f0:	83 c4 10             	add    $0x10,%esp
  8030f3:	c9                   	leave  
  8030f4:	c3                   	ret    

008030f5 <getchar>:

int
getchar(void)
{
  8030f5:	55                   	push   %ebp
  8030f6:	89 e5                	mov    %esp,%ebp
  8030f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8030fb:	6a 01                	push   $0x1
  8030fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803100:	50                   	push   %eax
  803101:	6a 00                	push   $0x0
  803103:	e8 81 f6 ff ff       	call   802789 <read>
	if (r < 0)
  803108:	83 c4 10             	add    $0x10,%esp
  80310b:	85 c0                	test   %eax,%eax
  80310d:	78 0f                	js     80311e <getchar+0x29>
		return r;
	if (r < 1)
  80310f:	85 c0                	test   %eax,%eax
  803111:	7e 06                	jle    803119 <getchar+0x24>
		return -E_EOF;
	return c;
  803113:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803117:	eb 05                	jmp    80311e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803119:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80311e:	c9                   	leave  
  80311f:	c3                   	ret    

00803120 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803120:	55                   	push   %ebp
  803121:	89 e5                	mov    %esp,%ebp
  803123:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803129:	50                   	push   %eax
  80312a:	ff 75 08             	pushl  0x8(%ebp)
  80312d:	e8 f1 f3 ff ff       	call   802523 <fd_lookup>
  803132:	83 c4 10             	add    $0x10,%esp
  803135:	85 c0                	test   %eax,%eax
  803137:	78 11                	js     80314a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80313c:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  803142:	39 10                	cmp    %edx,(%eax)
  803144:	0f 94 c0             	sete   %al
  803147:	0f b6 c0             	movzbl %al,%eax
}
  80314a:	c9                   	leave  
  80314b:	c3                   	ret    

0080314c <opencons>:

int
opencons(void)
{
  80314c:	55                   	push   %ebp
  80314d:	89 e5                	mov    %esp,%ebp
  80314f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803155:	50                   	push   %eax
  803156:	e8 79 f3 ff ff       	call   8024d4 <fd_alloc>
  80315b:	83 c4 10             	add    $0x10,%esp
		return r;
  80315e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803160:	85 c0                	test   %eax,%eax
  803162:	78 3e                	js     8031a2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803164:	83 ec 04             	sub    $0x4,%esp
  803167:	68 07 04 00 00       	push   $0x407
  80316c:	ff 75 f4             	pushl  -0xc(%ebp)
  80316f:	6a 00                	push   $0x0
  803171:	e8 e7 ef ff ff       	call   80215d <sys_page_alloc>
  803176:	83 c4 10             	add    $0x10,%esp
		return r;
  803179:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80317b:	85 c0                	test   %eax,%eax
  80317d:	78 23                	js     8031a2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80317f:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  803185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803188:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80318a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80318d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803194:	83 ec 0c             	sub    $0xc,%esp
  803197:	50                   	push   %eax
  803198:	e8 10 f3 ff ff       	call   8024ad <fd2num>
  80319d:	89 c2                	mov    %eax,%edx
  80319f:	83 c4 10             	add    $0x10,%esp
}
  8031a2:	89 d0                	mov    %edx,%eax
  8031a4:	c9                   	leave  
  8031a5:	c3                   	ret    
  8031a6:	66 90                	xchg   %ax,%ax
  8031a8:	66 90                	xchg   %ax,%ax
  8031aa:	66 90                	xchg   %ax,%ax
  8031ac:	66 90                	xchg   %ax,%ax
  8031ae:	66 90                	xchg   %ax,%ax

008031b0 <__udivdi3>:
  8031b0:	55                   	push   %ebp
  8031b1:	57                   	push   %edi
  8031b2:	56                   	push   %esi
  8031b3:	53                   	push   %ebx
  8031b4:	83 ec 1c             	sub    $0x1c,%esp
  8031b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8031bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8031bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8031c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031c7:	85 f6                	test   %esi,%esi
  8031c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031cd:	89 ca                	mov    %ecx,%edx
  8031cf:	89 f8                	mov    %edi,%eax
  8031d1:	75 3d                	jne    803210 <__udivdi3+0x60>
  8031d3:	39 cf                	cmp    %ecx,%edi
  8031d5:	0f 87 c5 00 00 00    	ja     8032a0 <__udivdi3+0xf0>
  8031db:	85 ff                	test   %edi,%edi
  8031dd:	89 fd                	mov    %edi,%ebp
  8031df:	75 0b                	jne    8031ec <__udivdi3+0x3c>
  8031e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8031e6:	31 d2                	xor    %edx,%edx
  8031e8:	f7 f7                	div    %edi
  8031ea:	89 c5                	mov    %eax,%ebp
  8031ec:	89 c8                	mov    %ecx,%eax
  8031ee:	31 d2                	xor    %edx,%edx
  8031f0:	f7 f5                	div    %ebp
  8031f2:	89 c1                	mov    %eax,%ecx
  8031f4:	89 d8                	mov    %ebx,%eax
  8031f6:	89 cf                	mov    %ecx,%edi
  8031f8:	f7 f5                	div    %ebp
  8031fa:	89 c3                	mov    %eax,%ebx
  8031fc:	89 d8                	mov    %ebx,%eax
  8031fe:	89 fa                	mov    %edi,%edx
  803200:	83 c4 1c             	add    $0x1c,%esp
  803203:	5b                   	pop    %ebx
  803204:	5e                   	pop    %esi
  803205:	5f                   	pop    %edi
  803206:	5d                   	pop    %ebp
  803207:	c3                   	ret    
  803208:	90                   	nop
  803209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803210:	39 ce                	cmp    %ecx,%esi
  803212:	77 74                	ja     803288 <__udivdi3+0xd8>
  803214:	0f bd fe             	bsr    %esi,%edi
  803217:	83 f7 1f             	xor    $0x1f,%edi
  80321a:	0f 84 98 00 00 00    	je     8032b8 <__udivdi3+0x108>
  803220:	bb 20 00 00 00       	mov    $0x20,%ebx
  803225:	89 f9                	mov    %edi,%ecx
  803227:	89 c5                	mov    %eax,%ebp
  803229:	29 fb                	sub    %edi,%ebx
  80322b:	d3 e6                	shl    %cl,%esi
  80322d:	89 d9                	mov    %ebx,%ecx
  80322f:	d3 ed                	shr    %cl,%ebp
  803231:	89 f9                	mov    %edi,%ecx
  803233:	d3 e0                	shl    %cl,%eax
  803235:	09 ee                	or     %ebp,%esi
  803237:	89 d9                	mov    %ebx,%ecx
  803239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80323d:	89 d5                	mov    %edx,%ebp
  80323f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803243:	d3 ed                	shr    %cl,%ebp
  803245:	89 f9                	mov    %edi,%ecx
  803247:	d3 e2                	shl    %cl,%edx
  803249:	89 d9                	mov    %ebx,%ecx
  80324b:	d3 e8                	shr    %cl,%eax
  80324d:	09 c2                	or     %eax,%edx
  80324f:	89 d0                	mov    %edx,%eax
  803251:	89 ea                	mov    %ebp,%edx
  803253:	f7 f6                	div    %esi
  803255:	89 d5                	mov    %edx,%ebp
  803257:	89 c3                	mov    %eax,%ebx
  803259:	f7 64 24 0c          	mull   0xc(%esp)
  80325d:	39 d5                	cmp    %edx,%ebp
  80325f:	72 10                	jb     803271 <__udivdi3+0xc1>
  803261:	8b 74 24 08          	mov    0x8(%esp),%esi
  803265:	89 f9                	mov    %edi,%ecx
  803267:	d3 e6                	shl    %cl,%esi
  803269:	39 c6                	cmp    %eax,%esi
  80326b:	73 07                	jae    803274 <__udivdi3+0xc4>
  80326d:	39 d5                	cmp    %edx,%ebp
  80326f:	75 03                	jne    803274 <__udivdi3+0xc4>
  803271:	83 eb 01             	sub    $0x1,%ebx
  803274:	31 ff                	xor    %edi,%edi
  803276:	89 d8                	mov    %ebx,%eax
  803278:	89 fa                	mov    %edi,%edx
  80327a:	83 c4 1c             	add    $0x1c,%esp
  80327d:	5b                   	pop    %ebx
  80327e:	5e                   	pop    %esi
  80327f:	5f                   	pop    %edi
  803280:	5d                   	pop    %ebp
  803281:	c3                   	ret    
  803282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803288:	31 ff                	xor    %edi,%edi
  80328a:	31 db                	xor    %ebx,%ebx
  80328c:	89 d8                	mov    %ebx,%eax
  80328e:	89 fa                	mov    %edi,%edx
  803290:	83 c4 1c             	add    $0x1c,%esp
  803293:	5b                   	pop    %ebx
  803294:	5e                   	pop    %esi
  803295:	5f                   	pop    %edi
  803296:	5d                   	pop    %ebp
  803297:	c3                   	ret    
  803298:	90                   	nop
  803299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8032a0:	89 d8                	mov    %ebx,%eax
  8032a2:	f7 f7                	div    %edi
  8032a4:	31 ff                	xor    %edi,%edi
  8032a6:	89 c3                	mov    %eax,%ebx
  8032a8:	89 d8                	mov    %ebx,%eax
  8032aa:	89 fa                	mov    %edi,%edx
  8032ac:	83 c4 1c             	add    $0x1c,%esp
  8032af:	5b                   	pop    %ebx
  8032b0:	5e                   	pop    %esi
  8032b1:	5f                   	pop    %edi
  8032b2:	5d                   	pop    %ebp
  8032b3:	c3                   	ret    
  8032b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8032b8:	39 ce                	cmp    %ecx,%esi
  8032ba:	72 0c                	jb     8032c8 <__udivdi3+0x118>
  8032bc:	31 db                	xor    %ebx,%ebx
  8032be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8032c2:	0f 87 34 ff ff ff    	ja     8031fc <__udivdi3+0x4c>
  8032c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8032cd:	e9 2a ff ff ff       	jmp    8031fc <__udivdi3+0x4c>
  8032d2:	66 90                	xchg   %ax,%ax
  8032d4:	66 90                	xchg   %ax,%ax
  8032d6:	66 90                	xchg   %ax,%ax
  8032d8:	66 90                	xchg   %ax,%ax
  8032da:	66 90                	xchg   %ax,%ax
  8032dc:	66 90                	xchg   %ax,%ax
  8032de:	66 90                	xchg   %ax,%ax

008032e0 <__umoddi3>:
  8032e0:	55                   	push   %ebp
  8032e1:	57                   	push   %edi
  8032e2:	56                   	push   %esi
  8032e3:	53                   	push   %ebx
  8032e4:	83 ec 1c             	sub    $0x1c,%esp
  8032e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8032eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8032ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8032f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8032f7:	85 d2                	test   %edx,%edx
  8032f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8032fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803301:	89 f3                	mov    %esi,%ebx
  803303:	89 3c 24             	mov    %edi,(%esp)
  803306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80330a:	75 1c                	jne    803328 <__umoddi3+0x48>
  80330c:	39 f7                	cmp    %esi,%edi
  80330e:	76 50                	jbe    803360 <__umoddi3+0x80>
  803310:	89 c8                	mov    %ecx,%eax
  803312:	89 f2                	mov    %esi,%edx
  803314:	f7 f7                	div    %edi
  803316:	89 d0                	mov    %edx,%eax
  803318:	31 d2                	xor    %edx,%edx
  80331a:	83 c4 1c             	add    $0x1c,%esp
  80331d:	5b                   	pop    %ebx
  80331e:	5e                   	pop    %esi
  80331f:	5f                   	pop    %edi
  803320:	5d                   	pop    %ebp
  803321:	c3                   	ret    
  803322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803328:	39 f2                	cmp    %esi,%edx
  80332a:	89 d0                	mov    %edx,%eax
  80332c:	77 52                	ja     803380 <__umoddi3+0xa0>
  80332e:	0f bd ea             	bsr    %edx,%ebp
  803331:	83 f5 1f             	xor    $0x1f,%ebp
  803334:	75 5a                	jne    803390 <__umoddi3+0xb0>
  803336:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80333a:	0f 82 e0 00 00 00    	jb     803420 <__umoddi3+0x140>
  803340:	39 0c 24             	cmp    %ecx,(%esp)
  803343:	0f 86 d7 00 00 00    	jbe    803420 <__umoddi3+0x140>
  803349:	8b 44 24 08          	mov    0x8(%esp),%eax
  80334d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803351:	83 c4 1c             	add    $0x1c,%esp
  803354:	5b                   	pop    %ebx
  803355:	5e                   	pop    %esi
  803356:	5f                   	pop    %edi
  803357:	5d                   	pop    %ebp
  803358:	c3                   	ret    
  803359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803360:	85 ff                	test   %edi,%edi
  803362:	89 fd                	mov    %edi,%ebp
  803364:	75 0b                	jne    803371 <__umoddi3+0x91>
  803366:	b8 01 00 00 00       	mov    $0x1,%eax
  80336b:	31 d2                	xor    %edx,%edx
  80336d:	f7 f7                	div    %edi
  80336f:	89 c5                	mov    %eax,%ebp
  803371:	89 f0                	mov    %esi,%eax
  803373:	31 d2                	xor    %edx,%edx
  803375:	f7 f5                	div    %ebp
  803377:	89 c8                	mov    %ecx,%eax
  803379:	f7 f5                	div    %ebp
  80337b:	89 d0                	mov    %edx,%eax
  80337d:	eb 99                	jmp    803318 <__umoddi3+0x38>
  80337f:	90                   	nop
  803380:	89 c8                	mov    %ecx,%eax
  803382:	89 f2                	mov    %esi,%edx
  803384:	83 c4 1c             	add    $0x1c,%esp
  803387:	5b                   	pop    %ebx
  803388:	5e                   	pop    %esi
  803389:	5f                   	pop    %edi
  80338a:	5d                   	pop    %ebp
  80338b:	c3                   	ret    
  80338c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803390:	8b 34 24             	mov    (%esp),%esi
  803393:	bf 20 00 00 00       	mov    $0x20,%edi
  803398:	89 e9                	mov    %ebp,%ecx
  80339a:	29 ef                	sub    %ebp,%edi
  80339c:	d3 e0                	shl    %cl,%eax
  80339e:	89 f9                	mov    %edi,%ecx
  8033a0:	89 f2                	mov    %esi,%edx
  8033a2:	d3 ea                	shr    %cl,%edx
  8033a4:	89 e9                	mov    %ebp,%ecx
  8033a6:	09 c2                	or     %eax,%edx
  8033a8:	89 d8                	mov    %ebx,%eax
  8033aa:	89 14 24             	mov    %edx,(%esp)
  8033ad:	89 f2                	mov    %esi,%edx
  8033af:	d3 e2                	shl    %cl,%edx
  8033b1:	89 f9                	mov    %edi,%ecx
  8033b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8033b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8033bb:	d3 e8                	shr    %cl,%eax
  8033bd:	89 e9                	mov    %ebp,%ecx
  8033bf:	89 c6                	mov    %eax,%esi
  8033c1:	d3 e3                	shl    %cl,%ebx
  8033c3:	89 f9                	mov    %edi,%ecx
  8033c5:	89 d0                	mov    %edx,%eax
  8033c7:	d3 e8                	shr    %cl,%eax
  8033c9:	89 e9                	mov    %ebp,%ecx
  8033cb:	09 d8                	or     %ebx,%eax
  8033cd:	89 d3                	mov    %edx,%ebx
  8033cf:	89 f2                	mov    %esi,%edx
  8033d1:	f7 34 24             	divl   (%esp)
  8033d4:	89 d6                	mov    %edx,%esi
  8033d6:	d3 e3                	shl    %cl,%ebx
  8033d8:	f7 64 24 04          	mull   0x4(%esp)
  8033dc:	39 d6                	cmp    %edx,%esi
  8033de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8033e2:	89 d1                	mov    %edx,%ecx
  8033e4:	89 c3                	mov    %eax,%ebx
  8033e6:	72 08                	jb     8033f0 <__umoddi3+0x110>
  8033e8:	75 11                	jne    8033fb <__umoddi3+0x11b>
  8033ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8033ee:	73 0b                	jae    8033fb <__umoddi3+0x11b>
  8033f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8033f4:	1b 14 24             	sbb    (%esp),%edx
  8033f7:	89 d1                	mov    %edx,%ecx
  8033f9:	89 c3                	mov    %eax,%ebx
  8033fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8033ff:	29 da                	sub    %ebx,%edx
  803401:	19 ce                	sbb    %ecx,%esi
  803403:	89 f9                	mov    %edi,%ecx
  803405:	89 f0                	mov    %esi,%eax
  803407:	d3 e0                	shl    %cl,%eax
  803409:	89 e9                	mov    %ebp,%ecx
  80340b:	d3 ea                	shr    %cl,%edx
  80340d:	89 e9                	mov    %ebp,%ecx
  80340f:	d3 ee                	shr    %cl,%esi
  803411:	09 d0                	or     %edx,%eax
  803413:	89 f2                	mov    %esi,%edx
  803415:	83 c4 1c             	add    $0x1c,%esp
  803418:	5b                   	pop    %ebx
  803419:	5e                   	pop    %esi
  80341a:	5f                   	pop    %edi
  80341b:	5d                   	pop    %ebp
  80341c:	c3                   	ret    
  80341d:	8d 76 00             	lea    0x0(%esi),%esi
  803420:	29 f9                	sub    %edi,%ecx
  803422:	19 d6                	sbb    %edx,%esi
  803424:	89 74 24 04          	mov    %esi,0x4(%esp)
  803428:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80342c:	e9 18 ff ff ff       	jmp    803349 <__umoddi3+0x69>
