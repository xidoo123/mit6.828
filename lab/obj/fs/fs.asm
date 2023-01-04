
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
  80002c:	e8 a7 1a 00 00       	call   801ad8 <libmain>
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
  8000b2:	68 a0 38 80 00       	push   $0x8038a0
  8000b7:	e8 55 1b 00 00       	call   801c11 <cprintf>
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
  8000d4:	68 b7 38 80 00       	push   $0x8038b7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 c7 38 80 00       	push   $0x8038c7
  8000e0:	e8 53 1a 00 00       	call   801b38 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
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
  800106:	68 d0 38 80 00       	push   $0x8038d0
  80010b:	68 dd 38 80 00       	push   $0x8038dd
  800110:	6a 44                	push   $0x44
  800112:	68 c7 38 80 00       	push   $0x8038c7
  800117:	e8 1c 1a 00 00       	call   801b38 <_panic>

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
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
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
  8001ca:	68 d0 38 80 00       	push   $0x8038d0
  8001cf:	68 dd 38 80 00       	push   $0x8038dd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 c7 38 80 00       	push   $0x8038c7
  8001db:	e8 58 19 00 00       	call   801b38 <_panic>

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
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
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
  80029e:	68 f4 38 80 00       	push   $0x8038f4
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 d0 39 80 00       	push   $0x8039d0
  8002aa:	e8 89 18 00 00       	call   801b38 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 24 39 80 00       	push   $0x803924
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 d0 39 80 00       	push   $0x8039d0
  8002ca:	e8 69 18 00 00       	call   801b38 <_panic>
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
  8002df:	e8 b5 22 00 00       	call   802599 <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 48 39 80 00       	push   $0x803948
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 d0 39 80 00       	push   $0x8039d0
  8002f8:	e8 3b 18 00 00       	call   801b38 <_panic>

	r =	ide_read(blockno * (BLKSIZE / SECTSIZE), base_addr, (BLKSIZE / SECTSIZE));
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
  800318:	68 d8 39 80 00       	push   $0x8039d8
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 d0 39 80 00       	push   $0x8039d0
  800324:	e8 0f 18 00 00       	call   801b38 <_panic>

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
  800344:	e8 93 22 00 00       	call   8025dc <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 68 39 80 00       	push   $0x803968
  800356:	6a 41                	push   $0x41
  800358:	68 d0 39 80 00       	push   $0x8039d0
  80035d:	e8 d6 17 00 00       	call   801b38 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800362:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800369:	74 22                	je     80038d <bc_pgfault+0x119>
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	56                   	push   %esi
  80036f:	e8 94 04 00 00       	call   800808 <block_is_free>
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	84 c0                	test   %al,%al
  800379:	74 12                	je     80038d <bc_pgfault+0x119>
		panic("reading free block %08x\n", blockno);
  80037b:	56                   	push   %esi
  80037c:	68 f1 39 80 00       	push   $0x8039f1
  800381:	6a 47                	push   $0x47
  800383:	68 d0 39 80 00       	push   $0x8039d0
  800388:	e8 ab 17 00 00       	call   801b38 <_panic>
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
  8003a2:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 17                	je     8003c3 <diskaddr+0x2e>
  8003ac:	3b 42 04             	cmp    0x4(%edx),%eax
  8003af:	72 12                	jb     8003c3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003b1:	50                   	push   %eax
  8003b2:	68 88 39 80 00       	push   $0x803988
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 d0 39 80 00       	push   $0x8039d0
  8003be:	e8 75 17 00 00       	call   801b38 <_panic>
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
  800429:	68 0a 3a 80 00       	push   $0x803a0a
  80042e:	6a 57                	push   $0x57
  800430:	68 d0 39 80 00       	push   $0x8039d0
  800435:	e8 fe 16 00 00       	call   801b38 <_panic>

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
  800486:	68 25 3a 80 00       	push   $0x803a25
  80048b:	6a 63                	push   $0x63
  80048d:	68 d0 39 80 00       	push   $0x8039d0
  800492:	e8 a1 16 00 00       	call   801b38 <_panic>

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
  8004b0:	e8 27 21 00 00       	call   8025dc <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 40 3a 80 00       	push   $0x803a40
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 d0 39 80 00       	push   $0x8039d0
  8004c9:	e8 6a 16 00 00       	call   801b38 <_panic>

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
  8004e4:	e8 a1 22 00 00       	call   80278a <set_pgfault_handler>
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
  800505:	e8 1e 1e 00 00       	call   802328 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 5e 3a 80 00       	push   $0x803a5e
  80051e:	50                   	push   %eax
  80051f:	e8 72 1c 00 00       	call   802196 <strcpy>
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
  800553:	68 80 3a 80 00       	push   $0x803a80
  800558:	68 dd 38 80 00       	push   $0x8038dd
  80055d:	6a 78                	push   $0x78
  80055f:	68 d0 39 80 00       	push   $0x8039d0
  800564:	e8 cf 15 00 00       	call   801b38 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 65 3a 80 00       	push   $0x803a65
  800587:	68 dd 38 80 00       	push   $0x8038dd
  80058c:	6a 79                	push   $0x79
  80058e:	68 d0 39 80 00       	push   $0x8039d0
  800593:	e8 a0 15 00 00       	call   801b38 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 71 20 00 00       	call   80261e <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 7f 3a 80 00       	push   $0x803a7f
  8005cd:	68 dd 38 80 00       	push   $0x8038dd
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 d0 39 80 00       	push   $0x8039d0
  8005d9:	e8 5a 15 00 00       	call   801b38 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 5e 3a 80 00       	push   $0x803a5e
  8005f0:	50                   	push   %eax
  8005f1:	e8 4a 1c 00 00       	call   802240 <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 ac 39 80 00       	push   $0x8039ac
  800602:	68 dd 38 80 00       	push   $0x8038dd
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 d0 39 80 00       	push   $0x8039d0
  800611:	e8 22 15 00 00       	call   801b38 <_panic>

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
  800630:	e8 f3 1c 00 00       	call   802328 <memmove>
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
  80065f:	e8 c4 1c 00 00       	call   802328 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 5e 3a 80 00       	push   $0x803a5e
  800678:	50                   	push   %eax
  800679:	e8 18 1b 00 00       	call   802196 <strcpy>

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
  8006b0:	68 80 3a 80 00       	push   $0x803a80
  8006b5:	68 dd 38 80 00       	push   $0x8038dd
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 d0 39 80 00       	push   $0x8039d0
  8006c4:	e8 6f 14 00 00       	call   801b38 <_panic>
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
  8006d9:	e8 40 1f 00 00       	call   80261e <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 7f 3a 80 00       	push   $0x803a7f
  8006fe:	68 dd 38 80 00       	push   $0x8038dd
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 d0 39 80 00       	push   $0x8039d0
  80070d:	e8 26 14 00 00       	call   801b38 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 5e 3a 80 00       	push   $0x803a5e
  800724:	50                   	push   %eax
  800725:	e8 16 1b 00 00       	call   802240 <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 ac 39 80 00       	push   $0x8039ac
  800736:	68 dd 38 80 00       	push   $0x8038dd
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 d0 39 80 00       	push   $0x8039d0
  800745:	e8 ee 13 00 00       	call   801b38 <_panic>

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
  800764:	e8 bf 1b 00 00       	call   802328 <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 9a 3a 80 00 	movl   $0x803a9a,(%esp)
  800784:	e8 88 14 00 00       	call   801c11 <cprintf>
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
  8007a5:	e8 7e 1b 00 00       	call   802328 <memmove>
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007b8:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007bd:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007c3:	74 14                	je     8007d9 <check_super+0x27>
		panic("bad file system magic number");
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	68 af 3a 80 00       	push   $0x803aaf
  8007cd:	6a 0f                	push   $0xf
  8007cf:	68 cc 3a 80 00       	push   $0x803acc
  8007d4:	e8 5f 13 00 00       	call   801b38 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007d9:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e0:	76 14                	jbe    8007f6 <check_super+0x44>
		panic("file system is too large");
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	68 d4 3a 80 00       	push   $0x803ad4
  8007ea:	6a 12                	push   $0x12
  8007ec:	68 cc 3a 80 00       	push   $0x803acc
  8007f1:	e8 42 13 00 00       	call   801b38 <_panic>

	cprintf("superblock is good\n");
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	68 ed 3a 80 00       	push   $0x803aed
  8007fe:	e8 0e 14 00 00       	call   801c11 <cprintf>
}
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80080f:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 24                	je     80083d <block_is_free+0x35>
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80081e:	39 4a 04             	cmp    %ecx,0x4(%edx)
  800821:	76 1f                	jbe    800842 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800823:	89 cb                	mov    %ecx,%ebx
  800825:	c1 eb 05             	shr    $0x5,%ebx
  800828:	b8 01 00 00 00       	mov    $0x1,%eax
  80082d:	d3 e0                	shl    %cl,%eax
  80082f:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800835:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800838:	0f 95 c0             	setne  %al
  80083b:	eb 05                	jmp    800842 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	83 ec 04             	sub    $0x4,%esp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	75 14                	jne    800867 <free_block+0x22>
		panic("attempt to free zero block");
  800853:	83 ec 04             	sub    $0x4,%esp
  800856:	68 01 3b 80 00       	push   $0x803b01
  80085b:	6a 2d                	push   $0x2d
  80085d:	68 cc 3a 80 00       	push   $0x803acc
  800862:	e8 d1 12 00 00       	call   801b38 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800867:	89 cb                	mov    %ecx,%ebx
  800869:	c1 eb 05             	shr    $0x5,%ebx
  80086c:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800872:	b8 01 00 00 00       	mov    $0x1,%eax
  800877:	d3 e0                	shl    %cl,%eax
  800879:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80087c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  800886:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80088b:	8b 70 04             	mov    0x4(%eax),%esi
  80088e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800893:	eb 55                	jmp    8008ea <alloc_block+0x69>
		
		// find a free block
		if (block_is_free(i)) {
  800895:	53                   	push   %ebx
  800896:	e8 6d ff ff ff       	call   800808 <block_is_free>
  80089b:	83 c4 04             	add    $0x4,%esp
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 45                	je     8008e7 <alloc_block+0x66>

			// mark as used in bitmap
			bitmap[i/32] ^= (1<<(i%32));
  8008a2:	8d 43 1f             	lea    0x1f(%ebx),%eax
  8008a5:	85 db                	test   %ebx,%ebx
  8008a7:	0f 49 c3             	cmovns %ebx,%eax
  8008aa:	c1 f8 05             	sar    $0x5,%eax
  8008ad:	c1 e0 02             	shl    $0x2,%eax
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	03 15 04 a0 80 00    	add    0x80a004,%edx
  8008b8:	89 de                	mov    %ebx,%esi
  8008ba:	c1 fe 1f             	sar    $0x1f,%esi
  8008bd:	c1 ee 1b             	shr    $0x1b,%esi
  8008c0:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  8008c3:	83 e1 1f             	and    $0x1f,%ecx
  8008c6:	29 f1                	sub    %esi,%ecx
  8008c8:	be 01 00 00 00       	mov    $0x1,%esi
  8008cd:	d3 e6                	shl    %cl,%esi
  8008cf:	31 32                	xor    %esi,(%edx)
	
			// flush to disk
			flush_block(&bitmap[i/32]);
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8008da:	50                   	push   %eax
  8008db:	e8 33 fb ff ff       	call   800413 <flush_block>

			return i;
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	89 d8                	mov    %ebx,%eax
  8008e5:	eb 0c                	jmp    8008f3 <alloc_block+0x72>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// panic("alloc_block not implemented");

	for (int i=1; i<super->s_nblocks; i++) {
  8008e7:	83 c3 01             	add    $0x1,%ebx
  8008ea:	39 de                	cmp    %ebx,%esi
  8008ec:	77 a7                	ja     800895 <alloc_block+0x14>

			return i;
		}
	}

	return -E_NO_DISK;
  8008ee:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	83 ec 1c             	sub    $0x1c,%esp
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
  800906:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80090c:	0f 87 ca 00 00 00    	ja     8009dc <file_block_walk+0xe2>
		return -E_INVAL;

	// direct block
	if (filebno < NDIRECT) {
  800912:	83 fa 09             	cmp    $0x9,%edx
  800915:	77 1b                	ja     800932 <file_block_walk+0x38>
		if (ppdiskbno != 0)
  800917:	85 c9                	test   %ecx,%ecx
  800919:	0f 84 c4 00 00 00    	je     8009e3 <file_block_walk+0xe9>
			*ppdiskbno = &f->f_direct[filebno];
  80091f:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  800926:	89 01                	mov    %eax,(%ecx)
		
		// cprintf("[?] 0x%x, 0x%x -->\n", *ppdiskbno, **ppdiskbno);
		return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	e9 bd 00 00 00       	jmp    8009ef <file_block_walk+0xf5>
  800932:	89 cb                	mov    %ecx,%ebx
  800934:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800937:	89 c6                	mov    %eax,%esi
	}

	// indirect block, allocated
	if (f->f_indirect != 0) {
  800939:	8b 90 b0 00 00 00    	mov    0xb0(%eax),%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 2c                	je     80096f <file_block_walk+0x75>
		if (ppdiskbno != 0)
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
		// cprintf("[?] 0x%x, 0x%x, 0x%x, 0x%x -->\n", f->f_indirect, filebno - NDIRECT, *ppdiskbno, **ppdiskbno);
		return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}

	// indirect block, allocated
	if (f->f_indirect != 0) {
		if (ppdiskbno != 0)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	0f 84 9f 00 00 00    	je     8009ef <file_block_walk+0xf5>
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
  800950:	83 ec 0c             	sub    $0xc,%esp
  800953:	52                   	push   %edx
  800954:	e8 3c fa ff ff       	call   800395 <diskaddr>
  800959:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80095c:	8d 44 b0 d8          	lea    -0x28(%eax,%esi,4),%eax
  800960:	89 03                	mov    %eax,(%ebx)
  800962:	83 c4 10             	add    $0x10,%esp
		// cprintf("[?] 0x%x, 0x%x, 0x%x, 0x%x -->\n", f->f_indirect, filebno - NDIRECT, *ppdiskbno, **ppdiskbno);
		return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
  80096a:	e9 80 00 00 00       	jmp    8009ef <file_block_walk+0xf5>
	}
	else {

		// not allocated
		if (alloc == 0)
  80096f:	89 f8                	mov    %edi,%eax
  800971:	84 c0                	test   %al,%al
  800973:	74 75                	je     8009ea <file_block_walk+0xf0>
			return -E_NOT_FOUND;
		
		int blockno = alloc_block();
  800975:	e8 07 ff ff ff       	call   800881 <alloc_block>
  80097a:	89 c7                	mov    %eax,%edi

		if (blockno < 0)
  80097c:	85 c0                	test   %eax,%eax
  80097e:	78 6f                	js     8009ef <file_block_walk+0xf5>
			return blockno; // E_NO_DISK

		// cprintf("[?] %d\n", blockno);
		
		f->f_indirect = blockno;
  800980:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
  800986:	83 ec 0c             	sub    $0xc,%esp
  800989:	50                   	push   %eax
  80098a:	e8 06 fa ff ff       	call   800395 <diskaddr>
  80098f:	83 c4 0c             	add    $0xc,%esp
  800992:	68 00 10 00 00       	push   $0x1000
  800997:	6a 00                	push   $0x0
  800999:	50                   	push   %eax
  80099a:	e8 3c 19 00 00       	call   8022db <memset>
		flush_block(diskaddr(blockno));
  80099f:	89 3c 24             	mov    %edi,(%esp)
  8009a2:	e8 ee f9 ff ff       	call   800395 <diskaddr>
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	e8 64 fa ff ff       	call   800413 <flush_block>

		if (ppdiskbno != 0)
  8009af:	83 c4 10             	add    $0x10,%esp
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
		return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
		flush_block(diskaddr(blockno));

		if (ppdiskbno != 0)
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	74 34                	je     8009ef <file_block_walk+0xf5>
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
  8009bb:	83 ec 0c             	sub    $0xc,%esp
  8009be:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  8009c4:	e8 cc f9 ff ff       	call   800395 <diskaddr>
  8009c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009cc:	8d 44 b0 d8          	lea    -0x28(%eax,%esi,4),%eax
  8009d0:	89 03                	mov    %eax,(%ebx)
  8009d2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	eb 13                	jmp    8009ef <file_block_walk+0xf5>
{
	// LAB 5: Your code here.
    //    panic("file_block_walk not implemented");

	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  8009dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e1:	eb 0c                	jmp    8009ef <file_block_walk+0xf5>
	if (filebno < NDIRECT) {
		if (ppdiskbno != 0)
			*ppdiskbno = &f->f_direct[filebno];
		
		// cprintf("[?] 0x%x, 0x%x -->\n", *ppdiskbno, **ppdiskbno);
		return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e8:	eb 05                	jmp    8009ef <file_block_walk+0xf5>
	}
	else {

		// not allocated
		if (alloc == 0)
			return -E_NOT_FOUND;
  8009ea:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		if (ppdiskbno != 0)
			*ppdiskbno = ((uint32_t *)diskaddr(f->f_indirect) + filebno - NDIRECT);
		return 0;
	}

}
  8009ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009fc:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800a01:	8b 70 04             	mov    0x4(%eax),%esi
  800a04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a09:	eb 29                	jmp    800a34 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800a0b:	8d 43 02             	lea    0x2(%ebx),%eax
  800a0e:	50                   	push   %eax
  800a0f:	e8 f4 fd ff ff       	call   800808 <block_is_free>
  800a14:	83 c4 04             	add    $0x4,%esp
  800a17:	84 c0                	test   %al,%al
  800a19:	74 16                	je     800a31 <check_bitmap+0x3a>
  800a1b:	68 1c 3b 80 00       	push   $0x803b1c
  800a20:	68 dd 38 80 00       	push   $0x8038dd
  800a25:	6a 60                	push   $0x60
  800a27:	68 cc 3a 80 00       	push   $0x803acc
  800a2c:	e8 07 11 00 00       	call   801b38 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a31:	83 c3 01             	add    $0x1,%ebx
  800a34:	89 d8                	mov    %ebx,%eax
  800a36:	c1 e0 0f             	shl    $0xf,%eax
  800a39:	39 f0                	cmp    %esi,%eax
  800a3b:	72 ce                	jb     800a0b <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800a3d:	83 ec 0c             	sub    $0xc,%esp
  800a40:	6a 00                	push   $0x0
  800a42:	e8 c1 fd ff ff       	call   800808 <block_is_free>
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	84 c0                	test   %al,%al
  800a4c:	74 16                	je     800a64 <check_bitmap+0x6d>
  800a4e:	68 30 3b 80 00       	push   $0x803b30
  800a53:	68 dd 38 80 00       	push   $0x8038dd
  800a58:	6a 63                	push   $0x63
  800a5a:	68 cc 3a 80 00       	push   $0x803acc
  800a5f:	e8 d4 10 00 00       	call   801b38 <_panic>
	assert(!block_is_free(1));
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	6a 01                	push   $0x1
  800a69:	e8 9a fd ff ff       	call   800808 <block_is_free>
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	84 c0                	test   %al,%al
  800a73:	74 16                	je     800a8b <check_bitmap+0x94>
  800a75:	68 42 3b 80 00       	push   $0x803b42
  800a7a:	68 dd 38 80 00       	push   $0x8038dd
  800a7f:	6a 64                	push   $0x64
  800a81:	68 cc 3a 80 00       	push   $0x803acc
  800a86:	e8 ad 10 00 00       	call   801b38 <_panic>

	cprintf("bitmap is good\n");
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	68 54 3b 80 00       	push   $0x803b54
  800a93:	e8 79 11 00 00       	call   801c11 <cprintf>
}
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800aa8:	e8 b2 f5 ff ff       	call   80005f <ide_probe_disk1>
  800aad:	84 c0                	test   %al,%al
  800aaf:	74 0f                	je     800ac0 <fs_init+0x1e>
		ide_set_disk(1);
  800ab1:	83 ec 0c             	sub    $0xc,%esp
  800ab4:	6a 01                	push   $0x1
  800ab6:	e8 08 f6 ff ff       	call   8000c3 <ide_set_disk>
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	eb 0d                	jmp    800acd <fs_init+0x2b>
	else
		ide_set_disk(0);
  800ac0:	83 ec 0c             	sub    $0xc,%esp
  800ac3:	6a 00                	push   $0x0
  800ac5:	e8 f9 f5 ff ff       	call   8000c3 <ide_set_disk>
  800aca:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800acd:	e8 03 fa ff ff       	call   8004d5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800ad2:	83 ec 0c             	sub    $0xc,%esp
  800ad5:	6a 01                	push   $0x1
  800ad7:	e8 b9 f8 ff ff       	call   800395 <diskaddr>
  800adc:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800ae1:	e8 cc fc ff ff       	call   8007b2 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800ae6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800aed:	e8 a3 f8 ff ff       	call   800395 <diskaddr>
  800af2:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800af7:	e8 fb fe ff ff       	call   8009f7 <check_bitmap>
	
}
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	53                   	push   %ebx
  800b05:	83 ec 20             	sub    $0x20,%esp
    //    panic("file_get_block not implemented");

	uint32_t *ptr;
	int blockno = 0;

	int r = file_block_walk(f, filebno, &ptr, 1);
  800b08:	6a 01                	push   $0x1
  800b0a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	e8 e2 fd ff ff       	call   8008fa <file_block_walk>
	if (r < 0)
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	78 5e                	js     800b7d <file_get_block+0x7c>
		return r;
	// cprintf("[?] 0x%x -> \n", *ptr);
	// not allocated yet
	if (*ptr == 0) {
  800b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b22:	83 38 00             	cmpl   $0x0,(%eax)
  800b25:	75 3c                	jne    800b63 <file_get_block+0x62>
		
		blockno = alloc_block();
  800b27:	e8 55 fd ff ff       	call   800881 <alloc_block>
  800b2c:	89 c3                	mov    %eax,%ebx

		// cprintf("[?] %d\n", blockno);

		if (blockno < 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 4b                	js     800b7d <file_get_block+0x7c>
			return blockno;
		
		*ptr = blockno;
  800b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b35:	89 18                	mov    %ebx,(%eax)

		// flush to disk
		memset(diskaddr(blockno), 0, BLKSIZE);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	53                   	push   %ebx
  800b3b:	e8 55 f8 ff ff       	call   800395 <diskaddr>
  800b40:	83 c4 0c             	add    $0xc,%esp
  800b43:	68 00 10 00 00       	push   $0x1000
  800b48:	6a 00                	push   $0x0
  800b4a:	50                   	push   %eax
  800b4b:	e8 8b 17 00 00       	call   8022db <memset>
		flush_block(diskaddr(blockno));
  800b50:	89 1c 24             	mov    %ebx,(%esp)
  800b53:	e8 3d f8 ff ff       	call   800395 <diskaddr>
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 b3 f8 ff ff       	call   800413 <flush_block>
  800b60:	83 c4 10             	add    $0x10,%esp
	}

	// cprintf("[?] 0x%x\n", *ptr);

	*blk = diskaddr(*ptr);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b69:	ff 30                	pushl  (%eax)
  800b6b:	e8 25 f8 ff ff       	call   800395 <diskaddr>
  800b70:	8b 55 10             	mov    0x10(%ebp),%edx
  800b73:	89 02                	mov    %eax,(%edx)
	return 0;
  800b75:	83 c4 10             	add    $0x10,%esp
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b8e:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b94:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b9a:	eb 03                	jmp    800b9f <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b9c:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b9f:	80 38 2f             	cmpb   $0x2f,(%eax)
  800ba2:	74 f8                	je     800b9c <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800ba4:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800baa:	83 c1 08             	add    $0x8,%ecx
  800bad:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800bb3:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800bba:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800bc0:	85 c9                	test   %ecx,%ecx
  800bc2:	74 06                	je     800bca <walk_path+0x48>
		*pdir = 0;
  800bc4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800bca:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800bd0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800bdb:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800be1:	e9 5f 01 00 00       	jmp    800d45 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800be6:	83 c7 01             	add    $0x1,%edi
  800be9:	eb 02                	jmp    800bed <walk_path+0x6b>
  800beb:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800bed:	0f b6 17             	movzbl (%edi),%edx
  800bf0:	80 fa 2f             	cmp    $0x2f,%dl
  800bf3:	74 04                	je     800bf9 <walk_path+0x77>
  800bf5:	84 d2                	test   %dl,%dl
  800bf7:	75 ed                	jne    800be6 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800bf9:	89 fb                	mov    %edi,%ebx
  800bfb:	29 c3                	sub    %eax,%ebx
  800bfd:	83 fb 7f             	cmp    $0x7f,%ebx
  800c00:	0f 8f 69 01 00 00    	jg     800d6f <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c06:	83 ec 04             	sub    $0x4,%esp
  800c09:	53                   	push   %ebx
  800c0a:	50                   	push   %eax
  800c0b:	56                   	push   %esi
  800c0c:	e8 17 17 00 00       	call   802328 <memmove>
		name[path - p] = '\0';
  800c11:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c18:	00 
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	eb 03                	jmp    800c21 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800c1e:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800c21:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800c24:	74 f8                	je     800c1e <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800c26:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c2c:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c33:	0f 85 3d 01 00 00    	jne    800d76 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800c39:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c3f:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c44:	74 19                	je     800c5f <walk_path+0xdd>
  800c46:	68 64 3b 80 00       	push   $0x803b64
  800c4b:	68 dd 38 80 00       	push   $0x8038dd
  800c50:	68 05 01 00 00       	push   $0x105
  800c55:	68 cc 3a 80 00       	push   $0x803acc
  800c5a:	e8 d9 0e 00 00       	call   801b38 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800c5f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c65:	85 c0                	test   %eax,%eax
  800c67:	0f 48 c2             	cmovs  %edx,%eax
  800c6a:	c1 f8 0c             	sar    $0xc,%eax
  800c6d:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800c73:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800c7a:	00 00 00 
  800c7d:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800c83:	eb 5e                	jmp    800ce3 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c85:	83 ec 04             	sub    $0x4,%esp
  800c88:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c8e:	50                   	push   %eax
  800c8f:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c95:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c9b:	e8 61 fe ff ff       	call   800b01 <file_get_block>
  800ca0:	83 c4 10             	add    $0x10,%esp
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	0f 88 ee 00 00 00    	js     800d99 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800cab:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800cb1:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800cb7:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800cbd:	83 ec 08             	sub    $0x8,%esp
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	e8 79 15 00 00       	call   802240 <strcmp>
  800cc7:	83 c4 10             	add    $0x10,%esp
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	0f 84 ab 00 00 00    	je     800d7d <walk_path+0x1fb>
  800cd2:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800cd8:	39 fb                	cmp    %edi,%ebx
  800cda:	75 db                	jne    800cb7 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800cdc:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800ce3:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800ce9:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800cef:	75 94                	jne    800c85 <walk_path+0x103>
  800cf1:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800cf7:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800cfc:	80 3f 00             	cmpb   $0x0,(%edi)
  800cff:	0f 85 a3 00 00 00    	jne    800da8 <walk_path+0x226>
				if (pdir)
  800d05:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	74 08                	je     800d17 <walk_path+0x195>
					*pdir = dir;
  800d0f:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d15:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800d17:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d1b:	74 15                	je     800d32 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800d1d:	83 ec 08             	sub    $0x8,%esp
  800d20:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d26:	50                   	push   %eax
  800d27:	ff 75 08             	pushl  0x8(%ebp)
  800d2a:	e8 67 14 00 00       	call   802196 <strcpy>
  800d2f:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d32:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800d3e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d43:	eb 63                	jmp    800da8 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800d45:	80 38 00             	cmpb   $0x0,(%eax)
  800d48:	0f 85 9d fe ff ff    	jne    800beb <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800d4e:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d54:	85 c0                	test   %eax,%eax
  800d56:	74 02                	je     800d5a <walk_path+0x1d8>
		*pdir = dir;
  800d58:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800d5a:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d60:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d66:	89 08                	mov    %ecx,(%eax)
	return 0;
  800d68:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6d:	eb 39                	jmp    800da8 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800d6f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d74:	eb 32                	jmp    800da8 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800d76:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d7b:	eb 2b                	jmp    800da8 <walk_path+0x226>
  800d7d:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d83:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d89:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d8f:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d95:	89 f8                	mov    %edi,%eax
  800d97:	eb ac                	jmp    800d45 <walk_path+0x1c3>
  800d99:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d9f:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800da2:	0f 84 4f ff ff ff    	je     800cf7 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800db6:	6a 00                	push   $0x0
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	e8 ba fd ff ff       	call   800b82 <walk_path>
}
  800dc8:	c9                   	leave  
  800dc9:	c3                   	ret    

00800dca <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 2c             	sub    $0x2c,%esp
  800dd3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dd6:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800de2:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800de7:	39 ca                	cmp    %ecx,%edx
  800de9:	7e 7c                	jle    800e67 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800deb:	29 ca                	sub    %ecx,%edx
  800ded:	3b 55 10             	cmp    0x10(%ebp),%edx
  800df0:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800df4:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800df7:	89 ce                	mov    %ecx,%esi
  800df9:	01 d1                	add    %edx,%ecx
  800dfb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800dfe:	eb 5d                	jmp    800e5d <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e00:	83 ec 04             	sub    $0x4,%esp
  800e03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e06:	50                   	push   %eax
  800e07:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e0d:	85 f6                	test   %esi,%esi
  800e0f:	0f 49 c6             	cmovns %esi,%eax
  800e12:	c1 f8 0c             	sar    $0xc,%eax
  800e15:	50                   	push   %eax
  800e16:	ff 75 08             	pushl  0x8(%ebp)
  800e19:	e8 e3 fc ff ff       	call   800b01 <file_get_block>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 42                	js     800e67 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e25:	89 f2                	mov    %esi,%edx
  800e27:	c1 fa 1f             	sar    $0x1f,%edx
  800e2a:	c1 ea 14             	shr    $0x14,%edx
  800e2d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e30:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e35:	29 d0                	sub    %edx,%eax
  800e37:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e3a:	29 da                	sub    %ebx,%edx
  800e3c:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800e41:	29 c3                	sub    %eax,%ebx
  800e43:	39 da                	cmp    %ebx,%edx
  800e45:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	53                   	push   %ebx
  800e4c:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e4f:	50                   	push   %eax
  800e50:	57                   	push   %edi
  800e51:	e8 d2 14 00 00       	call   802328 <memmove>
		pos += bn;
  800e56:	01 de                	add    %ebx,%esi
		buf += bn;
  800e58:	01 df                	add    %ebx,%edi
  800e5a:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800e5d:	89 f3                	mov    %esi,%ebx
  800e5f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e62:	77 9c                	ja     800e00 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e64:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 2c             	sub    $0x2c,%esp
  800e78:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e7b:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e81:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e84:	0f 8e a7 00 00 00    	jle    800f31 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e8a:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e90:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e95:	0f 49 f8             	cmovns %eax,%edi
  800e98:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800ea3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea6:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800eac:	0f 49 c2             	cmovns %edx,%eax
  800eaf:	c1 f8 0c             	sar    $0xc,%eax
  800eb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800eb5:	89 c3                	mov    %eax,%ebx
  800eb7:	eb 39                	jmp    800ef2 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	6a 00                	push   $0x0
  800ebe:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	e8 30 fa ff ff       	call   8008fa <file_block_walk>
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	78 4d                	js     800f1e <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ed4:	8b 00                	mov    (%eax),%eax
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	74 15                	je     800eef <file_set_size+0x80>
		free_block(*ptr);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	50                   	push   %eax
  800ede:	e8 62 f9 ff ff       	call   800845 <free_block>
		*ptr = 0;
  800ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800eec:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800eef:	83 c3 01             	add    $0x1,%ebx
  800ef2:	39 df                	cmp    %ebx,%edi
  800ef4:	77 c3                	ja     800eb9 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800ef6:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800efa:	77 35                	ja     800f31 <file_set_size+0xc2>
  800efc:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f02:	85 c0                	test   %eax,%eax
  800f04:	74 2b                	je     800f31 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	50                   	push   %eax
  800f0a:	e8 36 f9 ff ff       	call   800845 <free_block>
		f->f_indirect = 0;
  800f0f:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800f16:	00 00 00 
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	eb 13                	jmp    800f31 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800f1e:	83 ec 08             	sub    $0x8,%esp
  800f21:	50                   	push   %eax
  800f22:	68 81 3b 80 00       	push   $0x803b81
  800f27:	e8 e5 0c 00 00       	call   801c11 <cprintf>
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	eb be                	jmp    800eef <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800f31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f34:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	56                   	push   %esi
  800f3e:	e8 d0 f4 ff ff       	call   800413 <flush_block>
	return 0;
}
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
  800f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	83 ec 2c             	sub    $0x2c,%esp
  800f59:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f5c:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	03 45 10             	add    0x10(%ebp),%eax
  800f64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6a:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f70:	76 72                	jbe    800fe4 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	50                   	push   %eax
  800f76:	51                   	push   %ecx
  800f77:	e8 f3 fe ff ff       	call   800e6f <file_set_size>
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	79 61                	jns    800fe4 <file_write+0x94>
  800f83:	eb 69                	jmp    800fee <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f92:	85 f6                	test   %esi,%esi
  800f94:	0f 49 c6             	cmovns %esi,%eax
  800f97:	c1 f8 0c             	sar    $0xc,%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 75 08             	pushl  0x8(%ebp)
  800f9e:	e8 5e fb ff ff       	call   800b01 <file_get_block>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 44                	js     800fee <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800faa:	89 f2                	mov    %esi,%edx
  800fac:	c1 fa 1f             	sar    $0x1f,%edx
  800faf:	c1 ea 14             	shr    $0x14,%edx
  800fb2:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800fb5:	25 ff 0f 00 00       	and    $0xfff,%eax
  800fba:	29 d0                	sub    %edx,%eax
  800fbc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800fbf:	29 d9                	sub    %ebx,%ecx
  800fc1:	89 cb                	mov    %ecx,%ebx
  800fc3:	ba 00 10 00 00       	mov    $0x1000,%edx
  800fc8:	29 c2                	sub    %eax,%edx
  800fca:	39 d1                	cmp    %edx,%ecx
  800fcc:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	53                   	push   %ebx
  800fd3:	57                   	push   %edi
  800fd4:	03 45 e4             	add    -0x1c(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	e8 4b 13 00 00       	call   802328 <memmove>
		pos += bn;
  800fdd:	01 de                	add    %ebx,%esi
		buf += bn;
  800fdf:	01 df                	add    %ebx,%edi
  800fe1:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800fe4:	89 f3                	mov    %esi,%ebx
  800fe6:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800fe9:	77 9a                	ja     800f85 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800feb:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 10             	sub    $0x10,%esp
  800ffe:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
  801006:	eb 3c                	jmp    801044 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	6a 00                	push   $0x0
  80100d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801010:	89 da                	mov    %ebx,%edx
  801012:	89 f0                	mov    %esi,%eax
  801014:	e8 e1 f8 ff ff       	call   8008fa <file_block_walk>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 21                	js     801041 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801023:	85 c0                	test   %eax,%eax
  801025:	74 1a                	je     801041 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  801027:	8b 00                	mov    (%eax),%eax
  801029:	85 c0                	test   %eax,%eax
  80102b:	74 14                	je     801041 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	50                   	push   %eax
  801031:	e8 5f f3 ff ff       	call   800395 <diskaddr>
  801036:	89 04 24             	mov    %eax,(%esp)
  801039:	e8 d5 f3 ff ff       	call   800413 <flush_block>
  80103e:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801041:	83 c3 01             	add    $0x1,%ebx
  801044:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  80104a:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801050:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  801056:	85 c9                	test   %ecx,%ecx
  801058:	0f 49 c1             	cmovns %ecx,%eax
  80105b:	c1 f8 0c             	sar    $0xc,%eax
  80105e:	39 c3                	cmp    %eax,%ebx
  801060:	7c a6                	jl     801008 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	56                   	push   %esi
  801066:	e8 a8 f3 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  80106b:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	74 14                	je     80108c <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	50                   	push   %eax
  80107c:	e8 14 f3 ff ff       	call   800395 <diskaddr>
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	e8 8a f3 ff ff       	call   800413 <flush_block>
  801089:	83 c4 10             	add    $0x10,%esp
}
  80108c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80109f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8010a5:	50                   	push   %eax
  8010a6:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8010ac:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b5:	e8 c8 fa ff ff       	call   800b82 <walk_path>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	0f 84 d1 00 00 00    	je     801196 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  8010c5:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8010c8:	0f 85 0c 01 00 00    	jne    8011da <file_create+0x147>
  8010ce:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  8010d4:	85 f6                	test   %esi,%esi
  8010d6:	0f 84 c1 00 00 00    	je     80119d <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  8010dc:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  8010e2:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8010e7:	74 19                	je     801102 <file_create+0x6f>
  8010e9:	68 64 3b 80 00       	push   $0x803b64
  8010ee:	68 dd 38 80 00       	push   $0x8038dd
  8010f3:	68 1e 01 00 00       	push   $0x11e
  8010f8:	68 cc 3a 80 00       	push   $0x803acc
  8010fd:	e8 36 0a 00 00       	call   801b38 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801102:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801108:	85 c0                	test   %eax,%eax
  80110a:	0f 48 c2             	cmovs  %edx,%eax
  80110d:	c1 f8 0c             	sar    $0xc,%eax
  801110:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80111b:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801121:	eb 3b                	jmp    80115e <file_create+0xcb>
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	57                   	push   %edi
  801127:	53                   	push   %ebx
  801128:	56                   	push   %esi
  801129:	e8 d3 f9 ff ff       	call   800b01 <file_get_block>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	0f 88 a1 00 00 00    	js     8011da <file_create+0x147>
			return r;
		f = (struct File*) blk;
  801139:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80113f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801145:	80 38 00             	cmpb   $0x0,(%eax)
  801148:	75 08                	jne    801152 <file_create+0xbf>
				*file = &f[j];
  80114a:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801150:	eb 52                	jmp    8011a4 <file_create+0x111>
  801152:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801157:	39 d0                	cmp    %edx,%eax
  801159:	75 ea                	jne    801145 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80115b:	83 c3 01             	add    $0x1,%ebx
  80115e:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801164:	75 bd                	jne    801123 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  801166:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  80116d:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	53                   	push   %ebx
  80117b:	56                   	push   %esi
  80117c:	e8 80 f9 ff ff       	call   800b01 <file_get_block>
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 52                	js     8011da <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801188:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80118e:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801194:	eb 0e                	jmp    8011a4 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  801196:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80119b:	eb 3d                	jmp    8011da <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  80119d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8011a2:	eb 36                	jmp    8011da <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8011a4:	83 ec 08             	sub    $0x8,%esp
  8011a7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  8011b4:	e8 dd 0f 00 00       	call   802196 <strcpy>
	*pf = f;
  8011b9:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8011bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c2:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8011c4:	83 c4 04             	add    $0x4,%esp
  8011c7:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  8011cd:	e8 24 fe ff ff       	call   800ff6 <file_flush>
	return 0;
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8011e9:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011ee:	eb 17                	jmp    801207 <fs_sync+0x25>
		flush_block(diskaddr(i));
  8011f0:	83 ec 0c             	sub    $0xc,%esp
  8011f3:	53                   	push   %ebx
  8011f4:	e8 9c f1 ff ff       	call   800395 <diskaddr>
  8011f9:	89 04 24             	mov    %eax,(%esp)
  8011fc:	e8 12 f2 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801201:	83 c3 01             	add    $0x1,%ebx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80120c:	39 58 04             	cmp    %ebx,0x4(%eax)
  80120f:	77 df                	ja     8011f0 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801211:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801214:	c9                   	leave  
  801215:	c3                   	ret    

00801216 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80121c:	e8 c1 ff ff ff       	call   8011e2 <fs_sync>
	return 0;
}
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  801230:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80123a:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80123c:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80123f:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801245:	83 c0 01             	add    $0x1,%eax
  801248:	83 c2 10             	add    $0x10,%edx
  80124b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801250:	75 e8                	jne    80123a <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80125c:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	89 d8                	mov    %ebx,%eax
  801266:	c1 e0 04             	shl    $0x4,%eax
  801269:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80126f:	e8 73 1e 00 00       	call   8030e7 <pageref>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	74 07                	je     801282 <openfile_alloc+0x2e>
  80127b:	83 f8 01             	cmp    $0x1,%eax
  80127e:	74 20                	je     8012a0 <openfile_alloc+0x4c>
  801280:	eb 51                	jmp    8012d3 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801282:	83 ec 04             	sub    $0x4,%esp
  801285:	6a 07                	push   $0x7
  801287:	89 d8                	mov    %ebx,%eax
  801289:	c1 e0 04             	shl    $0x4,%eax
  80128c:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801292:	6a 00                	push   $0x0
  801294:	e8 00 13 00 00       	call   802599 <sys_page_alloc>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 43                	js     8012e3 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8012a0:	c1 e3 04             	shl    $0x4,%ebx
  8012a3:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8012a9:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8012b0:	04 00 00 
			*o = &opentab[i];
  8012b3:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	68 00 10 00 00       	push   $0x1000
  8012bd:	6a 00                	push   $0x0
  8012bf:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8012c5:	e8 11 10 00 00       	call   8022db <memset>
			return (*o)->o_fileid;
  8012ca:	8b 06                	mov    (%esi),%eax
  8012cc:	8b 00                	mov    (%eax),%eax
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	eb 10                	jmp    8012e3 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8012d3:	83 c3 01             	add    $0x1,%ebx
  8012d6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012dc:	75 83                	jne    801261 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8012de:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 18             	sub    $0x18,%esp
  8012f3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8012f6:	89 fb                	mov    %edi,%ebx
  8012f8:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8012fe:	89 de                	mov    %ebx,%esi
  801300:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801303:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801309:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80130f:	e8 d3 1d 00 00       	call   8030e7 <pageref>
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	83 f8 01             	cmp    $0x1,%eax
  80131a:	7e 17                	jle    801333 <openfile_lookup+0x49>
  80131c:	c1 e3 04             	shl    $0x4,%ebx
  80131f:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801325:	75 13                	jne    80133a <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801327:	8b 45 10             	mov    0x10(%ebp),%eax
  80132a:	89 30                	mov    %esi,(%eax)
	return 0;
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
  801331:	eb 0c                	jmp    80133f <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801333:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801338:	eb 05                	jmp    80133f <openfile_lookup+0x55>
  80133a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80133f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5f                   	pop    %edi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 18             	sub    $0x18,%esp
  80134e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 33                	pushl  (%ebx)
  801357:	ff 75 08             	pushl  0x8(%ebp)
  80135a:	e8 8b ff ff ff       	call   8012ea <openfile_lookup>
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 14                	js     80137a <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	ff 73 04             	pushl  0x4(%ebx)
  80136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136f:	ff 70 04             	pushl  0x4(%eax)
  801372:	e8 f8 fa ff ff       	call   800e6f <file_set_size>
  801377:	83 c4 10             	add    $0x10,%esp
}
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 18             	sub    $0x18,%esp
  801386:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Lab 5: Your code here:

	struct OpenFile *o;
	int r;

    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 33                	pushl  (%ebx)
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 53 ff ff ff       	call   8012ea <openfile_lookup>
  801397:	83 c4 10             	add    $0x10,%esp
		return r;
  80139a:	89 c2                	mov    %eax,%edx
	// Lab 5: Your code here:

	struct OpenFile *o;
	int r;

    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 2b                	js     8013cb <serve_read+0x4c>
		return r;

	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  8013a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a3:	8b 50 0c             	mov    0xc(%eax),%edx
  8013a6:	ff 72 04             	pushl  0x4(%edx)
  8013a9:	ff 73 04             	pushl  0x4(%ebx)
  8013ac:	53                   	push   %ebx
  8013ad:	ff 70 04             	pushl  0x4(%eax)
  8013b0:	e8 15 fa ff ff       	call   800dca <file_read>
	if (r < 0)
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 0d                	js     8013c9 <serve_read+0x4a>
		return r;

	// req->req_fileid += r; 
	o->o_fd->fd_offset += r;
  8013bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8013c2:	01 42 04             	add    %eax,0x4(%edx)

	return r;
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	eb 02                	jmp    8013cb <serve_read+0x4c>
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
	if (r < 0)
		return r;
  8013c9:	89 c2                	mov    %eax,%edx

	// req->req_fileid += r; 
	o->o_fd->fd_offset += r;

	return r;
}
  8013cb:	89 d0                	mov    %edx,%eax
  8013cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    

008013d2 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 18             	sub    $0x18,%esp
  8013d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	ff 33                	pushl  (%ebx)
  8013e2:	ff 75 08             	pushl  0x8(%ebp)
  8013e5:	e8 00 ff ff ff       	call   8012ea <openfile_lookup>
  8013ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8013ed:	89 c2                	mov    %eax,%edx
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 31                	js     801424 <serve_write+0x52>
		return r;
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  8013f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f6:	8b 50 0c             	mov    0xc(%eax),%edx
  8013f9:	ff 72 04             	pushl  0x4(%edx)
  8013fc:	ff 73 04             	pushl  0x4(%ebx)
  8013ff:	8d 53 08             	lea    0x8(%ebx),%edx
  801402:	52                   	push   %edx
  801403:	ff 70 04             	pushl  0x4(%eax)
  801406:	e8 45 fb ff ff       	call   800f50 <file_write>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 10                	js     801422 <serve_write+0x50>
		return r;
	o->o_fd->fd_offset += req->req_n;
  801412:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801415:	8b 52 0c             	mov    0xc(%edx),%edx
  801418:	8b 4b 04             	mov    0x4(%ebx),%ecx
  80141b:	01 4a 04             	add    %ecx,0x4(%edx)
	return r;
  80141e:	89 c2                	mov    %eax,%edx
  801420:	eb 02                	jmp    801424 <serve_write+0x52>
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
		return r;
  801422:	89 c2                	mov    %eax,%edx
	o->o_fd->fd_offset += req->req_n;
	return r;

}
  801424:	89 d0                	mov    %edx,%eax
  801426:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	83 ec 18             	sub    $0x18,%esp
  801432:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801435:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	ff 33                	pushl  (%ebx)
  80143b:	ff 75 08             	pushl  0x8(%ebp)
  80143e:	e8 a7 fe ff ff       	call   8012ea <openfile_lookup>
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 3f                	js     801489 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801450:	ff 70 04             	pushl  0x4(%eax)
  801453:	53                   	push   %ebx
  801454:	e8 3d 0d 00 00       	call   802196 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145c:	8b 50 04             	mov    0x4(%eax),%edx
  80145f:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801465:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80146b:	8b 40 04             	mov    0x4(%eax),%eax
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801478:	0f 94 c0             	sete   %al
  80147b:	0f b6 c0             	movzbl %al,%eax
  80147e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	ff 30                	pushl  (%eax)
  80149d:	ff 75 08             	pushl  0x8(%ebp)
  8014a0:	e8 45 fe ff ff       	call   8012ea <openfile_lookup>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 16                	js     8014c2 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	ff 70 04             	pushl  0x4(%eax)
  8014b5:	e8 3c fb ff ff       	call   800ff6 <file_flush>
	return 0;
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	81 ec 18 04 00 00    	sub    $0x418,%esp
  8014ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8014d1:	68 00 04 00 00       	push   $0x400
  8014d6:	53                   	push   %ebx
  8014d7:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	e8 45 0e 00 00       	call   802328 <memmove>
	path[MAXPATHLEN-1] = 0;
  8014e3:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8014e7:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8014ed:	89 04 24             	mov    %eax,(%esp)
  8014f0:	e8 5f fd ff ff       	call   801254 <openfile_alloc>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	0f 88 f0 00 00 00    	js     8015f0 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801500:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801507:	74 33                	je     80153c <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	e8 74 fb ff ff       	call   801093 <file_create>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	79 37                	jns    80155d <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801526:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80152d:	0f 85 bd 00 00 00    	jne    8015f0 <serve_open+0x12c>
  801533:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801536:	0f 85 b4 00 00 00    	jne    8015f0 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	e8 5e f8 ff ff       	call   800db0 <file_open>
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	0f 88 93 00 00 00    	js     8015f0 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80155d:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801564:	74 17                	je     80157d <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	6a 00                	push   $0x0
  80156b:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801571:	e8 f9 f8 ff ff       	call   800e6f <file_set_size>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 73                	js     8015f0 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	e8 1d f8 ff ff       	call   800db0 <file_open>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 56                	js     8015f0 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80159a:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015a0:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8015a6:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8015a9:	8b 50 0c             	mov    0xc(%eax),%edx
  8015ac:	8b 08                	mov    (%eax),%ecx
  8015ae:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8015b1:	8b 48 0c             	mov    0xc(%eax),%ecx
  8015b4:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015ba:	83 e2 03             	and    $0x3,%edx
  8015bd:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8015c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c3:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8015c9:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8015cb:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015d1:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015d7:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8015da:	8b 50 0c             	mov    0xc(%eax),%edx
  8015dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8015e0:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8015e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e5:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8015eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015fd:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801600:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801603:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80160a:	83 ec 04             	sub    $0x4,%esp
  80160d:	53                   	push   %ebx
  80160e:	ff 35 44 50 80 00    	pushl  0x805044
  801614:	56                   	push   %esi
  801615:	e8 db 11 00 00       	call   8027f5 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801621:	75 15                	jne    801638 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	ff 75 f4             	pushl  -0xc(%ebp)
  801629:	68 a0 3b 80 00       	push   $0x803ba0
  80162e:	e8 de 05 00 00       	call   801c11 <cprintf>
				whom);
			continue; // just leave it hanging...
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb cb                	jmp    801603 <serve+0xe>
		}

		pg = NULL;
  801638:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80163f:	83 f8 01             	cmp    $0x1,%eax
  801642:	75 18                	jne    80165c <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801644:	53                   	push   %ebx
  801645:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 35 44 50 80 00    	pushl  0x805044
  80164f:	ff 75 f4             	pushl  -0xc(%ebp)
  801652:	e8 6d fe ff ff       	call   8014c4 <serve_open>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 3c                	jmp    801698 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  80165c:	83 f8 08             	cmp    $0x8,%eax
  80165f:	77 1e                	ja     80167f <serve+0x8a>
  801661:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801668:	85 d2                	test   %edx,%edx
  80166a:	74 13                	je     80167f <serve+0x8a>
			r = handlers[req](whom, fsreq);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	ff 35 44 50 80 00    	pushl  0x805044
  801675:	ff 75 f4             	pushl  -0xc(%ebp)
  801678:	ff d2                	call   *%edx
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	eb 19                	jmp    801698 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	ff 75 f4             	pushl  -0xc(%ebp)
  801685:	50                   	push   %eax
  801686:	68 d0 3b 80 00       	push   $0x803bd0
  80168b:	e8 81 05 00 00       	call   801c11 <cprintf>
  801690:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801698:	ff 75 f0             	pushl  -0x10(%ebp)
  80169b:	ff 75 ec             	pushl  -0x14(%ebp)
  80169e:	50                   	push   %eax
  80169f:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a2:	e8 b5 11 00 00       	call   80285c <ipc_send>
		sys_page_unmap(0, fsreq);
  8016a7:	83 c4 08             	add    $0x8,%esp
  8016aa:	ff 35 44 50 80 00    	pushl  0x805044
  8016b0:	6a 00                	push   $0x0
  8016b2:	e8 67 0f 00 00       	call   80261e <sys_page_unmap>
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	e9 44 ff ff ff       	jmp    801603 <serve+0xe>

008016bf <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8016c5:	c7 05 60 90 80 00 f3 	movl   $0x803bf3,0x809060
  8016cc:	3b 80 00 
	cprintf("FS is running\n");
  8016cf:	68 f6 3b 80 00       	push   $0x803bf6
  8016d4:	e8 38 05 00 00       	call   801c11 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8016d9:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8016de:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8016e3:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8016e5:	c7 04 24 05 3c 80 00 	movl   $0x803c05,(%esp)
  8016ec:	e8 20 05 00 00       	call   801c11 <cprintf>

	serve_init();
  8016f1:	e8 32 fb ff ff       	call   801228 <serve_init>
	fs_init();
  8016f6:	e8 a7 f3 ff ff       	call   800aa2 <fs_init>
        fs_test();
  8016fb:	e8 05 00 00 00       	call   801705 <fs_test>
	serve();
  801700:	e8 f0 fe ff ff       	call   8015f5 <serve>

00801705 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	53                   	push   %ebx
  801709:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80170c:	6a 07                	push   $0x7
  80170e:	68 00 10 00 00       	push   $0x1000
  801713:	6a 00                	push   $0x0
  801715:	e8 7f 0e 00 00       	call   802599 <sys_page_alloc>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	79 12                	jns    801733 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801721:	50                   	push   %eax
  801722:	68 14 3c 80 00       	push   $0x803c14
  801727:	6a 12                	push   $0x12
  801729:	68 27 3c 80 00       	push   $0x803c27
  80172e:	e8 05 04 00 00       	call   801b38 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	68 00 10 00 00       	push   $0x1000
  80173b:	ff 35 04 a0 80 00    	pushl  0x80a004
  801741:	68 00 10 00 00       	push   $0x1000
  801746:	e8 dd 0b 00 00       	call   802328 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80174b:	e8 31 f1 ff ff       	call   800881 <alloc_block>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	79 12                	jns    801769 <fs_test+0x64>
		panic("alloc_block: %e", r);
  801757:	50                   	push   %eax
  801758:	68 31 3c 80 00       	push   $0x803c31
  80175d:	6a 17                	push   $0x17
  80175f:	68 27 3c 80 00       	push   $0x803c27
  801764:	e8 cf 03 00 00       	call   801b38 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801769:	8d 50 1f             	lea    0x1f(%eax),%edx
  80176c:	85 c0                	test   %eax,%eax
  80176e:	0f 49 d0             	cmovns %eax,%edx
  801771:	c1 fa 05             	sar    $0x5,%edx
  801774:	89 c3                	mov    %eax,%ebx
  801776:	c1 fb 1f             	sar    $0x1f,%ebx
  801779:	c1 eb 1b             	shr    $0x1b,%ebx
  80177c:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  80177f:	83 e1 1f             	and    $0x1f,%ecx
  801782:	29 d9                	sub    %ebx,%ecx
  801784:	b8 01 00 00 00       	mov    $0x1,%eax
  801789:	d3 e0                	shl    %cl,%eax
  80178b:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801792:	75 16                	jne    8017aa <fs_test+0xa5>
  801794:	68 41 3c 80 00       	push   $0x803c41
  801799:	68 dd 38 80 00       	push   $0x8038dd
  80179e:	6a 19                	push   $0x19
  8017a0:	68 27 3c 80 00       	push   $0x803c27
  8017a5:	e8 8e 03 00 00       	call   801b38 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017aa:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8017b0:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8017b3:	74 16                	je     8017cb <fs_test+0xc6>
  8017b5:	68 bc 3d 80 00       	push   $0x803dbc
  8017ba:	68 dd 38 80 00       	push   $0x8038dd
  8017bf:	6a 1b                	push   $0x1b
  8017c1:	68 27 3c 80 00       	push   $0x803c27
  8017c6:	e8 6d 03 00 00       	call   801b38 <_panic>
	cprintf("alloc_block is good\n");
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	68 5c 3c 80 00       	push   $0x803c5c
  8017d3:	e8 39 04 00 00       	call   801c11 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8017d8:	83 c4 08             	add    $0x8,%esp
  8017db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017de:	50                   	push   %eax
  8017df:	68 71 3c 80 00       	push   $0x803c71
  8017e4:	e8 c7 f5 ff ff       	call   800db0 <file_open>
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8017ef:	74 1b                	je     80180c <fs_test+0x107>
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	c1 ea 1f             	shr    $0x1f,%edx
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	74 12                	je     80180c <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  8017fa:	50                   	push   %eax
  8017fb:	68 7c 3c 80 00       	push   $0x803c7c
  801800:	6a 1f                	push   $0x1f
  801802:	68 27 3c 80 00       	push   $0x803c27
  801807:	e8 2c 03 00 00       	call   801b38 <_panic>
	else if (r == 0)
  80180c:	85 c0                	test   %eax,%eax
  80180e:	75 14                	jne    801824 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801810:	83 ec 04             	sub    $0x4,%esp
  801813:	68 dc 3d 80 00       	push   $0x803ddc
  801818:	6a 21                	push   $0x21
  80181a:	68 27 3c 80 00       	push   $0x803c27
  80181f:	e8 14 03 00 00       	call   801b38 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	68 95 3c 80 00       	push   $0x803c95
  801830:	e8 7b f5 ff ff       	call   800db0 <file_open>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	79 12                	jns    80184e <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80183c:	50                   	push   %eax
  80183d:	68 9e 3c 80 00       	push   $0x803c9e
  801842:	6a 23                	push   $0x23
  801844:	68 27 3c 80 00       	push   $0x803c27
  801849:	e8 ea 02 00 00       	call   801b38 <_panic>
	cprintf("file_open is good\n");
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	68 b5 3c 80 00       	push   $0x803cb5
  801856:	e8 b6 03 00 00       	call   801c11 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80185b:	83 c4 0c             	add    $0xc,%esp
  80185e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801861:	50                   	push   %eax
  801862:	6a 00                	push   $0x0
  801864:	ff 75 f4             	pushl  -0xc(%ebp)
  801867:	e8 95 f2 ff ff       	call   800b01 <file_get_block>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	79 12                	jns    801885 <fs_test+0x180>
		panic("file_get_block: %e", r);
  801873:	50                   	push   %eax
  801874:	68 c8 3c 80 00       	push   $0x803cc8
  801879:	6a 27                	push   $0x27
  80187b:	68 27 3c 80 00       	push   $0x803c27
  801880:	e8 b3 02 00 00       	call   801b38 <_panic>
	if (strcmp(blk, msg) != 0)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	68 fc 3d 80 00       	push   $0x803dfc
  80188d:	ff 75 f0             	pushl  -0x10(%ebp)
  801890:	e8 ab 09 00 00       	call   802240 <strcmp>
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	74 14                	je     8018b0 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	68 24 3e 80 00       	push   $0x803e24
  8018a4:	6a 29                	push   $0x29
  8018a6:	68 27 3c 80 00       	push   $0x803c27
  8018ab:	e8 88 02 00 00       	call   801b38 <_panic>
	cprintf("file_get_block is good\n");
  8018b0:	83 ec 0c             	sub    $0xc,%esp
  8018b3:	68 db 3c 80 00       	push   $0x803cdb
  8018b8:	e8 54 03 00 00       	call   801c11 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c0:	0f b6 10             	movzbl (%eax),%edx
  8018c3:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c8:	c1 e8 0c             	shr    $0xc,%eax
  8018cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	a8 40                	test   $0x40,%al
  8018d7:	75 16                	jne    8018ef <fs_test+0x1ea>
  8018d9:	68 f4 3c 80 00       	push   $0x803cf4
  8018de:	68 dd 38 80 00       	push   $0x8038dd
  8018e3:	6a 2d                	push   $0x2d
  8018e5:	68 27 3c 80 00       	push   $0x803c27
  8018ea:	e8 49 02 00 00       	call   801b38 <_panic>
	file_flush(f);
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f5:	e8 fc f6 ff ff       	call   800ff6 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fd:	c1 e8 0c             	shr    $0xc,%eax
  801900:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	a8 40                	test   $0x40,%al
  80190c:	74 16                	je     801924 <fs_test+0x21f>
  80190e:	68 f3 3c 80 00       	push   $0x803cf3
  801913:	68 dd 38 80 00       	push   $0x8038dd
  801918:	6a 2f                	push   $0x2f
  80191a:	68 27 3c 80 00       	push   $0x803c27
  80191f:	e8 14 02 00 00       	call   801b38 <_panic>
	cprintf("file_flush is good\n");
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	68 0f 3d 80 00       	push   $0x803d0f
  80192c:	e8 e0 02 00 00       	call   801c11 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801931:	83 c4 08             	add    $0x8,%esp
  801934:	6a 00                	push   $0x0
  801936:	ff 75 f4             	pushl  -0xc(%ebp)
  801939:	e8 31 f5 ff ff       	call   800e6f <file_set_size>
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	79 12                	jns    801957 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801945:	50                   	push   %eax
  801946:	68 23 3d 80 00       	push   $0x803d23
  80194b:	6a 33                	push   $0x33
  80194d:	68 27 3c 80 00       	push   $0x803c27
  801952:	e8 e1 01 00 00       	call   801b38 <_panic>
	assert(f->f_direct[0] == 0);
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801961:	74 16                	je     801979 <fs_test+0x274>
  801963:	68 35 3d 80 00       	push   $0x803d35
  801968:	68 dd 38 80 00       	push   $0x8038dd
  80196d:	6a 34                	push   $0x34
  80196f:	68 27 3c 80 00       	push   $0x803c27
  801974:	e8 bf 01 00 00       	call   801b38 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801979:	c1 e8 0c             	shr    $0xc,%eax
  80197c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801983:	a8 40                	test   $0x40,%al
  801985:	74 16                	je     80199d <fs_test+0x298>
  801987:	68 49 3d 80 00       	push   $0x803d49
  80198c:	68 dd 38 80 00       	push   $0x8038dd
  801991:	6a 35                	push   $0x35
  801993:	68 27 3c 80 00       	push   $0x803c27
  801998:	e8 9b 01 00 00       	call   801b38 <_panic>
	cprintf("file_truncate is good\n");
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	68 63 3d 80 00       	push   $0x803d63
  8019a5:	e8 67 02 00 00       	call   801c11 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8019aa:	c7 04 24 fc 3d 80 00 	movl   $0x803dfc,(%esp)
  8019b1:	e8 a7 07 00 00       	call   80215d <strlen>
  8019b6:	83 c4 08             	add    $0x8,%esp
  8019b9:	50                   	push   %eax
  8019ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bd:	e8 ad f4 ff ff       	call   800e6f <file_set_size>
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	79 12                	jns    8019db <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8019c9:	50                   	push   %eax
  8019ca:	68 7a 3d 80 00       	push   $0x803d7a
  8019cf:	6a 39                	push   $0x39
  8019d1:	68 27 3c 80 00       	push   $0x803c27
  8019d6:	e8 5d 01 00 00       	call   801b38 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	c1 ea 0c             	shr    $0xc,%edx
  8019e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019ea:	f6 c2 40             	test   $0x40,%dl
  8019ed:	74 16                	je     801a05 <fs_test+0x300>
  8019ef:	68 49 3d 80 00       	push   $0x803d49
  8019f4:	68 dd 38 80 00       	push   $0x8038dd
  8019f9:	6a 3a                	push   $0x3a
  8019fb:	68 27 3c 80 00       	push   $0x803c27
  801a00:	e8 33 01 00 00       	call   801b38 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a05:	83 ec 04             	sub    $0x4,%esp
  801a08:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801a0b:	52                   	push   %edx
  801a0c:	6a 00                	push   $0x0
  801a0e:	50                   	push   %eax
  801a0f:	e8 ed f0 ff ff       	call   800b01 <file_get_block>
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	79 12                	jns    801a2d <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801a1b:	50                   	push   %eax
  801a1c:	68 8e 3d 80 00       	push   $0x803d8e
  801a21:	6a 3c                	push   $0x3c
  801a23:	68 27 3c 80 00       	push   $0x803c27
  801a28:	e8 0b 01 00 00       	call   801b38 <_panic>
	strcpy(blk, msg);
  801a2d:	83 ec 08             	sub    $0x8,%esp
  801a30:	68 fc 3d 80 00       	push   $0x803dfc
  801a35:	ff 75 f0             	pushl  -0x10(%ebp)
  801a38:	e8 59 07 00 00       	call   802196 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a40:	c1 e8 0c             	shr    $0xc,%eax
  801a43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	a8 40                	test   $0x40,%al
  801a4f:	75 16                	jne    801a67 <fs_test+0x362>
  801a51:	68 f4 3c 80 00       	push   $0x803cf4
  801a56:	68 dd 38 80 00       	push   $0x8038dd
  801a5b:	6a 3e                	push   $0x3e
  801a5d:	68 27 3c 80 00       	push   $0x803c27
  801a62:	e8 d1 00 00 00       	call   801b38 <_panic>
	file_flush(f);
  801a67:	83 ec 0c             	sub    $0xc,%esp
  801a6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6d:	e8 84 f5 ff ff       	call   800ff6 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a75:	c1 e8 0c             	shr    $0xc,%eax
  801a78:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	a8 40                	test   $0x40,%al
  801a84:	74 16                	je     801a9c <fs_test+0x397>
  801a86:	68 f3 3c 80 00       	push   $0x803cf3
  801a8b:	68 dd 38 80 00       	push   $0x8038dd
  801a90:	6a 40                	push   $0x40
  801a92:	68 27 3c 80 00       	push   $0x803c27
  801a97:	e8 9c 00 00 00       	call   801b38 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9f:	c1 e8 0c             	shr    $0xc,%eax
  801aa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aa9:	a8 40                	test   $0x40,%al
  801aab:	74 16                	je     801ac3 <fs_test+0x3be>
  801aad:	68 49 3d 80 00       	push   $0x803d49
  801ab2:	68 dd 38 80 00       	push   $0x8038dd
  801ab7:	6a 41                	push   $0x41
  801ab9:	68 27 3c 80 00       	push   $0x803c27
  801abe:	e8 75 00 00 00       	call   801b38 <_panic>
	cprintf("file rewrite is good\n");
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	68 a3 3d 80 00       	push   $0x803da3
  801acb:	e8 41 01 00 00       	call   801c11 <cprintf>
}
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801ae3:	e8 73 0a 00 00       	call   80255b <sys_getenvid>
  801ae8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801aed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af5:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801afa:	85 db                	test   %ebx,%ebx
  801afc:	7e 07                	jle    801b05 <libmain+0x2d>
		binaryname = argv[0];
  801afe:	8b 06                	mov    (%esi),%eax
  801b00:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801b05:	83 ec 08             	sub    $0x8,%esp
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	e8 b0 fb ff ff       	call   8016bf <umain>

	// exit gracefully
	exit();
  801b0f:	e8 0a 00 00 00       	call   801b1e <exit>
}
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801b24:	e8 8b 0f 00 00       	call   802ab4 <close_all>
	sys_env_destroy(0);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	6a 00                	push   $0x0
  801b2e:	e8 e7 09 00 00       	call   80251a <sys_env_destroy>
}
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b3d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b40:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801b46:	e8 10 0a 00 00       	call   80255b <sys_getenvid>
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	ff 75 0c             	pushl  0xc(%ebp)
  801b51:	ff 75 08             	pushl  0x8(%ebp)
  801b54:	56                   	push   %esi
  801b55:	50                   	push   %eax
  801b56:	68 54 3e 80 00       	push   $0x803e54
  801b5b:	e8 b1 00 00 00       	call   801c11 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b60:	83 c4 18             	add    $0x18,%esp
  801b63:	53                   	push   %ebx
  801b64:	ff 75 10             	pushl  0x10(%ebp)
  801b67:	e8 54 00 00 00       	call   801bc0 <vcprintf>
	cprintf("\n");
  801b6c:	c7 04 24 63 3a 80 00 	movl   $0x803a63,(%esp)
  801b73:	e8 99 00 00 00       	call   801c11 <cprintf>
  801b78:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b7b:	cc                   	int3   
  801b7c:	eb fd                	jmp    801b7b <_panic+0x43>

00801b7e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	53                   	push   %ebx
  801b82:	83 ec 04             	sub    $0x4,%esp
  801b85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b88:	8b 13                	mov    (%ebx),%edx
  801b8a:	8d 42 01             	lea    0x1(%edx),%eax
  801b8d:	89 03                	mov    %eax,(%ebx)
  801b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b96:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b9b:	75 1a                	jne    801bb7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b9d:	83 ec 08             	sub    $0x8,%esp
  801ba0:	68 ff 00 00 00       	push   $0xff
  801ba5:	8d 43 08             	lea    0x8(%ebx),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 2f 09 00 00       	call   8024dd <sys_cputs>
		b->idx = 0;
  801bae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bb4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801bb7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801bbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801bc9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801bd0:	00 00 00 
	b.cnt = 0;
  801bd3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801bda:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801bdd:	ff 75 0c             	pushl  0xc(%ebp)
  801be0:	ff 75 08             	pushl  0x8(%ebp)
  801be3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801be9:	50                   	push   %eax
  801bea:	68 7e 1b 80 00       	push   $0x801b7e
  801bef:	e8 54 01 00 00       	call   801d48 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bf4:	83 c4 08             	add    $0x8,%esp
  801bf7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801bfd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801c03:	50                   	push   %eax
  801c04:	e8 d4 08 00 00       	call   8024dd <sys_cputs>

	return b.cnt;
}
  801c09:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c17:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c1a:	50                   	push   %eax
  801c1b:	ff 75 08             	pushl  0x8(%ebp)
  801c1e:	e8 9d ff ff ff       	call   801bc0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	57                   	push   %edi
  801c29:	56                   	push   %esi
  801c2a:	53                   	push   %ebx
  801c2b:	83 ec 1c             	sub    $0x1c,%esp
  801c2e:	89 c7                	mov    %eax,%edi
  801c30:	89 d6                	mov    %edx,%esi
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c38:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c3b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c41:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c46:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801c49:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801c4c:	39 d3                	cmp    %edx,%ebx
  801c4e:	72 05                	jb     801c55 <printnum+0x30>
  801c50:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c53:	77 45                	ja     801c9a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 18             	pushl  0x18(%ebp)
  801c5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801c5e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c61:	53                   	push   %ebx
  801c62:	ff 75 10             	pushl  0x10(%ebp)
  801c65:	83 ec 08             	sub    $0x8,%esp
  801c68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c6b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6e:	ff 75 dc             	pushl  -0x24(%ebp)
  801c71:	ff 75 d8             	pushl  -0x28(%ebp)
  801c74:	e8 97 19 00 00       	call   803610 <__udivdi3>
  801c79:	83 c4 18             	add    $0x18,%esp
  801c7c:	52                   	push   %edx
  801c7d:	50                   	push   %eax
  801c7e:	89 f2                	mov    %esi,%edx
  801c80:	89 f8                	mov    %edi,%eax
  801c82:	e8 9e ff ff ff       	call   801c25 <printnum>
  801c87:	83 c4 20             	add    $0x20,%esp
  801c8a:	eb 18                	jmp    801ca4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c8c:	83 ec 08             	sub    $0x8,%esp
  801c8f:	56                   	push   %esi
  801c90:	ff 75 18             	pushl  0x18(%ebp)
  801c93:	ff d7                	call   *%edi
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	eb 03                	jmp    801c9d <printnum+0x78>
  801c9a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c9d:	83 eb 01             	sub    $0x1,%ebx
  801ca0:	85 db                	test   %ebx,%ebx
  801ca2:	7f e8                	jg     801c8c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	56                   	push   %esi
  801ca8:	83 ec 04             	sub    $0x4,%esp
  801cab:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cae:	ff 75 e0             	pushl  -0x20(%ebp)
  801cb1:	ff 75 dc             	pushl  -0x24(%ebp)
  801cb4:	ff 75 d8             	pushl  -0x28(%ebp)
  801cb7:	e8 84 1a 00 00       	call   803740 <__umoddi3>
  801cbc:	83 c4 14             	add    $0x14,%esp
  801cbf:	0f be 80 77 3e 80 00 	movsbl 0x803e77(%eax),%eax
  801cc6:	50                   	push   %eax
  801cc7:	ff d7                	call   *%edi
}
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801cd7:	83 fa 01             	cmp    $0x1,%edx
  801cda:	7e 0e                	jle    801cea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801cdc:	8b 10                	mov    (%eax),%edx
  801cde:	8d 4a 08             	lea    0x8(%edx),%ecx
  801ce1:	89 08                	mov    %ecx,(%eax)
  801ce3:	8b 02                	mov    (%edx),%eax
  801ce5:	8b 52 04             	mov    0x4(%edx),%edx
  801ce8:	eb 22                	jmp    801d0c <getuint+0x38>
	else if (lflag)
  801cea:	85 d2                	test   %edx,%edx
  801cec:	74 10                	je     801cfe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801cee:	8b 10                	mov    (%eax),%edx
  801cf0:	8d 4a 04             	lea    0x4(%edx),%ecx
  801cf3:	89 08                	mov    %ecx,(%eax)
  801cf5:	8b 02                	mov    (%edx),%eax
  801cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cfc:	eb 0e                	jmp    801d0c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801cfe:	8b 10                	mov    (%eax),%edx
  801d00:	8d 4a 04             	lea    0x4(%edx),%ecx
  801d03:	89 08                	mov    %ecx,(%eax)
  801d05:	8b 02                	mov    (%edx),%eax
  801d07:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d14:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801d18:	8b 10                	mov    (%eax),%edx
  801d1a:	3b 50 04             	cmp    0x4(%eax),%edx
  801d1d:	73 0a                	jae    801d29 <sprintputch+0x1b>
		*b->buf++ = ch;
  801d1f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801d22:	89 08                	mov    %ecx,(%eax)
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	88 02                	mov    %al,(%edx)
}
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801d31:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801d34:	50                   	push   %eax
  801d35:	ff 75 10             	pushl  0x10(%ebp)
  801d38:	ff 75 0c             	pushl  0xc(%ebp)
  801d3b:	ff 75 08             	pushl  0x8(%ebp)
  801d3e:	e8 05 00 00 00       	call   801d48 <vprintfmt>
	va_end(ap);
}
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	57                   	push   %edi
  801d4c:	56                   	push   %esi
  801d4d:	53                   	push   %ebx
  801d4e:	83 ec 2c             	sub    $0x2c,%esp
  801d51:	8b 75 08             	mov    0x8(%ebp),%esi
  801d54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d57:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d5a:	eb 12                	jmp    801d6e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	0f 84 89 03 00 00    	je     8020ed <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801d64:	83 ec 08             	sub    $0x8,%esp
  801d67:	53                   	push   %ebx
  801d68:	50                   	push   %eax
  801d69:	ff d6                	call   *%esi
  801d6b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d6e:	83 c7 01             	add    $0x1,%edi
  801d71:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d75:	83 f8 25             	cmp    $0x25,%eax
  801d78:	75 e2                	jne    801d5c <vprintfmt+0x14>
  801d7a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801d7e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d85:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d8c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d93:	ba 00 00 00 00       	mov    $0x0,%edx
  801d98:	eb 07                	jmp    801da1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d9d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da1:	8d 47 01             	lea    0x1(%edi),%eax
  801da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801da7:	0f b6 07             	movzbl (%edi),%eax
  801daa:	0f b6 c8             	movzbl %al,%ecx
  801dad:	83 e8 23             	sub    $0x23,%eax
  801db0:	3c 55                	cmp    $0x55,%al
  801db2:	0f 87 1a 03 00 00    	ja     8020d2 <vprintfmt+0x38a>
  801db8:	0f b6 c0             	movzbl %al,%eax
  801dbb:	ff 24 85 c0 3f 80 00 	jmp    *0x803fc0(,%eax,4)
  801dc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801dc5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801dc9:	eb d6                	jmp    801da1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801dd6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801dd9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801ddd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801de0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801de3:	83 fa 09             	cmp    $0x9,%edx
  801de6:	77 39                	ja     801e21 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801de8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801deb:	eb e9                	jmp    801dd6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801ded:	8b 45 14             	mov    0x14(%ebp),%eax
  801df0:	8d 48 04             	lea    0x4(%eax),%ecx
  801df3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801df6:	8b 00                	mov    (%eax),%eax
  801df8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dfb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801dfe:	eb 27                	jmp    801e27 <vprintfmt+0xdf>
  801e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e03:	85 c0                	test   %eax,%eax
  801e05:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e0a:	0f 49 c8             	cmovns %eax,%ecx
  801e0d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e13:	eb 8c                	jmp    801da1 <vprintfmt+0x59>
  801e15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801e18:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801e1f:	eb 80                	jmp    801da1 <vprintfmt+0x59>
  801e21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e24:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801e27:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e2b:	0f 89 70 ff ff ff    	jns    801da1 <vprintfmt+0x59>
				width = precision, precision = -1;
  801e31:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e34:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e37:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801e3e:	e9 5e ff ff ff       	jmp    801da1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801e43:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801e49:	e9 53 ff ff ff       	jmp    801da1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801e4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e51:	8d 50 04             	lea    0x4(%eax),%edx
  801e54:	89 55 14             	mov    %edx,0x14(%ebp)
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	53                   	push   %ebx
  801e5b:	ff 30                	pushl  (%eax)
  801e5d:	ff d6                	call   *%esi
			break;
  801e5f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e65:	e9 04 ff ff ff       	jmp    801d6e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e6a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6d:	8d 50 04             	lea    0x4(%eax),%edx
  801e70:	89 55 14             	mov    %edx,0x14(%ebp)
  801e73:	8b 00                	mov    (%eax),%eax
  801e75:	99                   	cltd   
  801e76:	31 d0                	xor    %edx,%eax
  801e78:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e7a:	83 f8 0f             	cmp    $0xf,%eax
  801e7d:	7f 0b                	jg     801e8a <vprintfmt+0x142>
  801e7f:	8b 14 85 20 41 80 00 	mov    0x804120(,%eax,4),%edx
  801e86:	85 d2                	test   %edx,%edx
  801e88:	75 18                	jne    801ea2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801e8a:	50                   	push   %eax
  801e8b:	68 8f 3e 80 00       	push   $0x803e8f
  801e90:	53                   	push   %ebx
  801e91:	56                   	push   %esi
  801e92:	e8 94 fe ff ff       	call   801d2b <printfmt>
  801e97:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e9d:	e9 cc fe ff ff       	jmp    801d6e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801ea2:	52                   	push   %edx
  801ea3:	68 ef 38 80 00       	push   $0x8038ef
  801ea8:	53                   	push   %ebx
  801ea9:	56                   	push   %esi
  801eaa:	e8 7c fe ff ff       	call   801d2b <printfmt>
  801eaf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801eb5:	e9 b4 fe ff ff       	jmp    801d6e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801eba:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebd:	8d 50 04             	lea    0x4(%eax),%edx
  801ec0:	89 55 14             	mov    %edx,0x14(%ebp)
  801ec3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801ec5:	85 ff                	test   %edi,%edi
  801ec7:	b8 88 3e 80 00       	mov    $0x803e88,%eax
  801ecc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ecf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ed3:	0f 8e 94 00 00 00    	jle    801f6d <vprintfmt+0x225>
  801ed9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801edd:	0f 84 98 00 00 00    	je     801f7b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801ee3:	83 ec 08             	sub    $0x8,%esp
  801ee6:	ff 75 d0             	pushl  -0x30(%ebp)
  801ee9:	57                   	push   %edi
  801eea:	e8 86 02 00 00       	call   802175 <strnlen>
  801eef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ef2:	29 c1                	sub    %eax,%ecx
  801ef4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801ef7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801efa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801efe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f01:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801f04:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f06:	eb 0f                	jmp    801f17 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801f08:	83 ec 08             	sub    $0x8,%esp
  801f0b:	53                   	push   %ebx
  801f0c:	ff 75 e0             	pushl  -0x20(%ebp)
  801f0f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f11:	83 ef 01             	sub    $0x1,%edi
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	85 ff                	test   %edi,%edi
  801f19:	7f ed                	jg     801f08 <vprintfmt+0x1c0>
  801f1b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801f1e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801f21:	85 c9                	test   %ecx,%ecx
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
  801f28:	0f 49 c1             	cmovns %ecx,%eax
  801f2b:	29 c1                	sub    %eax,%ecx
  801f2d:	89 75 08             	mov    %esi,0x8(%ebp)
  801f30:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f33:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f36:	89 cb                	mov    %ecx,%ebx
  801f38:	eb 4d                	jmp    801f87 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801f3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801f3e:	74 1b                	je     801f5b <vprintfmt+0x213>
  801f40:	0f be c0             	movsbl %al,%eax
  801f43:	83 e8 20             	sub    $0x20,%eax
  801f46:	83 f8 5e             	cmp    $0x5e,%eax
  801f49:	76 10                	jbe    801f5b <vprintfmt+0x213>
					putch('?', putdat);
  801f4b:	83 ec 08             	sub    $0x8,%esp
  801f4e:	ff 75 0c             	pushl  0xc(%ebp)
  801f51:	6a 3f                	push   $0x3f
  801f53:	ff 55 08             	call   *0x8(%ebp)
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	eb 0d                	jmp    801f68 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	ff 75 0c             	pushl  0xc(%ebp)
  801f61:	52                   	push   %edx
  801f62:	ff 55 08             	call   *0x8(%ebp)
  801f65:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f68:	83 eb 01             	sub    $0x1,%ebx
  801f6b:	eb 1a                	jmp    801f87 <vprintfmt+0x23f>
  801f6d:	89 75 08             	mov    %esi,0x8(%ebp)
  801f70:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f73:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f76:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f79:	eb 0c                	jmp    801f87 <vprintfmt+0x23f>
  801f7b:	89 75 08             	mov    %esi,0x8(%ebp)
  801f7e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f81:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f84:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f87:	83 c7 01             	add    $0x1,%edi
  801f8a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f8e:	0f be d0             	movsbl %al,%edx
  801f91:	85 d2                	test   %edx,%edx
  801f93:	74 23                	je     801fb8 <vprintfmt+0x270>
  801f95:	85 f6                	test   %esi,%esi
  801f97:	78 a1                	js     801f3a <vprintfmt+0x1f2>
  801f99:	83 ee 01             	sub    $0x1,%esi
  801f9c:	79 9c                	jns    801f3a <vprintfmt+0x1f2>
  801f9e:	89 df                	mov    %ebx,%edi
  801fa0:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fa6:	eb 18                	jmp    801fc0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801fa8:	83 ec 08             	sub    $0x8,%esp
  801fab:	53                   	push   %ebx
  801fac:	6a 20                	push   $0x20
  801fae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801fb0:	83 ef 01             	sub    $0x1,%edi
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	eb 08                	jmp    801fc0 <vprintfmt+0x278>
  801fb8:	89 df                	mov    %ebx,%edi
  801fba:	8b 75 08             	mov    0x8(%ebp),%esi
  801fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fc0:	85 ff                	test   %edi,%edi
  801fc2:	7f e4                	jg     801fa8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801fc7:	e9 a2 fd ff ff       	jmp    801d6e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801fcc:	83 fa 01             	cmp    $0x1,%edx
  801fcf:	7e 16                	jle    801fe7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801fd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd4:	8d 50 08             	lea    0x8(%eax),%edx
  801fd7:	89 55 14             	mov    %edx,0x14(%ebp)
  801fda:	8b 50 04             	mov    0x4(%eax),%edx
  801fdd:	8b 00                	mov    (%eax),%eax
  801fdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fe2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801fe5:	eb 32                	jmp    802019 <vprintfmt+0x2d1>
	else if (lflag)
  801fe7:	85 d2                	test   %edx,%edx
  801fe9:	74 18                	je     802003 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801feb:	8b 45 14             	mov    0x14(%ebp),%eax
  801fee:	8d 50 04             	lea    0x4(%eax),%edx
  801ff1:	89 55 14             	mov    %edx,0x14(%ebp)
  801ff4:	8b 00                	mov    (%eax),%eax
  801ff6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ff9:	89 c1                	mov    %eax,%ecx
  801ffb:	c1 f9 1f             	sar    $0x1f,%ecx
  801ffe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802001:	eb 16                	jmp    802019 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  802003:	8b 45 14             	mov    0x14(%ebp),%eax
  802006:	8d 50 04             	lea    0x4(%eax),%edx
  802009:	89 55 14             	mov    %edx,0x14(%ebp)
  80200c:	8b 00                	mov    (%eax),%eax
  80200e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802011:	89 c1                	mov    %eax,%ecx
  802013:	c1 f9 1f             	sar    $0x1f,%ecx
  802016:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  802019:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80201c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80201f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  802024:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802028:	79 74                	jns    80209e <vprintfmt+0x356>
				putch('-', putdat);
  80202a:	83 ec 08             	sub    $0x8,%esp
  80202d:	53                   	push   %ebx
  80202e:	6a 2d                	push   $0x2d
  802030:	ff d6                	call   *%esi
				num = -(long long) num;
  802032:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802035:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802038:	f7 d8                	neg    %eax
  80203a:	83 d2 00             	adc    $0x0,%edx
  80203d:	f7 da                	neg    %edx
  80203f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  802042:	b9 0a 00 00 00       	mov    $0xa,%ecx
  802047:	eb 55                	jmp    80209e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802049:	8d 45 14             	lea    0x14(%ebp),%eax
  80204c:	e8 83 fc ff ff       	call   801cd4 <getuint>
			base = 10;
  802051:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  802056:	eb 46                	jmp    80209e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  802058:	8d 45 14             	lea    0x14(%ebp),%eax
  80205b:	e8 74 fc ff ff       	call   801cd4 <getuint>
			base = 8;
  802060:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  802065:	eb 37                	jmp    80209e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  802067:	83 ec 08             	sub    $0x8,%esp
  80206a:	53                   	push   %ebx
  80206b:	6a 30                	push   $0x30
  80206d:	ff d6                	call   *%esi
			putch('x', putdat);
  80206f:	83 c4 08             	add    $0x8,%esp
  802072:	53                   	push   %ebx
  802073:	6a 78                	push   $0x78
  802075:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802077:	8b 45 14             	mov    0x14(%ebp),%eax
  80207a:	8d 50 04             	lea    0x4(%eax),%edx
  80207d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802080:	8b 00                	mov    (%eax),%eax
  802082:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802087:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80208a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80208f:	eb 0d                	jmp    80209e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802091:	8d 45 14             	lea    0x14(%ebp),%eax
  802094:	e8 3b fc ff ff       	call   801cd4 <getuint>
			base = 16;
  802099:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80209e:	83 ec 0c             	sub    $0xc,%esp
  8020a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8020a5:	57                   	push   %edi
  8020a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8020a9:	51                   	push   %ecx
  8020aa:	52                   	push   %edx
  8020ab:	50                   	push   %eax
  8020ac:	89 da                	mov    %ebx,%edx
  8020ae:	89 f0                	mov    %esi,%eax
  8020b0:	e8 70 fb ff ff       	call   801c25 <printnum>
			break;
  8020b5:	83 c4 20             	add    $0x20,%esp
  8020b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8020bb:	e9 ae fc ff ff       	jmp    801d6e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020c0:	83 ec 08             	sub    $0x8,%esp
  8020c3:	53                   	push   %ebx
  8020c4:	51                   	push   %ecx
  8020c5:	ff d6                	call   *%esi
			break;
  8020c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020cd:	e9 9c fc ff ff       	jmp    801d6e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020d2:	83 ec 08             	sub    $0x8,%esp
  8020d5:	53                   	push   %ebx
  8020d6:	6a 25                	push   $0x25
  8020d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	eb 03                	jmp    8020e2 <vprintfmt+0x39a>
  8020df:	83 ef 01             	sub    $0x1,%edi
  8020e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8020e6:	75 f7                	jne    8020df <vprintfmt+0x397>
  8020e8:	e9 81 fc ff ff       	jmp    801d6e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8020ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    

008020f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 18             	sub    $0x18,%esp
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802101:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802104:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802108:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80210b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802112:	85 c0                	test   %eax,%eax
  802114:	74 26                	je     80213c <vsnprintf+0x47>
  802116:	85 d2                	test   %edx,%edx
  802118:	7e 22                	jle    80213c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80211a:	ff 75 14             	pushl  0x14(%ebp)
  80211d:	ff 75 10             	pushl  0x10(%ebp)
  802120:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802123:	50                   	push   %eax
  802124:	68 0e 1d 80 00       	push   $0x801d0e
  802129:	e8 1a fc ff ff       	call   801d48 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80212e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802131:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802134:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	eb 05                	jmp    802141 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80213c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802141:	c9                   	leave  
  802142:	c3                   	ret    

00802143 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802149:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80214c:	50                   	push   %eax
  80214d:	ff 75 10             	pushl  0x10(%ebp)
  802150:	ff 75 0c             	pushl  0xc(%ebp)
  802153:	ff 75 08             	pushl  0x8(%ebp)
  802156:	e8 9a ff ff ff       	call   8020f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    

0080215d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	eb 03                	jmp    80216d <strlen+0x10>
		n++;
  80216a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80216d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802171:	75 f7                	jne    80216a <strlen+0xd>
		n++;
	return n;
}
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    

00802175 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80217e:	ba 00 00 00 00       	mov    $0x0,%edx
  802183:	eb 03                	jmp    802188 <strnlen+0x13>
		n++;
  802185:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802188:	39 c2                	cmp    %eax,%edx
  80218a:	74 08                	je     802194 <strnlen+0x1f>
  80218c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802190:	75 f3                	jne    802185 <strnlen+0x10>
  802192:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    

00802196 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	53                   	push   %ebx
  80219a:	8b 45 08             	mov    0x8(%ebp),%eax
  80219d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8021a0:	89 c2                	mov    %eax,%edx
  8021a2:	83 c2 01             	add    $0x1,%edx
  8021a5:	83 c1 01             	add    $0x1,%ecx
  8021a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8021ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8021af:	84 db                	test   %bl,%bl
  8021b1:	75 ef                	jne    8021a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8021b3:	5b                   	pop    %ebx
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    

008021b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	53                   	push   %ebx
  8021ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021bd:	53                   	push   %ebx
  8021be:	e8 9a ff ff ff       	call   80215d <strlen>
  8021c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8021c6:	ff 75 0c             	pushl  0xc(%ebp)
  8021c9:	01 d8                	add    %ebx,%eax
  8021cb:	50                   	push   %eax
  8021cc:	e8 c5 ff ff ff       	call   802196 <strcpy>
	return dst;
}
  8021d1:	89 d8                	mov    %ebx,%eax
  8021d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d6:	c9                   	leave  
  8021d7:	c3                   	ret    

008021d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	56                   	push   %esi
  8021dc:	53                   	push   %ebx
  8021dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8021e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021e3:	89 f3                	mov    %esi,%ebx
  8021e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021e8:	89 f2                	mov    %esi,%edx
  8021ea:	eb 0f                	jmp    8021fb <strncpy+0x23>
		*dst++ = *src;
  8021ec:	83 c2 01             	add    $0x1,%edx
  8021ef:	0f b6 01             	movzbl (%ecx),%eax
  8021f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8021f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8021f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021fb:	39 da                	cmp    %ebx,%edx
  8021fd:	75 ed                	jne    8021ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8021ff:	89 f0                	mov    %esi,%eax
  802201:	5b                   	pop    %ebx
  802202:	5e                   	pop    %esi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    

00802205 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	56                   	push   %esi
  802209:	53                   	push   %ebx
  80220a:	8b 75 08             	mov    0x8(%ebp),%esi
  80220d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802210:	8b 55 10             	mov    0x10(%ebp),%edx
  802213:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802215:	85 d2                	test   %edx,%edx
  802217:	74 21                	je     80223a <strlcpy+0x35>
  802219:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	eb 09                	jmp    80222a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802221:	83 c2 01             	add    $0x1,%edx
  802224:	83 c1 01             	add    $0x1,%ecx
  802227:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80222a:	39 c2                	cmp    %eax,%edx
  80222c:	74 09                	je     802237 <strlcpy+0x32>
  80222e:	0f b6 19             	movzbl (%ecx),%ebx
  802231:	84 db                	test   %bl,%bl
  802233:	75 ec                	jne    802221 <strlcpy+0x1c>
  802235:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802237:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80223a:	29 f0                	sub    %esi,%eax
}
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5d                   	pop    %ebp
  80223f:	c3                   	ret    

00802240 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802246:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802249:	eb 06                	jmp    802251 <strcmp+0x11>
		p++, q++;
  80224b:	83 c1 01             	add    $0x1,%ecx
  80224e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802251:	0f b6 01             	movzbl (%ecx),%eax
  802254:	84 c0                	test   %al,%al
  802256:	74 04                	je     80225c <strcmp+0x1c>
  802258:	3a 02                	cmp    (%edx),%al
  80225a:	74 ef                	je     80224b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80225c:	0f b6 c0             	movzbl %al,%eax
  80225f:	0f b6 12             	movzbl (%edx),%edx
  802262:	29 d0                	sub    %edx,%eax
}
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	53                   	push   %ebx
  80226a:	8b 45 08             	mov    0x8(%ebp),%eax
  80226d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802270:	89 c3                	mov    %eax,%ebx
  802272:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802275:	eb 06                	jmp    80227d <strncmp+0x17>
		n--, p++, q++;
  802277:	83 c0 01             	add    $0x1,%eax
  80227a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80227d:	39 d8                	cmp    %ebx,%eax
  80227f:	74 15                	je     802296 <strncmp+0x30>
  802281:	0f b6 08             	movzbl (%eax),%ecx
  802284:	84 c9                	test   %cl,%cl
  802286:	74 04                	je     80228c <strncmp+0x26>
  802288:	3a 0a                	cmp    (%edx),%cl
  80228a:	74 eb                	je     802277 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80228c:	0f b6 00             	movzbl (%eax),%eax
  80228f:	0f b6 12             	movzbl (%edx),%edx
  802292:	29 d0                	sub    %edx,%eax
  802294:	eb 05                	jmp    80229b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802296:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80229b:	5b                   	pop    %ebx
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    

0080229e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022a8:	eb 07                	jmp    8022b1 <strchr+0x13>
		if (*s == c)
  8022aa:	38 ca                	cmp    %cl,%dl
  8022ac:	74 0f                	je     8022bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8022ae:	83 c0 01             	add    $0x1,%eax
  8022b1:	0f b6 10             	movzbl (%eax),%edx
  8022b4:	84 d2                	test   %dl,%dl
  8022b6:	75 f2                	jne    8022aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8022b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022c9:	eb 03                	jmp    8022ce <strfind+0xf>
  8022cb:	83 c0 01             	add    $0x1,%eax
  8022ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022d1:	38 ca                	cmp    %cl,%dl
  8022d3:	74 04                	je     8022d9 <strfind+0x1a>
  8022d5:	84 d2                	test   %dl,%dl
  8022d7:	75 f2                	jne    8022cb <strfind+0xc>
			break;
	return (char *) s;
}
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    

008022db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	57                   	push   %edi
  8022df:	56                   	push   %esi
  8022e0:	53                   	push   %ebx
  8022e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8022e7:	85 c9                	test   %ecx,%ecx
  8022e9:	74 36                	je     802321 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8022eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022f1:	75 28                	jne    80231b <memset+0x40>
  8022f3:	f6 c1 03             	test   $0x3,%cl
  8022f6:	75 23                	jne    80231b <memset+0x40>
		c &= 0xFF;
  8022f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8022fc:	89 d3                	mov    %edx,%ebx
  8022fe:	c1 e3 08             	shl    $0x8,%ebx
  802301:	89 d6                	mov    %edx,%esi
  802303:	c1 e6 18             	shl    $0x18,%esi
  802306:	89 d0                	mov    %edx,%eax
  802308:	c1 e0 10             	shl    $0x10,%eax
  80230b:	09 f0                	or     %esi,%eax
  80230d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80230f:	89 d8                	mov    %ebx,%eax
  802311:	09 d0                	or     %edx,%eax
  802313:	c1 e9 02             	shr    $0x2,%ecx
  802316:	fc                   	cld    
  802317:	f3 ab                	rep stos %eax,%es:(%edi)
  802319:	eb 06                	jmp    802321 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80231b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231e:	fc                   	cld    
  80231f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802321:	89 f8                	mov    %edi,%eax
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    

00802328 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	57                   	push   %edi
  80232c:	56                   	push   %esi
  80232d:	8b 45 08             	mov    0x8(%ebp),%eax
  802330:	8b 75 0c             	mov    0xc(%ebp),%esi
  802333:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802336:	39 c6                	cmp    %eax,%esi
  802338:	73 35                	jae    80236f <memmove+0x47>
  80233a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80233d:	39 d0                	cmp    %edx,%eax
  80233f:	73 2e                	jae    80236f <memmove+0x47>
		s += n;
		d += n;
  802341:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802344:	89 d6                	mov    %edx,%esi
  802346:	09 fe                	or     %edi,%esi
  802348:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80234e:	75 13                	jne    802363 <memmove+0x3b>
  802350:	f6 c1 03             	test   $0x3,%cl
  802353:	75 0e                	jne    802363 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802355:	83 ef 04             	sub    $0x4,%edi
  802358:	8d 72 fc             	lea    -0x4(%edx),%esi
  80235b:	c1 e9 02             	shr    $0x2,%ecx
  80235e:	fd                   	std    
  80235f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802361:	eb 09                	jmp    80236c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802363:	83 ef 01             	sub    $0x1,%edi
  802366:	8d 72 ff             	lea    -0x1(%edx),%esi
  802369:	fd                   	std    
  80236a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80236c:	fc                   	cld    
  80236d:	eb 1d                	jmp    80238c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80236f:	89 f2                	mov    %esi,%edx
  802371:	09 c2                	or     %eax,%edx
  802373:	f6 c2 03             	test   $0x3,%dl
  802376:	75 0f                	jne    802387 <memmove+0x5f>
  802378:	f6 c1 03             	test   $0x3,%cl
  80237b:	75 0a                	jne    802387 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80237d:	c1 e9 02             	shr    $0x2,%ecx
  802380:	89 c7                	mov    %eax,%edi
  802382:	fc                   	cld    
  802383:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802385:	eb 05                	jmp    80238c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802387:	89 c7                	mov    %eax,%edi
  802389:	fc                   	cld    
  80238a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80238c:	5e                   	pop    %esi
  80238d:	5f                   	pop    %edi
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802393:	ff 75 10             	pushl  0x10(%ebp)
  802396:	ff 75 0c             	pushl  0xc(%ebp)
  802399:	ff 75 08             	pushl  0x8(%ebp)
  80239c:	e8 87 ff ff ff       	call   802328 <memmove>
}
  8023a1:	c9                   	leave  
  8023a2:	c3                   	ret    

008023a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8023a3:	55                   	push   %ebp
  8023a4:	89 e5                	mov    %esp,%ebp
  8023a6:	56                   	push   %esi
  8023a7:	53                   	push   %ebx
  8023a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ae:	89 c6                	mov    %eax,%esi
  8023b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023b3:	eb 1a                	jmp    8023cf <memcmp+0x2c>
		if (*s1 != *s2)
  8023b5:	0f b6 08             	movzbl (%eax),%ecx
  8023b8:	0f b6 1a             	movzbl (%edx),%ebx
  8023bb:	38 d9                	cmp    %bl,%cl
  8023bd:	74 0a                	je     8023c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8023bf:	0f b6 c1             	movzbl %cl,%eax
  8023c2:	0f b6 db             	movzbl %bl,%ebx
  8023c5:	29 d8                	sub    %ebx,%eax
  8023c7:	eb 0f                	jmp    8023d8 <memcmp+0x35>
		s1++, s2++;
  8023c9:	83 c0 01             	add    $0x1,%eax
  8023cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023cf:	39 f0                	cmp    %esi,%eax
  8023d1:	75 e2                	jne    8023b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8023d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    

008023dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	53                   	push   %ebx
  8023e0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8023e3:	89 c1                	mov    %eax,%ecx
  8023e5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8023e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023ec:	eb 0a                	jmp    8023f8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8023ee:	0f b6 10             	movzbl (%eax),%edx
  8023f1:	39 da                	cmp    %ebx,%edx
  8023f3:	74 07                	je     8023fc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023f5:	83 c0 01             	add    $0x1,%eax
  8023f8:	39 c8                	cmp    %ecx,%eax
  8023fa:	72 f2                	jb     8023ee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8023fc:	5b                   	pop    %ebx
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	57                   	push   %edi
  802403:	56                   	push   %esi
  802404:	53                   	push   %ebx
  802405:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802408:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80240b:	eb 03                	jmp    802410 <strtol+0x11>
		s++;
  80240d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802410:	0f b6 01             	movzbl (%ecx),%eax
  802413:	3c 20                	cmp    $0x20,%al
  802415:	74 f6                	je     80240d <strtol+0xe>
  802417:	3c 09                	cmp    $0x9,%al
  802419:	74 f2                	je     80240d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80241b:	3c 2b                	cmp    $0x2b,%al
  80241d:	75 0a                	jne    802429 <strtol+0x2a>
		s++;
  80241f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802422:	bf 00 00 00 00       	mov    $0x0,%edi
  802427:	eb 11                	jmp    80243a <strtol+0x3b>
  802429:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80242e:	3c 2d                	cmp    $0x2d,%al
  802430:	75 08                	jne    80243a <strtol+0x3b>
		s++, neg = 1;
  802432:	83 c1 01             	add    $0x1,%ecx
  802435:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80243a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802440:	75 15                	jne    802457 <strtol+0x58>
  802442:	80 39 30             	cmpb   $0x30,(%ecx)
  802445:	75 10                	jne    802457 <strtol+0x58>
  802447:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80244b:	75 7c                	jne    8024c9 <strtol+0xca>
		s += 2, base = 16;
  80244d:	83 c1 02             	add    $0x2,%ecx
  802450:	bb 10 00 00 00       	mov    $0x10,%ebx
  802455:	eb 16                	jmp    80246d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  802457:	85 db                	test   %ebx,%ebx
  802459:	75 12                	jne    80246d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80245b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802460:	80 39 30             	cmpb   $0x30,(%ecx)
  802463:	75 08                	jne    80246d <strtol+0x6e>
		s++, base = 8;
  802465:	83 c1 01             	add    $0x1,%ecx
  802468:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80246d:	b8 00 00 00 00       	mov    $0x0,%eax
  802472:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802475:	0f b6 11             	movzbl (%ecx),%edx
  802478:	8d 72 d0             	lea    -0x30(%edx),%esi
  80247b:	89 f3                	mov    %esi,%ebx
  80247d:	80 fb 09             	cmp    $0x9,%bl
  802480:	77 08                	ja     80248a <strtol+0x8b>
			dig = *s - '0';
  802482:	0f be d2             	movsbl %dl,%edx
  802485:	83 ea 30             	sub    $0x30,%edx
  802488:	eb 22                	jmp    8024ac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80248a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80248d:	89 f3                	mov    %esi,%ebx
  80248f:	80 fb 19             	cmp    $0x19,%bl
  802492:	77 08                	ja     80249c <strtol+0x9d>
			dig = *s - 'a' + 10;
  802494:	0f be d2             	movsbl %dl,%edx
  802497:	83 ea 57             	sub    $0x57,%edx
  80249a:	eb 10                	jmp    8024ac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80249c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80249f:	89 f3                	mov    %esi,%ebx
  8024a1:	80 fb 19             	cmp    $0x19,%bl
  8024a4:	77 16                	ja     8024bc <strtol+0xbd>
			dig = *s - 'A' + 10;
  8024a6:	0f be d2             	movsbl %dl,%edx
  8024a9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8024ac:	3b 55 10             	cmp    0x10(%ebp),%edx
  8024af:	7d 0b                	jge    8024bc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8024b1:	83 c1 01             	add    $0x1,%ecx
  8024b4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8024b8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8024ba:	eb b9                	jmp    802475 <strtol+0x76>

	if (endptr)
  8024bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024c0:	74 0d                	je     8024cf <strtol+0xd0>
		*endptr = (char *) s;
  8024c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c5:	89 0e                	mov    %ecx,(%esi)
  8024c7:	eb 06                	jmp    8024cf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024c9:	85 db                	test   %ebx,%ebx
  8024cb:	74 98                	je     802465 <strtol+0x66>
  8024cd:	eb 9e                	jmp    80246d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8024cf:	89 c2                	mov    %eax,%edx
  8024d1:	f7 da                	neg    %edx
  8024d3:	85 ff                	test   %edi,%edi
  8024d5:	0f 45 c2             	cmovne %edx,%eax
}
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    

008024dd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024dd:	55                   	push   %ebp
  8024de:	89 e5                	mov    %esp,%ebp
  8024e0:	57                   	push   %edi
  8024e1:	56                   	push   %esi
  8024e2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ee:	89 c3                	mov    %eax,%ebx
  8024f0:	89 c7                	mov    %eax,%edi
  8024f2:	89 c6                	mov    %eax,%esi
  8024f4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024f6:	5b                   	pop    %ebx
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    

008024fb <sys_cgetc>:

int
sys_cgetc(void)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
  8024fe:	57                   	push   %edi
  8024ff:	56                   	push   %esi
  802500:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802501:	ba 00 00 00 00       	mov    $0x0,%edx
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	89 d1                	mov    %edx,%ecx
  80250d:	89 d3                	mov    %edx,%ebx
  80250f:	89 d7                	mov    %edx,%edi
  802511:	89 d6                	mov    %edx,%esi
  802513:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    

0080251a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80251a:	55                   	push   %ebp
  80251b:	89 e5                	mov    %esp,%ebp
  80251d:	57                   	push   %edi
  80251e:	56                   	push   %esi
  80251f:	53                   	push   %ebx
  802520:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802523:	b9 00 00 00 00       	mov    $0x0,%ecx
  802528:	b8 03 00 00 00       	mov    $0x3,%eax
  80252d:	8b 55 08             	mov    0x8(%ebp),%edx
  802530:	89 cb                	mov    %ecx,%ebx
  802532:	89 cf                	mov    %ecx,%edi
  802534:	89 ce                	mov    %ecx,%esi
  802536:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802538:	85 c0                	test   %eax,%eax
  80253a:	7e 17                	jle    802553 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80253c:	83 ec 0c             	sub    $0xc,%esp
  80253f:	50                   	push   %eax
  802540:	6a 03                	push   $0x3
  802542:	68 7f 41 80 00       	push   $0x80417f
  802547:	6a 23                	push   $0x23
  802549:	68 9c 41 80 00       	push   $0x80419c
  80254e:	e8 e5 f5 ff ff       	call   801b38 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802553:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802556:	5b                   	pop    %ebx
  802557:	5e                   	pop    %esi
  802558:	5f                   	pop    %edi
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    

0080255b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80255b:	55                   	push   %ebp
  80255c:	89 e5                	mov    %esp,%ebp
  80255e:	57                   	push   %edi
  80255f:	56                   	push   %esi
  802560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802561:	ba 00 00 00 00       	mov    $0x0,%edx
  802566:	b8 02 00 00 00       	mov    $0x2,%eax
  80256b:	89 d1                	mov    %edx,%ecx
  80256d:	89 d3                	mov    %edx,%ebx
  80256f:	89 d7                	mov    %edx,%edi
  802571:	89 d6                	mov    %edx,%esi
  802573:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802575:	5b                   	pop    %ebx
  802576:	5e                   	pop    %esi
  802577:	5f                   	pop    %edi
  802578:	5d                   	pop    %ebp
  802579:	c3                   	ret    

0080257a <sys_yield>:

void
sys_yield(void)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	57                   	push   %edi
  80257e:	56                   	push   %esi
  80257f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802580:	ba 00 00 00 00       	mov    $0x0,%edx
  802585:	b8 0b 00 00 00       	mov    $0xb,%eax
  80258a:	89 d1                	mov    %edx,%ecx
  80258c:	89 d3                	mov    %edx,%ebx
  80258e:	89 d7                	mov    %edx,%edi
  802590:	89 d6                	mov    %edx,%esi
  802592:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802594:	5b                   	pop    %ebx
  802595:	5e                   	pop    %esi
  802596:	5f                   	pop    %edi
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    

00802599 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802599:	55                   	push   %ebp
  80259a:	89 e5                	mov    %esp,%ebp
  80259c:	57                   	push   %edi
  80259d:	56                   	push   %esi
  80259e:	53                   	push   %ebx
  80259f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025a2:	be 00 00 00 00       	mov    $0x0,%esi
  8025a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8025ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025af:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b5:	89 f7                	mov    %esi,%edi
  8025b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025b9:	85 c0                	test   %eax,%eax
  8025bb:	7e 17                	jle    8025d4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025bd:	83 ec 0c             	sub    $0xc,%esp
  8025c0:	50                   	push   %eax
  8025c1:	6a 04                	push   $0x4
  8025c3:	68 7f 41 80 00       	push   $0x80417f
  8025c8:	6a 23                	push   $0x23
  8025ca:	68 9c 41 80 00       	push   $0x80419c
  8025cf:	e8 64 f5 ff ff       	call   801b38 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d7:	5b                   	pop    %ebx
  8025d8:	5e                   	pop    %esi
  8025d9:	5f                   	pop    %edi
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    

008025dc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025dc:	55                   	push   %ebp
  8025dd:	89 e5                	mov    %esp,%ebp
  8025df:	57                   	push   %edi
  8025e0:	56                   	push   %esi
  8025e1:	53                   	push   %ebx
  8025e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8025ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8025f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025f6:	8b 75 18             	mov    0x18(%ebp),%esi
  8025f9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	7e 17                	jle    802616 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025ff:	83 ec 0c             	sub    $0xc,%esp
  802602:	50                   	push   %eax
  802603:	6a 05                	push   $0x5
  802605:	68 7f 41 80 00       	push   $0x80417f
  80260a:	6a 23                	push   $0x23
  80260c:	68 9c 41 80 00       	push   $0x80419c
  802611:	e8 22 f5 ff ff       	call   801b38 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802616:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802619:	5b                   	pop    %ebx
  80261a:	5e                   	pop    %esi
  80261b:	5f                   	pop    %edi
  80261c:	5d                   	pop    %ebp
  80261d:	c3                   	ret    

0080261e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80261e:	55                   	push   %ebp
  80261f:	89 e5                	mov    %esp,%ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	53                   	push   %ebx
  802624:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802627:	bb 00 00 00 00       	mov    $0x0,%ebx
  80262c:	b8 06 00 00 00       	mov    $0x6,%eax
  802631:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802634:	8b 55 08             	mov    0x8(%ebp),%edx
  802637:	89 df                	mov    %ebx,%edi
  802639:	89 de                	mov    %ebx,%esi
  80263b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80263d:	85 c0                	test   %eax,%eax
  80263f:	7e 17                	jle    802658 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802641:	83 ec 0c             	sub    $0xc,%esp
  802644:	50                   	push   %eax
  802645:	6a 06                	push   $0x6
  802647:	68 7f 41 80 00       	push   $0x80417f
  80264c:	6a 23                	push   $0x23
  80264e:	68 9c 41 80 00       	push   $0x80419c
  802653:	e8 e0 f4 ff ff       	call   801b38 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80265b:	5b                   	pop    %ebx
  80265c:	5e                   	pop    %esi
  80265d:	5f                   	pop    %edi
  80265e:	5d                   	pop    %ebp
  80265f:	c3                   	ret    

00802660 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	57                   	push   %edi
  802664:	56                   	push   %esi
  802665:	53                   	push   %ebx
  802666:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802669:	bb 00 00 00 00       	mov    $0x0,%ebx
  80266e:	b8 08 00 00 00       	mov    $0x8,%eax
  802673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802676:	8b 55 08             	mov    0x8(%ebp),%edx
  802679:	89 df                	mov    %ebx,%edi
  80267b:	89 de                	mov    %ebx,%esi
  80267d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80267f:	85 c0                	test   %eax,%eax
  802681:	7e 17                	jle    80269a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802683:	83 ec 0c             	sub    $0xc,%esp
  802686:	50                   	push   %eax
  802687:	6a 08                	push   $0x8
  802689:	68 7f 41 80 00       	push   $0x80417f
  80268e:	6a 23                	push   $0x23
  802690:	68 9c 41 80 00       	push   $0x80419c
  802695:	e8 9e f4 ff ff       	call   801b38 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80269a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    

008026a2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8026a2:	55                   	push   %ebp
  8026a3:	89 e5                	mov    %esp,%ebp
  8026a5:	57                   	push   %edi
  8026a6:	56                   	push   %esi
  8026a7:	53                   	push   %ebx
  8026a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026b0:	b8 09 00 00 00       	mov    $0x9,%eax
  8026b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8026bb:	89 df                	mov    %ebx,%edi
  8026bd:	89 de                	mov    %ebx,%esi
  8026bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026c1:	85 c0                	test   %eax,%eax
  8026c3:	7e 17                	jle    8026dc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026c5:	83 ec 0c             	sub    $0xc,%esp
  8026c8:	50                   	push   %eax
  8026c9:	6a 09                	push   $0x9
  8026cb:	68 7f 41 80 00       	push   $0x80417f
  8026d0:	6a 23                	push   $0x23
  8026d2:	68 9c 41 80 00       	push   $0x80419c
  8026d7:	e8 5c f4 ff ff       	call   801b38 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026df:	5b                   	pop    %ebx
  8026e0:	5e                   	pop    %esi
  8026e1:	5f                   	pop    %edi
  8026e2:	5d                   	pop    %ebp
  8026e3:	c3                   	ret    

008026e4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026e4:	55                   	push   %ebp
  8026e5:	89 e5                	mov    %esp,%ebp
  8026e7:	57                   	push   %edi
  8026e8:	56                   	push   %esi
  8026e9:	53                   	push   %ebx
  8026ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8026f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8026fd:	89 df                	mov    %ebx,%edi
  8026ff:	89 de                	mov    %ebx,%esi
  802701:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802703:	85 c0                	test   %eax,%eax
  802705:	7e 17                	jle    80271e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802707:	83 ec 0c             	sub    $0xc,%esp
  80270a:	50                   	push   %eax
  80270b:	6a 0a                	push   $0xa
  80270d:	68 7f 41 80 00       	push   $0x80417f
  802712:	6a 23                	push   $0x23
  802714:	68 9c 41 80 00       	push   $0x80419c
  802719:	e8 1a f4 ff ff       	call   801b38 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80271e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802721:	5b                   	pop    %ebx
  802722:	5e                   	pop    %esi
  802723:	5f                   	pop    %edi
  802724:	5d                   	pop    %ebp
  802725:	c3                   	ret    

00802726 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802726:	55                   	push   %ebp
  802727:	89 e5                	mov    %esp,%ebp
  802729:	57                   	push   %edi
  80272a:	56                   	push   %esi
  80272b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80272c:	be 00 00 00 00       	mov    $0x0,%esi
  802731:	b8 0c 00 00 00       	mov    $0xc,%eax
  802736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802739:	8b 55 08             	mov    0x8(%ebp),%edx
  80273c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80273f:	8b 7d 14             	mov    0x14(%ebp),%edi
  802742:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802744:	5b                   	pop    %ebx
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    

00802749 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802749:	55                   	push   %ebp
  80274a:	89 e5                	mov    %esp,%ebp
  80274c:	57                   	push   %edi
  80274d:	56                   	push   %esi
  80274e:	53                   	push   %ebx
  80274f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802752:	b9 00 00 00 00       	mov    $0x0,%ecx
  802757:	b8 0d 00 00 00       	mov    $0xd,%eax
  80275c:	8b 55 08             	mov    0x8(%ebp),%edx
  80275f:	89 cb                	mov    %ecx,%ebx
  802761:	89 cf                	mov    %ecx,%edi
  802763:	89 ce                	mov    %ecx,%esi
  802765:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802767:	85 c0                	test   %eax,%eax
  802769:	7e 17                	jle    802782 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80276b:	83 ec 0c             	sub    $0xc,%esp
  80276e:	50                   	push   %eax
  80276f:	6a 0d                	push   $0xd
  802771:	68 7f 41 80 00       	push   $0x80417f
  802776:	6a 23                	push   $0x23
  802778:	68 9c 41 80 00       	push   $0x80419c
  80277d:	e8 b6 f3 ff ff       	call   801b38 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802782:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802785:	5b                   	pop    %ebx
  802786:	5e                   	pop    %esi
  802787:	5f                   	pop    %edi
  802788:	5d                   	pop    %ebp
  802789:	c3                   	ret    

0080278a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80278a:	55                   	push   %ebp
  80278b:	89 e5                	mov    %esp,%ebp
  80278d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802790:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802797:	75 2e                	jne    8027c7 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802799:	e8 bd fd ff ff       	call   80255b <sys_getenvid>
  80279e:	83 ec 04             	sub    $0x4,%esp
  8027a1:	68 07 0e 00 00       	push   $0xe07
  8027a6:	68 00 f0 bf ee       	push   $0xeebff000
  8027ab:	50                   	push   %eax
  8027ac:	e8 e8 fd ff ff       	call   802599 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8027b1:	e8 a5 fd ff ff       	call   80255b <sys_getenvid>
  8027b6:	83 c4 08             	add    $0x8,%esp
  8027b9:	68 d1 27 80 00       	push   $0x8027d1
  8027be:	50                   	push   %eax
  8027bf:	e8 20 ff ff ff       	call   8026e4 <sys_env_set_pgfault_upcall>
  8027c4:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ca:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  8027cf:	c9                   	leave  
  8027d0:	c3                   	ret    

008027d1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027d1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027d2:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8027d7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027d9:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8027dc:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8027e0:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8027e4:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8027e7:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8027ea:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8027eb:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8027ee:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8027ef:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8027f0:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8027f4:	c3                   	ret    

008027f5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027f5:	55                   	push   %ebp
  8027f6:	89 e5                	mov    %esp,%ebp
  8027f8:	56                   	push   %esi
  8027f9:	53                   	push   %ebx
  8027fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8027fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802800:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802803:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802805:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80280a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80280d:	83 ec 0c             	sub    $0xc,%esp
  802810:	50                   	push   %eax
  802811:	e8 33 ff ff ff       	call   802749 <sys_ipc_recv>

	if (from_env_store != NULL)
  802816:	83 c4 10             	add    $0x10,%esp
  802819:	85 f6                	test   %esi,%esi
  80281b:	74 14                	je     802831 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80281d:	ba 00 00 00 00       	mov    $0x0,%edx
  802822:	85 c0                	test   %eax,%eax
  802824:	78 09                	js     80282f <ipc_recv+0x3a>
  802826:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80282c:	8b 52 74             	mov    0x74(%edx),%edx
  80282f:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802831:	85 db                	test   %ebx,%ebx
  802833:	74 14                	je     802849 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802835:	ba 00 00 00 00       	mov    $0x0,%edx
  80283a:	85 c0                	test   %eax,%eax
  80283c:	78 09                	js     802847 <ipc_recv+0x52>
  80283e:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  802844:	8b 52 78             	mov    0x78(%edx),%edx
  802847:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802849:	85 c0                	test   %eax,%eax
  80284b:	78 08                	js     802855 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80284d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802852:	8b 40 70             	mov    0x70(%eax),%eax
}
  802855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802858:	5b                   	pop    %ebx
  802859:	5e                   	pop    %esi
  80285a:	5d                   	pop    %ebp
  80285b:	c3                   	ret    

0080285c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80285c:	55                   	push   %ebp
  80285d:	89 e5                	mov    %esp,%ebp
  80285f:	57                   	push   %edi
  802860:	56                   	push   %esi
  802861:	53                   	push   %ebx
  802862:	83 ec 0c             	sub    $0xc,%esp
  802865:	8b 7d 08             	mov    0x8(%ebp),%edi
  802868:	8b 75 0c             	mov    0xc(%ebp),%esi
  80286b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80286e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802870:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802875:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802878:	ff 75 14             	pushl  0x14(%ebp)
  80287b:	53                   	push   %ebx
  80287c:	56                   	push   %esi
  80287d:	57                   	push   %edi
  80287e:	e8 a3 fe ff ff       	call   802726 <sys_ipc_try_send>

		if (err < 0) {
  802883:	83 c4 10             	add    $0x10,%esp
  802886:	85 c0                	test   %eax,%eax
  802888:	79 1e                	jns    8028a8 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80288a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80288d:	75 07                	jne    802896 <ipc_send+0x3a>
				sys_yield();
  80288f:	e8 e6 fc ff ff       	call   80257a <sys_yield>
  802894:	eb e2                	jmp    802878 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802896:	50                   	push   %eax
  802897:	68 aa 41 80 00       	push   $0x8041aa
  80289c:	6a 49                	push   $0x49
  80289e:	68 b7 41 80 00       	push   $0x8041b7
  8028a3:	e8 90 f2 ff ff       	call   801b38 <_panic>
		}

	} while (err < 0);

}
  8028a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028ab:	5b                   	pop    %ebx
  8028ac:	5e                   	pop    %esi
  8028ad:	5f                   	pop    %edi
  8028ae:	5d                   	pop    %ebp
  8028af:	c3                   	ret    

008028b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028b0:	55                   	push   %ebp
  8028b1:	89 e5                	mov    %esp,%ebp
  8028b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028bb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028be:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028c4:	8b 52 50             	mov    0x50(%edx),%edx
  8028c7:	39 ca                	cmp    %ecx,%edx
  8028c9:	75 0d                	jne    8028d8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8028cb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028d3:	8b 40 48             	mov    0x48(%eax),%eax
  8028d6:	eb 0f                	jmp    8028e7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028d8:	83 c0 01             	add    $0x1,%eax
  8028db:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028e0:	75 d9                	jne    8028bb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    

008028e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028e9:	55                   	push   %ebp
  8028ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8028f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8028f7:	5d                   	pop    %ebp
  8028f8:	c3                   	ret    

008028f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8028f9:	55                   	push   %ebp
  8028fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8028fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ff:	05 00 00 00 30       	add    $0x30000000,%eax
  802904:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802909:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80290e:	5d                   	pop    %ebp
  80290f:	c3                   	ret    

00802910 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802910:	55                   	push   %ebp
  802911:	89 e5                	mov    %esp,%ebp
  802913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802916:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80291b:	89 c2                	mov    %eax,%edx
  80291d:	c1 ea 16             	shr    $0x16,%edx
  802920:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802927:	f6 c2 01             	test   $0x1,%dl
  80292a:	74 11                	je     80293d <fd_alloc+0x2d>
  80292c:	89 c2                	mov    %eax,%edx
  80292e:	c1 ea 0c             	shr    $0xc,%edx
  802931:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802938:	f6 c2 01             	test   $0x1,%dl
  80293b:	75 09                	jne    802946 <fd_alloc+0x36>
			*fd_store = fd;
  80293d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80293f:	b8 00 00 00 00       	mov    $0x0,%eax
  802944:	eb 17                	jmp    80295d <fd_alloc+0x4d>
  802946:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80294b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802950:	75 c9                	jne    80291b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802952:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802958:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80295d:	5d                   	pop    %ebp
  80295e:	c3                   	ret    

0080295f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80295f:	55                   	push   %ebp
  802960:	89 e5                	mov    %esp,%ebp
  802962:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802965:	83 f8 1f             	cmp    $0x1f,%eax
  802968:	77 36                	ja     8029a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80296a:	c1 e0 0c             	shl    $0xc,%eax
  80296d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802972:	89 c2                	mov    %eax,%edx
  802974:	c1 ea 16             	shr    $0x16,%edx
  802977:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80297e:	f6 c2 01             	test   $0x1,%dl
  802981:	74 24                	je     8029a7 <fd_lookup+0x48>
  802983:	89 c2                	mov    %eax,%edx
  802985:	c1 ea 0c             	shr    $0xc,%edx
  802988:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80298f:	f6 c2 01             	test   $0x1,%dl
  802992:	74 1a                	je     8029ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802994:	8b 55 0c             	mov    0xc(%ebp),%edx
  802997:	89 02                	mov    %eax,(%edx)
	return 0;
  802999:	b8 00 00 00 00       	mov    $0x0,%eax
  80299e:	eb 13                	jmp    8029b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029a5:	eb 0c                	jmp    8029b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029ac:	eb 05                	jmp    8029b3 <fd_lookup+0x54>
  8029ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8029b3:	5d                   	pop    %ebp
  8029b4:	c3                   	ret    

008029b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8029b5:	55                   	push   %ebp
  8029b6:	89 e5                	mov    %esp,%ebp
  8029b8:	83 ec 08             	sub    $0x8,%esp
  8029bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029be:	ba 44 42 80 00       	mov    $0x804244,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8029c3:	eb 13                	jmp    8029d8 <dev_lookup+0x23>
  8029c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8029c8:	39 08                	cmp    %ecx,(%eax)
  8029ca:	75 0c                	jne    8029d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8029cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8029d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8029d6:	eb 2e                	jmp    802a06 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8029d8:	8b 02                	mov    (%edx),%eax
  8029da:	85 c0                	test   %eax,%eax
  8029dc:	75 e7                	jne    8029c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029de:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029e3:	8b 40 48             	mov    0x48(%eax),%eax
  8029e6:	83 ec 04             	sub    $0x4,%esp
  8029e9:	51                   	push   %ecx
  8029ea:	50                   	push   %eax
  8029eb:	68 c4 41 80 00       	push   $0x8041c4
  8029f0:	e8 1c f2 ff ff       	call   801c11 <cprintf>
	*dev = 0;
  8029f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8029fe:	83 c4 10             	add    $0x10,%esp
  802a01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a06:	c9                   	leave  
  802a07:	c3                   	ret    

00802a08 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802a08:	55                   	push   %ebp
  802a09:	89 e5                	mov    %esp,%ebp
  802a0b:	56                   	push   %esi
  802a0c:	53                   	push   %ebx
  802a0d:	83 ec 10             	sub    $0x10,%esp
  802a10:	8b 75 08             	mov    0x8(%ebp),%esi
  802a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a19:	50                   	push   %eax
  802a1a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a20:	c1 e8 0c             	shr    $0xc,%eax
  802a23:	50                   	push   %eax
  802a24:	e8 36 ff ff ff       	call   80295f <fd_lookup>
  802a29:	83 c4 08             	add    $0x8,%esp
  802a2c:	85 c0                	test   %eax,%eax
  802a2e:	78 05                	js     802a35 <fd_close+0x2d>
	    || fd != fd2)
  802a30:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a33:	74 0c                	je     802a41 <fd_close+0x39>
		return (must_exist ? r : 0);
  802a35:	84 db                	test   %bl,%bl
  802a37:	ba 00 00 00 00       	mov    $0x0,%edx
  802a3c:	0f 44 c2             	cmove  %edx,%eax
  802a3f:	eb 41                	jmp    802a82 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a41:	83 ec 08             	sub    $0x8,%esp
  802a44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a47:	50                   	push   %eax
  802a48:	ff 36                	pushl  (%esi)
  802a4a:	e8 66 ff ff ff       	call   8029b5 <dev_lookup>
  802a4f:	89 c3                	mov    %eax,%ebx
  802a51:	83 c4 10             	add    $0x10,%esp
  802a54:	85 c0                	test   %eax,%eax
  802a56:	78 1a                	js     802a72 <fd_close+0x6a>
		if (dev->dev_close)
  802a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a5b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a63:	85 c0                	test   %eax,%eax
  802a65:	74 0b                	je     802a72 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a67:	83 ec 0c             	sub    $0xc,%esp
  802a6a:	56                   	push   %esi
  802a6b:	ff d0                	call   *%eax
  802a6d:	89 c3                	mov    %eax,%ebx
  802a6f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a72:	83 ec 08             	sub    $0x8,%esp
  802a75:	56                   	push   %esi
  802a76:	6a 00                	push   $0x0
  802a78:	e8 a1 fb ff ff       	call   80261e <sys_page_unmap>
	return r;
  802a7d:	83 c4 10             	add    $0x10,%esp
  802a80:	89 d8                	mov    %ebx,%eax
}
  802a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a85:	5b                   	pop    %ebx
  802a86:	5e                   	pop    %esi
  802a87:	5d                   	pop    %ebp
  802a88:	c3                   	ret    

00802a89 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a89:	55                   	push   %ebp
  802a8a:	89 e5                	mov    %esp,%ebp
  802a8c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a92:	50                   	push   %eax
  802a93:	ff 75 08             	pushl  0x8(%ebp)
  802a96:	e8 c4 fe ff ff       	call   80295f <fd_lookup>
  802a9b:	83 c4 08             	add    $0x8,%esp
  802a9e:	85 c0                	test   %eax,%eax
  802aa0:	78 10                	js     802ab2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802aa2:	83 ec 08             	sub    $0x8,%esp
  802aa5:	6a 01                	push   $0x1
  802aa7:	ff 75 f4             	pushl  -0xc(%ebp)
  802aaa:	e8 59 ff ff ff       	call   802a08 <fd_close>
  802aaf:	83 c4 10             	add    $0x10,%esp
}
  802ab2:	c9                   	leave  
  802ab3:	c3                   	ret    

00802ab4 <close_all>:

void
close_all(void)
{
  802ab4:	55                   	push   %ebp
  802ab5:	89 e5                	mov    %esp,%ebp
  802ab7:	53                   	push   %ebx
  802ab8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802abb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802ac0:	83 ec 0c             	sub    $0xc,%esp
  802ac3:	53                   	push   %ebx
  802ac4:	e8 c0 ff ff ff       	call   802a89 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802ac9:	83 c3 01             	add    $0x1,%ebx
  802acc:	83 c4 10             	add    $0x10,%esp
  802acf:	83 fb 20             	cmp    $0x20,%ebx
  802ad2:	75 ec                	jne    802ac0 <close_all+0xc>
		close(i);
}
  802ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ad7:	c9                   	leave  
  802ad8:	c3                   	ret    

00802ad9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802ad9:	55                   	push   %ebp
  802ada:	89 e5                	mov    %esp,%ebp
  802adc:	57                   	push   %edi
  802add:	56                   	push   %esi
  802ade:	53                   	push   %ebx
  802adf:	83 ec 2c             	sub    $0x2c,%esp
  802ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802ae5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ae8:	50                   	push   %eax
  802ae9:	ff 75 08             	pushl  0x8(%ebp)
  802aec:	e8 6e fe ff ff       	call   80295f <fd_lookup>
  802af1:	83 c4 08             	add    $0x8,%esp
  802af4:	85 c0                	test   %eax,%eax
  802af6:	0f 88 c1 00 00 00    	js     802bbd <dup+0xe4>
		return r;
	close(newfdnum);
  802afc:	83 ec 0c             	sub    $0xc,%esp
  802aff:	56                   	push   %esi
  802b00:	e8 84 ff ff ff       	call   802a89 <close>

	newfd = INDEX2FD(newfdnum);
  802b05:	89 f3                	mov    %esi,%ebx
  802b07:	c1 e3 0c             	shl    $0xc,%ebx
  802b0a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802b10:	83 c4 04             	add    $0x4,%esp
  802b13:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b16:	e8 de fd ff ff       	call   8028f9 <fd2data>
  802b1b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b1d:	89 1c 24             	mov    %ebx,(%esp)
  802b20:	e8 d4 fd ff ff       	call   8028f9 <fd2data>
  802b25:	83 c4 10             	add    $0x10,%esp
  802b28:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b2b:	89 f8                	mov    %edi,%eax
  802b2d:	c1 e8 16             	shr    $0x16,%eax
  802b30:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b37:	a8 01                	test   $0x1,%al
  802b39:	74 37                	je     802b72 <dup+0x99>
  802b3b:	89 f8                	mov    %edi,%eax
  802b3d:	c1 e8 0c             	shr    $0xc,%eax
  802b40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b47:	f6 c2 01             	test   $0x1,%dl
  802b4a:	74 26                	je     802b72 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b53:	83 ec 0c             	sub    $0xc,%esp
  802b56:	25 07 0e 00 00       	and    $0xe07,%eax
  802b5b:	50                   	push   %eax
  802b5c:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b5f:	6a 00                	push   $0x0
  802b61:	57                   	push   %edi
  802b62:	6a 00                	push   $0x0
  802b64:	e8 73 fa ff ff       	call   8025dc <sys_page_map>
  802b69:	89 c7                	mov    %eax,%edi
  802b6b:	83 c4 20             	add    $0x20,%esp
  802b6e:	85 c0                	test   %eax,%eax
  802b70:	78 2e                	js     802ba0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b75:	89 d0                	mov    %edx,%eax
  802b77:	c1 e8 0c             	shr    $0xc,%eax
  802b7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b81:	83 ec 0c             	sub    $0xc,%esp
  802b84:	25 07 0e 00 00       	and    $0xe07,%eax
  802b89:	50                   	push   %eax
  802b8a:	53                   	push   %ebx
  802b8b:	6a 00                	push   $0x0
  802b8d:	52                   	push   %edx
  802b8e:	6a 00                	push   $0x0
  802b90:	e8 47 fa ff ff       	call   8025dc <sys_page_map>
  802b95:	89 c7                	mov    %eax,%edi
  802b97:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802b9a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b9c:	85 ff                	test   %edi,%edi
  802b9e:	79 1d                	jns    802bbd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802ba0:	83 ec 08             	sub    $0x8,%esp
  802ba3:	53                   	push   %ebx
  802ba4:	6a 00                	push   $0x0
  802ba6:	e8 73 fa ff ff       	call   80261e <sys_page_unmap>
	sys_page_unmap(0, nva);
  802bab:	83 c4 08             	add    $0x8,%esp
  802bae:	ff 75 d4             	pushl  -0x2c(%ebp)
  802bb1:	6a 00                	push   $0x0
  802bb3:	e8 66 fa ff ff       	call   80261e <sys_page_unmap>
	return r;
  802bb8:	83 c4 10             	add    $0x10,%esp
  802bbb:	89 f8                	mov    %edi,%eax
}
  802bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bc0:	5b                   	pop    %ebx
  802bc1:	5e                   	pop    %esi
  802bc2:	5f                   	pop    %edi
  802bc3:	5d                   	pop    %ebp
  802bc4:	c3                   	ret    

00802bc5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bc5:	55                   	push   %ebp
  802bc6:	89 e5                	mov    %esp,%ebp
  802bc8:	53                   	push   %ebx
  802bc9:	83 ec 14             	sub    $0x14,%esp
  802bcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bd2:	50                   	push   %eax
  802bd3:	53                   	push   %ebx
  802bd4:	e8 86 fd ff ff       	call   80295f <fd_lookup>
  802bd9:	83 c4 08             	add    $0x8,%esp
  802bdc:	89 c2                	mov    %eax,%edx
  802bde:	85 c0                	test   %eax,%eax
  802be0:	78 6d                	js     802c4f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802be2:	83 ec 08             	sub    $0x8,%esp
  802be5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802be8:	50                   	push   %eax
  802be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bec:	ff 30                	pushl  (%eax)
  802bee:	e8 c2 fd ff ff       	call   8029b5 <dev_lookup>
  802bf3:	83 c4 10             	add    $0x10,%esp
  802bf6:	85 c0                	test   %eax,%eax
  802bf8:	78 4c                	js     802c46 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802bfa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bfd:	8b 42 08             	mov    0x8(%edx),%eax
  802c00:	83 e0 03             	and    $0x3,%eax
  802c03:	83 f8 01             	cmp    $0x1,%eax
  802c06:	75 21                	jne    802c29 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c08:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c0d:	8b 40 48             	mov    0x48(%eax),%eax
  802c10:	83 ec 04             	sub    $0x4,%esp
  802c13:	53                   	push   %ebx
  802c14:	50                   	push   %eax
  802c15:	68 08 42 80 00       	push   $0x804208
  802c1a:	e8 f2 ef ff ff       	call   801c11 <cprintf>
		return -E_INVAL;
  802c1f:	83 c4 10             	add    $0x10,%esp
  802c22:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c27:	eb 26                	jmp    802c4f <read+0x8a>
	}
	if (!dev->dev_read)
  802c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2c:	8b 40 08             	mov    0x8(%eax),%eax
  802c2f:	85 c0                	test   %eax,%eax
  802c31:	74 17                	je     802c4a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c33:	83 ec 04             	sub    $0x4,%esp
  802c36:	ff 75 10             	pushl  0x10(%ebp)
  802c39:	ff 75 0c             	pushl  0xc(%ebp)
  802c3c:	52                   	push   %edx
  802c3d:	ff d0                	call   *%eax
  802c3f:	89 c2                	mov    %eax,%edx
  802c41:	83 c4 10             	add    $0x10,%esp
  802c44:	eb 09                	jmp    802c4f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c46:	89 c2                	mov    %eax,%edx
  802c48:	eb 05                	jmp    802c4f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c4a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802c4f:	89 d0                	mov    %edx,%eax
  802c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c54:	c9                   	leave  
  802c55:	c3                   	ret    

00802c56 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c56:	55                   	push   %ebp
  802c57:	89 e5                	mov    %esp,%ebp
  802c59:	57                   	push   %edi
  802c5a:	56                   	push   %esi
  802c5b:	53                   	push   %ebx
  802c5c:	83 ec 0c             	sub    $0xc,%esp
  802c5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c62:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c6a:	eb 21                	jmp    802c8d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c6c:	83 ec 04             	sub    $0x4,%esp
  802c6f:	89 f0                	mov    %esi,%eax
  802c71:	29 d8                	sub    %ebx,%eax
  802c73:	50                   	push   %eax
  802c74:	89 d8                	mov    %ebx,%eax
  802c76:	03 45 0c             	add    0xc(%ebp),%eax
  802c79:	50                   	push   %eax
  802c7a:	57                   	push   %edi
  802c7b:	e8 45 ff ff ff       	call   802bc5 <read>
		if (m < 0)
  802c80:	83 c4 10             	add    $0x10,%esp
  802c83:	85 c0                	test   %eax,%eax
  802c85:	78 10                	js     802c97 <readn+0x41>
			return m;
		if (m == 0)
  802c87:	85 c0                	test   %eax,%eax
  802c89:	74 0a                	je     802c95 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c8b:	01 c3                	add    %eax,%ebx
  802c8d:	39 f3                	cmp    %esi,%ebx
  802c8f:	72 db                	jb     802c6c <readn+0x16>
  802c91:	89 d8                	mov    %ebx,%eax
  802c93:	eb 02                	jmp    802c97 <readn+0x41>
  802c95:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c9a:	5b                   	pop    %ebx
  802c9b:	5e                   	pop    %esi
  802c9c:	5f                   	pop    %edi
  802c9d:	5d                   	pop    %ebp
  802c9e:	c3                   	ret    

00802c9f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c9f:	55                   	push   %ebp
  802ca0:	89 e5                	mov    %esp,%ebp
  802ca2:	53                   	push   %ebx
  802ca3:	83 ec 14             	sub    $0x14,%esp
  802ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ca9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cac:	50                   	push   %eax
  802cad:	53                   	push   %ebx
  802cae:	e8 ac fc ff ff       	call   80295f <fd_lookup>
  802cb3:	83 c4 08             	add    $0x8,%esp
  802cb6:	89 c2                	mov    %eax,%edx
  802cb8:	85 c0                	test   %eax,%eax
  802cba:	78 68                	js     802d24 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cbc:	83 ec 08             	sub    $0x8,%esp
  802cbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cc2:	50                   	push   %eax
  802cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc6:	ff 30                	pushl  (%eax)
  802cc8:	e8 e8 fc ff ff       	call   8029b5 <dev_lookup>
  802ccd:	83 c4 10             	add    $0x10,%esp
  802cd0:	85 c0                	test   %eax,%eax
  802cd2:	78 47                	js     802d1b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cd7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cdb:	75 21                	jne    802cfe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802cdd:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ce2:	8b 40 48             	mov    0x48(%eax),%eax
  802ce5:	83 ec 04             	sub    $0x4,%esp
  802ce8:	53                   	push   %ebx
  802ce9:	50                   	push   %eax
  802cea:	68 24 42 80 00       	push   $0x804224
  802cef:	e8 1d ef ff ff       	call   801c11 <cprintf>
		return -E_INVAL;
  802cf4:	83 c4 10             	add    $0x10,%esp
  802cf7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802cfc:	eb 26                	jmp    802d24 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d01:	8b 52 0c             	mov    0xc(%edx),%edx
  802d04:	85 d2                	test   %edx,%edx
  802d06:	74 17                	je     802d1f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d08:	83 ec 04             	sub    $0x4,%esp
  802d0b:	ff 75 10             	pushl  0x10(%ebp)
  802d0e:	ff 75 0c             	pushl  0xc(%ebp)
  802d11:	50                   	push   %eax
  802d12:	ff d2                	call   *%edx
  802d14:	89 c2                	mov    %eax,%edx
  802d16:	83 c4 10             	add    $0x10,%esp
  802d19:	eb 09                	jmp    802d24 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d1b:	89 c2                	mov    %eax,%edx
  802d1d:	eb 05                	jmp    802d24 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d1f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d24:	89 d0                	mov    %edx,%eax
  802d26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d29:	c9                   	leave  
  802d2a:	c3                   	ret    

00802d2b <seek>:

int
seek(int fdnum, off_t offset)
{
  802d2b:	55                   	push   %ebp
  802d2c:	89 e5                	mov    %esp,%ebp
  802d2e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d31:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d34:	50                   	push   %eax
  802d35:	ff 75 08             	pushl  0x8(%ebp)
  802d38:	e8 22 fc ff ff       	call   80295f <fd_lookup>
  802d3d:	83 c4 08             	add    $0x8,%esp
  802d40:	85 c0                	test   %eax,%eax
  802d42:	78 0e                	js     802d52 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d44:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d4a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d52:	c9                   	leave  
  802d53:	c3                   	ret    

00802d54 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d54:	55                   	push   %ebp
  802d55:	89 e5                	mov    %esp,%ebp
  802d57:	53                   	push   %ebx
  802d58:	83 ec 14             	sub    $0x14,%esp
  802d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d61:	50                   	push   %eax
  802d62:	53                   	push   %ebx
  802d63:	e8 f7 fb ff ff       	call   80295f <fd_lookup>
  802d68:	83 c4 08             	add    $0x8,%esp
  802d6b:	89 c2                	mov    %eax,%edx
  802d6d:	85 c0                	test   %eax,%eax
  802d6f:	78 65                	js     802dd6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d71:	83 ec 08             	sub    $0x8,%esp
  802d74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d77:	50                   	push   %eax
  802d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d7b:	ff 30                	pushl  (%eax)
  802d7d:	e8 33 fc ff ff       	call   8029b5 <dev_lookup>
  802d82:	83 c4 10             	add    $0x10,%esp
  802d85:	85 c0                	test   %eax,%eax
  802d87:	78 44                	js     802dcd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d8c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d90:	75 21                	jne    802db3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d92:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d97:	8b 40 48             	mov    0x48(%eax),%eax
  802d9a:	83 ec 04             	sub    $0x4,%esp
  802d9d:	53                   	push   %ebx
  802d9e:	50                   	push   %eax
  802d9f:	68 e4 41 80 00       	push   $0x8041e4
  802da4:	e8 68 ee ff ff       	call   801c11 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802da9:	83 c4 10             	add    $0x10,%esp
  802dac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802db1:	eb 23                	jmp    802dd6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802db6:	8b 52 18             	mov    0x18(%edx),%edx
  802db9:	85 d2                	test   %edx,%edx
  802dbb:	74 14                	je     802dd1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802dbd:	83 ec 08             	sub    $0x8,%esp
  802dc0:	ff 75 0c             	pushl  0xc(%ebp)
  802dc3:	50                   	push   %eax
  802dc4:	ff d2                	call   *%edx
  802dc6:	89 c2                	mov    %eax,%edx
  802dc8:	83 c4 10             	add    $0x10,%esp
  802dcb:	eb 09                	jmp    802dd6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dcd:	89 c2                	mov    %eax,%edx
  802dcf:	eb 05                	jmp    802dd6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802dd1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802dd6:	89 d0                	mov    %edx,%eax
  802dd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ddb:	c9                   	leave  
  802ddc:	c3                   	ret    

00802ddd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802ddd:	55                   	push   %ebp
  802dde:	89 e5                	mov    %esp,%ebp
  802de0:	53                   	push   %ebx
  802de1:	83 ec 14             	sub    $0x14,%esp
  802de4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802de7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dea:	50                   	push   %eax
  802deb:	ff 75 08             	pushl  0x8(%ebp)
  802dee:	e8 6c fb ff ff       	call   80295f <fd_lookup>
  802df3:	83 c4 08             	add    $0x8,%esp
  802df6:	89 c2                	mov    %eax,%edx
  802df8:	85 c0                	test   %eax,%eax
  802dfa:	78 58                	js     802e54 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dfc:	83 ec 08             	sub    $0x8,%esp
  802dff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e02:	50                   	push   %eax
  802e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e06:	ff 30                	pushl  (%eax)
  802e08:	e8 a8 fb ff ff       	call   8029b5 <dev_lookup>
  802e0d:	83 c4 10             	add    $0x10,%esp
  802e10:	85 c0                	test   %eax,%eax
  802e12:	78 37                	js     802e4b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e17:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e1b:	74 32                	je     802e4f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e1d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e20:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e27:	00 00 00 
	stat->st_isdir = 0;
  802e2a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e31:	00 00 00 
	stat->st_dev = dev;
  802e34:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e3a:	83 ec 08             	sub    $0x8,%esp
  802e3d:	53                   	push   %ebx
  802e3e:	ff 75 f0             	pushl  -0x10(%ebp)
  802e41:	ff 50 14             	call   *0x14(%eax)
  802e44:	89 c2                	mov    %eax,%edx
  802e46:	83 c4 10             	add    $0x10,%esp
  802e49:	eb 09                	jmp    802e54 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e4b:	89 c2                	mov    %eax,%edx
  802e4d:	eb 05                	jmp    802e54 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e4f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e54:	89 d0                	mov    %edx,%eax
  802e56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e59:	c9                   	leave  
  802e5a:	c3                   	ret    

00802e5b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e5b:	55                   	push   %ebp
  802e5c:	89 e5                	mov    %esp,%ebp
  802e5e:	56                   	push   %esi
  802e5f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e60:	83 ec 08             	sub    $0x8,%esp
  802e63:	6a 00                	push   $0x0
  802e65:	ff 75 08             	pushl  0x8(%ebp)
  802e68:	e8 d6 01 00 00       	call   803043 <open>
  802e6d:	89 c3                	mov    %eax,%ebx
  802e6f:	83 c4 10             	add    $0x10,%esp
  802e72:	85 c0                	test   %eax,%eax
  802e74:	78 1b                	js     802e91 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e76:	83 ec 08             	sub    $0x8,%esp
  802e79:	ff 75 0c             	pushl  0xc(%ebp)
  802e7c:	50                   	push   %eax
  802e7d:	e8 5b ff ff ff       	call   802ddd <fstat>
  802e82:	89 c6                	mov    %eax,%esi
	close(fd);
  802e84:	89 1c 24             	mov    %ebx,(%esp)
  802e87:	e8 fd fb ff ff       	call   802a89 <close>
	return r;
  802e8c:	83 c4 10             	add    $0x10,%esp
  802e8f:	89 f0                	mov    %esi,%eax
}
  802e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e94:	5b                   	pop    %ebx
  802e95:	5e                   	pop    %esi
  802e96:	5d                   	pop    %ebp
  802e97:	c3                   	ret    

00802e98 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e98:	55                   	push   %ebp
  802e99:	89 e5                	mov    %esp,%ebp
  802e9b:	56                   	push   %esi
  802e9c:	53                   	push   %ebx
  802e9d:	89 c6                	mov    %eax,%esi
  802e9f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802ea1:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802ea8:	75 12                	jne    802ebc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802eaa:	83 ec 0c             	sub    $0xc,%esp
  802ead:	6a 01                	push   $0x1
  802eaf:	e8 fc f9 ff ff       	call   8028b0 <ipc_find_env>
  802eb4:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802eb9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ebc:	6a 07                	push   $0x7
  802ebe:	68 00 b0 80 00       	push   $0x80b000
  802ec3:	56                   	push   %esi
  802ec4:	ff 35 00 a0 80 00    	pushl  0x80a000
  802eca:	e8 8d f9 ff ff       	call   80285c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802ecf:	83 c4 0c             	add    $0xc,%esp
  802ed2:	6a 00                	push   $0x0
  802ed4:	53                   	push   %ebx
  802ed5:	6a 00                	push   $0x0
  802ed7:	e8 19 f9 ff ff       	call   8027f5 <ipc_recv>
}
  802edc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802edf:	5b                   	pop    %ebx
  802ee0:	5e                   	pop    %esi
  802ee1:	5d                   	pop    %ebp
  802ee2:	c3                   	ret    

00802ee3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802ee3:	55                   	push   %ebp
  802ee4:	89 e5                	mov    %esp,%ebp
  802ee6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  802eec:	8b 40 0c             	mov    0xc(%eax),%eax
  802eef:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ef7:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802efc:	ba 00 00 00 00       	mov    $0x0,%edx
  802f01:	b8 02 00 00 00       	mov    $0x2,%eax
  802f06:	e8 8d ff ff ff       	call   802e98 <fsipc>
}
  802f0b:	c9                   	leave  
  802f0c:	c3                   	ret    

00802f0d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802f0d:	55                   	push   %ebp
  802f0e:	89 e5                	mov    %esp,%ebp
  802f10:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f13:	8b 45 08             	mov    0x8(%ebp),%eax
  802f16:	8b 40 0c             	mov    0xc(%eax),%eax
  802f19:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  802f23:	b8 06 00 00 00       	mov    $0x6,%eax
  802f28:	e8 6b ff ff ff       	call   802e98 <fsipc>
}
  802f2d:	c9                   	leave  
  802f2e:	c3                   	ret    

00802f2f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f2f:	55                   	push   %ebp
  802f30:	89 e5                	mov    %esp,%ebp
  802f32:	53                   	push   %ebx
  802f33:	83 ec 04             	sub    $0x4,%esp
  802f36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f39:	8b 45 08             	mov    0x8(%ebp),%eax
  802f3c:	8b 40 0c             	mov    0xc(%eax),%eax
  802f3f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f44:	ba 00 00 00 00       	mov    $0x0,%edx
  802f49:	b8 05 00 00 00       	mov    $0x5,%eax
  802f4e:	e8 45 ff ff ff       	call   802e98 <fsipc>
  802f53:	85 c0                	test   %eax,%eax
  802f55:	78 2c                	js     802f83 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f57:	83 ec 08             	sub    $0x8,%esp
  802f5a:	68 00 b0 80 00       	push   $0x80b000
  802f5f:	53                   	push   %ebx
  802f60:	e8 31 f2 ff ff       	call   802196 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f65:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f70:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f7b:	83 c4 10             	add    $0x10,%esp
  802f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f86:	c9                   	leave  
  802f87:	c3                   	ret    

00802f88 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f88:	55                   	push   %ebp
  802f89:	89 e5                	mov    %esp,%ebp
  802f8b:	83 ec 0c             	sub    $0xc,%esp
  802f8e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802f91:	8b 55 08             	mov    0x8(%ebp),%edx
  802f94:	8b 52 0c             	mov    0xc(%edx),%edx
  802f97:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802f9d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802fa2:	50                   	push   %eax
  802fa3:	ff 75 0c             	pushl  0xc(%ebp)
  802fa6:	68 08 b0 80 00       	push   $0x80b008
  802fab:	e8 78 f3 ff ff       	call   802328 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  802fb5:	b8 04 00 00 00       	mov    $0x4,%eax
  802fba:	e8 d9 fe ff ff       	call   802e98 <fsipc>

}
  802fbf:	c9                   	leave  
  802fc0:	c3                   	ret    

00802fc1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802fc1:	55                   	push   %ebp
  802fc2:	89 e5                	mov    %esp,%ebp
  802fc4:	56                   	push   %esi
  802fc5:	53                   	push   %ebx
  802fc6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  802fcc:	8b 40 0c             	mov    0xc(%eax),%eax
  802fcf:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802fd4:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802fda:	ba 00 00 00 00       	mov    $0x0,%edx
  802fdf:	b8 03 00 00 00       	mov    $0x3,%eax
  802fe4:	e8 af fe ff ff       	call   802e98 <fsipc>
  802fe9:	89 c3                	mov    %eax,%ebx
  802feb:	85 c0                	test   %eax,%eax
  802fed:	78 4b                	js     80303a <devfile_read+0x79>
		return r;
	assert(r <= n);
  802fef:	39 c6                	cmp    %eax,%esi
  802ff1:	73 16                	jae    803009 <devfile_read+0x48>
  802ff3:	68 54 42 80 00       	push   $0x804254
  802ff8:	68 dd 38 80 00       	push   $0x8038dd
  802ffd:	6a 7c                	push   $0x7c
  802fff:	68 5b 42 80 00       	push   $0x80425b
  803004:	e8 2f eb ff ff       	call   801b38 <_panic>
	assert(r <= PGSIZE);
  803009:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80300e:	7e 16                	jle    803026 <devfile_read+0x65>
  803010:	68 66 42 80 00       	push   $0x804266
  803015:	68 dd 38 80 00       	push   $0x8038dd
  80301a:	6a 7d                	push   $0x7d
  80301c:	68 5b 42 80 00       	push   $0x80425b
  803021:	e8 12 eb ff ff       	call   801b38 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803026:	83 ec 04             	sub    $0x4,%esp
  803029:	50                   	push   %eax
  80302a:	68 00 b0 80 00       	push   $0x80b000
  80302f:	ff 75 0c             	pushl  0xc(%ebp)
  803032:	e8 f1 f2 ff ff       	call   802328 <memmove>
	return r;
  803037:	83 c4 10             	add    $0x10,%esp
}
  80303a:	89 d8                	mov    %ebx,%eax
  80303c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80303f:	5b                   	pop    %ebx
  803040:	5e                   	pop    %esi
  803041:	5d                   	pop    %ebp
  803042:	c3                   	ret    

00803043 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803043:	55                   	push   %ebp
  803044:	89 e5                	mov    %esp,%ebp
  803046:	53                   	push   %ebx
  803047:	83 ec 20             	sub    $0x20,%esp
  80304a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80304d:	53                   	push   %ebx
  80304e:	e8 0a f1 ff ff       	call   80215d <strlen>
  803053:	83 c4 10             	add    $0x10,%esp
  803056:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80305b:	7f 67                	jg     8030c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80305d:	83 ec 0c             	sub    $0xc,%esp
  803060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803063:	50                   	push   %eax
  803064:	e8 a7 f8 ff ff       	call   802910 <fd_alloc>
  803069:	83 c4 10             	add    $0x10,%esp
		return r;
  80306c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80306e:	85 c0                	test   %eax,%eax
  803070:	78 57                	js     8030c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803072:	83 ec 08             	sub    $0x8,%esp
  803075:	53                   	push   %ebx
  803076:	68 00 b0 80 00       	push   $0x80b000
  80307b:	e8 16 f1 ff ff       	call   802196 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803080:	8b 45 0c             	mov    0xc(%ebp),%eax
  803083:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803088:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80308b:	b8 01 00 00 00       	mov    $0x1,%eax
  803090:	e8 03 fe ff ff       	call   802e98 <fsipc>
  803095:	89 c3                	mov    %eax,%ebx
  803097:	83 c4 10             	add    $0x10,%esp
  80309a:	85 c0                	test   %eax,%eax
  80309c:	79 14                	jns    8030b2 <open+0x6f>
		fd_close(fd, 0);
  80309e:	83 ec 08             	sub    $0x8,%esp
  8030a1:	6a 00                	push   $0x0
  8030a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8030a6:	e8 5d f9 ff ff       	call   802a08 <fd_close>
		return r;
  8030ab:	83 c4 10             	add    $0x10,%esp
  8030ae:	89 da                	mov    %ebx,%edx
  8030b0:	eb 17                	jmp    8030c9 <open+0x86>
	}

	return fd2num(fd);
  8030b2:	83 ec 0c             	sub    $0xc,%esp
  8030b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8030b8:	e8 2c f8 ff ff       	call   8028e9 <fd2num>
  8030bd:	89 c2                	mov    %eax,%edx
  8030bf:	83 c4 10             	add    $0x10,%esp
  8030c2:	eb 05                	jmp    8030c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8030c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8030c9:	89 d0                	mov    %edx,%eax
  8030cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030ce:	c9                   	leave  
  8030cf:	c3                   	ret    

008030d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030d0:	55                   	push   %ebp
  8030d1:	89 e5                	mov    %esp,%ebp
  8030d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8030db:	b8 08 00 00 00       	mov    $0x8,%eax
  8030e0:	e8 b3 fd ff ff       	call   802e98 <fsipc>
}
  8030e5:	c9                   	leave  
  8030e6:	c3                   	ret    

008030e7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8030e7:	55                   	push   %ebp
  8030e8:	89 e5                	mov    %esp,%ebp
  8030ea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030ed:	89 d0                	mov    %edx,%eax
  8030ef:	c1 e8 16             	shr    $0x16,%eax
  8030f2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030f9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030fe:	f6 c1 01             	test   $0x1,%cl
  803101:	74 1d                	je     803120 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803103:	c1 ea 0c             	shr    $0xc,%edx
  803106:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80310d:	f6 c2 01             	test   $0x1,%dl
  803110:	74 0e                	je     803120 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803112:	c1 ea 0c             	shr    $0xc,%edx
  803115:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80311c:	ef 
  80311d:	0f b7 c0             	movzwl %ax,%eax
}
  803120:	5d                   	pop    %ebp
  803121:	c3                   	ret    

00803122 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803122:	55                   	push   %ebp
  803123:	89 e5                	mov    %esp,%ebp
  803125:	56                   	push   %esi
  803126:	53                   	push   %ebx
  803127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80312a:	83 ec 0c             	sub    $0xc,%esp
  80312d:	ff 75 08             	pushl  0x8(%ebp)
  803130:	e8 c4 f7 ff ff       	call   8028f9 <fd2data>
  803135:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803137:	83 c4 08             	add    $0x8,%esp
  80313a:	68 72 42 80 00       	push   $0x804272
  80313f:	53                   	push   %ebx
  803140:	e8 51 f0 ff ff       	call   802196 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803145:	8b 46 04             	mov    0x4(%esi),%eax
  803148:	2b 06                	sub    (%esi),%eax
  80314a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803150:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803157:	00 00 00 
	stat->st_dev = &devpipe;
  80315a:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803161:	90 80 00 
	return 0;
}
  803164:	b8 00 00 00 00       	mov    $0x0,%eax
  803169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80316c:	5b                   	pop    %ebx
  80316d:	5e                   	pop    %esi
  80316e:	5d                   	pop    %ebp
  80316f:	c3                   	ret    

00803170 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803170:	55                   	push   %ebp
  803171:	89 e5                	mov    %esp,%ebp
  803173:	53                   	push   %ebx
  803174:	83 ec 0c             	sub    $0xc,%esp
  803177:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80317a:	53                   	push   %ebx
  80317b:	6a 00                	push   $0x0
  80317d:	e8 9c f4 ff ff       	call   80261e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803182:	89 1c 24             	mov    %ebx,(%esp)
  803185:	e8 6f f7 ff ff       	call   8028f9 <fd2data>
  80318a:	83 c4 08             	add    $0x8,%esp
  80318d:	50                   	push   %eax
  80318e:	6a 00                	push   $0x0
  803190:	e8 89 f4 ff ff       	call   80261e <sys_page_unmap>
}
  803195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803198:	c9                   	leave  
  803199:	c3                   	ret    

0080319a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80319a:	55                   	push   %ebp
  80319b:	89 e5                	mov    %esp,%ebp
  80319d:	57                   	push   %edi
  80319e:	56                   	push   %esi
  80319f:	53                   	push   %ebx
  8031a0:	83 ec 1c             	sub    $0x1c,%esp
  8031a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8031a6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8031a8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8031ad:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8031b0:	83 ec 0c             	sub    $0xc,%esp
  8031b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8031b6:	e8 2c ff ff ff       	call   8030e7 <pageref>
  8031bb:	89 c3                	mov    %eax,%ebx
  8031bd:	89 3c 24             	mov    %edi,(%esp)
  8031c0:	e8 22 ff ff ff       	call   8030e7 <pageref>
  8031c5:	83 c4 10             	add    $0x10,%esp
  8031c8:	39 c3                	cmp    %eax,%ebx
  8031ca:	0f 94 c1             	sete   %cl
  8031cd:	0f b6 c9             	movzbl %cl,%ecx
  8031d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8031d3:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8031d9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8031dc:	39 ce                	cmp    %ecx,%esi
  8031de:	74 1b                	je     8031fb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8031e0:	39 c3                	cmp    %eax,%ebx
  8031e2:	75 c4                	jne    8031a8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8031e4:	8b 42 58             	mov    0x58(%edx),%eax
  8031e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8031ea:	50                   	push   %eax
  8031eb:	56                   	push   %esi
  8031ec:	68 79 42 80 00       	push   $0x804279
  8031f1:	e8 1b ea ff ff       	call   801c11 <cprintf>
  8031f6:	83 c4 10             	add    $0x10,%esp
  8031f9:	eb ad                	jmp    8031a8 <_pipeisclosed+0xe>
	}
}
  8031fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8031fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803201:	5b                   	pop    %ebx
  803202:	5e                   	pop    %esi
  803203:	5f                   	pop    %edi
  803204:	5d                   	pop    %ebp
  803205:	c3                   	ret    

00803206 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803206:	55                   	push   %ebp
  803207:	89 e5                	mov    %esp,%ebp
  803209:	57                   	push   %edi
  80320a:	56                   	push   %esi
  80320b:	53                   	push   %ebx
  80320c:	83 ec 28             	sub    $0x28,%esp
  80320f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803212:	56                   	push   %esi
  803213:	e8 e1 f6 ff ff       	call   8028f9 <fd2data>
  803218:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80321a:	83 c4 10             	add    $0x10,%esp
  80321d:	bf 00 00 00 00       	mov    $0x0,%edi
  803222:	eb 4b                	jmp    80326f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803224:	89 da                	mov    %ebx,%edx
  803226:	89 f0                	mov    %esi,%eax
  803228:	e8 6d ff ff ff       	call   80319a <_pipeisclosed>
  80322d:	85 c0                	test   %eax,%eax
  80322f:	75 48                	jne    803279 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803231:	e8 44 f3 ff ff       	call   80257a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803236:	8b 43 04             	mov    0x4(%ebx),%eax
  803239:	8b 0b                	mov    (%ebx),%ecx
  80323b:	8d 51 20             	lea    0x20(%ecx),%edx
  80323e:	39 d0                	cmp    %edx,%eax
  803240:	73 e2                	jae    803224 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803245:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803249:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80324c:	89 c2                	mov    %eax,%edx
  80324e:	c1 fa 1f             	sar    $0x1f,%edx
  803251:	89 d1                	mov    %edx,%ecx
  803253:	c1 e9 1b             	shr    $0x1b,%ecx
  803256:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803259:	83 e2 1f             	and    $0x1f,%edx
  80325c:	29 ca                	sub    %ecx,%edx
  80325e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803262:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803266:	83 c0 01             	add    $0x1,%eax
  803269:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80326c:	83 c7 01             	add    $0x1,%edi
  80326f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803272:	75 c2                	jne    803236 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803274:	8b 45 10             	mov    0x10(%ebp),%eax
  803277:	eb 05                	jmp    80327e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803279:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80327e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803281:	5b                   	pop    %ebx
  803282:	5e                   	pop    %esi
  803283:	5f                   	pop    %edi
  803284:	5d                   	pop    %ebp
  803285:	c3                   	ret    

00803286 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803286:	55                   	push   %ebp
  803287:	89 e5                	mov    %esp,%ebp
  803289:	57                   	push   %edi
  80328a:	56                   	push   %esi
  80328b:	53                   	push   %ebx
  80328c:	83 ec 18             	sub    $0x18,%esp
  80328f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803292:	57                   	push   %edi
  803293:	e8 61 f6 ff ff       	call   8028f9 <fd2data>
  803298:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80329a:	83 c4 10             	add    $0x10,%esp
  80329d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8032a2:	eb 3d                	jmp    8032e1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8032a4:	85 db                	test   %ebx,%ebx
  8032a6:	74 04                	je     8032ac <devpipe_read+0x26>
				return i;
  8032a8:	89 d8                	mov    %ebx,%eax
  8032aa:	eb 44                	jmp    8032f0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8032ac:	89 f2                	mov    %esi,%edx
  8032ae:	89 f8                	mov    %edi,%eax
  8032b0:	e8 e5 fe ff ff       	call   80319a <_pipeisclosed>
  8032b5:	85 c0                	test   %eax,%eax
  8032b7:	75 32                	jne    8032eb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8032b9:	e8 bc f2 ff ff       	call   80257a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8032be:	8b 06                	mov    (%esi),%eax
  8032c0:	3b 46 04             	cmp    0x4(%esi),%eax
  8032c3:	74 df                	je     8032a4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8032c5:	99                   	cltd   
  8032c6:	c1 ea 1b             	shr    $0x1b,%edx
  8032c9:	01 d0                	add    %edx,%eax
  8032cb:	83 e0 1f             	and    $0x1f,%eax
  8032ce:	29 d0                	sub    %edx,%eax
  8032d0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8032d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032d8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8032db:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032de:	83 c3 01             	add    $0x1,%ebx
  8032e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8032e4:	75 d8                	jne    8032be <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8032e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8032e9:	eb 05                	jmp    8032f0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8032eb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8032f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032f3:	5b                   	pop    %ebx
  8032f4:	5e                   	pop    %esi
  8032f5:	5f                   	pop    %edi
  8032f6:	5d                   	pop    %ebp
  8032f7:	c3                   	ret    

008032f8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8032f8:	55                   	push   %ebp
  8032f9:	89 e5                	mov    %esp,%ebp
  8032fb:	56                   	push   %esi
  8032fc:	53                   	push   %ebx
  8032fd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803303:	50                   	push   %eax
  803304:	e8 07 f6 ff ff       	call   802910 <fd_alloc>
  803309:	83 c4 10             	add    $0x10,%esp
  80330c:	89 c2                	mov    %eax,%edx
  80330e:	85 c0                	test   %eax,%eax
  803310:	0f 88 2c 01 00 00    	js     803442 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803316:	83 ec 04             	sub    $0x4,%esp
  803319:	68 07 04 00 00       	push   $0x407
  80331e:	ff 75 f4             	pushl  -0xc(%ebp)
  803321:	6a 00                	push   $0x0
  803323:	e8 71 f2 ff ff       	call   802599 <sys_page_alloc>
  803328:	83 c4 10             	add    $0x10,%esp
  80332b:	89 c2                	mov    %eax,%edx
  80332d:	85 c0                	test   %eax,%eax
  80332f:	0f 88 0d 01 00 00    	js     803442 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803335:	83 ec 0c             	sub    $0xc,%esp
  803338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80333b:	50                   	push   %eax
  80333c:	e8 cf f5 ff ff       	call   802910 <fd_alloc>
  803341:	89 c3                	mov    %eax,%ebx
  803343:	83 c4 10             	add    $0x10,%esp
  803346:	85 c0                	test   %eax,%eax
  803348:	0f 88 e2 00 00 00    	js     803430 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80334e:	83 ec 04             	sub    $0x4,%esp
  803351:	68 07 04 00 00       	push   $0x407
  803356:	ff 75 f0             	pushl  -0x10(%ebp)
  803359:	6a 00                	push   $0x0
  80335b:	e8 39 f2 ff ff       	call   802599 <sys_page_alloc>
  803360:	89 c3                	mov    %eax,%ebx
  803362:	83 c4 10             	add    $0x10,%esp
  803365:	85 c0                	test   %eax,%eax
  803367:	0f 88 c3 00 00 00    	js     803430 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80336d:	83 ec 0c             	sub    $0xc,%esp
  803370:	ff 75 f4             	pushl  -0xc(%ebp)
  803373:	e8 81 f5 ff ff       	call   8028f9 <fd2data>
  803378:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80337a:	83 c4 0c             	add    $0xc,%esp
  80337d:	68 07 04 00 00       	push   $0x407
  803382:	50                   	push   %eax
  803383:	6a 00                	push   $0x0
  803385:	e8 0f f2 ff ff       	call   802599 <sys_page_alloc>
  80338a:	89 c3                	mov    %eax,%ebx
  80338c:	83 c4 10             	add    $0x10,%esp
  80338f:	85 c0                	test   %eax,%eax
  803391:	0f 88 89 00 00 00    	js     803420 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803397:	83 ec 0c             	sub    $0xc,%esp
  80339a:	ff 75 f0             	pushl  -0x10(%ebp)
  80339d:	e8 57 f5 ff ff       	call   8028f9 <fd2data>
  8033a2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8033a9:	50                   	push   %eax
  8033aa:	6a 00                	push   $0x0
  8033ac:	56                   	push   %esi
  8033ad:	6a 00                	push   $0x0
  8033af:	e8 28 f2 ff ff       	call   8025dc <sys_page_map>
  8033b4:	89 c3                	mov    %eax,%ebx
  8033b6:	83 c4 20             	add    $0x20,%esp
  8033b9:	85 c0                	test   %eax,%eax
  8033bb:	78 55                	js     803412 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8033bd:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8033c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8033d2:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8033dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8033e7:	83 ec 0c             	sub    $0xc,%esp
  8033ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8033ed:	e8 f7 f4 ff ff       	call   8028e9 <fd2num>
  8033f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033f5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8033f7:	83 c4 04             	add    $0x4,%esp
  8033fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8033fd:	e8 e7 f4 ff ff       	call   8028e9 <fd2num>
  803402:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803405:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803408:	83 c4 10             	add    $0x10,%esp
  80340b:	ba 00 00 00 00       	mov    $0x0,%edx
  803410:	eb 30                	jmp    803442 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803412:	83 ec 08             	sub    $0x8,%esp
  803415:	56                   	push   %esi
  803416:	6a 00                	push   $0x0
  803418:	e8 01 f2 ff ff       	call   80261e <sys_page_unmap>
  80341d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803420:	83 ec 08             	sub    $0x8,%esp
  803423:	ff 75 f0             	pushl  -0x10(%ebp)
  803426:	6a 00                	push   $0x0
  803428:	e8 f1 f1 ff ff       	call   80261e <sys_page_unmap>
  80342d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803430:	83 ec 08             	sub    $0x8,%esp
  803433:	ff 75 f4             	pushl  -0xc(%ebp)
  803436:	6a 00                	push   $0x0
  803438:	e8 e1 f1 ff ff       	call   80261e <sys_page_unmap>
  80343d:	83 c4 10             	add    $0x10,%esp
  803440:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803442:	89 d0                	mov    %edx,%eax
  803444:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803447:	5b                   	pop    %ebx
  803448:	5e                   	pop    %esi
  803449:	5d                   	pop    %ebp
  80344a:	c3                   	ret    

0080344b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80344b:	55                   	push   %ebp
  80344c:	89 e5                	mov    %esp,%ebp
  80344e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803454:	50                   	push   %eax
  803455:	ff 75 08             	pushl  0x8(%ebp)
  803458:	e8 02 f5 ff ff       	call   80295f <fd_lookup>
  80345d:	83 c4 10             	add    $0x10,%esp
  803460:	85 c0                	test   %eax,%eax
  803462:	78 18                	js     80347c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803464:	83 ec 0c             	sub    $0xc,%esp
  803467:	ff 75 f4             	pushl  -0xc(%ebp)
  80346a:	e8 8a f4 ff ff       	call   8028f9 <fd2data>
	return _pipeisclosed(fd, p);
  80346f:	89 c2                	mov    %eax,%edx
  803471:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803474:	e8 21 fd ff ff       	call   80319a <_pipeisclosed>
  803479:	83 c4 10             	add    $0x10,%esp
}
  80347c:	c9                   	leave  
  80347d:	c3                   	ret    

0080347e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80347e:	55                   	push   %ebp
  80347f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803481:	b8 00 00 00 00       	mov    $0x0,%eax
  803486:	5d                   	pop    %ebp
  803487:	c3                   	ret    

00803488 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803488:	55                   	push   %ebp
  803489:	89 e5                	mov    %esp,%ebp
  80348b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80348e:	68 91 42 80 00       	push   $0x804291
  803493:	ff 75 0c             	pushl  0xc(%ebp)
  803496:	e8 fb ec ff ff       	call   802196 <strcpy>
	return 0;
}
  80349b:	b8 00 00 00 00       	mov    $0x0,%eax
  8034a0:	c9                   	leave  
  8034a1:	c3                   	ret    

008034a2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8034a2:	55                   	push   %ebp
  8034a3:	89 e5                	mov    %esp,%ebp
  8034a5:	57                   	push   %edi
  8034a6:	56                   	push   %esi
  8034a7:	53                   	push   %ebx
  8034a8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034ae:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034b9:	eb 2d                	jmp    8034e8 <devcons_write+0x46>
		m = n - tot;
  8034bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8034be:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8034c0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8034c3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8034c8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034cb:	83 ec 04             	sub    $0x4,%esp
  8034ce:	53                   	push   %ebx
  8034cf:	03 45 0c             	add    0xc(%ebp),%eax
  8034d2:	50                   	push   %eax
  8034d3:	57                   	push   %edi
  8034d4:	e8 4f ee ff ff       	call   802328 <memmove>
		sys_cputs(buf, m);
  8034d9:	83 c4 08             	add    $0x8,%esp
  8034dc:	53                   	push   %ebx
  8034dd:	57                   	push   %edi
  8034de:	e8 fa ef ff ff       	call   8024dd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034e3:	01 de                	add    %ebx,%esi
  8034e5:	83 c4 10             	add    $0x10,%esp
  8034e8:	89 f0                	mov    %esi,%eax
  8034ea:	3b 75 10             	cmp    0x10(%ebp),%esi
  8034ed:	72 cc                	jb     8034bb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8034ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034f2:	5b                   	pop    %ebx
  8034f3:	5e                   	pop    %esi
  8034f4:	5f                   	pop    %edi
  8034f5:	5d                   	pop    %ebp
  8034f6:	c3                   	ret    

008034f7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8034f7:	55                   	push   %ebp
  8034f8:	89 e5                	mov    %esp,%ebp
  8034fa:	83 ec 08             	sub    $0x8,%esp
  8034fd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803502:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803506:	74 2a                	je     803532 <devcons_read+0x3b>
  803508:	eb 05                	jmp    80350f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80350a:	e8 6b f0 ff ff       	call   80257a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80350f:	e8 e7 ef ff ff       	call   8024fb <sys_cgetc>
  803514:	85 c0                	test   %eax,%eax
  803516:	74 f2                	je     80350a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803518:	85 c0                	test   %eax,%eax
  80351a:	78 16                	js     803532 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80351c:	83 f8 04             	cmp    $0x4,%eax
  80351f:	74 0c                	je     80352d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803521:	8b 55 0c             	mov    0xc(%ebp),%edx
  803524:	88 02                	mov    %al,(%edx)
	return 1;
  803526:	b8 01 00 00 00       	mov    $0x1,%eax
  80352b:	eb 05                	jmp    803532 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80352d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803532:	c9                   	leave  
  803533:	c3                   	ret    

00803534 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803534:	55                   	push   %ebp
  803535:	89 e5                	mov    %esp,%ebp
  803537:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80353a:	8b 45 08             	mov    0x8(%ebp),%eax
  80353d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803540:	6a 01                	push   $0x1
  803542:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803545:	50                   	push   %eax
  803546:	e8 92 ef ff ff       	call   8024dd <sys_cputs>
}
  80354b:	83 c4 10             	add    $0x10,%esp
  80354e:	c9                   	leave  
  80354f:	c3                   	ret    

00803550 <getchar>:

int
getchar(void)
{
  803550:	55                   	push   %ebp
  803551:	89 e5                	mov    %esp,%ebp
  803553:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803556:	6a 01                	push   $0x1
  803558:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80355b:	50                   	push   %eax
  80355c:	6a 00                	push   $0x0
  80355e:	e8 62 f6 ff ff       	call   802bc5 <read>
	if (r < 0)
  803563:	83 c4 10             	add    $0x10,%esp
  803566:	85 c0                	test   %eax,%eax
  803568:	78 0f                	js     803579 <getchar+0x29>
		return r;
	if (r < 1)
  80356a:	85 c0                	test   %eax,%eax
  80356c:	7e 06                	jle    803574 <getchar+0x24>
		return -E_EOF;
	return c;
  80356e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803572:	eb 05                	jmp    803579 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803574:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803579:	c9                   	leave  
  80357a:	c3                   	ret    

0080357b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80357b:	55                   	push   %ebp
  80357c:	89 e5                	mov    %esp,%ebp
  80357e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803584:	50                   	push   %eax
  803585:	ff 75 08             	pushl  0x8(%ebp)
  803588:	e8 d2 f3 ff ff       	call   80295f <fd_lookup>
  80358d:	83 c4 10             	add    $0x10,%esp
  803590:	85 c0                	test   %eax,%eax
  803592:	78 11                	js     8035a5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803597:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80359d:	39 10                	cmp    %edx,(%eax)
  80359f:	0f 94 c0             	sete   %al
  8035a2:	0f b6 c0             	movzbl %al,%eax
}
  8035a5:	c9                   	leave  
  8035a6:	c3                   	ret    

008035a7 <opencons>:

int
opencons(void)
{
  8035a7:	55                   	push   %ebp
  8035a8:	89 e5                	mov    %esp,%ebp
  8035aa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035b0:	50                   	push   %eax
  8035b1:	e8 5a f3 ff ff       	call   802910 <fd_alloc>
  8035b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8035b9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035bb:	85 c0                	test   %eax,%eax
  8035bd:	78 3e                	js     8035fd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035bf:	83 ec 04             	sub    $0x4,%esp
  8035c2:	68 07 04 00 00       	push   $0x407
  8035c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8035ca:	6a 00                	push   $0x0
  8035cc:	e8 c8 ef ff ff       	call   802599 <sys_page_alloc>
  8035d1:	83 c4 10             	add    $0x10,%esp
		return r;
  8035d4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035d6:	85 c0                	test   %eax,%eax
  8035d8:	78 23                	js     8035fd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8035da:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8035e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8035ef:	83 ec 0c             	sub    $0xc,%esp
  8035f2:	50                   	push   %eax
  8035f3:	e8 f1 f2 ff ff       	call   8028e9 <fd2num>
  8035f8:	89 c2                	mov    %eax,%edx
  8035fa:	83 c4 10             	add    $0x10,%esp
}
  8035fd:	89 d0                	mov    %edx,%eax
  8035ff:	c9                   	leave  
  803600:	c3                   	ret    
  803601:	66 90                	xchg   %ax,%ax
  803603:	66 90                	xchg   %ax,%ax
  803605:	66 90                	xchg   %ax,%ax
  803607:	66 90                	xchg   %ax,%ax
  803609:	66 90                	xchg   %ax,%ax
  80360b:	66 90                	xchg   %ax,%ax
  80360d:	66 90                	xchg   %ax,%ax
  80360f:	90                   	nop

00803610 <__udivdi3>:
  803610:	55                   	push   %ebp
  803611:	57                   	push   %edi
  803612:	56                   	push   %esi
  803613:	53                   	push   %ebx
  803614:	83 ec 1c             	sub    $0x1c,%esp
  803617:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80361b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80361f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803623:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803627:	85 f6                	test   %esi,%esi
  803629:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80362d:	89 ca                	mov    %ecx,%edx
  80362f:	89 f8                	mov    %edi,%eax
  803631:	75 3d                	jne    803670 <__udivdi3+0x60>
  803633:	39 cf                	cmp    %ecx,%edi
  803635:	0f 87 c5 00 00 00    	ja     803700 <__udivdi3+0xf0>
  80363b:	85 ff                	test   %edi,%edi
  80363d:	89 fd                	mov    %edi,%ebp
  80363f:	75 0b                	jne    80364c <__udivdi3+0x3c>
  803641:	b8 01 00 00 00       	mov    $0x1,%eax
  803646:	31 d2                	xor    %edx,%edx
  803648:	f7 f7                	div    %edi
  80364a:	89 c5                	mov    %eax,%ebp
  80364c:	89 c8                	mov    %ecx,%eax
  80364e:	31 d2                	xor    %edx,%edx
  803650:	f7 f5                	div    %ebp
  803652:	89 c1                	mov    %eax,%ecx
  803654:	89 d8                	mov    %ebx,%eax
  803656:	89 cf                	mov    %ecx,%edi
  803658:	f7 f5                	div    %ebp
  80365a:	89 c3                	mov    %eax,%ebx
  80365c:	89 d8                	mov    %ebx,%eax
  80365e:	89 fa                	mov    %edi,%edx
  803660:	83 c4 1c             	add    $0x1c,%esp
  803663:	5b                   	pop    %ebx
  803664:	5e                   	pop    %esi
  803665:	5f                   	pop    %edi
  803666:	5d                   	pop    %ebp
  803667:	c3                   	ret    
  803668:	90                   	nop
  803669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803670:	39 ce                	cmp    %ecx,%esi
  803672:	77 74                	ja     8036e8 <__udivdi3+0xd8>
  803674:	0f bd fe             	bsr    %esi,%edi
  803677:	83 f7 1f             	xor    $0x1f,%edi
  80367a:	0f 84 98 00 00 00    	je     803718 <__udivdi3+0x108>
  803680:	bb 20 00 00 00       	mov    $0x20,%ebx
  803685:	89 f9                	mov    %edi,%ecx
  803687:	89 c5                	mov    %eax,%ebp
  803689:	29 fb                	sub    %edi,%ebx
  80368b:	d3 e6                	shl    %cl,%esi
  80368d:	89 d9                	mov    %ebx,%ecx
  80368f:	d3 ed                	shr    %cl,%ebp
  803691:	89 f9                	mov    %edi,%ecx
  803693:	d3 e0                	shl    %cl,%eax
  803695:	09 ee                	or     %ebp,%esi
  803697:	89 d9                	mov    %ebx,%ecx
  803699:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80369d:	89 d5                	mov    %edx,%ebp
  80369f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8036a3:	d3 ed                	shr    %cl,%ebp
  8036a5:	89 f9                	mov    %edi,%ecx
  8036a7:	d3 e2                	shl    %cl,%edx
  8036a9:	89 d9                	mov    %ebx,%ecx
  8036ab:	d3 e8                	shr    %cl,%eax
  8036ad:	09 c2                	or     %eax,%edx
  8036af:	89 d0                	mov    %edx,%eax
  8036b1:	89 ea                	mov    %ebp,%edx
  8036b3:	f7 f6                	div    %esi
  8036b5:	89 d5                	mov    %edx,%ebp
  8036b7:	89 c3                	mov    %eax,%ebx
  8036b9:	f7 64 24 0c          	mull   0xc(%esp)
  8036bd:	39 d5                	cmp    %edx,%ebp
  8036bf:	72 10                	jb     8036d1 <__udivdi3+0xc1>
  8036c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8036c5:	89 f9                	mov    %edi,%ecx
  8036c7:	d3 e6                	shl    %cl,%esi
  8036c9:	39 c6                	cmp    %eax,%esi
  8036cb:	73 07                	jae    8036d4 <__udivdi3+0xc4>
  8036cd:	39 d5                	cmp    %edx,%ebp
  8036cf:	75 03                	jne    8036d4 <__udivdi3+0xc4>
  8036d1:	83 eb 01             	sub    $0x1,%ebx
  8036d4:	31 ff                	xor    %edi,%edi
  8036d6:	89 d8                	mov    %ebx,%eax
  8036d8:	89 fa                	mov    %edi,%edx
  8036da:	83 c4 1c             	add    $0x1c,%esp
  8036dd:	5b                   	pop    %ebx
  8036de:	5e                   	pop    %esi
  8036df:	5f                   	pop    %edi
  8036e0:	5d                   	pop    %ebp
  8036e1:	c3                   	ret    
  8036e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036e8:	31 ff                	xor    %edi,%edi
  8036ea:	31 db                	xor    %ebx,%ebx
  8036ec:	89 d8                	mov    %ebx,%eax
  8036ee:	89 fa                	mov    %edi,%edx
  8036f0:	83 c4 1c             	add    $0x1c,%esp
  8036f3:	5b                   	pop    %ebx
  8036f4:	5e                   	pop    %esi
  8036f5:	5f                   	pop    %edi
  8036f6:	5d                   	pop    %ebp
  8036f7:	c3                   	ret    
  8036f8:	90                   	nop
  8036f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803700:	89 d8                	mov    %ebx,%eax
  803702:	f7 f7                	div    %edi
  803704:	31 ff                	xor    %edi,%edi
  803706:	89 c3                	mov    %eax,%ebx
  803708:	89 d8                	mov    %ebx,%eax
  80370a:	89 fa                	mov    %edi,%edx
  80370c:	83 c4 1c             	add    $0x1c,%esp
  80370f:	5b                   	pop    %ebx
  803710:	5e                   	pop    %esi
  803711:	5f                   	pop    %edi
  803712:	5d                   	pop    %ebp
  803713:	c3                   	ret    
  803714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803718:	39 ce                	cmp    %ecx,%esi
  80371a:	72 0c                	jb     803728 <__udivdi3+0x118>
  80371c:	31 db                	xor    %ebx,%ebx
  80371e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803722:	0f 87 34 ff ff ff    	ja     80365c <__udivdi3+0x4c>
  803728:	bb 01 00 00 00       	mov    $0x1,%ebx
  80372d:	e9 2a ff ff ff       	jmp    80365c <__udivdi3+0x4c>
  803732:	66 90                	xchg   %ax,%ax
  803734:	66 90                	xchg   %ax,%ax
  803736:	66 90                	xchg   %ax,%ax
  803738:	66 90                	xchg   %ax,%ax
  80373a:	66 90                	xchg   %ax,%ax
  80373c:	66 90                	xchg   %ax,%ax
  80373e:	66 90                	xchg   %ax,%ax

00803740 <__umoddi3>:
  803740:	55                   	push   %ebp
  803741:	57                   	push   %edi
  803742:	56                   	push   %esi
  803743:	53                   	push   %ebx
  803744:	83 ec 1c             	sub    $0x1c,%esp
  803747:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80374b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80374f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803753:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803757:	85 d2                	test   %edx,%edx
  803759:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80375d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803761:	89 f3                	mov    %esi,%ebx
  803763:	89 3c 24             	mov    %edi,(%esp)
  803766:	89 74 24 04          	mov    %esi,0x4(%esp)
  80376a:	75 1c                	jne    803788 <__umoddi3+0x48>
  80376c:	39 f7                	cmp    %esi,%edi
  80376e:	76 50                	jbe    8037c0 <__umoddi3+0x80>
  803770:	89 c8                	mov    %ecx,%eax
  803772:	89 f2                	mov    %esi,%edx
  803774:	f7 f7                	div    %edi
  803776:	89 d0                	mov    %edx,%eax
  803778:	31 d2                	xor    %edx,%edx
  80377a:	83 c4 1c             	add    $0x1c,%esp
  80377d:	5b                   	pop    %ebx
  80377e:	5e                   	pop    %esi
  80377f:	5f                   	pop    %edi
  803780:	5d                   	pop    %ebp
  803781:	c3                   	ret    
  803782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803788:	39 f2                	cmp    %esi,%edx
  80378a:	89 d0                	mov    %edx,%eax
  80378c:	77 52                	ja     8037e0 <__umoddi3+0xa0>
  80378e:	0f bd ea             	bsr    %edx,%ebp
  803791:	83 f5 1f             	xor    $0x1f,%ebp
  803794:	75 5a                	jne    8037f0 <__umoddi3+0xb0>
  803796:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80379a:	0f 82 e0 00 00 00    	jb     803880 <__umoddi3+0x140>
  8037a0:	39 0c 24             	cmp    %ecx,(%esp)
  8037a3:	0f 86 d7 00 00 00    	jbe    803880 <__umoddi3+0x140>
  8037a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8037ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8037b1:	83 c4 1c             	add    $0x1c,%esp
  8037b4:	5b                   	pop    %ebx
  8037b5:	5e                   	pop    %esi
  8037b6:	5f                   	pop    %edi
  8037b7:	5d                   	pop    %ebp
  8037b8:	c3                   	ret    
  8037b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037c0:	85 ff                	test   %edi,%edi
  8037c2:	89 fd                	mov    %edi,%ebp
  8037c4:	75 0b                	jne    8037d1 <__umoddi3+0x91>
  8037c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8037cb:	31 d2                	xor    %edx,%edx
  8037cd:	f7 f7                	div    %edi
  8037cf:	89 c5                	mov    %eax,%ebp
  8037d1:	89 f0                	mov    %esi,%eax
  8037d3:	31 d2                	xor    %edx,%edx
  8037d5:	f7 f5                	div    %ebp
  8037d7:	89 c8                	mov    %ecx,%eax
  8037d9:	f7 f5                	div    %ebp
  8037db:	89 d0                	mov    %edx,%eax
  8037dd:	eb 99                	jmp    803778 <__umoddi3+0x38>
  8037df:	90                   	nop
  8037e0:	89 c8                	mov    %ecx,%eax
  8037e2:	89 f2                	mov    %esi,%edx
  8037e4:	83 c4 1c             	add    $0x1c,%esp
  8037e7:	5b                   	pop    %ebx
  8037e8:	5e                   	pop    %esi
  8037e9:	5f                   	pop    %edi
  8037ea:	5d                   	pop    %ebp
  8037eb:	c3                   	ret    
  8037ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8037f0:	8b 34 24             	mov    (%esp),%esi
  8037f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8037f8:	89 e9                	mov    %ebp,%ecx
  8037fa:	29 ef                	sub    %ebp,%edi
  8037fc:	d3 e0                	shl    %cl,%eax
  8037fe:	89 f9                	mov    %edi,%ecx
  803800:	89 f2                	mov    %esi,%edx
  803802:	d3 ea                	shr    %cl,%edx
  803804:	89 e9                	mov    %ebp,%ecx
  803806:	09 c2                	or     %eax,%edx
  803808:	89 d8                	mov    %ebx,%eax
  80380a:	89 14 24             	mov    %edx,(%esp)
  80380d:	89 f2                	mov    %esi,%edx
  80380f:	d3 e2                	shl    %cl,%edx
  803811:	89 f9                	mov    %edi,%ecx
  803813:	89 54 24 04          	mov    %edx,0x4(%esp)
  803817:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80381b:	d3 e8                	shr    %cl,%eax
  80381d:	89 e9                	mov    %ebp,%ecx
  80381f:	89 c6                	mov    %eax,%esi
  803821:	d3 e3                	shl    %cl,%ebx
  803823:	89 f9                	mov    %edi,%ecx
  803825:	89 d0                	mov    %edx,%eax
  803827:	d3 e8                	shr    %cl,%eax
  803829:	89 e9                	mov    %ebp,%ecx
  80382b:	09 d8                	or     %ebx,%eax
  80382d:	89 d3                	mov    %edx,%ebx
  80382f:	89 f2                	mov    %esi,%edx
  803831:	f7 34 24             	divl   (%esp)
  803834:	89 d6                	mov    %edx,%esi
  803836:	d3 e3                	shl    %cl,%ebx
  803838:	f7 64 24 04          	mull   0x4(%esp)
  80383c:	39 d6                	cmp    %edx,%esi
  80383e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803842:	89 d1                	mov    %edx,%ecx
  803844:	89 c3                	mov    %eax,%ebx
  803846:	72 08                	jb     803850 <__umoddi3+0x110>
  803848:	75 11                	jne    80385b <__umoddi3+0x11b>
  80384a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80384e:	73 0b                	jae    80385b <__umoddi3+0x11b>
  803850:	2b 44 24 04          	sub    0x4(%esp),%eax
  803854:	1b 14 24             	sbb    (%esp),%edx
  803857:	89 d1                	mov    %edx,%ecx
  803859:	89 c3                	mov    %eax,%ebx
  80385b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80385f:	29 da                	sub    %ebx,%edx
  803861:	19 ce                	sbb    %ecx,%esi
  803863:	89 f9                	mov    %edi,%ecx
  803865:	89 f0                	mov    %esi,%eax
  803867:	d3 e0                	shl    %cl,%eax
  803869:	89 e9                	mov    %ebp,%ecx
  80386b:	d3 ea                	shr    %cl,%edx
  80386d:	89 e9                	mov    %ebp,%ecx
  80386f:	d3 ee                	shr    %cl,%esi
  803871:	09 d0                	or     %edx,%eax
  803873:	89 f2                	mov    %esi,%edx
  803875:	83 c4 1c             	add    $0x1c,%esp
  803878:	5b                   	pop    %ebx
  803879:	5e                   	pop    %esi
  80387a:	5f                   	pop    %edi
  80387b:	5d                   	pop    %ebp
  80387c:	c3                   	ret    
  80387d:	8d 76 00             	lea    0x0(%esi),%esi
  803880:	29 f9                	sub    %edi,%ecx
  803882:	19 d6                	sbb    %edx,%esi
  803884:	89 74 24 04          	mov    %esi,0x4(%esp)
  803888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80388c:	e9 18 ff ff ff       	jmp    8037a9 <__umoddi3+0x69>
