
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
  80002c:	e8 a2 1a 00 00       	call   801ad3 <libmain>
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
  8000b2:	68 60 3d 80 00       	push   $0x803d60
  8000b7:	e8 50 1b 00 00       	call   801c0c <cprintf>
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
  8000d4:	68 77 3d 80 00       	push   $0x803d77
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 87 3d 80 00       	push   $0x803d87
  8000e0:	e8 4e 1a 00 00       	call   801b33 <_panic>
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
  800106:	68 90 3d 80 00       	push   $0x803d90
  80010b:	68 9d 3d 80 00       	push   $0x803d9d
  800110:	6a 44                	push   $0x44
  800112:	68 87 3d 80 00       	push   $0x803d87
  800117:	e8 17 1a 00 00       	call   801b33 <_panic>

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
  8001ca:	68 90 3d 80 00       	push   $0x803d90
  8001cf:	68 9d 3d 80 00       	push   $0x803d9d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 87 3d 80 00       	push   $0x803d87
  8001db:	e8 53 19 00 00       	call   801b33 <_panic>

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
  80029e:	68 b4 3d 80 00       	push   $0x803db4
  8002a3:	6a 27                	push   $0x27
  8002a5:	68 90 3e 80 00       	push   $0x803e90
  8002aa:	e8 84 18 00 00       	call   801b33 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002af:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 70 04             	cmp    0x4(%eax),%esi
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	56                   	push   %esi
  8002be:	68 e4 3d 80 00       	push   $0x803de4
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 90 3e 80 00       	push   $0x803e90
  8002ca:	e8 64 18 00 00       	call   801b33 <_panic>
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
  8002df:	e8 b0 22 00 00       	call   802594 <sys_page_alloc>
	if (r < 0)
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	79 12                	jns    8002fd <bc_pgfault+0x89>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8002eb:	50                   	push   %eax
  8002ec:	68 08 3e 80 00       	push   $0x803e08
  8002f1:	6a 38                	push   $0x38
  8002f3:	68 90 3e 80 00       	push   $0x803e90
  8002f8:	e8 36 18 00 00       	call   801b33 <_panic>

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
  800318:	68 98 3e 80 00       	push   $0x803e98
  80031d:	6a 3c                	push   $0x3c
  80031f:	68 90 3e 80 00       	push   $0x803e90
  800324:	e8 0a 18 00 00       	call   801b33 <_panic>

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
  800344:	e8 8e 22 00 00       	call   8025d7 <sys_page_map>
  800349:	83 c4 20             	add    $0x20,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 12                	jns    800362 <bc_pgfault+0xee>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800350:	50                   	push   %eax
  800351:	68 28 3e 80 00       	push   $0x803e28
  800356:	6a 41                	push   $0x41
  800358:	68 90 3e 80 00       	push   $0x803e90
  80035d:	e8 d1 17 00 00       	call   801b33 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800362:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800369:	74 22                	je     80038d <bc_pgfault+0x119>
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	56                   	push   %esi
  80036f:	e8 94 04 00 00       	call   800808 <block_is_free>
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	84 c0                	test   %al,%al
  800379:	74 12                	je     80038d <bc_pgfault+0x119>
		panic("reading free block %08x\n", blockno);
  80037b:	56                   	push   %esi
  80037c:	68 b1 3e 80 00       	push   $0x803eb1
  800381:	6a 47                	push   $0x47
  800383:	68 90 3e 80 00       	push   $0x803e90
  800388:	e8 a6 17 00 00       	call   801b33 <_panic>
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
  8003a2:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 17                	je     8003c3 <diskaddr+0x2e>
  8003ac:	3b 42 04             	cmp    0x4(%edx),%eax
  8003af:	72 12                	jb     8003c3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003b1:	50                   	push   %eax
  8003b2:	68 48 3e 80 00       	push   $0x803e48
  8003b7:	6a 09                	push   $0x9
  8003b9:	68 90 3e 80 00       	push   $0x803e90
  8003be:	e8 70 17 00 00       	call   801b33 <_panic>
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
  800429:	68 ca 3e 80 00       	push   $0x803eca
  80042e:	6a 57                	push   $0x57
  800430:	68 90 3e 80 00       	push   $0x803e90
  800435:	e8 f9 16 00 00       	call   801b33 <_panic>

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

	int r = ide_write(blockno * (BLKSIZE / SECTSIZE), base_addr, (BLKSIZE / SECTSIZE));
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
  800486:	68 e5 3e 80 00       	push   $0x803ee5
  80048b:	6a 63                	push   $0x63
  80048d:	68 90 3e 80 00       	push   $0x803e90
  800492:	e8 9c 16 00 00       	call   801b33 <_panic>

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
  8004b0:	e8 22 21 00 00       	call   8025d7 <sys_page_map>
	if (r < 0)
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 12                	jns    8004ce <flush_block+0xbb>
		panic("flush_block: sys_page_map: %e", r);
  8004bc:	50                   	push   %eax
  8004bd:	68 00 3f 80 00       	push   $0x803f00
  8004c2:	6a 67                	push   $0x67
  8004c4:	68 90 3e 80 00       	push   $0x803e90
  8004c9:	e8 65 16 00 00       	call   801b33 <_panic>

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
  8004e4:	e8 fd 22 00 00       	call   8027e6 <set_pgfault_handler>
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
  800505:	e8 19 1e 00 00       	call   802323 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80050a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800511:	e8 7f fe ff ff       	call   800395 <diskaddr>
  800516:	83 c4 08             	add    $0x8,%esp
  800519:	68 1e 3f 80 00       	push   $0x803f1e
  80051e:	50                   	push   %eax
  80051f:	e8 6d 1c 00 00       	call   802191 <strcpy>
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
  800553:	68 40 3f 80 00       	push   $0x803f40
  800558:	68 9d 3d 80 00       	push   $0x803d9d
  80055d:	6a 78                	push   $0x78
  80055f:	68 90 3e 80 00       	push   $0x803e90
  800564:	e8 ca 15 00 00       	call   801b33 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	e8 22 fe ff ff       	call   800395 <diskaddr>
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 80 fe ff ff       	call   8003fb <va_is_dirty>
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	84 c0                	test   %al,%al
  800580:	74 16                	je     800598 <bc_init+0xc3>
  800582:	68 25 3f 80 00       	push   $0x803f25
  800587:	68 9d 3d 80 00       	push   $0x803d9d
  80058c:	6a 79                	push   $0x79
  80058e:	68 90 3e 80 00       	push   $0x803e90
  800593:	e8 9b 15 00 00       	call   801b33 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	6a 01                	push   $0x1
  80059d:	e8 f3 fd ff ff       	call   800395 <diskaddr>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	50                   	push   %eax
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 6c 20 00 00       	call   802619 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b4:	e8 dc fd ff ff       	call   800395 <diskaddr>
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 0c fe ff ff       	call   8003cd <va_is_mapped>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	84 c0                	test   %al,%al
  8005c6:	74 16                	je     8005de <bc_init+0x109>
  8005c8:	68 3f 3f 80 00       	push   $0x803f3f
  8005cd:	68 9d 3d 80 00       	push   $0x803d9d
  8005d2:	6a 7d                	push   $0x7d
  8005d4:	68 90 3e 80 00       	push   $0x803e90
  8005d9:	e8 55 15 00 00       	call   801b33 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	6a 01                	push   $0x1
  8005e3:	e8 ad fd ff ff       	call   800395 <diskaddr>
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	68 1e 3f 80 00       	push   $0x803f1e
  8005f0:	50                   	push   %eax
  8005f1:	e8 45 1c 00 00       	call   80223b <strcmp>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	74 19                	je     800616 <bc_init+0x141>
  8005fd:	68 6c 3e 80 00       	push   $0x803e6c
  800602:	68 9d 3d 80 00       	push   $0x803d9d
  800607:	68 80 00 00 00       	push   $0x80
  80060c:	68 90 3e 80 00       	push   $0x803e90
  800611:	e8 1d 15 00 00       	call   801b33 <_panic>

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
  800630:	e8 ee 1c 00 00       	call   802323 <memmove>
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
  80065f:	e8 bf 1c 00 00       	call   802323 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066b:	e8 25 fd ff ff       	call   800395 <diskaddr>
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	68 1e 3f 80 00       	push   $0x803f1e
  800678:	50                   	push   %eax
  800679:	e8 13 1b 00 00       	call   802191 <strcpy>

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
  8006b0:	68 40 3f 80 00       	push   $0x803f40
  8006b5:	68 9d 3d 80 00       	push   $0x803d9d
  8006ba:	68 91 00 00 00       	push   $0x91
  8006bf:	68 90 3e 80 00       	push   $0x803e90
  8006c4:	e8 6a 14 00 00       	call   801b33 <_panic>
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
  8006d9:	e8 3b 1f 00 00       	call   802619 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 ab fc ff ff       	call   800395 <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 db fc ff ff       	call   8003cd <va_is_mapped>
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	84 c0                	test   %al,%al
  8006f7:	74 19                	je     800712 <bc_init+0x23d>
  8006f9:	68 3f 3f 80 00       	push   $0x803f3f
  8006fe:	68 9d 3d 80 00       	push   $0x803d9d
  800703:	68 99 00 00 00       	push   $0x99
  800708:	68 90 3e 80 00       	push   $0x803e90
  80070d:	e8 21 14 00 00       	call   801b33 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	6a 01                	push   $0x1
  800717:	e8 79 fc ff ff       	call   800395 <diskaddr>
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	68 1e 3f 80 00       	push   $0x803f1e
  800724:	50                   	push   %eax
  800725:	e8 11 1b 00 00       	call   80223b <strcmp>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 19                	je     80074a <bc_init+0x275>
  800731:	68 6c 3e 80 00       	push   $0x803e6c
  800736:	68 9d 3d 80 00       	push   $0x803d9d
  80073b:	68 9c 00 00 00       	push   $0x9c
  800740:	68 90 3e 80 00       	push   $0x803e90
  800745:	e8 e9 13 00 00       	call   801b33 <_panic>

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
  800764:	e8 ba 1b 00 00       	call   802323 <memmove>
	flush_block(diskaddr(1));
  800769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800770:	e8 20 fc ff ff       	call   800395 <diskaddr>
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 96 fc ff ff       	call   800413 <flush_block>

	cprintf("block cache is good\n");
  80077d:	c7 04 24 5a 3f 80 00 	movl   $0x803f5a,(%esp)
  800784:	e8 83 14 00 00       	call   801c0c <cprintf>
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
  8007a5:	e8 79 1b 00 00       	call   802323 <memmove>
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
  8007b8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8007bd:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007c3:	74 14                	je     8007d9 <check_super+0x27>
		panic("bad file system magic number");
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	68 6f 3f 80 00       	push   $0x803f6f
  8007cd:	6a 0f                	push   $0xf
  8007cf:	68 8c 3f 80 00       	push   $0x803f8c
  8007d4:	e8 5a 13 00 00       	call   801b33 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007d9:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e0:	76 14                	jbe    8007f6 <check_super+0x44>
		panic("file system is too large");
  8007e2:	83 ec 04             	sub    $0x4,%esp
  8007e5:	68 94 3f 80 00       	push   $0x803f94
  8007ea:	6a 12                	push   $0x12
  8007ec:	68 8c 3f 80 00       	push   $0x803f8c
  8007f1:	e8 3d 13 00 00       	call   801b33 <_panic>

	cprintf("superblock is good\n");
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	68 ad 3f 80 00       	push   $0x803fad
  8007fe:	e8 09 14 00 00       	call   801c0c <cprintf>
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
  80080f:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
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
  80082f:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
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
  800856:	68 c1 3f 80 00       	push   $0x803fc1
  80085b:	6a 2d                	push   $0x2d
  80085d:	68 8c 3f 80 00       	push   $0x803f8c
  800862:	e8 cc 12 00 00       	call   801b33 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800867:	89 cb                	mov    %ecx,%ebx
  800869:	c1 eb 05             	shr    $0x5,%ebx
  80086c:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
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
  800886:	a1 0c a0 80 00       	mov    0x80a00c,%eax
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
  8008b2:	03 15 08 a0 80 00    	add    0x80a008,%edx
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
  8008d4:	03 05 08 a0 80 00    	add    0x80a008,%eax
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
  80099a:	e8 37 19 00 00       	call   8022d6 <memset>
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
  8009fc:	a1 0c a0 80 00       	mov    0x80a00c,%eax
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
  800a1b:	68 dc 3f 80 00       	push   $0x803fdc
  800a20:	68 9d 3d 80 00       	push   $0x803d9d
  800a25:	6a 60                	push   $0x60
  800a27:	68 8c 3f 80 00       	push   $0x803f8c
  800a2c:	e8 02 11 00 00       	call   801b33 <_panic>
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
  800a4e:	68 f0 3f 80 00       	push   $0x803ff0
  800a53:	68 9d 3d 80 00       	push   $0x803d9d
  800a58:	6a 63                	push   $0x63
  800a5a:	68 8c 3f 80 00       	push   $0x803f8c
  800a5f:	e8 cf 10 00 00       	call   801b33 <_panic>
	assert(!block_is_free(1));
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	6a 01                	push   $0x1
  800a69:	e8 9a fd ff ff       	call   800808 <block_is_free>
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	84 c0                	test   %al,%al
  800a73:	74 16                	je     800a8b <check_bitmap+0x94>
  800a75:	68 02 40 80 00       	push   $0x804002
  800a7a:	68 9d 3d 80 00       	push   $0x803d9d
  800a7f:	6a 64                	push   $0x64
  800a81:	68 8c 3f 80 00       	push   $0x803f8c
  800a86:	e8 a8 10 00 00       	call   801b33 <_panic>

	cprintf("bitmap is good\n");
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	68 14 40 80 00       	push   $0x804014
  800a93:	e8 74 11 00 00       	call   801c0c <cprintf>
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
  800adc:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800ae1:	e8 cc fc ff ff       	call   8007b2 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800ae6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800aed:	e8 a3 f8 ff ff       	call   800395 <diskaddr>
  800af2:	a3 08 a0 80 00       	mov    %eax,0x80a008
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
  800b4b:	e8 86 17 00 00       	call   8022d6 <memset>
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
  800ba4:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
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
  800c0c:	e8 12 17 00 00       	call   802323 <memmove>
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
  800c46:	68 24 40 80 00       	push   $0x804024
  800c4b:	68 9d 3d 80 00       	push   $0x803d9d
  800c50:	68 05 01 00 00       	push   $0x105
  800c55:	68 8c 3f 80 00       	push   $0x803f8c
  800c5a:	e8 d4 0e 00 00       	call   801b33 <_panic>
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
  800cc2:	e8 74 15 00 00       	call   80223b <strcmp>
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
  800d2a:	e8 62 14 00 00       	call   802191 <strcpy>
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
  800e51:	e8 cd 14 00 00       	call   802323 <memmove>
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
  800f22:	68 41 40 80 00       	push   $0x804041
  800f27:	e8 e0 0c 00 00       	call   801c0c <cprintf>
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
  800fd8:	e8 46 13 00 00       	call   802323 <memmove>
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
  8010e9:	68 24 40 80 00       	push   $0x804024
  8010ee:	68 9d 3d 80 00       	push   $0x803d9d
  8010f3:	68 1e 01 00 00       	push   $0x11e
  8010f8:	68 8c 3f 80 00       	push   $0x803f8c
  8010fd:	e8 31 0a 00 00       	call   801b33 <_panic>
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
  8011b4:	e8 d8 0f 00 00       	call   802191 <strcpy>
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
  801207:	a1 0c a0 80 00       	mov    0x80a00c,%eax
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
  80126f:	e8 cf 1e 00 00       	call   803143 <pageref>
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
  801294:	e8 fb 12 00 00       	call   802594 <sys_page_alloc>
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
  8012c5:	e8 0c 10 00 00       	call   8022d6 <memset>
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
  80130f:	e8 2f 1e 00 00       	call   803143 <pageref>
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
  801454:	e8 38 0d 00 00       	call   802191 <strcpy>
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
  8014de:	e8 40 0e 00 00       	call   802323 <memmove>
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
  801615:	e8 37 12 00 00       	call   802851 <ipc_recv>
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
  801629:	68 60 40 80 00       	push   $0x804060
  80162e:	e8 d9 05 00 00       	call   801c0c <cprintf>
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
  801686:	68 90 40 80 00       	push   $0x804090
  80168b:	e8 7c 05 00 00       	call   801c0c <cprintf>
  801690:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801698:	ff 75 f0             	pushl  -0x10(%ebp)
  80169b:	ff 75 ec             	pushl  -0x14(%ebp)
  80169e:	50                   	push   %eax
  80169f:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a2:	e8 11 12 00 00       	call   8028b8 <ipc_send>
		sys_page_unmap(0, fsreq);
  8016a7:	83 c4 08             	add    $0x8,%esp
  8016aa:	ff 35 44 50 80 00    	pushl  0x805044
  8016b0:	6a 00                	push   $0x0
  8016b2:	e8 62 0f 00 00       	call   802619 <sys_page_unmap>
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
  8016c5:	c7 05 60 90 80 00 b3 	movl   $0x8040b3,0x809060
  8016cc:	40 80 00 
	cprintf("FS is running\n");
  8016cf:	68 b6 40 80 00       	push   $0x8040b6
  8016d4:	e8 33 05 00 00       	call   801c0c <cprintf>
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
  8016e5:	c7 04 24 c5 40 80 00 	movl   $0x8040c5,(%esp)
  8016ec:	e8 1b 05 00 00       	call   801c0c <cprintf>

	serve_init();
  8016f1:	e8 32 fb ff ff       	call   801228 <serve_init>
	fs_init();
  8016f6:	e8 a7 f3 ff ff       	call   800aa2 <fs_init>
	serve();
  8016fb:	e8 f5 fe ff ff       	call   8015f5 <serve>

00801700 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	53                   	push   %ebx
  801704:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801707:	6a 07                	push   $0x7
  801709:	68 00 10 00 00       	push   $0x1000
  80170e:	6a 00                	push   $0x0
  801710:	e8 7f 0e 00 00       	call   802594 <sys_page_alloc>
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	79 12                	jns    80172e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80171c:	50                   	push   %eax
  80171d:	68 d4 40 80 00       	push   $0x8040d4
  801722:	6a 12                	push   $0x12
  801724:	68 e7 40 80 00       	push   $0x8040e7
  801729:	e8 05 04 00 00       	call   801b33 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	68 00 10 00 00       	push   $0x1000
  801736:	ff 35 08 a0 80 00    	pushl  0x80a008
  80173c:	68 00 10 00 00       	push   $0x1000
  801741:	e8 dd 0b 00 00       	call   802323 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801746:	e8 36 f1 ff ff       	call   800881 <alloc_block>
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	85 c0                	test   %eax,%eax
  801750:	79 12                	jns    801764 <fs_test+0x64>
		panic("alloc_block: %e", r);
  801752:	50                   	push   %eax
  801753:	68 f1 40 80 00       	push   $0x8040f1
  801758:	6a 17                	push   $0x17
  80175a:	68 e7 40 80 00       	push   $0x8040e7
  80175f:	e8 cf 03 00 00       	call   801b33 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801764:	8d 50 1f             	lea    0x1f(%eax),%edx
  801767:	85 c0                	test   %eax,%eax
  801769:	0f 49 d0             	cmovns %eax,%edx
  80176c:	c1 fa 05             	sar    $0x5,%edx
  80176f:	89 c3                	mov    %eax,%ebx
  801771:	c1 fb 1f             	sar    $0x1f,%ebx
  801774:	c1 eb 1b             	shr    $0x1b,%ebx
  801777:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  80177a:	83 e1 1f             	and    $0x1f,%ecx
  80177d:	29 d9                	sub    %ebx,%ecx
  80177f:	b8 01 00 00 00       	mov    $0x1,%eax
  801784:	d3 e0                	shl    %cl,%eax
  801786:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  80178d:	75 16                	jne    8017a5 <fs_test+0xa5>
  80178f:	68 01 41 80 00       	push   $0x804101
  801794:	68 9d 3d 80 00       	push   $0x803d9d
  801799:	6a 19                	push   $0x19
  80179b:	68 e7 40 80 00       	push   $0x8040e7
  8017a0:	e8 8e 03 00 00       	call   801b33 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017a5:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8017ab:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8017ae:	74 16                	je     8017c6 <fs_test+0xc6>
  8017b0:	68 7c 42 80 00       	push   $0x80427c
  8017b5:	68 9d 3d 80 00       	push   $0x803d9d
  8017ba:	6a 1b                	push   $0x1b
  8017bc:	68 e7 40 80 00       	push   $0x8040e7
  8017c1:	e8 6d 03 00 00       	call   801b33 <_panic>
	cprintf("alloc_block is good\n");
  8017c6:	83 ec 0c             	sub    $0xc,%esp
  8017c9:	68 1c 41 80 00       	push   $0x80411c
  8017ce:	e8 39 04 00 00       	call   801c0c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8017d3:	83 c4 08             	add    $0x8,%esp
  8017d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	68 31 41 80 00       	push   $0x804131
  8017df:	e8 cc f5 ff ff       	call   800db0 <file_open>
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8017ea:	74 1b                	je     801807 <fs_test+0x107>
  8017ec:	89 c2                	mov    %eax,%edx
  8017ee:	c1 ea 1f             	shr    $0x1f,%edx
  8017f1:	84 d2                	test   %dl,%dl
  8017f3:	74 12                	je     801807 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  8017f5:	50                   	push   %eax
  8017f6:	68 3c 41 80 00       	push   $0x80413c
  8017fb:	6a 1f                	push   $0x1f
  8017fd:	68 e7 40 80 00       	push   $0x8040e7
  801802:	e8 2c 03 00 00       	call   801b33 <_panic>
	else if (r == 0)
  801807:	85 c0                	test   %eax,%eax
  801809:	75 14                	jne    80181f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	68 9c 42 80 00       	push   $0x80429c
  801813:	6a 21                	push   $0x21
  801815:	68 e7 40 80 00       	push   $0x8040e7
  80181a:	e8 14 03 00 00       	call   801b33 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	68 55 41 80 00       	push   $0x804155
  80182b:	e8 80 f5 ff ff       	call   800db0 <file_open>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	79 12                	jns    801849 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801837:	50                   	push   %eax
  801838:	68 5e 41 80 00       	push   $0x80415e
  80183d:	6a 23                	push   $0x23
  80183f:	68 e7 40 80 00       	push   $0x8040e7
  801844:	e8 ea 02 00 00       	call   801b33 <_panic>
	cprintf("file_open is good\n");
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	68 75 41 80 00       	push   $0x804175
  801851:	e8 b6 03 00 00       	call   801c0c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801856:	83 c4 0c             	add    $0xc,%esp
  801859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	6a 00                	push   $0x0
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 9a f2 ff ff       	call   800b01 <file_get_block>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	79 12                	jns    801880 <fs_test+0x180>
		panic("file_get_block: %e", r);
  80186e:	50                   	push   %eax
  80186f:	68 88 41 80 00       	push   $0x804188
  801874:	6a 27                	push   $0x27
  801876:	68 e7 40 80 00       	push   $0x8040e7
  80187b:	e8 b3 02 00 00       	call   801b33 <_panic>
	if (strcmp(blk, msg) != 0)
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	68 bc 42 80 00       	push   $0x8042bc
  801888:	ff 75 f0             	pushl  -0x10(%ebp)
  80188b:	e8 ab 09 00 00       	call   80223b <strcmp>
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	74 14                	je     8018ab <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801897:	83 ec 04             	sub    $0x4,%esp
  80189a:	68 e4 42 80 00       	push   $0x8042e4
  80189f:	6a 29                	push   $0x29
  8018a1:	68 e7 40 80 00       	push   $0x8040e7
  8018a6:	e8 88 02 00 00       	call   801b33 <_panic>
	cprintf("file_get_block is good\n");
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	68 9b 41 80 00       	push   $0x80419b
  8018b3:	e8 54 03 00 00       	call   801c0c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8018b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bb:	0f b6 10             	movzbl (%eax),%edx
  8018be:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c3:	c1 e8 0c             	shr    $0xc,%eax
  8018c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	a8 40                	test   $0x40,%al
  8018d2:	75 16                	jne    8018ea <fs_test+0x1ea>
  8018d4:	68 b4 41 80 00       	push   $0x8041b4
  8018d9:	68 9d 3d 80 00       	push   $0x803d9d
  8018de:	6a 2d                	push   $0x2d
  8018e0:	68 e7 40 80 00       	push   $0x8040e7
  8018e5:	e8 49 02 00 00       	call   801b33 <_panic>
	file_flush(f);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f0:	e8 01 f7 ff ff       	call   800ff6 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f8:	c1 e8 0c             	shr    $0xc,%eax
  8018fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	a8 40                	test   $0x40,%al
  801907:	74 16                	je     80191f <fs_test+0x21f>
  801909:	68 b3 41 80 00       	push   $0x8041b3
  80190e:	68 9d 3d 80 00       	push   $0x803d9d
  801913:	6a 2f                	push   $0x2f
  801915:	68 e7 40 80 00       	push   $0x8040e7
  80191a:	e8 14 02 00 00       	call   801b33 <_panic>
	cprintf("file_flush is good\n");
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	68 cf 41 80 00       	push   $0x8041cf
  801927:	e8 e0 02 00 00       	call   801c0c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80192c:	83 c4 08             	add    $0x8,%esp
  80192f:	6a 00                	push   $0x0
  801931:	ff 75 f4             	pushl  -0xc(%ebp)
  801934:	e8 36 f5 ff ff       	call   800e6f <file_set_size>
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	79 12                	jns    801952 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801940:	50                   	push   %eax
  801941:	68 e3 41 80 00       	push   $0x8041e3
  801946:	6a 33                	push   $0x33
  801948:	68 e7 40 80 00       	push   $0x8040e7
  80194d:	e8 e1 01 00 00       	call   801b33 <_panic>
	assert(f->f_direct[0] == 0);
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80195c:	74 16                	je     801974 <fs_test+0x274>
  80195e:	68 f5 41 80 00       	push   $0x8041f5
  801963:	68 9d 3d 80 00       	push   $0x803d9d
  801968:	6a 34                	push   $0x34
  80196a:	68 e7 40 80 00       	push   $0x8040e7
  80196f:	e8 bf 01 00 00       	call   801b33 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801974:	c1 e8 0c             	shr    $0xc,%eax
  801977:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80197e:	a8 40                	test   $0x40,%al
  801980:	74 16                	je     801998 <fs_test+0x298>
  801982:	68 09 42 80 00       	push   $0x804209
  801987:	68 9d 3d 80 00       	push   $0x803d9d
  80198c:	6a 35                	push   $0x35
  80198e:	68 e7 40 80 00       	push   $0x8040e7
  801993:	e8 9b 01 00 00       	call   801b33 <_panic>
	cprintf("file_truncate is good\n");
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	68 23 42 80 00       	push   $0x804223
  8019a0:	e8 67 02 00 00       	call   801c0c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8019a5:	c7 04 24 bc 42 80 00 	movl   $0x8042bc,(%esp)
  8019ac:	e8 a7 07 00 00       	call   802158 <strlen>
  8019b1:	83 c4 08             	add    $0x8,%esp
  8019b4:	50                   	push   %eax
  8019b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b8:	e8 b2 f4 ff ff       	call   800e6f <file_set_size>
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	79 12                	jns    8019d6 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8019c4:	50                   	push   %eax
  8019c5:	68 3a 42 80 00       	push   $0x80423a
  8019ca:	6a 39                	push   $0x39
  8019cc:	68 e7 40 80 00       	push   $0x8040e7
  8019d1:	e8 5d 01 00 00       	call   801b33 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	c1 ea 0c             	shr    $0xc,%edx
  8019de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019e5:	f6 c2 40             	test   $0x40,%dl
  8019e8:	74 16                	je     801a00 <fs_test+0x300>
  8019ea:	68 09 42 80 00       	push   $0x804209
  8019ef:	68 9d 3d 80 00       	push   $0x803d9d
  8019f4:	6a 3a                	push   $0x3a
  8019f6:	68 e7 40 80 00       	push   $0x8040e7
  8019fb:	e8 33 01 00 00       	call   801b33 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a00:	83 ec 04             	sub    $0x4,%esp
  801a03:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801a06:	52                   	push   %edx
  801a07:	6a 00                	push   $0x0
  801a09:	50                   	push   %eax
  801a0a:	e8 f2 f0 ff ff       	call   800b01 <file_get_block>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	79 12                	jns    801a28 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801a16:	50                   	push   %eax
  801a17:	68 4e 42 80 00       	push   $0x80424e
  801a1c:	6a 3c                	push   $0x3c
  801a1e:	68 e7 40 80 00       	push   $0x8040e7
  801a23:	e8 0b 01 00 00       	call   801b33 <_panic>
	strcpy(blk, msg);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	68 bc 42 80 00       	push   $0x8042bc
  801a30:	ff 75 f0             	pushl  -0x10(%ebp)
  801a33:	e8 59 07 00 00       	call   802191 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3b:	c1 e8 0c             	shr    $0xc,%eax
  801a3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	a8 40                	test   $0x40,%al
  801a4a:	75 16                	jne    801a62 <fs_test+0x362>
  801a4c:	68 b4 41 80 00       	push   $0x8041b4
  801a51:	68 9d 3d 80 00       	push   $0x803d9d
  801a56:	6a 3e                	push   $0x3e
  801a58:	68 e7 40 80 00       	push   $0x8040e7
  801a5d:	e8 d1 00 00 00       	call   801b33 <_panic>
	file_flush(f);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	ff 75 f4             	pushl  -0xc(%ebp)
  801a68:	e8 89 f5 ff ff       	call   800ff6 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a70:	c1 e8 0c             	shr    $0xc,%eax
  801a73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	a8 40                	test   $0x40,%al
  801a7f:	74 16                	je     801a97 <fs_test+0x397>
  801a81:	68 b3 41 80 00       	push   $0x8041b3
  801a86:	68 9d 3d 80 00       	push   $0x803d9d
  801a8b:	6a 40                	push   $0x40
  801a8d:	68 e7 40 80 00       	push   $0x8040e7
  801a92:	e8 9c 00 00 00       	call   801b33 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9a:	c1 e8 0c             	shr    $0xc,%eax
  801a9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aa4:	a8 40                	test   $0x40,%al
  801aa6:	74 16                	je     801abe <fs_test+0x3be>
  801aa8:	68 09 42 80 00       	push   $0x804209
  801aad:	68 9d 3d 80 00       	push   $0x803d9d
  801ab2:	6a 41                	push   $0x41
  801ab4:	68 e7 40 80 00       	push   $0x8040e7
  801ab9:	e8 75 00 00 00       	call   801b33 <_panic>
	cprintf("file rewrite is good\n");
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	68 63 42 80 00       	push   $0x804263
  801ac6:	e8 41 01 00 00       	call   801c0c <cprintf>
}
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801adb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801ade:	e8 73 0a 00 00       	call   802556 <sys_getenvid>
  801ae3:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ae8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aeb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af0:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801af5:	85 db                	test   %ebx,%ebx
  801af7:	7e 07                	jle    801b00 <libmain+0x2d>
		binaryname = argv[0];
  801af9:	8b 06                	mov    (%esi),%eax
  801afb:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	e8 b5 fb ff ff       	call   8016bf <umain>

	// exit gracefully
	exit();
  801b0a:	e8 0a 00 00 00       	call   801b19 <exit>
}
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801b1f:	e8 ec 0f 00 00       	call   802b10 <close_all>
	sys_env_destroy(0);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	6a 00                	push   $0x0
  801b29:	e8 e7 09 00 00       	call   802515 <sys_env_destroy>
}
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b38:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b3b:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801b41:	e8 10 0a 00 00       	call   802556 <sys_getenvid>
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	ff 75 0c             	pushl  0xc(%ebp)
  801b4c:	ff 75 08             	pushl  0x8(%ebp)
  801b4f:	56                   	push   %esi
  801b50:	50                   	push   %eax
  801b51:	68 14 43 80 00       	push   $0x804314
  801b56:	e8 b1 00 00 00       	call   801c0c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b5b:	83 c4 18             	add    $0x18,%esp
  801b5e:	53                   	push   %ebx
  801b5f:	ff 75 10             	pushl  0x10(%ebp)
  801b62:	e8 54 00 00 00       	call   801bbb <vcprintf>
	cprintf("\n");
  801b67:	c7 04 24 23 3f 80 00 	movl   $0x803f23,(%esp)
  801b6e:	e8 99 00 00 00       	call   801c0c <cprintf>
  801b73:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b76:	cc                   	int3   
  801b77:	eb fd                	jmp    801b76 <_panic+0x43>

00801b79 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 04             	sub    $0x4,%esp
  801b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b83:	8b 13                	mov    (%ebx),%edx
  801b85:	8d 42 01             	lea    0x1(%edx),%eax
  801b88:	89 03                	mov    %eax,(%ebx)
  801b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b91:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b96:	75 1a                	jne    801bb2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b98:	83 ec 08             	sub    $0x8,%esp
  801b9b:	68 ff 00 00 00       	push   $0xff
  801ba0:	8d 43 08             	lea    0x8(%ebx),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 2f 09 00 00       	call   8024d8 <sys_cputs>
		b->idx = 0;
  801ba9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801baf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801bb2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801bc4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801bcb:	00 00 00 
	b.cnt = 0;
  801bce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801bd5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	ff 75 08             	pushl  0x8(%ebp)
  801bde:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801be4:	50                   	push   %eax
  801be5:	68 79 1b 80 00       	push   $0x801b79
  801bea:	e8 54 01 00 00       	call   801d43 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bef:	83 c4 08             	add    $0x8,%esp
  801bf2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801bf8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	e8 d4 08 00 00       	call   8024d8 <sys_cputs>

	return b.cnt;
}
  801c04:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c12:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c15:	50                   	push   %eax
  801c16:	ff 75 08             	pushl  0x8(%ebp)
  801c19:	e8 9d ff ff ff       	call   801bbb <vcprintf>
	va_end(ap);

	return cnt;
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	57                   	push   %edi
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 1c             	sub    $0x1c,%esp
  801c29:	89 c7                	mov    %eax,%edi
  801c2b:	89 d6                	mov    %edx,%esi
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c36:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c39:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c41:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801c44:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801c47:	39 d3                	cmp    %edx,%ebx
  801c49:	72 05                	jb     801c50 <printnum+0x30>
  801c4b:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c4e:	77 45                	ja     801c95 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	ff 75 18             	pushl  0x18(%ebp)
  801c56:	8b 45 14             	mov    0x14(%ebp),%eax
  801c59:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c5c:	53                   	push   %ebx
  801c5d:	ff 75 10             	pushl  0x10(%ebp)
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c66:	ff 75 e0             	pushl  -0x20(%ebp)
  801c69:	ff 75 dc             	pushl  -0x24(%ebp)
  801c6c:	ff 75 d8             	pushl  -0x28(%ebp)
  801c6f:	e8 5c 1e 00 00       	call   803ad0 <__udivdi3>
  801c74:	83 c4 18             	add    $0x18,%esp
  801c77:	52                   	push   %edx
  801c78:	50                   	push   %eax
  801c79:	89 f2                	mov    %esi,%edx
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	e8 9e ff ff ff       	call   801c20 <printnum>
  801c82:	83 c4 20             	add    $0x20,%esp
  801c85:	eb 18                	jmp    801c9f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	56                   	push   %esi
  801c8b:	ff 75 18             	pushl  0x18(%ebp)
  801c8e:	ff d7                	call   *%edi
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	eb 03                	jmp    801c98 <printnum+0x78>
  801c95:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c98:	83 eb 01             	sub    $0x1,%ebx
  801c9b:	85 db                	test   %ebx,%ebx
  801c9d:	7f e8                	jg     801c87 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	56                   	push   %esi
  801ca3:	83 ec 04             	sub    $0x4,%esp
  801ca6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ca9:	ff 75 e0             	pushl  -0x20(%ebp)
  801cac:	ff 75 dc             	pushl  -0x24(%ebp)
  801caf:	ff 75 d8             	pushl  -0x28(%ebp)
  801cb2:	e8 49 1f 00 00       	call   803c00 <__umoddi3>
  801cb7:	83 c4 14             	add    $0x14,%esp
  801cba:	0f be 80 37 43 80 00 	movsbl 0x804337(%eax),%eax
  801cc1:	50                   	push   %eax
  801cc2:	ff d7                	call   *%edi
}
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801cd2:	83 fa 01             	cmp    $0x1,%edx
  801cd5:	7e 0e                	jle    801ce5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801cd7:	8b 10                	mov    (%eax),%edx
  801cd9:	8d 4a 08             	lea    0x8(%edx),%ecx
  801cdc:	89 08                	mov    %ecx,(%eax)
  801cde:	8b 02                	mov    (%edx),%eax
  801ce0:	8b 52 04             	mov    0x4(%edx),%edx
  801ce3:	eb 22                	jmp    801d07 <getuint+0x38>
	else if (lflag)
  801ce5:	85 d2                	test   %edx,%edx
  801ce7:	74 10                	je     801cf9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ce9:	8b 10                	mov    (%eax),%edx
  801ceb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801cee:	89 08                	mov    %ecx,(%eax)
  801cf0:	8b 02                	mov    (%edx),%eax
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf7:	eb 0e                	jmp    801d07 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801cf9:	8b 10                	mov    (%eax),%edx
  801cfb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801cfe:	89 08                	mov    %ecx,(%eax)
  801d00:	8b 02                	mov    (%edx),%eax
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d0f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801d13:	8b 10                	mov    (%eax),%edx
  801d15:	3b 50 04             	cmp    0x4(%eax),%edx
  801d18:	73 0a                	jae    801d24 <sprintputch+0x1b>
		*b->buf++ = ch;
  801d1a:	8d 4a 01             	lea    0x1(%edx),%ecx
  801d1d:	89 08                	mov    %ecx,(%eax)
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	88 02                	mov    %al,(%edx)
}
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801d2c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801d2f:	50                   	push   %eax
  801d30:	ff 75 10             	pushl  0x10(%ebp)
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	ff 75 08             	pushl  0x8(%ebp)
  801d39:	e8 05 00 00 00       	call   801d43 <vprintfmt>
	va_end(ap);
}
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	57                   	push   %edi
  801d47:	56                   	push   %esi
  801d48:	53                   	push   %ebx
  801d49:	83 ec 2c             	sub    $0x2c,%esp
  801d4c:	8b 75 08             	mov    0x8(%ebp),%esi
  801d4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d52:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d55:	eb 12                	jmp    801d69 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d57:	85 c0                	test   %eax,%eax
  801d59:	0f 84 89 03 00 00    	je     8020e8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	53                   	push   %ebx
  801d63:	50                   	push   %eax
  801d64:	ff d6                	call   *%esi
  801d66:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d69:	83 c7 01             	add    $0x1,%edi
  801d6c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d70:	83 f8 25             	cmp    $0x25,%eax
  801d73:	75 e2                	jne    801d57 <vprintfmt+0x14>
  801d75:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801d79:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d80:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d87:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d93:	eb 07                	jmp    801d9c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d98:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d9c:	8d 47 01             	lea    0x1(%edi),%eax
  801d9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801da2:	0f b6 07             	movzbl (%edi),%eax
  801da5:	0f b6 c8             	movzbl %al,%ecx
  801da8:	83 e8 23             	sub    $0x23,%eax
  801dab:	3c 55                	cmp    $0x55,%al
  801dad:	0f 87 1a 03 00 00    	ja     8020cd <vprintfmt+0x38a>
  801db3:	0f b6 c0             	movzbl %al,%eax
  801db6:	ff 24 85 80 44 80 00 	jmp    *0x804480(,%eax,4)
  801dbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801dc0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801dc4:	eb d6                	jmp    801d9c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801dd1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801dd4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801dd8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801ddb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801dde:	83 fa 09             	cmp    $0x9,%edx
  801de1:	77 39                	ja     801e1c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801de3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801de6:	eb e9                	jmp    801dd1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801de8:	8b 45 14             	mov    0x14(%ebp),%eax
  801deb:	8d 48 04             	lea    0x4(%eax),%ecx
  801dee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801df1:	8b 00                	mov    (%eax),%eax
  801df3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801df9:	eb 27                	jmp    801e22 <vprintfmt+0xdf>
  801dfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e05:	0f 49 c8             	cmovns %eax,%ecx
  801e08:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e0e:	eb 8c                	jmp    801d9c <vprintfmt+0x59>
  801e10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801e13:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801e1a:	eb 80                	jmp    801d9c <vprintfmt+0x59>
  801e1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e1f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801e22:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e26:	0f 89 70 ff ff ff    	jns    801d9c <vprintfmt+0x59>
				width = precision, precision = -1;
  801e2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e32:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801e39:	e9 5e ff ff ff       	jmp    801d9c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801e3e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801e44:	e9 53 ff ff ff       	jmp    801d9c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801e49:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4c:	8d 50 04             	lea    0x4(%eax),%edx
  801e4f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	53                   	push   %ebx
  801e56:	ff 30                	pushl  (%eax)
  801e58:	ff d6                	call   *%esi
			break;
  801e5a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e60:	e9 04 ff ff ff       	jmp    801d69 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e65:	8b 45 14             	mov    0x14(%ebp),%eax
  801e68:	8d 50 04             	lea    0x4(%eax),%edx
  801e6b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e6e:	8b 00                	mov    (%eax),%eax
  801e70:	99                   	cltd   
  801e71:	31 d0                	xor    %edx,%eax
  801e73:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e75:	83 f8 0f             	cmp    $0xf,%eax
  801e78:	7f 0b                	jg     801e85 <vprintfmt+0x142>
  801e7a:	8b 14 85 e0 45 80 00 	mov    0x8045e0(,%eax,4),%edx
  801e81:	85 d2                	test   %edx,%edx
  801e83:	75 18                	jne    801e9d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801e85:	50                   	push   %eax
  801e86:	68 4f 43 80 00       	push   $0x80434f
  801e8b:	53                   	push   %ebx
  801e8c:	56                   	push   %esi
  801e8d:	e8 94 fe ff ff       	call   801d26 <printfmt>
  801e92:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e98:	e9 cc fe ff ff       	jmp    801d69 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e9d:	52                   	push   %edx
  801e9e:	68 af 3d 80 00       	push   $0x803daf
  801ea3:	53                   	push   %ebx
  801ea4:	56                   	push   %esi
  801ea5:	e8 7c fe ff ff       	call   801d26 <printfmt>
  801eaa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ead:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801eb0:	e9 b4 fe ff ff       	jmp    801d69 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801eb5:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb8:	8d 50 04             	lea    0x4(%eax),%edx
  801ebb:	89 55 14             	mov    %edx,0x14(%ebp)
  801ebe:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801ec0:	85 ff                	test   %edi,%edi
  801ec2:	b8 48 43 80 00       	mov    $0x804348,%eax
  801ec7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801eca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ece:	0f 8e 94 00 00 00    	jle    801f68 <vprintfmt+0x225>
  801ed4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801ed8:	0f 84 98 00 00 00    	je     801f76 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	ff 75 d0             	pushl  -0x30(%ebp)
  801ee4:	57                   	push   %edi
  801ee5:	e8 86 02 00 00       	call   802170 <strnlen>
  801eea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801eed:	29 c1                	sub    %eax,%ecx
  801eef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801ef2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801ef5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801efc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801eff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f01:	eb 0f                	jmp    801f12 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801f03:	83 ec 08             	sub    $0x8,%esp
  801f06:	53                   	push   %ebx
  801f07:	ff 75 e0             	pushl  -0x20(%ebp)
  801f0a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f0c:	83 ef 01             	sub    $0x1,%edi
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 ff                	test   %edi,%edi
  801f14:	7f ed                	jg     801f03 <vprintfmt+0x1c0>
  801f16:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801f19:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801f1c:	85 c9                	test   %ecx,%ecx
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f23:	0f 49 c1             	cmovns %ecx,%eax
  801f26:	29 c1                	sub    %eax,%ecx
  801f28:	89 75 08             	mov    %esi,0x8(%ebp)
  801f2b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f2e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f31:	89 cb                	mov    %ecx,%ebx
  801f33:	eb 4d                	jmp    801f82 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801f35:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801f39:	74 1b                	je     801f56 <vprintfmt+0x213>
  801f3b:	0f be c0             	movsbl %al,%eax
  801f3e:	83 e8 20             	sub    $0x20,%eax
  801f41:	83 f8 5e             	cmp    $0x5e,%eax
  801f44:	76 10                	jbe    801f56 <vprintfmt+0x213>
					putch('?', putdat);
  801f46:	83 ec 08             	sub    $0x8,%esp
  801f49:	ff 75 0c             	pushl  0xc(%ebp)
  801f4c:	6a 3f                	push   $0x3f
  801f4e:	ff 55 08             	call   *0x8(%ebp)
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	eb 0d                	jmp    801f63 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801f56:	83 ec 08             	sub    $0x8,%esp
  801f59:	ff 75 0c             	pushl  0xc(%ebp)
  801f5c:	52                   	push   %edx
  801f5d:	ff 55 08             	call   *0x8(%ebp)
  801f60:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f63:	83 eb 01             	sub    $0x1,%ebx
  801f66:	eb 1a                	jmp    801f82 <vprintfmt+0x23f>
  801f68:	89 75 08             	mov    %esi,0x8(%ebp)
  801f6b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f6e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f71:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f74:	eb 0c                	jmp    801f82 <vprintfmt+0x23f>
  801f76:	89 75 08             	mov    %esi,0x8(%ebp)
  801f79:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f7c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f7f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f82:	83 c7 01             	add    $0x1,%edi
  801f85:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f89:	0f be d0             	movsbl %al,%edx
  801f8c:	85 d2                	test   %edx,%edx
  801f8e:	74 23                	je     801fb3 <vprintfmt+0x270>
  801f90:	85 f6                	test   %esi,%esi
  801f92:	78 a1                	js     801f35 <vprintfmt+0x1f2>
  801f94:	83 ee 01             	sub    $0x1,%esi
  801f97:	79 9c                	jns    801f35 <vprintfmt+0x1f2>
  801f99:	89 df                	mov    %ebx,%edi
  801f9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fa1:	eb 18                	jmp    801fbb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801fa3:	83 ec 08             	sub    $0x8,%esp
  801fa6:	53                   	push   %ebx
  801fa7:	6a 20                	push   $0x20
  801fa9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801fab:	83 ef 01             	sub    $0x1,%edi
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	eb 08                	jmp    801fbb <vprintfmt+0x278>
  801fb3:	89 df                	mov    %ebx,%edi
  801fb5:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	7f e4                	jg     801fa3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801fc2:	e9 a2 fd ff ff       	jmp    801d69 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801fc7:	83 fa 01             	cmp    $0x1,%edx
  801fca:	7e 16                	jle    801fe2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801fcc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fcf:	8d 50 08             	lea    0x8(%eax),%edx
  801fd2:	89 55 14             	mov    %edx,0x14(%ebp)
  801fd5:	8b 50 04             	mov    0x4(%eax),%edx
  801fd8:	8b 00                	mov    (%eax),%eax
  801fda:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fdd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801fe0:	eb 32                	jmp    802014 <vprintfmt+0x2d1>
	else if (lflag)
  801fe2:	85 d2                	test   %edx,%edx
  801fe4:	74 18                	je     801ffe <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801fe6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe9:	8d 50 04             	lea    0x4(%eax),%edx
  801fec:	89 55 14             	mov    %edx,0x14(%ebp)
  801fef:	8b 00                	mov    (%eax),%eax
  801ff1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ff4:	89 c1                	mov    %eax,%ecx
  801ff6:	c1 f9 1f             	sar    $0x1f,%ecx
  801ff9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ffc:	eb 16                	jmp    802014 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801ffe:	8b 45 14             	mov    0x14(%ebp),%eax
  802001:	8d 50 04             	lea    0x4(%eax),%edx
  802004:	89 55 14             	mov    %edx,0x14(%ebp)
  802007:	8b 00                	mov    (%eax),%eax
  802009:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80200c:	89 c1                	mov    %eax,%ecx
  80200e:	c1 f9 1f             	sar    $0x1f,%ecx
  802011:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  802014:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802017:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80201a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80201f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802023:	79 74                	jns    802099 <vprintfmt+0x356>
				putch('-', putdat);
  802025:	83 ec 08             	sub    $0x8,%esp
  802028:	53                   	push   %ebx
  802029:	6a 2d                	push   $0x2d
  80202b:	ff d6                	call   *%esi
				num = -(long long) num;
  80202d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802030:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802033:	f7 d8                	neg    %eax
  802035:	83 d2 00             	adc    $0x0,%edx
  802038:	f7 da                	neg    %edx
  80203a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80203d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  802042:	eb 55                	jmp    802099 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802044:	8d 45 14             	lea    0x14(%ebp),%eax
  802047:	e8 83 fc ff ff       	call   801ccf <getuint>
			base = 10;
  80204c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  802051:	eb 46                	jmp    802099 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  802053:	8d 45 14             	lea    0x14(%ebp),%eax
  802056:	e8 74 fc ff ff       	call   801ccf <getuint>
			base = 8;
  80205b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  802060:	eb 37                	jmp    802099 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  802062:	83 ec 08             	sub    $0x8,%esp
  802065:	53                   	push   %ebx
  802066:	6a 30                	push   $0x30
  802068:	ff d6                	call   *%esi
			putch('x', putdat);
  80206a:	83 c4 08             	add    $0x8,%esp
  80206d:	53                   	push   %ebx
  80206e:	6a 78                	push   $0x78
  802070:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802072:	8b 45 14             	mov    0x14(%ebp),%eax
  802075:	8d 50 04             	lea    0x4(%eax),%edx
  802078:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80207b:	8b 00                	mov    (%eax),%eax
  80207d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802082:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802085:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80208a:	eb 0d                	jmp    802099 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80208c:	8d 45 14             	lea    0x14(%ebp),%eax
  80208f:	e8 3b fc ff ff       	call   801ccf <getuint>
			base = 16;
  802094:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802099:	83 ec 0c             	sub    $0xc,%esp
  80209c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8020a0:	57                   	push   %edi
  8020a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8020a4:	51                   	push   %ecx
  8020a5:	52                   	push   %edx
  8020a6:	50                   	push   %eax
  8020a7:	89 da                	mov    %ebx,%edx
  8020a9:	89 f0                	mov    %esi,%eax
  8020ab:	e8 70 fb ff ff       	call   801c20 <printnum>
			break;
  8020b0:	83 c4 20             	add    $0x20,%esp
  8020b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8020b6:	e9 ae fc ff ff       	jmp    801d69 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020bb:	83 ec 08             	sub    $0x8,%esp
  8020be:	53                   	push   %ebx
  8020bf:	51                   	push   %ecx
  8020c0:	ff d6                	call   *%esi
			break;
  8020c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020c8:	e9 9c fc ff ff       	jmp    801d69 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020cd:	83 ec 08             	sub    $0x8,%esp
  8020d0:	53                   	push   %ebx
  8020d1:	6a 25                	push   $0x25
  8020d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	eb 03                	jmp    8020dd <vprintfmt+0x39a>
  8020da:	83 ef 01             	sub    $0x1,%edi
  8020dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8020e1:	75 f7                	jne    8020da <vprintfmt+0x397>
  8020e3:	e9 81 fc ff ff       	jmp    801d69 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8020e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020eb:	5b                   	pop    %ebx
  8020ec:	5e                   	pop    %esi
  8020ed:	5f                   	pop    %edi
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    

008020f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	83 ec 18             	sub    $0x18,%esp
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802103:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802106:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80210d:	85 c0                	test   %eax,%eax
  80210f:	74 26                	je     802137 <vsnprintf+0x47>
  802111:	85 d2                	test   %edx,%edx
  802113:	7e 22                	jle    802137 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802115:	ff 75 14             	pushl  0x14(%ebp)
  802118:	ff 75 10             	pushl  0x10(%ebp)
  80211b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80211e:	50                   	push   %eax
  80211f:	68 09 1d 80 00       	push   $0x801d09
  802124:	e8 1a fc ff ff       	call   801d43 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802129:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80212c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	eb 05                	jmp    80213c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802144:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802147:	50                   	push   %eax
  802148:	ff 75 10             	pushl  0x10(%ebp)
  80214b:	ff 75 0c             	pushl  0xc(%ebp)
  80214e:	ff 75 08             	pushl  0x8(%ebp)
  802151:	e8 9a ff ff ff       	call   8020f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80215e:	b8 00 00 00 00       	mov    $0x0,%eax
  802163:	eb 03                	jmp    802168 <strlen+0x10>
		n++;
  802165:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802168:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80216c:	75 f7                	jne    802165 <strlen+0xd>
		n++;
	return n;
}
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    

00802170 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802176:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802179:	ba 00 00 00 00       	mov    $0x0,%edx
  80217e:	eb 03                	jmp    802183 <strnlen+0x13>
		n++;
  802180:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802183:	39 c2                	cmp    %eax,%edx
  802185:	74 08                	je     80218f <strnlen+0x1f>
  802187:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80218b:	75 f3                	jne    802180 <strnlen+0x10>
  80218d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80218f:	5d                   	pop    %ebp
  802190:	c3                   	ret    

00802191 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802191:	55                   	push   %ebp
  802192:	89 e5                	mov    %esp,%ebp
  802194:	53                   	push   %ebx
  802195:	8b 45 08             	mov    0x8(%ebp),%eax
  802198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80219b:	89 c2                	mov    %eax,%edx
  80219d:	83 c2 01             	add    $0x1,%edx
  8021a0:	83 c1 01             	add    $0x1,%ecx
  8021a3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8021a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8021aa:	84 db                	test   %bl,%bl
  8021ac:	75 ef                	jne    80219d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8021ae:	5b                   	pop    %ebx
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	53                   	push   %ebx
  8021b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021b8:	53                   	push   %ebx
  8021b9:	e8 9a ff ff ff       	call   802158 <strlen>
  8021be:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8021c1:	ff 75 0c             	pushl  0xc(%ebp)
  8021c4:	01 d8                	add    %ebx,%eax
  8021c6:	50                   	push   %eax
  8021c7:	e8 c5 ff ff ff       	call   802191 <strcpy>
	return dst;
}
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    

008021d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021de:	89 f3                	mov    %esi,%ebx
  8021e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	eb 0f                	jmp    8021f6 <strncpy+0x23>
		*dst++ = *src;
  8021e7:	83 c2 01             	add    $0x1,%edx
  8021ea:	0f b6 01             	movzbl (%ecx),%eax
  8021ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8021f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8021f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021f6:	39 da                	cmp    %ebx,%edx
  8021f8:	75 ed                	jne    8021e7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8021fa:	89 f0                	mov    %esi,%eax
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	56                   	push   %esi
  802204:	53                   	push   %ebx
  802205:	8b 75 08             	mov    0x8(%ebp),%esi
  802208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80220b:	8b 55 10             	mov    0x10(%ebp),%edx
  80220e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802210:	85 d2                	test   %edx,%edx
  802212:	74 21                	je     802235 <strlcpy+0x35>
  802214:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802218:	89 f2                	mov    %esi,%edx
  80221a:	eb 09                	jmp    802225 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80221c:	83 c2 01             	add    $0x1,%edx
  80221f:	83 c1 01             	add    $0x1,%ecx
  802222:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802225:	39 c2                	cmp    %eax,%edx
  802227:	74 09                	je     802232 <strlcpy+0x32>
  802229:	0f b6 19             	movzbl (%ecx),%ebx
  80222c:	84 db                	test   %bl,%bl
  80222e:	75 ec                	jne    80221c <strlcpy+0x1c>
  802230:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802232:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802235:	29 f0                	sub    %esi,%eax
}
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    

0080223b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802241:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802244:	eb 06                	jmp    80224c <strcmp+0x11>
		p++, q++;
  802246:	83 c1 01             	add    $0x1,%ecx
  802249:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80224c:	0f b6 01             	movzbl (%ecx),%eax
  80224f:	84 c0                	test   %al,%al
  802251:	74 04                	je     802257 <strcmp+0x1c>
  802253:	3a 02                	cmp    (%edx),%al
  802255:	74 ef                	je     802246 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802257:	0f b6 c0             	movzbl %al,%eax
  80225a:	0f b6 12             	movzbl (%edx),%edx
  80225d:	29 d0                	sub    %edx,%eax
}
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	53                   	push   %ebx
  802265:	8b 45 08             	mov    0x8(%ebp),%eax
  802268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226b:	89 c3                	mov    %eax,%ebx
  80226d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802270:	eb 06                	jmp    802278 <strncmp+0x17>
		n--, p++, q++;
  802272:	83 c0 01             	add    $0x1,%eax
  802275:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802278:	39 d8                	cmp    %ebx,%eax
  80227a:	74 15                	je     802291 <strncmp+0x30>
  80227c:	0f b6 08             	movzbl (%eax),%ecx
  80227f:	84 c9                	test   %cl,%cl
  802281:	74 04                	je     802287 <strncmp+0x26>
  802283:	3a 0a                	cmp    (%edx),%cl
  802285:	74 eb                	je     802272 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802287:	0f b6 00             	movzbl (%eax),%eax
  80228a:	0f b6 12             	movzbl (%edx),%edx
  80228d:	29 d0                	sub    %edx,%eax
  80228f:	eb 05                	jmp    802296 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802291:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802296:	5b                   	pop    %ebx
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    

00802299 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802299:	55                   	push   %ebp
  80229a:	89 e5                	mov    %esp,%ebp
  80229c:	8b 45 08             	mov    0x8(%ebp),%eax
  80229f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022a3:	eb 07                	jmp    8022ac <strchr+0x13>
		if (*s == c)
  8022a5:	38 ca                	cmp    %cl,%dl
  8022a7:	74 0f                	je     8022b8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8022a9:	83 c0 01             	add    $0x1,%eax
  8022ac:	0f b6 10             	movzbl (%eax),%edx
  8022af:	84 d2                	test   %dl,%dl
  8022b1:	75 f2                	jne    8022a5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b8:	5d                   	pop    %ebp
  8022b9:	c3                   	ret    

008022ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022ba:	55                   	push   %ebp
  8022bb:	89 e5                	mov    %esp,%ebp
  8022bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022c4:	eb 03                	jmp    8022c9 <strfind+0xf>
  8022c6:	83 c0 01             	add    $0x1,%eax
  8022c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022cc:	38 ca                	cmp    %cl,%dl
  8022ce:	74 04                	je     8022d4 <strfind+0x1a>
  8022d0:	84 d2                	test   %dl,%dl
  8022d2:	75 f2                	jne    8022c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	57                   	push   %edi
  8022da:	56                   	push   %esi
  8022db:	53                   	push   %ebx
  8022dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8022e2:	85 c9                	test   %ecx,%ecx
  8022e4:	74 36                	je     80231c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8022e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022ec:	75 28                	jne    802316 <memset+0x40>
  8022ee:	f6 c1 03             	test   $0x3,%cl
  8022f1:	75 23                	jne    802316 <memset+0x40>
		c &= 0xFF;
  8022f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8022f7:	89 d3                	mov    %edx,%ebx
  8022f9:	c1 e3 08             	shl    $0x8,%ebx
  8022fc:	89 d6                	mov    %edx,%esi
  8022fe:	c1 e6 18             	shl    $0x18,%esi
  802301:	89 d0                	mov    %edx,%eax
  802303:	c1 e0 10             	shl    $0x10,%eax
  802306:	09 f0                	or     %esi,%eax
  802308:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80230a:	89 d8                	mov    %ebx,%eax
  80230c:	09 d0                	or     %edx,%eax
  80230e:	c1 e9 02             	shr    $0x2,%ecx
  802311:	fc                   	cld    
  802312:	f3 ab                	rep stos %eax,%es:(%edi)
  802314:	eb 06                	jmp    80231c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802316:	8b 45 0c             	mov    0xc(%ebp),%eax
  802319:	fc                   	cld    
  80231a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80231c:	89 f8                	mov    %edi,%eax
  80231e:	5b                   	pop    %ebx
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    

00802323 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802323:	55                   	push   %ebp
  802324:	89 e5                	mov    %esp,%ebp
  802326:	57                   	push   %edi
  802327:	56                   	push   %esi
  802328:	8b 45 08             	mov    0x8(%ebp),%eax
  80232b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80232e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802331:	39 c6                	cmp    %eax,%esi
  802333:	73 35                	jae    80236a <memmove+0x47>
  802335:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802338:	39 d0                	cmp    %edx,%eax
  80233a:	73 2e                	jae    80236a <memmove+0x47>
		s += n;
		d += n;
  80233c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80233f:	89 d6                	mov    %edx,%esi
  802341:	09 fe                	or     %edi,%esi
  802343:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802349:	75 13                	jne    80235e <memmove+0x3b>
  80234b:	f6 c1 03             	test   $0x3,%cl
  80234e:	75 0e                	jne    80235e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802350:	83 ef 04             	sub    $0x4,%edi
  802353:	8d 72 fc             	lea    -0x4(%edx),%esi
  802356:	c1 e9 02             	shr    $0x2,%ecx
  802359:	fd                   	std    
  80235a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80235c:	eb 09                	jmp    802367 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80235e:	83 ef 01             	sub    $0x1,%edi
  802361:	8d 72 ff             	lea    -0x1(%edx),%esi
  802364:	fd                   	std    
  802365:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802367:	fc                   	cld    
  802368:	eb 1d                	jmp    802387 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80236a:	89 f2                	mov    %esi,%edx
  80236c:	09 c2                	or     %eax,%edx
  80236e:	f6 c2 03             	test   $0x3,%dl
  802371:	75 0f                	jne    802382 <memmove+0x5f>
  802373:	f6 c1 03             	test   $0x3,%cl
  802376:	75 0a                	jne    802382 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802378:	c1 e9 02             	shr    $0x2,%ecx
  80237b:	89 c7                	mov    %eax,%edi
  80237d:	fc                   	cld    
  80237e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802380:	eb 05                	jmp    802387 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802382:	89 c7                	mov    %eax,%edi
  802384:	fc                   	cld    
  802385:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802387:	5e                   	pop    %esi
  802388:	5f                   	pop    %edi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    

0080238b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80238e:	ff 75 10             	pushl  0x10(%ebp)
  802391:	ff 75 0c             	pushl  0xc(%ebp)
  802394:	ff 75 08             	pushl  0x8(%ebp)
  802397:	e8 87 ff ff ff       	call   802323 <memmove>
}
  80239c:	c9                   	leave  
  80239d:	c3                   	ret    

0080239e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	56                   	push   %esi
  8023a2:	53                   	push   %ebx
  8023a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023a9:	89 c6                	mov    %eax,%esi
  8023ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023ae:	eb 1a                	jmp    8023ca <memcmp+0x2c>
		if (*s1 != *s2)
  8023b0:	0f b6 08             	movzbl (%eax),%ecx
  8023b3:	0f b6 1a             	movzbl (%edx),%ebx
  8023b6:	38 d9                	cmp    %bl,%cl
  8023b8:	74 0a                	je     8023c4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8023ba:	0f b6 c1             	movzbl %cl,%eax
  8023bd:	0f b6 db             	movzbl %bl,%ebx
  8023c0:	29 d8                	sub    %ebx,%eax
  8023c2:	eb 0f                	jmp    8023d3 <memcmp+0x35>
		s1++, s2++;
  8023c4:	83 c0 01             	add    $0x1,%eax
  8023c7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023ca:	39 f0                	cmp    %esi,%eax
  8023cc:	75 e2                	jne    8023b0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8023ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    

008023d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	53                   	push   %ebx
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8023de:	89 c1                	mov    %eax,%ecx
  8023e0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8023e3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023e7:	eb 0a                	jmp    8023f3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8023e9:	0f b6 10             	movzbl (%eax),%edx
  8023ec:	39 da                	cmp    %ebx,%edx
  8023ee:	74 07                	je     8023f7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023f0:	83 c0 01             	add    $0x1,%eax
  8023f3:	39 c8                	cmp    %ecx,%eax
  8023f5:	72 f2                	jb     8023e9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8023f7:	5b                   	pop    %ebx
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    

008023fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	57                   	push   %edi
  8023fe:	56                   	push   %esi
  8023ff:	53                   	push   %ebx
  802400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802403:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802406:	eb 03                	jmp    80240b <strtol+0x11>
		s++;
  802408:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80240b:	0f b6 01             	movzbl (%ecx),%eax
  80240e:	3c 20                	cmp    $0x20,%al
  802410:	74 f6                	je     802408 <strtol+0xe>
  802412:	3c 09                	cmp    $0x9,%al
  802414:	74 f2                	je     802408 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802416:	3c 2b                	cmp    $0x2b,%al
  802418:	75 0a                	jne    802424 <strtol+0x2a>
		s++;
  80241a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80241d:	bf 00 00 00 00       	mov    $0x0,%edi
  802422:	eb 11                	jmp    802435 <strtol+0x3b>
  802424:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802429:	3c 2d                	cmp    $0x2d,%al
  80242b:	75 08                	jne    802435 <strtol+0x3b>
		s++, neg = 1;
  80242d:	83 c1 01             	add    $0x1,%ecx
  802430:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802435:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80243b:	75 15                	jne    802452 <strtol+0x58>
  80243d:	80 39 30             	cmpb   $0x30,(%ecx)
  802440:	75 10                	jne    802452 <strtol+0x58>
  802442:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802446:	75 7c                	jne    8024c4 <strtol+0xca>
		s += 2, base = 16;
  802448:	83 c1 02             	add    $0x2,%ecx
  80244b:	bb 10 00 00 00       	mov    $0x10,%ebx
  802450:	eb 16                	jmp    802468 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  802452:	85 db                	test   %ebx,%ebx
  802454:	75 12                	jne    802468 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802456:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80245b:	80 39 30             	cmpb   $0x30,(%ecx)
  80245e:	75 08                	jne    802468 <strtol+0x6e>
		s++, base = 8;
  802460:	83 c1 01             	add    $0x1,%ecx
  802463:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802468:	b8 00 00 00 00       	mov    $0x0,%eax
  80246d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802470:	0f b6 11             	movzbl (%ecx),%edx
  802473:	8d 72 d0             	lea    -0x30(%edx),%esi
  802476:	89 f3                	mov    %esi,%ebx
  802478:	80 fb 09             	cmp    $0x9,%bl
  80247b:	77 08                	ja     802485 <strtol+0x8b>
			dig = *s - '0';
  80247d:	0f be d2             	movsbl %dl,%edx
  802480:	83 ea 30             	sub    $0x30,%edx
  802483:	eb 22                	jmp    8024a7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802485:	8d 72 9f             	lea    -0x61(%edx),%esi
  802488:	89 f3                	mov    %esi,%ebx
  80248a:	80 fb 19             	cmp    $0x19,%bl
  80248d:	77 08                	ja     802497 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80248f:	0f be d2             	movsbl %dl,%edx
  802492:	83 ea 57             	sub    $0x57,%edx
  802495:	eb 10                	jmp    8024a7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802497:	8d 72 bf             	lea    -0x41(%edx),%esi
  80249a:	89 f3                	mov    %esi,%ebx
  80249c:	80 fb 19             	cmp    $0x19,%bl
  80249f:	77 16                	ja     8024b7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8024a1:	0f be d2             	movsbl %dl,%edx
  8024a4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8024a7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8024aa:	7d 0b                	jge    8024b7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8024ac:	83 c1 01             	add    $0x1,%ecx
  8024af:	0f af 45 10          	imul   0x10(%ebp),%eax
  8024b3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8024b5:	eb b9                	jmp    802470 <strtol+0x76>

	if (endptr)
  8024b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024bb:	74 0d                	je     8024ca <strtol+0xd0>
		*endptr = (char *) s;
  8024bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c0:	89 0e                	mov    %ecx,(%esi)
  8024c2:	eb 06                	jmp    8024ca <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024c4:	85 db                	test   %ebx,%ebx
  8024c6:	74 98                	je     802460 <strtol+0x66>
  8024c8:	eb 9e                	jmp    802468 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8024ca:	89 c2                	mov    %eax,%edx
  8024cc:	f7 da                	neg    %edx
  8024ce:	85 ff                	test   %edi,%edi
  8024d0:	0f 45 c2             	cmovne %edx,%eax
}
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    

008024d8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024d8:	55                   	push   %ebp
  8024d9:	89 e5                	mov    %esp,%ebp
  8024db:	57                   	push   %edi
  8024dc:	56                   	push   %esi
  8024dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024de:	b8 00 00 00 00       	mov    $0x0,%eax
  8024e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8024e9:	89 c3                	mov    %eax,%ebx
  8024eb:	89 c7                	mov    %eax,%edi
  8024ed:	89 c6                	mov    %eax,%esi
  8024ef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024f1:	5b                   	pop    %ebx
  8024f2:	5e                   	pop    %esi
  8024f3:	5f                   	pop    %edi
  8024f4:	5d                   	pop    %ebp
  8024f5:	c3                   	ret    

008024f6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	57                   	push   %edi
  8024fa:	56                   	push   %esi
  8024fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024fc:	ba 00 00 00 00       	mov    $0x0,%edx
  802501:	b8 01 00 00 00       	mov    $0x1,%eax
  802506:	89 d1                	mov    %edx,%ecx
  802508:	89 d3                	mov    %edx,%ebx
  80250a:	89 d7                	mov    %edx,%edi
  80250c:	89 d6                	mov    %edx,%esi
  80250e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	57                   	push   %edi
  802519:	56                   	push   %esi
  80251a:	53                   	push   %ebx
  80251b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80251e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802523:	b8 03 00 00 00       	mov    $0x3,%eax
  802528:	8b 55 08             	mov    0x8(%ebp),%edx
  80252b:	89 cb                	mov    %ecx,%ebx
  80252d:	89 cf                	mov    %ecx,%edi
  80252f:	89 ce                	mov    %ecx,%esi
  802531:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802533:	85 c0                	test   %eax,%eax
  802535:	7e 17                	jle    80254e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802537:	83 ec 0c             	sub    $0xc,%esp
  80253a:	50                   	push   %eax
  80253b:	6a 03                	push   $0x3
  80253d:	68 3f 46 80 00       	push   $0x80463f
  802542:	6a 23                	push   $0x23
  802544:	68 5c 46 80 00       	push   $0x80465c
  802549:	e8 e5 f5 ff ff       	call   801b33 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80254e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    

00802556 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	57                   	push   %edi
  80255a:	56                   	push   %esi
  80255b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80255c:	ba 00 00 00 00       	mov    $0x0,%edx
  802561:	b8 02 00 00 00       	mov    $0x2,%eax
  802566:	89 d1                	mov    %edx,%ecx
  802568:	89 d3                	mov    %edx,%ebx
  80256a:	89 d7                	mov    %edx,%edi
  80256c:	89 d6                	mov    %edx,%esi
  80256e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <sys_yield>:

void
sys_yield(void)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	57                   	push   %edi
  802579:	56                   	push   %esi
  80257a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80257b:	ba 00 00 00 00       	mov    $0x0,%edx
  802580:	b8 0b 00 00 00       	mov    $0xb,%eax
  802585:	89 d1                	mov    %edx,%ecx
  802587:	89 d3                	mov    %edx,%ebx
  802589:	89 d7                	mov    %edx,%edi
  80258b:	89 d6                	mov    %edx,%esi
  80258d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    

00802594 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802594:	55                   	push   %ebp
  802595:	89 e5                	mov    %esp,%ebp
  802597:	57                   	push   %edi
  802598:	56                   	push   %esi
  802599:	53                   	push   %ebx
  80259a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80259d:	be 00 00 00 00       	mov    $0x0,%esi
  8025a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8025a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b0:	89 f7                	mov    %esi,%edi
  8025b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	7e 17                	jle    8025cf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025b8:	83 ec 0c             	sub    $0xc,%esp
  8025bb:	50                   	push   %eax
  8025bc:	6a 04                	push   $0x4
  8025be:	68 3f 46 80 00       	push   $0x80463f
  8025c3:	6a 23                	push   $0x23
  8025c5:	68 5c 46 80 00       	push   $0x80465c
  8025ca:	e8 64 f5 ff ff       	call   801b33 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d2:	5b                   	pop    %ebx
  8025d3:	5e                   	pop    %esi
  8025d4:	5f                   	pop    %edi
  8025d5:	5d                   	pop    %ebp
  8025d6:	c3                   	ret    

008025d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025d7:	55                   	push   %ebp
  8025d8:	89 e5                	mov    %esp,%ebp
  8025da:	57                   	push   %edi
  8025db:	56                   	push   %esi
  8025dc:	53                   	push   %ebx
  8025dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8025e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8025eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025f1:	8b 75 18             	mov    0x18(%ebp),%esi
  8025f4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025f6:	85 c0                	test   %eax,%eax
  8025f8:	7e 17                	jle    802611 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025fa:	83 ec 0c             	sub    $0xc,%esp
  8025fd:	50                   	push   %eax
  8025fe:	6a 05                	push   $0x5
  802600:	68 3f 46 80 00       	push   $0x80463f
  802605:	6a 23                	push   $0x23
  802607:	68 5c 46 80 00       	push   $0x80465c
  80260c:	e8 22 f5 ff ff       	call   801b33 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802611:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    

00802619 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802619:	55                   	push   %ebp
  80261a:	89 e5                	mov    %esp,%ebp
  80261c:	57                   	push   %edi
  80261d:	56                   	push   %esi
  80261e:	53                   	push   %ebx
  80261f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802622:	bb 00 00 00 00       	mov    $0x0,%ebx
  802627:	b8 06 00 00 00       	mov    $0x6,%eax
  80262c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80262f:	8b 55 08             	mov    0x8(%ebp),%edx
  802632:	89 df                	mov    %ebx,%edi
  802634:	89 de                	mov    %ebx,%esi
  802636:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802638:	85 c0                	test   %eax,%eax
  80263a:	7e 17                	jle    802653 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80263c:	83 ec 0c             	sub    $0xc,%esp
  80263f:	50                   	push   %eax
  802640:	6a 06                	push   $0x6
  802642:	68 3f 46 80 00       	push   $0x80463f
  802647:	6a 23                	push   $0x23
  802649:	68 5c 46 80 00       	push   $0x80465c
  80264e:	e8 e0 f4 ff ff       	call   801b33 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802656:	5b                   	pop    %ebx
  802657:	5e                   	pop    %esi
  802658:	5f                   	pop    %edi
  802659:	5d                   	pop    %ebp
  80265a:	c3                   	ret    

0080265b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80265b:	55                   	push   %ebp
  80265c:	89 e5                	mov    %esp,%ebp
  80265e:	57                   	push   %edi
  80265f:	56                   	push   %esi
  802660:	53                   	push   %ebx
  802661:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802664:	bb 00 00 00 00       	mov    $0x0,%ebx
  802669:	b8 08 00 00 00       	mov    $0x8,%eax
  80266e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802671:	8b 55 08             	mov    0x8(%ebp),%edx
  802674:	89 df                	mov    %ebx,%edi
  802676:	89 de                	mov    %ebx,%esi
  802678:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80267a:	85 c0                	test   %eax,%eax
  80267c:	7e 17                	jle    802695 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80267e:	83 ec 0c             	sub    $0xc,%esp
  802681:	50                   	push   %eax
  802682:	6a 08                	push   $0x8
  802684:	68 3f 46 80 00       	push   $0x80463f
  802689:	6a 23                	push   $0x23
  80268b:	68 5c 46 80 00       	push   $0x80465c
  802690:	e8 9e f4 ff ff       	call   801b33 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802695:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    

0080269d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80269d:	55                   	push   %ebp
  80269e:	89 e5                	mov    %esp,%ebp
  8026a0:	57                   	push   %edi
  8026a1:	56                   	push   %esi
  8026a2:	53                   	push   %ebx
  8026a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026ab:	b8 09 00 00 00       	mov    $0x9,%eax
  8026b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8026b6:	89 df                	mov    %ebx,%edi
  8026b8:	89 de                	mov    %ebx,%esi
  8026ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026bc:	85 c0                	test   %eax,%eax
  8026be:	7e 17                	jle    8026d7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026c0:	83 ec 0c             	sub    $0xc,%esp
  8026c3:	50                   	push   %eax
  8026c4:	6a 09                	push   $0x9
  8026c6:	68 3f 46 80 00       	push   $0x80463f
  8026cb:	6a 23                	push   $0x23
  8026cd:	68 5c 46 80 00       	push   $0x80465c
  8026d2:	e8 5c f4 ff ff       	call   801b33 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026da:	5b                   	pop    %ebx
  8026db:	5e                   	pop    %esi
  8026dc:	5f                   	pop    %edi
  8026dd:	5d                   	pop    %ebp
  8026de:	c3                   	ret    

008026df <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026df:	55                   	push   %ebp
  8026e0:	89 e5                	mov    %esp,%ebp
  8026e2:	57                   	push   %edi
  8026e3:	56                   	push   %esi
  8026e4:	53                   	push   %ebx
  8026e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8026f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8026f8:	89 df                	mov    %ebx,%edi
  8026fa:	89 de                	mov    %ebx,%esi
  8026fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026fe:	85 c0                	test   %eax,%eax
  802700:	7e 17                	jle    802719 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802702:	83 ec 0c             	sub    $0xc,%esp
  802705:	50                   	push   %eax
  802706:	6a 0a                	push   $0xa
  802708:	68 3f 46 80 00       	push   $0x80463f
  80270d:	6a 23                	push   $0x23
  80270f:	68 5c 46 80 00       	push   $0x80465c
  802714:	e8 1a f4 ff ff       	call   801b33 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802719:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80271c:	5b                   	pop    %ebx
  80271d:	5e                   	pop    %esi
  80271e:	5f                   	pop    %edi
  80271f:	5d                   	pop    %ebp
  802720:	c3                   	ret    

00802721 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802721:	55                   	push   %ebp
  802722:	89 e5                	mov    %esp,%ebp
  802724:	57                   	push   %edi
  802725:	56                   	push   %esi
  802726:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802727:	be 00 00 00 00       	mov    $0x0,%esi
  80272c:	b8 0c 00 00 00       	mov    $0xc,%eax
  802731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802734:	8b 55 08             	mov    0x8(%ebp),%edx
  802737:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80273a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80273d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80273f:	5b                   	pop    %ebx
  802740:	5e                   	pop    %esi
  802741:	5f                   	pop    %edi
  802742:	5d                   	pop    %ebp
  802743:	c3                   	ret    

00802744 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802744:	55                   	push   %ebp
  802745:	89 e5                	mov    %esp,%ebp
  802747:	57                   	push   %edi
  802748:	56                   	push   %esi
  802749:	53                   	push   %ebx
  80274a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80274d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802752:	b8 0d 00 00 00       	mov    $0xd,%eax
  802757:	8b 55 08             	mov    0x8(%ebp),%edx
  80275a:	89 cb                	mov    %ecx,%ebx
  80275c:	89 cf                	mov    %ecx,%edi
  80275e:	89 ce                	mov    %ecx,%esi
  802760:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802762:	85 c0                	test   %eax,%eax
  802764:	7e 17                	jle    80277d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802766:	83 ec 0c             	sub    $0xc,%esp
  802769:	50                   	push   %eax
  80276a:	6a 0d                	push   $0xd
  80276c:	68 3f 46 80 00       	push   $0x80463f
  802771:	6a 23                	push   $0x23
  802773:	68 5c 46 80 00       	push   $0x80465c
  802778:	e8 b6 f3 ff ff       	call   801b33 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80277d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802780:	5b                   	pop    %ebx
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    

00802785 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  802785:	55                   	push   %ebp
  802786:	89 e5                	mov    %esp,%ebp
  802788:	57                   	push   %edi
  802789:	56                   	push   %esi
  80278a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80278b:	ba 00 00 00 00       	mov    $0x0,%edx
  802790:	b8 0e 00 00 00       	mov    $0xe,%eax
  802795:	89 d1                	mov    %edx,%ecx
  802797:	89 d3                	mov    %edx,%ebx
  802799:	89 d7                	mov    %edx,%edi
  80279b:	89 d6                	mov    %edx,%esi
  80279d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80279f:	5b                   	pop    %ebx
  8027a0:	5e                   	pop    %esi
  8027a1:	5f                   	pop    %edi
  8027a2:	5d                   	pop    %ebp
  8027a3:	c3                   	ret    

008027a4 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  8027a4:	55                   	push   %ebp
  8027a5:	89 e5                	mov    %esp,%ebp
  8027a7:	57                   	push   %edi
  8027a8:	56                   	push   %esi
  8027a9:	53                   	push   %ebx
  8027aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027b2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8027b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8027bd:	89 df                	mov    %ebx,%edi
  8027bf:	89 de                	mov    %ebx,%esi
  8027c1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027c3:	85 c0                	test   %eax,%eax
  8027c5:	7e 17                	jle    8027de <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027c7:	83 ec 0c             	sub    $0xc,%esp
  8027ca:	50                   	push   %eax
  8027cb:	6a 0f                	push   $0xf
  8027cd:	68 3f 46 80 00       	push   $0x80463f
  8027d2:	6a 23                	push   $0x23
  8027d4:	68 5c 46 80 00       	push   $0x80465c
  8027d9:	e8 55 f3 ff ff       	call   801b33 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8027de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027e1:	5b                   	pop    %ebx
  8027e2:	5e                   	pop    %esi
  8027e3:	5f                   	pop    %edi
  8027e4:	5d                   	pop    %ebp
  8027e5:	c3                   	ret    

008027e6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027e6:	55                   	push   %ebp
  8027e7:	89 e5                	mov    %esp,%ebp
  8027e9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027ec:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  8027f3:	75 2e                	jne    802823 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8027f5:	e8 5c fd ff ff       	call   802556 <sys_getenvid>
  8027fa:	83 ec 04             	sub    $0x4,%esp
  8027fd:	68 07 0e 00 00       	push   $0xe07
  802802:	68 00 f0 bf ee       	push   $0xeebff000
  802807:	50                   	push   %eax
  802808:	e8 87 fd ff ff       	call   802594 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80280d:	e8 44 fd ff ff       	call   802556 <sys_getenvid>
  802812:	83 c4 08             	add    $0x8,%esp
  802815:	68 2d 28 80 00       	push   $0x80282d
  80281a:	50                   	push   %eax
  80281b:	e8 bf fe ff ff       	call   8026df <sys_env_set_pgfault_upcall>
  802820:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802823:	8b 45 08             	mov    0x8(%ebp),%eax
  802826:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  80282b:	c9                   	leave  
  80282c:	c3                   	ret    

0080282d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80282d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80282e:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802833:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802835:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802838:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80283c:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802840:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802843:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802846:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802847:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80284a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80284b:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80284c:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802850:	c3                   	ret    

00802851 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802851:	55                   	push   %ebp
  802852:	89 e5                	mov    %esp,%ebp
  802854:	56                   	push   %esi
  802855:	53                   	push   %ebx
  802856:	8b 75 08             	mov    0x8(%ebp),%esi
  802859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80285c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80285f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802861:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802866:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802869:	83 ec 0c             	sub    $0xc,%esp
  80286c:	50                   	push   %eax
  80286d:	e8 d2 fe ff ff       	call   802744 <sys_ipc_recv>

	if (from_env_store != NULL)
  802872:	83 c4 10             	add    $0x10,%esp
  802875:	85 f6                	test   %esi,%esi
  802877:	74 14                	je     80288d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802879:	ba 00 00 00 00       	mov    $0x0,%edx
  80287e:	85 c0                	test   %eax,%eax
  802880:	78 09                	js     80288b <ipc_recv+0x3a>
  802882:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  802888:	8b 52 74             	mov    0x74(%edx),%edx
  80288b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80288d:	85 db                	test   %ebx,%ebx
  80288f:	74 14                	je     8028a5 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802891:	ba 00 00 00 00       	mov    $0x0,%edx
  802896:	85 c0                	test   %eax,%eax
  802898:	78 09                	js     8028a3 <ipc_recv+0x52>
  80289a:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  8028a0:	8b 52 78             	mov    0x78(%edx),%edx
  8028a3:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8028a5:	85 c0                	test   %eax,%eax
  8028a7:	78 08                	js     8028b1 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8028a9:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8028ae:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028b4:	5b                   	pop    %ebx
  8028b5:	5e                   	pop    %esi
  8028b6:	5d                   	pop    %ebp
  8028b7:	c3                   	ret    

008028b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028b8:	55                   	push   %ebp
  8028b9:	89 e5                	mov    %esp,%ebp
  8028bb:	57                   	push   %edi
  8028bc:	56                   	push   %esi
  8028bd:	53                   	push   %ebx
  8028be:	83 ec 0c             	sub    $0xc,%esp
  8028c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8028c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8028ca:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8028cc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8028d1:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8028d4:	ff 75 14             	pushl  0x14(%ebp)
  8028d7:	53                   	push   %ebx
  8028d8:	56                   	push   %esi
  8028d9:	57                   	push   %edi
  8028da:	e8 42 fe ff ff       	call   802721 <sys_ipc_try_send>

		if (err < 0) {
  8028df:	83 c4 10             	add    $0x10,%esp
  8028e2:	85 c0                	test   %eax,%eax
  8028e4:	79 1e                	jns    802904 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8028e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028e9:	75 07                	jne    8028f2 <ipc_send+0x3a>
				sys_yield();
  8028eb:	e8 85 fc ff ff       	call   802575 <sys_yield>
  8028f0:	eb e2                	jmp    8028d4 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8028f2:	50                   	push   %eax
  8028f3:	68 6a 46 80 00       	push   $0x80466a
  8028f8:	6a 49                	push   $0x49
  8028fa:	68 77 46 80 00       	push   $0x804677
  8028ff:	e8 2f f2 ff ff       	call   801b33 <_panic>
		}

	} while (err < 0);

}
  802904:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802907:	5b                   	pop    %ebx
  802908:	5e                   	pop    %esi
  802909:	5f                   	pop    %edi
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    

0080290c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80290c:	55                   	push   %ebp
  80290d:	89 e5                	mov    %esp,%ebp
  80290f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802912:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802917:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80291a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802920:	8b 52 50             	mov    0x50(%edx),%edx
  802923:	39 ca                	cmp    %ecx,%edx
  802925:	75 0d                	jne    802934 <ipc_find_env+0x28>
			return envs[i].env_id;
  802927:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80292a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80292f:	8b 40 48             	mov    0x48(%eax),%eax
  802932:	eb 0f                	jmp    802943 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802934:	83 c0 01             	add    $0x1,%eax
  802937:	3d 00 04 00 00       	cmp    $0x400,%eax
  80293c:	75 d9                	jne    802917 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80293e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802943:	5d                   	pop    %ebp
  802944:	c3                   	ret    

00802945 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802945:	55                   	push   %ebp
  802946:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802948:	8b 45 08             	mov    0x8(%ebp),%eax
  80294b:	05 00 00 00 30       	add    $0x30000000,%eax
  802950:	c1 e8 0c             	shr    $0xc,%eax
}
  802953:	5d                   	pop    %ebp
  802954:	c3                   	ret    

00802955 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802955:	55                   	push   %ebp
  802956:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802958:	8b 45 08             	mov    0x8(%ebp),%eax
  80295b:	05 00 00 00 30       	add    $0x30000000,%eax
  802960:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802965:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80296a:	5d                   	pop    %ebp
  80296b:	c3                   	ret    

0080296c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80296c:	55                   	push   %ebp
  80296d:	89 e5                	mov    %esp,%ebp
  80296f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802972:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802977:	89 c2                	mov    %eax,%edx
  802979:	c1 ea 16             	shr    $0x16,%edx
  80297c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802983:	f6 c2 01             	test   $0x1,%dl
  802986:	74 11                	je     802999 <fd_alloc+0x2d>
  802988:	89 c2                	mov    %eax,%edx
  80298a:	c1 ea 0c             	shr    $0xc,%edx
  80298d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802994:	f6 c2 01             	test   $0x1,%dl
  802997:	75 09                	jne    8029a2 <fd_alloc+0x36>
			*fd_store = fd;
  802999:	89 01                	mov    %eax,(%ecx)
			return 0;
  80299b:	b8 00 00 00 00       	mov    $0x0,%eax
  8029a0:	eb 17                	jmp    8029b9 <fd_alloc+0x4d>
  8029a2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8029a7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8029ac:	75 c9                	jne    802977 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8029ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8029b4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8029b9:	5d                   	pop    %ebp
  8029ba:	c3                   	ret    

008029bb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8029bb:	55                   	push   %ebp
  8029bc:	89 e5                	mov    %esp,%ebp
  8029be:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8029c1:	83 f8 1f             	cmp    $0x1f,%eax
  8029c4:	77 36                	ja     8029fc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8029c6:	c1 e0 0c             	shl    $0xc,%eax
  8029c9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8029ce:	89 c2                	mov    %eax,%edx
  8029d0:	c1 ea 16             	shr    $0x16,%edx
  8029d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029da:	f6 c2 01             	test   $0x1,%dl
  8029dd:	74 24                	je     802a03 <fd_lookup+0x48>
  8029df:	89 c2                	mov    %eax,%edx
  8029e1:	c1 ea 0c             	shr    $0xc,%edx
  8029e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029eb:	f6 c2 01             	test   $0x1,%dl
  8029ee:	74 1a                	je     802a0a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8029f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8029f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8029fa:	eb 13                	jmp    802a0f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a01:	eb 0c                	jmp    802a0f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a08:	eb 05                	jmp    802a0f <fd_lookup+0x54>
  802a0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802a0f:	5d                   	pop    %ebp
  802a10:	c3                   	ret    

00802a11 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802a11:	55                   	push   %ebp
  802a12:	89 e5                	mov    %esp,%ebp
  802a14:	83 ec 08             	sub    $0x8,%esp
  802a17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a1a:	ba 04 47 80 00       	mov    $0x804704,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802a1f:	eb 13                	jmp    802a34 <dev_lookup+0x23>
  802a21:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802a24:	39 08                	cmp    %ecx,(%eax)
  802a26:	75 0c                	jne    802a34 <dev_lookup+0x23>
			*dev = devtab[i];
  802a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a2b:	89 01                	mov    %eax,(%ecx)
			return 0;
  802a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  802a32:	eb 2e                	jmp    802a62 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802a34:	8b 02                	mov    (%edx),%eax
  802a36:	85 c0                	test   %eax,%eax
  802a38:	75 e7                	jne    802a21 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802a3a:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802a3f:	8b 40 48             	mov    0x48(%eax),%eax
  802a42:	83 ec 04             	sub    $0x4,%esp
  802a45:	51                   	push   %ecx
  802a46:	50                   	push   %eax
  802a47:	68 84 46 80 00       	push   $0x804684
  802a4c:	e8 bb f1 ff ff       	call   801c0c <cprintf>
	*dev = 0;
  802a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802a5a:	83 c4 10             	add    $0x10,%esp
  802a5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a62:	c9                   	leave  
  802a63:	c3                   	ret    

00802a64 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802a64:	55                   	push   %ebp
  802a65:	89 e5                	mov    %esp,%ebp
  802a67:	56                   	push   %esi
  802a68:	53                   	push   %ebx
  802a69:	83 ec 10             	sub    $0x10,%esp
  802a6c:	8b 75 08             	mov    0x8(%ebp),%esi
  802a6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a75:	50                   	push   %eax
  802a76:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a7c:	c1 e8 0c             	shr    $0xc,%eax
  802a7f:	50                   	push   %eax
  802a80:	e8 36 ff ff ff       	call   8029bb <fd_lookup>
  802a85:	83 c4 08             	add    $0x8,%esp
  802a88:	85 c0                	test   %eax,%eax
  802a8a:	78 05                	js     802a91 <fd_close+0x2d>
	    || fd != fd2)
  802a8c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a8f:	74 0c                	je     802a9d <fd_close+0x39>
		return (must_exist ? r : 0);
  802a91:	84 db                	test   %bl,%bl
  802a93:	ba 00 00 00 00       	mov    $0x0,%edx
  802a98:	0f 44 c2             	cmove  %edx,%eax
  802a9b:	eb 41                	jmp    802ade <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a9d:	83 ec 08             	sub    $0x8,%esp
  802aa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802aa3:	50                   	push   %eax
  802aa4:	ff 36                	pushl  (%esi)
  802aa6:	e8 66 ff ff ff       	call   802a11 <dev_lookup>
  802aab:	89 c3                	mov    %eax,%ebx
  802aad:	83 c4 10             	add    $0x10,%esp
  802ab0:	85 c0                	test   %eax,%eax
  802ab2:	78 1a                	js     802ace <fd_close+0x6a>
		if (dev->dev_close)
  802ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ab7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802aba:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802abf:	85 c0                	test   %eax,%eax
  802ac1:	74 0b                	je     802ace <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802ac3:	83 ec 0c             	sub    $0xc,%esp
  802ac6:	56                   	push   %esi
  802ac7:	ff d0                	call   *%eax
  802ac9:	89 c3                	mov    %eax,%ebx
  802acb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802ace:	83 ec 08             	sub    $0x8,%esp
  802ad1:	56                   	push   %esi
  802ad2:	6a 00                	push   $0x0
  802ad4:	e8 40 fb ff ff       	call   802619 <sys_page_unmap>
	return r;
  802ad9:	83 c4 10             	add    $0x10,%esp
  802adc:	89 d8                	mov    %ebx,%eax
}
  802ade:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ae1:	5b                   	pop    %ebx
  802ae2:	5e                   	pop    %esi
  802ae3:	5d                   	pop    %ebp
  802ae4:	c3                   	ret    

00802ae5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802ae5:	55                   	push   %ebp
  802ae6:	89 e5                	mov    %esp,%ebp
  802ae8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aee:	50                   	push   %eax
  802aef:	ff 75 08             	pushl  0x8(%ebp)
  802af2:	e8 c4 fe ff ff       	call   8029bb <fd_lookup>
  802af7:	83 c4 08             	add    $0x8,%esp
  802afa:	85 c0                	test   %eax,%eax
  802afc:	78 10                	js     802b0e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802afe:	83 ec 08             	sub    $0x8,%esp
  802b01:	6a 01                	push   $0x1
  802b03:	ff 75 f4             	pushl  -0xc(%ebp)
  802b06:	e8 59 ff ff ff       	call   802a64 <fd_close>
  802b0b:	83 c4 10             	add    $0x10,%esp
}
  802b0e:	c9                   	leave  
  802b0f:	c3                   	ret    

00802b10 <close_all>:

void
close_all(void)
{
  802b10:	55                   	push   %ebp
  802b11:	89 e5                	mov    %esp,%ebp
  802b13:	53                   	push   %ebx
  802b14:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802b17:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802b1c:	83 ec 0c             	sub    $0xc,%esp
  802b1f:	53                   	push   %ebx
  802b20:	e8 c0 ff ff ff       	call   802ae5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802b25:	83 c3 01             	add    $0x1,%ebx
  802b28:	83 c4 10             	add    $0x10,%esp
  802b2b:	83 fb 20             	cmp    $0x20,%ebx
  802b2e:	75 ec                	jne    802b1c <close_all+0xc>
		close(i);
}
  802b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b33:	c9                   	leave  
  802b34:	c3                   	ret    

00802b35 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802b35:	55                   	push   %ebp
  802b36:	89 e5                	mov    %esp,%ebp
  802b38:	57                   	push   %edi
  802b39:	56                   	push   %esi
  802b3a:	53                   	push   %ebx
  802b3b:	83 ec 2c             	sub    $0x2c,%esp
  802b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802b41:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b44:	50                   	push   %eax
  802b45:	ff 75 08             	pushl  0x8(%ebp)
  802b48:	e8 6e fe ff ff       	call   8029bb <fd_lookup>
  802b4d:	83 c4 08             	add    $0x8,%esp
  802b50:	85 c0                	test   %eax,%eax
  802b52:	0f 88 c1 00 00 00    	js     802c19 <dup+0xe4>
		return r;
	close(newfdnum);
  802b58:	83 ec 0c             	sub    $0xc,%esp
  802b5b:	56                   	push   %esi
  802b5c:	e8 84 ff ff ff       	call   802ae5 <close>

	newfd = INDEX2FD(newfdnum);
  802b61:	89 f3                	mov    %esi,%ebx
  802b63:	c1 e3 0c             	shl    $0xc,%ebx
  802b66:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802b6c:	83 c4 04             	add    $0x4,%esp
  802b6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b72:	e8 de fd ff ff       	call   802955 <fd2data>
  802b77:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b79:	89 1c 24             	mov    %ebx,(%esp)
  802b7c:	e8 d4 fd ff ff       	call   802955 <fd2data>
  802b81:	83 c4 10             	add    $0x10,%esp
  802b84:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b87:	89 f8                	mov    %edi,%eax
  802b89:	c1 e8 16             	shr    $0x16,%eax
  802b8c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b93:	a8 01                	test   $0x1,%al
  802b95:	74 37                	je     802bce <dup+0x99>
  802b97:	89 f8                	mov    %edi,%eax
  802b99:	c1 e8 0c             	shr    $0xc,%eax
  802b9c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802ba3:	f6 c2 01             	test   $0x1,%dl
  802ba6:	74 26                	je     802bce <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ba8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802baf:	83 ec 0c             	sub    $0xc,%esp
  802bb2:	25 07 0e 00 00       	and    $0xe07,%eax
  802bb7:	50                   	push   %eax
  802bb8:	ff 75 d4             	pushl  -0x2c(%ebp)
  802bbb:	6a 00                	push   $0x0
  802bbd:	57                   	push   %edi
  802bbe:	6a 00                	push   $0x0
  802bc0:	e8 12 fa ff ff       	call   8025d7 <sys_page_map>
  802bc5:	89 c7                	mov    %eax,%edi
  802bc7:	83 c4 20             	add    $0x20,%esp
  802bca:	85 c0                	test   %eax,%eax
  802bcc:	78 2e                	js     802bfc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802bd1:	89 d0                	mov    %edx,%eax
  802bd3:	c1 e8 0c             	shr    $0xc,%eax
  802bd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802bdd:	83 ec 0c             	sub    $0xc,%esp
  802be0:	25 07 0e 00 00       	and    $0xe07,%eax
  802be5:	50                   	push   %eax
  802be6:	53                   	push   %ebx
  802be7:	6a 00                	push   $0x0
  802be9:	52                   	push   %edx
  802bea:	6a 00                	push   $0x0
  802bec:	e8 e6 f9 ff ff       	call   8025d7 <sys_page_map>
  802bf1:	89 c7                	mov    %eax,%edi
  802bf3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802bf6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bf8:	85 ff                	test   %edi,%edi
  802bfa:	79 1d                	jns    802c19 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802bfc:	83 ec 08             	sub    $0x8,%esp
  802bff:	53                   	push   %ebx
  802c00:	6a 00                	push   $0x0
  802c02:	e8 12 fa ff ff       	call   802619 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802c07:	83 c4 08             	add    $0x8,%esp
  802c0a:	ff 75 d4             	pushl  -0x2c(%ebp)
  802c0d:	6a 00                	push   $0x0
  802c0f:	e8 05 fa ff ff       	call   802619 <sys_page_unmap>
	return r;
  802c14:	83 c4 10             	add    $0x10,%esp
  802c17:	89 f8                	mov    %edi,%eax
}
  802c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c1c:	5b                   	pop    %ebx
  802c1d:	5e                   	pop    %esi
  802c1e:	5f                   	pop    %edi
  802c1f:	5d                   	pop    %ebp
  802c20:	c3                   	ret    

00802c21 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802c21:	55                   	push   %ebp
  802c22:	89 e5                	mov    %esp,%ebp
  802c24:	53                   	push   %ebx
  802c25:	83 ec 14             	sub    $0x14,%esp
  802c28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c2e:	50                   	push   %eax
  802c2f:	53                   	push   %ebx
  802c30:	e8 86 fd ff ff       	call   8029bb <fd_lookup>
  802c35:	83 c4 08             	add    $0x8,%esp
  802c38:	89 c2                	mov    %eax,%edx
  802c3a:	85 c0                	test   %eax,%eax
  802c3c:	78 6d                	js     802cab <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c3e:	83 ec 08             	sub    $0x8,%esp
  802c41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c44:	50                   	push   %eax
  802c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c48:	ff 30                	pushl  (%eax)
  802c4a:	e8 c2 fd ff ff       	call   802a11 <dev_lookup>
  802c4f:	83 c4 10             	add    $0x10,%esp
  802c52:	85 c0                	test   %eax,%eax
  802c54:	78 4c                	js     802ca2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c56:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c59:	8b 42 08             	mov    0x8(%edx),%eax
  802c5c:	83 e0 03             	and    $0x3,%eax
  802c5f:	83 f8 01             	cmp    $0x1,%eax
  802c62:	75 21                	jne    802c85 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c64:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802c69:	8b 40 48             	mov    0x48(%eax),%eax
  802c6c:	83 ec 04             	sub    $0x4,%esp
  802c6f:	53                   	push   %ebx
  802c70:	50                   	push   %eax
  802c71:	68 c8 46 80 00       	push   $0x8046c8
  802c76:	e8 91 ef ff ff       	call   801c0c <cprintf>
		return -E_INVAL;
  802c7b:	83 c4 10             	add    $0x10,%esp
  802c7e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c83:	eb 26                	jmp    802cab <read+0x8a>
	}
	if (!dev->dev_read)
  802c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c88:	8b 40 08             	mov    0x8(%eax),%eax
  802c8b:	85 c0                	test   %eax,%eax
  802c8d:	74 17                	je     802ca6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c8f:	83 ec 04             	sub    $0x4,%esp
  802c92:	ff 75 10             	pushl  0x10(%ebp)
  802c95:	ff 75 0c             	pushl  0xc(%ebp)
  802c98:	52                   	push   %edx
  802c99:	ff d0                	call   *%eax
  802c9b:	89 c2                	mov    %eax,%edx
  802c9d:	83 c4 10             	add    $0x10,%esp
  802ca0:	eb 09                	jmp    802cab <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ca2:	89 c2                	mov    %eax,%edx
  802ca4:	eb 05                	jmp    802cab <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802ca6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802cab:	89 d0                	mov    %edx,%eax
  802cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cb0:	c9                   	leave  
  802cb1:	c3                   	ret    

00802cb2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802cb2:	55                   	push   %ebp
  802cb3:	89 e5                	mov    %esp,%ebp
  802cb5:	57                   	push   %edi
  802cb6:	56                   	push   %esi
  802cb7:	53                   	push   %ebx
  802cb8:	83 ec 0c             	sub    $0xc,%esp
  802cbb:	8b 7d 08             	mov    0x8(%ebp),%edi
  802cbe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cc6:	eb 21                	jmp    802ce9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802cc8:	83 ec 04             	sub    $0x4,%esp
  802ccb:	89 f0                	mov    %esi,%eax
  802ccd:	29 d8                	sub    %ebx,%eax
  802ccf:	50                   	push   %eax
  802cd0:	89 d8                	mov    %ebx,%eax
  802cd2:	03 45 0c             	add    0xc(%ebp),%eax
  802cd5:	50                   	push   %eax
  802cd6:	57                   	push   %edi
  802cd7:	e8 45 ff ff ff       	call   802c21 <read>
		if (m < 0)
  802cdc:	83 c4 10             	add    $0x10,%esp
  802cdf:	85 c0                	test   %eax,%eax
  802ce1:	78 10                	js     802cf3 <readn+0x41>
			return m;
		if (m == 0)
  802ce3:	85 c0                	test   %eax,%eax
  802ce5:	74 0a                	je     802cf1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802ce7:	01 c3                	add    %eax,%ebx
  802ce9:	39 f3                	cmp    %esi,%ebx
  802ceb:	72 db                	jb     802cc8 <readn+0x16>
  802ced:	89 d8                	mov    %ebx,%eax
  802cef:	eb 02                	jmp    802cf3 <readn+0x41>
  802cf1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cf6:	5b                   	pop    %ebx
  802cf7:	5e                   	pop    %esi
  802cf8:	5f                   	pop    %edi
  802cf9:	5d                   	pop    %ebp
  802cfa:	c3                   	ret    

00802cfb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802cfb:	55                   	push   %ebp
  802cfc:	89 e5                	mov    %esp,%ebp
  802cfe:	53                   	push   %ebx
  802cff:	83 ec 14             	sub    $0x14,%esp
  802d02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d08:	50                   	push   %eax
  802d09:	53                   	push   %ebx
  802d0a:	e8 ac fc ff ff       	call   8029bb <fd_lookup>
  802d0f:	83 c4 08             	add    $0x8,%esp
  802d12:	89 c2                	mov    %eax,%edx
  802d14:	85 c0                	test   %eax,%eax
  802d16:	78 68                	js     802d80 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d18:	83 ec 08             	sub    $0x8,%esp
  802d1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d1e:	50                   	push   %eax
  802d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d22:	ff 30                	pushl  (%eax)
  802d24:	e8 e8 fc ff ff       	call   802a11 <dev_lookup>
  802d29:	83 c4 10             	add    $0x10,%esp
  802d2c:	85 c0                	test   %eax,%eax
  802d2e:	78 47                	js     802d77 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d33:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d37:	75 21                	jne    802d5a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d39:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802d3e:	8b 40 48             	mov    0x48(%eax),%eax
  802d41:	83 ec 04             	sub    $0x4,%esp
  802d44:	53                   	push   %ebx
  802d45:	50                   	push   %eax
  802d46:	68 e4 46 80 00       	push   $0x8046e4
  802d4b:	e8 bc ee ff ff       	call   801c0c <cprintf>
		return -E_INVAL;
  802d50:	83 c4 10             	add    $0x10,%esp
  802d53:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d58:	eb 26                	jmp    802d80 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d5d:	8b 52 0c             	mov    0xc(%edx),%edx
  802d60:	85 d2                	test   %edx,%edx
  802d62:	74 17                	je     802d7b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d64:	83 ec 04             	sub    $0x4,%esp
  802d67:	ff 75 10             	pushl  0x10(%ebp)
  802d6a:	ff 75 0c             	pushl  0xc(%ebp)
  802d6d:	50                   	push   %eax
  802d6e:	ff d2                	call   *%edx
  802d70:	89 c2                	mov    %eax,%edx
  802d72:	83 c4 10             	add    $0x10,%esp
  802d75:	eb 09                	jmp    802d80 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d77:	89 c2                	mov    %eax,%edx
  802d79:	eb 05                	jmp    802d80 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d7b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d80:	89 d0                	mov    %edx,%eax
  802d82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d85:	c9                   	leave  
  802d86:	c3                   	ret    

00802d87 <seek>:

int
seek(int fdnum, off_t offset)
{
  802d87:	55                   	push   %ebp
  802d88:	89 e5                	mov    %esp,%ebp
  802d8a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d8d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d90:	50                   	push   %eax
  802d91:	ff 75 08             	pushl  0x8(%ebp)
  802d94:	e8 22 fc ff ff       	call   8029bb <fd_lookup>
  802d99:	83 c4 08             	add    $0x8,%esp
  802d9c:	85 c0                	test   %eax,%eax
  802d9e:	78 0e                	js     802dae <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802da0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802da3:	8b 55 0c             	mov    0xc(%ebp),%edx
  802da6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802dae:	c9                   	leave  
  802daf:	c3                   	ret    

00802db0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802db0:	55                   	push   %ebp
  802db1:	89 e5                	mov    %esp,%ebp
  802db3:	53                   	push   %ebx
  802db4:	83 ec 14             	sub    $0x14,%esp
  802db7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802dba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dbd:	50                   	push   %eax
  802dbe:	53                   	push   %ebx
  802dbf:	e8 f7 fb ff ff       	call   8029bb <fd_lookup>
  802dc4:	83 c4 08             	add    $0x8,%esp
  802dc7:	89 c2                	mov    %eax,%edx
  802dc9:	85 c0                	test   %eax,%eax
  802dcb:	78 65                	js     802e32 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dcd:	83 ec 08             	sub    $0x8,%esp
  802dd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dd3:	50                   	push   %eax
  802dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dd7:	ff 30                	pushl  (%eax)
  802dd9:	e8 33 fc ff ff       	call   802a11 <dev_lookup>
  802dde:	83 c4 10             	add    $0x10,%esp
  802de1:	85 c0                	test   %eax,%eax
  802de3:	78 44                	js     802e29 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802de8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802dec:	75 21                	jne    802e0f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802dee:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802df3:	8b 40 48             	mov    0x48(%eax),%eax
  802df6:	83 ec 04             	sub    $0x4,%esp
  802df9:	53                   	push   %ebx
  802dfa:	50                   	push   %eax
  802dfb:	68 a4 46 80 00       	push   $0x8046a4
  802e00:	e8 07 ee ff ff       	call   801c0c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802e05:	83 c4 10             	add    $0x10,%esp
  802e08:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802e0d:	eb 23                	jmp    802e32 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e12:	8b 52 18             	mov    0x18(%edx),%edx
  802e15:	85 d2                	test   %edx,%edx
  802e17:	74 14                	je     802e2d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802e19:	83 ec 08             	sub    $0x8,%esp
  802e1c:	ff 75 0c             	pushl  0xc(%ebp)
  802e1f:	50                   	push   %eax
  802e20:	ff d2                	call   *%edx
  802e22:	89 c2                	mov    %eax,%edx
  802e24:	83 c4 10             	add    $0x10,%esp
  802e27:	eb 09                	jmp    802e32 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e29:	89 c2                	mov    %eax,%edx
  802e2b:	eb 05                	jmp    802e32 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802e2d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802e32:	89 d0                	mov    %edx,%eax
  802e34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e37:	c9                   	leave  
  802e38:	c3                   	ret    

00802e39 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802e39:	55                   	push   %ebp
  802e3a:	89 e5                	mov    %esp,%ebp
  802e3c:	53                   	push   %ebx
  802e3d:	83 ec 14             	sub    $0x14,%esp
  802e40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e46:	50                   	push   %eax
  802e47:	ff 75 08             	pushl  0x8(%ebp)
  802e4a:	e8 6c fb ff ff       	call   8029bb <fd_lookup>
  802e4f:	83 c4 08             	add    $0x8,%esp
  802e52:	89 c2                	mov    %eax,%edx
  802e54:	85 c0                	test   %eax,%eax
  802e56:	78 58                	js     802eb0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e58:	83 ec 08             	sub    $0x8,%esp
  802e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e5e:	50                   	push   %eax
  802e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e62:	ff 30                	pushl  (%eax)
  802e64:	e8 a8 fb ff ff       	call   802a11 <dev_lookup>
  802e69:	83 c4 10             	add    $0x10,%esp
  802e6c:	85 c0                	test   %eax,%eax
  802e6e:	78 37                	js     802ea7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e73:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e77:	74 32                	je     802eab <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e79:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e7c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e83:	00 00 00 
	stat->st_isdir = 0;
  802e86:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e8d:	00 00 00 
	stat->st_dev = dev;
  802e90:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e96:	83 ec 08             	sub    $0x8,%esp
  802e99:	53                   	push   %ebx
  802e9a:	ff 75 f0             	pushl  -0x10(%ebp)
  802e9d:	ff 50 14             	call   *0x14(%eax)
  802ea0:	89 c2                	mov    %eax,%edx
  802ea2:	83 c4 10             	add    $0x10,%esp
  802ea5:	eb 09                	jmp    802eb0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ea7:	89 c2                	mov    %eax,%edx
  802ea9:	eb 05                	jmp    802eb0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802eab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802eb0:	89 d0                	mov    %edx,%eax
  802eb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802eb5:	c9                   	leave  
  802eb6:	c3                   	ret    

00802eb7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802eb7:	55                   	push   %ebp
  802eb8:	89 e5                	mov    %esp,%ebp
  802eba:	56                   	push   %esi
  802ebb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ebc:	83 ec 08             	sub    $0x8,%esp
  802ebf:	6a 00                	push   $0x0
  802ec1:	ff 75 08             	pushl  0x8(%ebp)
  802ec4:	e8 d6 01 00 00       	call   80309f <open>
  802ec9:	89 c3                	mov    %eax,%ebx
  802ecb:	83 c4 10             	add    $0x10,%esp
  802ece:	85 c0                	test   %eax,%eax
  802ed0:	78 1b                	js     802eed <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802ed2:	83 ec 08             	sub    $0x8,%esp
  802ed5:	ff 75 0c             	pushl  0xc(%ebp)
  802ed8:	50                   	push   %eax
  802ed9:	e8 5b ff ff ff       	call   802e39 <fstat>
  802ede:	89 c6                	mov    %eax,%esi
	close(fd);
  802ee0:	89 1c 24             	mov    %ebx,(%esp)
  802ee3:	e8 fd fb ff ff       	call   802ae5 <close>
	return r;
  802ee8:	83 c4 10             	add    $0x10,%esp
  802eeb:	89 f0                	mov    %esi,%eax
}
  802eed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ef0:	5b                   	pop    %ebx
  802ef1:	5e                   	pop    %esi
  802ef2:	5d                   	pop    %ebp
  802ef3:	c3                   	ret    

00802ef4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802ef4:	55                   	push   %ebp
  802ef5:	89 e5                	mov    %esp,%ebp
  802ef7:	56                   	push   %esi
  802ef8:	53                   	push   %ebx
  802ef9:	89 c6                	mov    %eax,%esi
  802efb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802efd:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802f04:	75 12                	jne    802f18 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802f06:	83 ec 0c             	sub    $0xc,%esp
  802f09:	6a 01                	push   $0x1
  802f0b:	e8 fc f9 ff ff       	call   80290c <ipc_find_env>
  802f10:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802f15:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802f18:	6a 07                	push   $0x7
  802f1a:	68 00 b0 80 00       	push   $0x80b000
  802f1f:	56                   	push   %esi
  802f20:	ff 35 00 a0 80 00    	pushl  0x80a000
  802f26:	e8 8d f9 ff ff       	call   8028b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802f2b:	83 c4 0c             	add    $0xc,%esp
  802f2e:	6a 00                	push   $0x0
  802f30:	53                   	push   %ebx
  802f31:	6a 00                	push   $0x0
  802f33:	e8 19 f9 ff ff       	call   802851 <ipc_recv>
}
  802f38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f3b:	5b                   	pop    %ebx
  802f3c:	5e                   	pop    %esi
  802f3d:	5d                   	pop    %ebp
  802f3e:	c3                   	ret    

00802f3f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802f3f:	55                   	push   %ebp
  802f40:	89 e5                	mov    %esp,%ebp
  802f42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802f45:	8b 45 08             	mov    0x8(%ebp),%eax
  802f48:	8b 40 0c             	mov    0xc(%eax),%eax
  802f4b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f53:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f58:	ba 00 00 00 00       	mov    $0x0,%edx
  802f5d:	b8 02 00 00 00       	mov    $0x2,%eax
  802f62:	e8 8d ff ff ff       	call   802ef4 <fsipc>
}
  802f67:	c9                   	leave  
  802f68:	c3                   	ret    

00802f69 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802f69:	55                   	push   %ebp
  802f6a:	89 e5                	mov    %esp,%ebp
  802f6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f72:	8b 40 0c             	mov    0xc(%eax),%eax
  802f75:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f7a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f7f:	b8 06 00 00 00       	mov    $0x6,%eax
  802f84:	e8 6b ff ff ff       	call   802ef4 <fsipc>
}
  802f89:	c9                   	leave  
  802f8a:	c3                   	ret    

00802f8b <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f8b:	55                   	push   %ebp
  802f8c:	89 e5                	mov    %esp,%ebp
  802f8e:	53                   	push   %ebx
  802f8f:	83 ec 04             	sub    $0x4,%esp
  802f92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f95:	8b 45 08             	mov    0x8(%ebp),%eax
  802f98:	8b 40 0c             	mov    0xc(%eax),%eax
  802f9b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802fa0:	ba 00 00 00 00       	mov    $0x0,%edx
  802fa5:	b8 05 00 00 00       	mov    $0x5,%eax
  802faa:	e8 45 ff ff ff       	call   802ef4 <fsipc>
  802faf:	85 c0                	test   %eax,%eax
  802fb1:	78 2c                	js     802fdf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802fb3:	83 ec 08             	sub    $0x8,%esp
  802fb6:	68 00 b0 80 00       	push   $0x80b000
  802fbb:	53                   	push   %ebx
  802fbc:	e8 d0 f1 ff ff       	call   802191 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802fc1:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802fc6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802fcc:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802fd1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802fd7:	83 c4 10             	add    $0x10,%esp
  802fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802fdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fe2:	c9                   	leave  
  802fe3:	c3                   	ret    

00802fe4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802fe4:	55                   	push   %ebp
  802fe5:	89 e5                	mov    %esp,%ebp
  802fe7:	83 ec 0c             	sub    $0xc,%esp
  802fea:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802fed:	8b 55 08             	mov    0x8(%ebp),%edx
  802ff0:	8b 52 0c             	mov    0xc(%edx),%edx
  802ff3:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802ff9:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802ffe:	50                   	push   %eax
  802fff:	ff 75 0c             	pushl  0xc(%ebp)
  803002:	68 08 b0 80 00       	push   $0x80b008
  803007:	e8 17 f3 ff ff       	call   802323 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80300c:	ba 00 00 00 00       	mov    $0x0,%edx
  803011:	b8 04 00 00 00       	mov    $0x4,%eax
  803016:	e8 d9 fe ff ff       	call   802ef4 <fsipc>

}
  80301b:	c9                   	leave  
  80301c:	c3                   	ret    

0080301d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80301d:	55                   	push   %ebp
  80301e:	89 e5                	mov    %esp,%ebp
  803020:	56                   	push   %esi
  803021:	53                   	push   %ebx
  803022:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  803025:	8b 45 08             	mov    0x8(%ebp),%eax
  803028:	8b 40 0c             	mov    0xc(%eax),%eax
  80302b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803030:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803036:	ba 00 00 00 00       	mov    $0x0,%edx
  80303b:	b8 03 00 00 00       	mov    $0x3,%eax
  803040:	e8 af fe ff ff       	call   802ef4 <fsipc>
  803045:	89 c3                	mov    %eax,%ebx
  803047:	85 c0                	test   %eax,%eax
  803049:	78 4b                	js     803096 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80304b:	39 c6                	cmp    %eax,%esi
  80304d:	73 16                	jae    803065 <devfile_read+0x48>
  80304f:	68 18 47 80 00       	push   $0x804718
  803054:	68 9d 3d 80 00       	push   $0x803d9d
  803059:	6a 7c                	push   $0x7c
  80305b:	68 1f 47 80 00       	push   $0x80471f
  803060:	e8 ce ea ff ff       	call   801b33 <_panic>
	assert(r <= PGSIZE);
  803065:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80306a:	7e 16                	jle    803082 <devfile_read+0x65>
  80306c:	68 2a 47 80 00       	push   $0x80472a
  803071:	68 9d 3d 80 00       	push   $0x803d9d
  803076:	6a 7d                	push   $0x7d
  803078:	68 1f 47 80 00       	push   $0x80471f
  80307d:	e8 b1 ea ff ff       	call   801b33 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803082:	83 ec 04             	sub    $0x4,%esp
  803085:	50                   	push   %eax
  803086:	68 00 b0 80 00       	push   $0x80b000
  80308b:	ff 75 0c             	pushl  0xc(%ebp)
  80308e:	e8 90 f2 ff ff       	call   802323 <memmove>
	return r;
  803093:	83 c4 10             	add    $0x10,%esp
}
  803096:	89 d8                	mov    %ebx,%eax
  803098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80309b:	5b                   	pop    %ebx
  80309c:	5e                   	pop    %esi
  80309d:	5d                   	pop    %ebp
  80309e:	c3                   	ret    

0080309f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80309f:	55                   	push   %ebp
  8030a0:	89 e5                	mov    %esp,%ebp
  8030a2:	53                   	push   %ebx
  8030a3:	83 ec 20             	sub    $0x20,%esp
  8030a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8030a9:	53                   	push   %ebx
  8030aa:	e8 a9 f0 ff ff       	call   802158 <strlen>
  8030af:	83 c4 10             	add    $0x10,%esp
  8030b2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8030b7:	7f 67                	jg     803120 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8030b9:	83 ec 0c             	sub    $0xc,%esp
  8030bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030bf:	50                   	push   %eax
  8030c0:	e8 a7 f8 ff ff       	call   80296c <fd_alloc>
  8030c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8030c8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8030ca:	85 c0                	test   %eax,%eax
  8030cc:	78 57                	js     803125 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8030ce:	83 ec 08             	sub    $0x8,%esp
  8030d1:	53                   	push   %ebx
  8030d2:	68 00 b0 80 00       	push   $0x80b000
  8030d7:	e8 b5 f0 ff ff       	call   802191 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8030dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030df:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8030e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8030ec:	e8 03 fe ff ff       	call   802ef4 <fsipc>
  8030f1:	89 c3                	mov    %eax,%ebx
  8030f3:	83 c4 10             	add    $0x10,%esp
  8030f6:	85 c0                	test   %eax,%eax
  8030f8:	79 14                	jns    80310e <open+0x6f>
		fd_close(fd, 0);
  8030fa:	83 ec 08             	sub    $0x8,%esp
  8030fd:	6a 00                	push   $0x0
  8030ff:	ff 75 f4             	pushl  -0xc(%ebp)
  803102:	e8 5d f9 ff ff       	call   802a64 <fd_close>
		return r;
  803107:	83 c4 10             	add    $0x10,%esp
  80310a:	89 da                	mov    %ebx,%edx
  80310c:	eb 17                	jmp    803125 <open+0x86>
	}

	return fd2num(fd);
  80310e:	83 ec 0c             	sub    $0xc,%esp
  803111:	ff 75 f4             	pushl  -0xc(%ebp)
  803114:	e8 2c f8 ff ff       	call   802945 <fd2num>
  803119:	89 c2                	mov    %eax,%edx
  80311b:	83 c4 10             	add    $0x10,%esp
  80311e:	eb 05                	jmp    803125 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  803120:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  803125:	89 d0                	mov    %edx,%eax
  803127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80312a:	c9                   	leave  
  80312b:	c3                   	ret    

0080312c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80312c:	55                   	push   %ebp
  80312d:	89 e5                	mov    %esp,%ebp
  80312f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803132:	ba 00 00 00 00       	mov    $0x0,%edx
  803137:	b8 08 00 00 00       	mov    $0x8,%eax
  80313c:	e8 b3 fd ff ff       	call   802ef4 <fsipc>
}
  803141:	c9                   	leave  
  803142:	c3                   	ret    

00803143 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803143:	55                   	push   %ebp
  803144:	89 e5                	mov    %esp,%ebp
  803146:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803149:	89 d0                	mov    %edx,%eax
  80314b:	c1 e8 16             	shr    $0x16,%eax
  80314e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803155:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80315a:	f6 c1 01             	test   $0x1,%cl
  80315d:	74 1d                	je     80317c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80315f:	c1 ea 0c             	shr    $0xc,%edx
  803162:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803169:	f6 c2 01             	test   $0x1,%dl
  80316c:	74 0e                	je     80317c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80316e:	c1 ea 0c             	shr    $0xc,%edx
  803171:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803178:	ef 
  803179:	0f b7 c0             	movzwl %ax,%eax
}
  80317c:	5d                   	pop    %ebp
  80317d:	c3                   	ret    

0080317e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80317e:	55                   	push   %ebp
  80317f:	89 e5                	mov    %esp,%ebp
  803181:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  803184:	68 36 47 80 00       	push   $0x804736
  803189:	ff 75 0c             	pushl  0xc(%ebp)
  80318c:	e8 00 f0 ff ff       	call   802191 <strcpy>
	return 0;
}
  803191:	b8 00 00 00 00       	mov    $0x0,%eax
  803196:	c9                   	leave  
  803197:	c3                   	ret    

00803198 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803198:	55                   	push   %ebp
  803199:	89 e5                	mov    %esp,%ebp
  80319b:	53                   	push   %ebx
  80319c:	83 ec 10             	sub    $0x10,%esp
  80319f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8031a2:	53                   	push   %ebx
  8031a3:	e8 9b ff ff ff       	call   803143 <pageref>
  8031a8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8031ab:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8031b0:	83 f8 01             	cmp    $0x1,%eax
  8031b3:	75 10                	jne    8031c5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8031b5:	83 ec 0c             	sub    $0xc,%esp
  8031b8:	ff 73 0c             	pushl  0xc(%ebx)
  8031bb:	e8 c0 02 00 00       	call   803480 <nsipc_close>
  8031c0:	89 c2                	mov    %eax,%edx
  8031c2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8031c5:	89 d0                	mov    %edx,%eax
  8031c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031ca:	c9                   	leave  
  8031cb:	c3                   	ret    

008031cc <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8031cc:	55                   	push   %ebp
  8031cd:	89 e5                	mov    %esp,%ebp
  8031cf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8031d2:	6a 00                	push   $0x0
  8031d4:	ff 75 10             	pushl  0x10(%ebp)
  8031d7:	ff 75 0c             	pushl  0xc(%ebp)
  8031da:	8b 45 08             	mov    0x8(%ebp),%eax
  8031dd:	ff 70 0c             	pushl  0xc(%eax)
  8031e0:	e8 78 03 00 00       	call   80355d <nsipc_send>
}
  8031e5:	c9                   	leave  
  8031e6:	c3                   	ret    

008031e7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8031e7:	55                   	push   %ebp
  8031e8:	89 e5                	mov    %esp,%ebp
  8031ea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8031ed:	6a 00                	push   $0x0
  8031ef:	ff 75 10             	pushl  0x10(%ebp)
  8031f2:	ff 75 0c             	pushl  0xc(%ebp)
  8031f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8031f8:	ff 70 0c             	pushl  0xc(%eax)
  8031fb:	e8 f1 02 00 00       	call   8034f1 <nsipc_recv>
}
  803200:	c9                   	leave  
  803201:	c3                   	ret    

00803202 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  803202:	55                   	push   %ebp
  803203:	89 e5                	mov    %esp,%ebp
  803205:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803208:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80320b:	52                   	push   %edx
  80320c:	50                   	push   %eax
  80320d:	e8 a9 f7 ff ff       	call   8029bb <fd_lookup>
  803212:	83 c4 10             	add    $0x10,%esp
  803215:	85 c0                	test   %eax,%eax
  803217:	78 17                	js     803230 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80321c:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  803222:	39 08                	cmp    %ecx,(%eax)
  803224:	75 05                	jne    80322b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  803226:	8b 40 0c             	mov    0xc(%eax),%eax
  803229:	eb 05                	jmp    803230 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80322b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  803230:	c9                   	leave  
  803231:	c3                   	ret    

00803232 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  803232:	55                   	push   %ebp
  803233:	89 e5                	mov    %esp,%ebp
  803235:	56                   	push   %esi
  803236:	53                   	push   %ebx
  803237:	83 ec 1c             	sub    $0x1c,%esp
  80323a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80323c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80323f:	50                   	push   %eax
  803240:	e8 27 f7 ff ff       	call   80296c <fd_alloc>
  803245:	89 c3                	mov    %eax,%ebx
  803247:	83 c4 10             	add    $0x10,%esp
  80324a:	85 c0                	test   %eax,%eax
  80324c:	78 1b                	js     803269 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80324e:	83 ec 04             	sub    $0x4,%esp
  803251:	68 07 04 00 00       	push   $0x407
  803256:	ff 75 f4             	pushl  -0xc(%ebp)
  803259:	6a 00                	push   $0x0
  80325b:	e8 34 f3 ff ff       	call   802594 <sys_page_alloc>
  803260:	89 c3                	mov    %eax,%ebx
  803262:	83 c4 10             	add    $0x10,%esp
  803265:	85 c0                	test   %eax,%eax
  803267:	79 10                	jns    803279 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  803269:	83 ec 0c             	sub    $0xc,%esp
  80326c:	56                   	push   %esi
  80326d:	e8 0e 02 00 00       	call   803480 <nsipc_close>
		return r;
  803272:	83 c4 10             	add    $0x10,%esp
  803275:	89 d8                	mov    %ebx,%eax
  803277:	eb 24                	jmp    80329d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803279:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80327f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803282:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803284:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803287:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80328e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  803291:	83 ec 0c             	sub    $0xc,%esp
  803294:	50                   	push   %eax
  803295:	e8 ab f6 ff ff       	call   802945 <fd2num>
  80329a:	83 c4 10             	add    $0x10,%esp
}
  80329d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032a0:	5b                   	pop    %ebx
  8032a1:	5e                   	pop    %esi
  8032a2:	5d                   	pop    %ebp
  8032a3:	c3                   	ret    

008032a4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8032a4:	55                   	push   %ebp
  8032a5:	89 e5                	mov    %esp,%ebp
  8032a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8032ad:	e8 50 ff ff ff       	call   803202 <fd2sockid>
		return r;
  8032b2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032b4:	85 c0                	test   %eax,%eax
  8032b6:	78 1f                	js     8032d7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8032b8:	83 ec 04             	sub    $0x4,%esp
  8032bb:	ff 75 10             	pushl  0x10(%ebp)
  8032be:	ff 75 0c             	pushl  0xc(%ebp)
  8032c1:	50                   	push   %eax
  8032c2:	e8 12 01 00 00       	call   8033d9 <nsipc_accept>
  8032c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8032ca:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8032cc:	85 c0                	test   %eax,%eax
  8032ce:	78 07                	js     8032d7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8032d0:	e8 5d ff ff ff       	call   803232 <alloc_sockfd>
  8032d5:	89 c1                	mov    %eax,%ecx
}
  8032d7:	89 c8                	mov    %ecx,%eax
  8032d9:	c9                   	leave  
  8032da:	c3                   	ret    

008032db <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8032db:	55                   	push   %ebp
  8032dc:	89 e5                	mov    %esp,%ebp
  8032de:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8032e4:	e8 19 ff ff ff       	call   803202 <fd2sockid>
  8032e9:	85 c0                	test   %eax,%eax
  8032eb:	78 12                	js     8032ff <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8032ed:	83 ec 04             	sub    $0x4,%esp
  8032f0:	ff 75 10             	pushl  0x10(%ebp)
  8032f3:	ff 75 0c             	pushl  0xc(%ebp)
  8032f6:	50                   	push   %eax
  8032f7:	e8 2d 01 00 00       	call   803429 <nsipc_bind>
  8032fc:	83 c4 10             	add    $0x10,%esp
}
  8032ff:	c9                   	leave  
  803300:	c3                   	ret    

00803301 <shutdown>:

int
shutdown(int s, int how)
{
  803301:	55                   	push   %ebp
  803302:	89 e5                	mov    %esp,%ebp
  803304:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803307:	8b 45 08             	mov    0x8(%ebp),%eax
  80330a:	e8 f3 fe ff ff       	call   803202 <fd2sockid>
  80330f:	85 c0                	test   %eax,%eax
  803311:	78 0f                	js     803322 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  803313:	83 ec 08             	sub    $0x8,%esp
  803316:	ff 75 0c             	pushl  0xc(%ebp)
  803319:	50                   	push   %eax
  80331a:	e8 3f 01 00 00       	call   80345e <nsipc_shutdown>
  80331f:	83 c4 10             	add    $0x10,%esp
}
  803322:	c9                   	leave  
  803323:	c3                   	ret    

00803324 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803324:	55                   	push   %ebp
  803325:	89 e5                	mov    %esp,%ebp
  803327:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80332a:	8b 45 08             	mov    0x8(%ebp),%eax
  80332d:	e8 d0 fe ff ff       	call   803202 <fd2sockid>
  803332:	85 c0                	test   %eax,%eax
  803334:	78 12                	js     803348 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  803336:	83 ec 04             	sub    $0x4,%esp
  803339:	ff 75 10             	pushl  0x10(%ebp)
  80333c:	ff 75 0c             	pushl  0xc(%ebp)
  80333f:	50                   	push   %eax
  803340:	e8 55 01 00 00       	call   80349a <nsipc_connect>
  803345:	83 c4 10             	add    $0x10,%esp
}
  803348:	c9                   	leave  
  803349:	c3                   	ret    

0080334a <listen>:

int
listen(int s, int backlog)
{
  80334a:	55                   	push   %ebp
  80334b:	89 e5                	mov    %esp,%ebp
  80334d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803350:	8b 45 08             	mov    0x8(%ebp),%eax
  803353:	e8 aa fe ff ff       	call   803202 <fd2sockid>
  803358:	85 c0                	test   %eax,%eax
  80335a:	78 0f                	js     80336b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80335c:	83 ec 08             	sub    $0x8,%esp
  80335f:	ff 75 0c             	pushl  0xc(%ebp)
  803362:	50                   	push   %eax
  803363:	e8 67 01 00 00       	call   8034cf <nsipc_listen>
  803368:	83 c4 10             	add    $0x10,%esp
}
  80336b:	c9                   	leave  
  80336c:	c3                   	ret    

0080336d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80336d:	55                   	push   %ebp
  80336e:	89 e5                	mov    %esp,%ebp
  803370:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803373:	ff 75 10             	pushl  0x10(%ebp)
  803376:	ff 75 0c             	pushl  0xc(%ebp)
  803379:	ff 75 08             	pushl  0x8(%ebp)
  80337c:	e8 3a 02 00 00       	call   8035bb <nsipc_socket>
  803381:	83 c4 10             	add    $0x10,%esp
  803384:	85 c0                	test   %eax,%eax
  803386:	78 05                	js     80338d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  803388:	e8 a5 fe ff ff       	call   803232 <alloc_sockfd>
}
  80338d:	c9                   	leave  
  80338e:	c3                   	ret    

0080338f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80338f:	55                   	push   %ebp
  803390:	89 e5                	mov    %esp,%ebp
  803392:	53                   	push   %ebx
  803393:	83 ec 04             	sub    $0x4,%esp
  803396:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803398:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80339f:	75 12                	jne    8033b3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8033a1:	83 ec 0c             	sub    $0xc,%esp
  8033a4:	6a 02                	push   $0x2
  8033a6:	e8 61 f5 ff ff       	call   80290c <ipc_find_env>
  8033ab:	a3 04 a0 80 00       	mov    %eax,0x80a004
  8033b0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8033b3:	6a 07                	push   $0x7
  8033b5:	68 00 c0 80 00       	push   $0x80c000
  8033ba:	53                   	push   %ebx
  8033bb:	ff 35 04 a0 80 00    	pushl  0x80a004
  8033c1:	e8 f2 f4 ff ff       	call   8028b8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8033c6:	83 c4 0c             	add    $0xc,%esp
  8033c9:	6a 00                	push   $0x0
  8033cb:	6a 00                	push   $0x0
  8033cd:	6a 00                	push   $0x0
  8033cf:	e8 7d f4 ff ff       	call   802851 <ipc_recv>
}
  8033d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033d7:	c9                   	leave  
  8033d8:	c3                   	ret    

008033d9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8033d9:	55                   	push   %ebp
  8033da:	89 e5                	mov    %esp,%ebp
  8033dc:	56                   	push   %esi
  8033dd:	53                   	push   %ebx
  8033de:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8033e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8033e4:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8033e9:	8b 06                	mov    (%esi),%eax
  8033eb:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8033f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8033f5:	e8 95 ff ff ff       	call   80338f <nsipc>
  8033fa:	89 c3                	mov    %eax,%ebx
  8033fc:	85 c0                	test   %eax,%eax
  8033fe:	78 20                	js     803420 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803400:	83 ec 04             	sub    $0x4,%esp
  803403:	ff 35 10 c0 80 00    	pushl  0x80c010
  803409:	68 00 c0 80 00       	push   $0x80c000
  80340e:	ff 75 0c             	pushl  0xc(%ebp)
  803411:	e8 0d ef ff ff       	call   802323 <memmove>
		*addrlen = ret->ret_addrlen;
  803416:	a1 10 c0 80 00       	mov    0x80c010,%eax
  80341b:	89 06                	mov    %eax,(%esi)
  80341d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  803420:	89 d8                	mov    %ebx,%eax
  803422:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803425:	5b                   	pop    %ebx
  803426:	5e                   	pop    %esi
  803427:	5d                   	pop    %ebp
  803428:	c3                   	ret    

00803429 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803429:	55                   	push   %ebp
  80342a:	89 e5                	mov    %esp,%ebp
  80342c:	53                   	push   %ebx
  80342d:	83 ec 08             	sub    $0x8,%esp
  803430:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803433:	8b 45 08             	mov    0x8(%ebp),%eax
  803436:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80343b:	53                   	push   %ebx
  80343c:	ff 75 0c             	pushl  0xc(%ebp)
  80343f:	68 04 c0 80 00       	push   $0x80c004
  803444:	e8 da ee ff ff       	call   802323 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803449:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  80344f:	b8 02 00 00 00       	mov    $0x2,%eax
  803454:	e8 36 ff ff ff       	call   80338f <nsipc>
}
  803459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80345c:	c9                   	leave  
  80345d:	c3                   	ret    

0080345e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80345e:	55                   	push   %ebp
  80345f:	89 e5                	mov    %esp,%ebp
  803461:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803464:	8b 45 08             	mov    0x8(%ebp),%eax
  803467:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  80346c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80346f:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803474:	b8 03 00 00 00       	mov    $0x3,%eax
  803479:	e8 11 ff ff ff       	call   80338f <nsipc>
}
  80347e:	c9                   	leave  
  80347f:	c3                   	ret    

00803480 <nsipc_close>:

int
nsipc_close(int s)
{
  803480:	55                   	push   %ebp
  803481:	89 e5                	mov    %esp,%ebp
  803483:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803486:	8b 45 08             	mov    0x8(%ebp),%eax
  803489:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  80348e:	b8 04 00 00 00       	mov    $0x4,%eax
  803493:	e8 f7 fe ff ff       	call   80338f <nsipc>
}
  803498:	c9                   	leave  
  803499:	c3                   	ret    

0080349a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80349a:	55                   	push   %ebp
  80349b:	89 e5                	mov    %esp,%ebp
  80349d:	53                   	push   %ebx
  80349e:	83 ec 08             	sub    $0x8,%esp
  8034a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8034a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8034a7:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8034ac:	53                   	push   %ebx
  8034ad:	ff 75 0c             	pushl  0xc(%ebp)
  8034b0:	68 04 c0 80 00       	push   $0x80c004
  8034b5:	e8 69 ee ff ff       	call   802323 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8034ba:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  8034c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8034c5:	e8 c5 fe ff ff       	call   80338f <nsipc>
}
  8034ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034cd:	c9                   	leave  
  8034ce:	c3                   	ret    

008034cf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8034cf:	55                   	push   %ebp
  8034d0:	89 e5                	mov    %esp,%ebp
  8034d2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8034d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8034d8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  8034dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034e0:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  8034e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8034ea:	e8 a0 fe ff ff       	call   80338f <nsipc>
}
  8034ef:	c9                   	leave  
  8034f0:	c3                   	ret    

008034f1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8034f1:	55                   	push   %ebp
  8034f2:	89 e5                	mov    %esp,%ebp
  8034f4:	56                   	push   %esi
  8034f5:	53                   	push   %ebx
  8034f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8034f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8034fc:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  803501:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803507:	8b 45 14             	mov    0x14(%ebp),%eax
  80350a:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80350f:	b8 07 00 00 00       	mov    $0x7,%eax
  803514:	e8 76 fe ff ff       	call   80338f <nsipc>
  803519:	89 c3                	mov    %eax,%ebx
  80351b:	85 c0                	test   %eax,%eax
  80351d:	78 35                	js     803554 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80351f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803524:	7f 04                	jg     80352a <nsipc_recv+0x39>
  803526:	39 c6                	cmp    %eax,%esi
  803528:	7d 16                	jge    803540 <nsipc_recv+0x4f>
  80352a:	68 42 47 80 00       	push   $0x804742
  80352f:	68 9d 3d 80 00       	push   $0x803d9d
  803534:	6a 62                	push   $0x62
  803536:	68 57 47 80 00       	push   $0x804757
  80353b:	e8 f3 e5 ff ff       	call   801b33 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803540:	83 ec 04             	sub    $0x4,%esp
  803543:	50                   	push   %eax
  803544:	68 00 c0 80 00       	push   $0x80c000
  803549:	ff 75 0c             	pushl  0xc(%ebp)
  80354c:	e8 d2 ed ff ff       	call   802323 <memmove>
  803551:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803554:	89 d8                	mov    %ebx,%eax
  803556:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803559:	5b                   	pop    %ebx
  80355a:	5e                   	pop    %esi
  80355b:	5d                   	pop    %ebp
  80355c:	c3                   	ret    

0080355d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80355d:	55                   	push   %ebp
  80355e:	89 e5                	mov    %esp,%ebp
  803560:	53                   	push   %ebx
  803561:	83 ec 04             	sub    $0x4,%esp
  803564:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803567:	8b 45 08             	mov    0x8(%ebp),%eax
  80356a:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  80356f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803575:	7e 16                	jle    80358d <nsipc_send+0x30>
  803577:	68 63 47 80 00       	push   $0x804763
  80357c:	68 9d 3d 80 00       	push   $0x803d9d
  803581:	6a 6d                	push   $0x6d
  803583:	68 57 47 80 00       	push   $0x804757
  803588:	e8 a6 e5 ff ff       	call   801b33 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80358d:	83 ec 04             	sub    $0x4,%esp
  803590:	53                   	push   %ebx
  803591:	ff 75 0c             	pushl  0xc(%ebp)
  803594:	68 0c c0 80 00       	push   $0x80c00c
  803599:	e8 85 ed ff ff       	call   802323 <memmove>
	nsipcbuf.send.req_size = size;
  80359e:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  8035a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8035a7:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  8035ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8035b1:	e8 d9 fd ff ff       	call   80338f <nsipc>
}
  8035b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035b9:	c9                   	leave  
  8035ba:	c3                   	ret    

008035bb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8035bb:	55                   	push   %ebp
  8035bc:	89 e5                	mov    %esp,%ebp
  8035be:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8035c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8035c4:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  8035c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035cc:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  8035d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8035d4:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  8035d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8035de:	e8 ac fd ff ff       	call   80338f <nsipc>
}
  8035e3:	c9                   	leave  
  8035e4:	c3                   	ret    

008035e5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8035e5:	55                   	push   %ebp
  8035e6:	89 e5                	mov    %esp,%ebp
  8035e8:	56                   	push   %esi
  8035e9:	53                   	push   %ebx
  8035ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8035ed:	83 ec 0c             	sub    $0xc,%esp
  8035f0:	ff 75 08             	pushl  0x8(%ebp)
  8035f3:	e8 5d f3 ff ff       	call   802955 <fd2data>
  8035f8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8035fa:	83 c4 08             	add    $0x8,%esp
  8035fd:	68 6f 47 80 00       	push   $0x80476f
  803602:	53                   	push   %ebx
  803603:	e8 89 eb ff ff       	call   802191 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803608:	8b 46 04             	mov    0x4(%esi),%eax
  80360b:	2b 06                	sub    (%esi),%eax
  80360d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803613:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80361a:	00 00 00 
	stat->st_dev = &devpipe;
  80361d:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  803624:	90 80 00 
	return 0;
}
  803627:	b8 00 00 00 00       	mov    $0x0,%eax
  80362c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80362f:	5b                   	pop    %ebx
  803630:	5e                   	pop    %esi
  803631:	5d                   	pop    %ebp
  803632:	c3                   	ret    

00803633 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803633:	55                   	push   %ebp
  803634:	89 e5                	mov    %esp,%ebp
  803636:	53                   	push   %ebx
  803637:	83 ec 0c             	sub    $0xc,%esp
  80363a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80363d:	53                   	push   %ebx
  80363e:	6a 00                	push   $0x0
  803640:	e8 d4 ef ff ff       	call   802619 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803645:	89 1c 24             	mov    %ebx,(%esp)
  803648:	e8 08 f3 ff ff       	call   802955 <fd2data>
  80364d:	83 c4 08             	add    $0x8,%esp
  803650:	50                   	push   %eax
  803651:	6a 00                	push   $0x0
  803653:	e8 c1 ef ff ff       	call   802619 <sys_page_unmap>
}
  803658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80365b:	c9                   	leave  
  80365c:	c3                   	ret    

0080365d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80365d:	55                   	push   %ebp
  80365e:	89 e5                	mov    %esp,%ebp
  803660:	57                   	push   %edi
  803661:	56                   	push   %esi
  803662:	53                   	push   %ebx
  803663:	83 ec 1c             	sub    $0x1c,%esp
  803666:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803669:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80366b:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803670:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  803673:	83 ec 0c             	sub    $0xc,%esp
  803676:	ff 75 e0             	pushl  -0x20(%ebp)
  803679:	e8 c5 fa ff ff       	call   803143 <pageref>
  80367e:	89 c3                	mov    %eax,%ebx
  803680:	89 3c 24             	mov    %edi,(%esp)
  803683:	e8 bb fa ff ff       	call   803143 <pageref>
  803688:	83 c4 10             	add    $0x10,%esp
  80368b:	39 c3                	cmp    %eax,%ebx
  80368d:	0f 94 c1             	sete   %cl
  803690:	0f b6 c9             	movzbl %cl,%ecx
  803693:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803696:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  80369c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80369f:	39 ce                	cmp    %ecx,%esi
  8036a1:	74 1b                	je     8036be <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8036a3:	39 c3                	cmp    %eax,%ebx
  8036a5:	75 c4                	jne    80366b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8036a7:	8b 42 58             	mov    0x58(%edx),%eax
  8036aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8036ad:	50                   	push   %eax
  8036ae:	56                   	push   %esi
  8036af:	68 76 47 80 00       	push   $0x804776
  8036b4:	e8 53 e5 ff ff       	call   801c0c <cprintf>
  8036b9:	83 c4 10             	add    $0x10,%esp
  8036bc:	eb ad                	jmp    80366b <_pipeisclosed+0xe>
	}
}
  8036be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8036c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036c4:	5b                   	pop    %ebx
  8036c5:	5e                   	pop    %esi
  8036c6:	5f                   	pop    %edi
  8036c7:	5d                   	pop    %ebp
  8036c8:	c3                   	ret    

008036c9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8036c9:	55                   	push   %ebp
  8036ca:	89 e5                	mov    %esp,%ebp
  8036cc:	57                   	push   %edi
  8036cd:	56                   	push   %esi
  8036ce:	53                   	push   %ebx
  8036cf:	83 ec 28             	sub    $0x28,%esp
  8036d2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8036d5:	56                   	push   %esi
  8036d6:	e8 7a f2 ff ff       	call   802955 <fd2data>
  8036db:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036dd:	83 c4 10             	add    $0x10,%esp
  8036e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8036e5:	eb 4b                	jmp    803732 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8036e7:	89 da                	mov    %ebx,%edx
  8036e9:	89 f0                	mov    %esi,%eax
  8036eb:	e8 6d ff ff ff       	call   80365d <_pipeisclosed>
  8036f0:	85 c0                	test   %eax,%eax
  8036f2:	75 48                	jne    80373c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8036f4:	e8 7c ee ff ff       	call   802575 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8036f9:	8b 43 04             	mov    0x4(%ebx),%eax
  8036fc:	8b 0b                	mov    (%ebx),%ecx
  8036fe:	8d 51 20             	lea    0x20(%ecx),%edx
  803701:	39 d0                	cmp    %edx,%eax
  803703:	73 e2                	jae    8036e7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803708:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80370c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80370f:	89 c2                	mov    %eax,%edx
  803711:	c1 fa 1f             	sar    $0x1f,%edx
  803714:	89 d1                	mov    %edx,%ecx
  803716:	c1 e9 1b             	shr    $0x1b,%ecx
  803719:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80371c:	83 e2 1f             	and    $0x1f,%edx
  80371f:	29 ca                	sub    %ecx,%edx
  803721:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803725:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803729:	83 c0 01             	add    $0x1,%eax
  80372c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80372f:	83 c7 01             	add    $0x1,%edi
  803732:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803735:	75 c2                	jne    8036f9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803737:	8b 45 10             	mov    0x10(%ebp),%eax
  80373a:	eb 05                	jmp    803741 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80373c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803744:	5b                   	pop    %ebx
  803745:	5e                   	pop    %esi
  803746:	5f                   	pop    %edi
  803747:	5d                   	pop    %ebp
  803748:	c3                   	ret    

00803749 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803749:	55                   	push   %ebp
  80374a:	89 e5                	mov    %esp,%ebp
  80374c:	57                   	push   %edi
  80374d:	56                   	push   %esi
  80374e:	53                   	push   %ebx
  80374f:	83 ec 18             	sub    $0x18,%esp
  803752:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803755:	57                   	push   %edi
  803756:	e8 fa f1 ff ff       	call   802955 <fd2data>
  80375b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80375d:	83 c4 10             	add    $0x10,%esp
  803760:	bb 00 00 00 00       	mov    $0x0,%ebx
  803765:	eb 3d                	jmp    8037a4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803767:	85 db                	test   %ebx,%ebx
  803769:	74 04                	je     80376f <devpipe_read+0x26>
				return i;
  80376b:	89 d8                	mov    %ebx,%eax
  80376d:	eb 44                	jmp    8037b3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80376f:	89 f2                	mov    %esi,%edx
  803771:	89 f8                	mov    %edi,%eax
  803773:	e8 e5 fe ff ff       	call   80365d <_pipeisclosed>
  803778:	85 c0                	test   %eax,%eax
  80377a:	75 32                	jne    8037ae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80377c:	e8 f4 ed ff ff       	call   802575 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803781:	8b 06                	mov    (%esi),%eax
  803783:	3b 46 04             	cmp    0x4(%esi),%eax
  803786:	74 df                	je     803767 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803788:	99                   	cltd   
  803789:	c1 ea 1b             	shr    $0x1b,%edx
  80378c:	01 d0                	add    %edx,%eax
  80378e:	83 e0 1f             	and    $0x1f,%eax
  803791:	29 d0                	sub    %edx,%eax
  803793:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80379b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80379e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8037a1:	83 c3 01             	add    $0x1,%ebx
  8037a4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8037a7:	75 d8                	jne    803781 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8037a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8037ac:	eb 05                	jmp    8037b3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8037ae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8037b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8037b6:	5b                   	pop    %ebx
  8037b7:	5e                   	pop    %esi
  8037b8:	5f                   	pop    %edi
  8037b9:	5d                   	pop    %ebp
  8037ba:	c3                   	ret    

008037bb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8037bb:	55                   	push   %ebp
  8037bc:	89 e5                	mov    %esp,%ebp
  8037be:	56                   	push   %esi
  8037bf:	53                   	push   %ebx
  8037c0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8037c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037c6:	50                   	push   %eax
  8037c7:	e8 a0 f1 ff ff       	call   80296c <fd_alloc>
  8037cc:	83 c4 10             	add    $0x10,%esp
  8037cf:	89 c2                	mov    %eax,%edx
  8037d1:	85 c0                	test   %eax,%eax
  8037d3:	0f 88 2c 01 00 00    	js     803905 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037d9:	83 ec 04             	sub    $0x4,%esp
  8037dc:	68 07 04 00 00       	push   $0x407
  8037e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8037e4:	6a 00                	push   $0x0
  8037e6:	e8 a9 ed ff ff       	call   802594 <sys_page_alloc>
  8037eb:	83 c4 10             	add    $0x10,%esp
  8037ee:	89 c2                	mov    %eax,%edx
  8037f0:	85 c0                	test   %eax,%eax
  8037f2:	0f 88 0d 01 00 00    	js     803905 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8037f8:	83 ec 0c             	sub    $0xc,%esp
  8037fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8037fe:	50                   	push   %eax
  8037ff:	e8 68 f1 ff ff       	call   80296c <fd_alloc>
  803804:	89 c3                	mov    %eax,%ebx
  803806:	83 c4 10             	add    $0x10,%esp
  803809:	85 c0                	test   %eax,%eax
  80380b:	0f 88 e2 00 00 00    	js     8038f3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803811:	83 ec 04             	sub    $0x4,%esp
  803814:	68 07 04 00 00       	push   $0x407
  803819:	ff 75 f0             	pushl  -0x10(%ebp)
  80381c:	6a 00                	push   $0x0
  80381e:	e8 71 ed ff ff       	call   802594 <sys_page_alloc>
  803823:	89 c3                	mov    %eax,%ebx
  803825:	83 c4 10             	add    $0x10,%esp
  803828:	85 c0                	test   %eax,%eax
  80382a:	0f 88 c3 00 00 00    	js     8038f3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803830:	83 ec 0c             	sub    $0xc,%esp
  803833:	ff 75 f4             	pushl  -0xc(%ebp)
  803836:	e8 1a f1 ff ff       	call   802955 <fd2data>
  80383b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80383d:	83 c4 0c             	add    $0xc,%esp
  803840:	68 07 04 00 00       	push   $0x407
  803845:	50                   	push   %eax
  803846:	6a 00                	push   $0x0
  803848:	e8 47 ed ff ff       	call   802594 <sys_page_alloc>
  80384d:	89 c3                	mov    %eax,%ebx
  80384f:	83 c4 10             	add    $0x10,%esp
  803852:	85 c0                	test   %eax,%eax
  803854:	0f 88 89 00 00 00    	js     8038e3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80385a:	83 ec 0c             	sub    $0xc,%esp
  80385d:	ff 75 f0             	pushl  -0x10(%ebp)
  803860:	e8 f0 f0 ff ff       	call   802955 <fd2data>
  803865:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80386c:	50                   	push   %eax
  80386d:	6a 00                	push   $0x0
  80386f:	56                   	push   %esi
  803870:	6a 00                	push   $0x0
  803872:	e8 60 ed ff ff       	call   8025d7 <sys_page_map>
  803877:	89 c3                	mov    %eax,%ebx
  803879:	83 c4 20             	add    $0x20,%esp
  80387c:	85 c0                	test   %eax,%eax
  80387e:	78 55                	js     8038d5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803880:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803889:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80388b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80388e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803895:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80389b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80389e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8038a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8038a3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8038aa:	83 ec 0c             	sub    $0xc,%esp
  8038ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8038b0:	e8 90 f0 ff ff       	call   802945 <fd2num>
  8038b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038b8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8038ba:	83 c4 04             	add    $0x4,%esp
  8038bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8038c0:	e8 80 f0 ff ff       	call   802945 <fd2num>
  8038c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8038c8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8038cb:	83 c4 10             	add    $0x10,%esp
  8038ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8038d3:	eb 30                	jmp    803905 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8038d5:	83 ec 08             	sub    $0x8,%esp
  8038d8:	56                   	push   %esi
  8038d9:	6a 00                	push   $0x0
  8038db:	e8 39 ed ff ff       	call   802619 <sys_page_unmap>
  8038e0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8038e3:	83 ec 08             	sub    $0x8,%esp
  8038e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8038e9:	6a 00                	push   $0x0
  8038eb:	e8 29 ed ff ff       	call   802619 <sys_page_unmap>
  8038f0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8038f3:	83 ec 08             	sub    $0x8,%esp
  8038f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8038f9:	6a 00                	push   $0x0
  8038fb:	e8 19 ed ff ff       	call   802619 <sys_page_unmap>
  803900:	83 c4 10             	add    $0x10,%esp
  803903:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803905:	89 d0                	mov    %edx,%eax
  803907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80390a:	5b                   	pop    %ebx
  80390b:	5e                   	pop    %esi
  80390c:	5d                   	pop    %ebp
  80390d:	c3                   	ret    

0080390e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80390e:	55                   	push   %ebp
  80390f:	89 e5                	mov    %esp,%ebp
  803911:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803917:	50                   	push   %eax
  803918:	ff 75 08             	pushl  0x8(%ebp)
  80391b:	e8 9b f0 ff ff       	call   8029bb <fd_lookup>
  803920:	83 c4 10             	add    $0x10,%esp
  803923:	85 c0                	test   %eax,%eax
  803925:	78 18                	js     80393f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803927:	83 ec 0c             	sub    $0xc,%esp
  80392a:	ff 75 f4             	pushl  -0xc(%ebp)
  80392d:	e8 23 f0 ff ff       	call   802955 <fd2data>
	return _pipeisclosed(fd, p);
  803932:	89 c2                	mov    %eax,%edx
  803934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803937:	e8 21 fd ff ff       	call   80365d <_pipeisclosed>
  80393c:	83 c4 10             	add    $0x10,%esp
}
  80393f:	c9                   	leave  
  803940:	c3                   	ret    

00803941 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803941:	55                   	push   %ebp
  803942:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803944:	b8 00 00 00 00       	mov    $0x0,%eax
  803949:	5d                   	pop    %ebp
  80394a:	c3                   	ret    

0080394b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80394b:	55                   	push   %ebp
  80394c:	89 e5                	mov    %esp,%ebp
  80394e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803951:	68 8e 47 80 00       	push   $0x80478e
  803956:	ff 75 0c             	pushl  0xc(%ebp)
  803959:	e8 33 e8 ff ff       	call   802191 <strcpy>
	return 0;
}
  80395e:	b8 00 00 00 00       	mov    $0x0,%eax
  803963:	c9                   	leave  
  803964:	c3                   	ret    

00803965 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803965:	55                   	push   %ebp
  803966:	89 e5                	mov    %esp,%ebp
  803968:	57                   	push   %edi
  803969:	56                   	push   %esi
  80396a:	53                   	push   %ebx
  80396b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803971:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803976:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80397c:	eb 2d                	jmp    8039ab <devcons_write+0x46>
		m = n - tot;
  80397e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803981:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803983:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803986:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80398b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80398e:	83 ec 04             	sub    $0x4,%esp
  803991:	53                   	push   %ebx
  803992:	03 45 0c             	add    0xc(%ebp),%eax
  803995:	50                   	push   %eax
  803996:	57                   	push   %edi
  803997:	e8 87 e9 ff ff       	call   802323 <memmove>
		sys_cputs(buf, m);
  80399c:	83 c4 08             	add    $0x8,%esp
  80399f:	53                   	push   %ebx
  8039a0:	57                   	push   %edi
  8039a1:	e8 32 eb ff ff       	call   8024d8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8039a6:	01 de                	add    %ebx,%esi
  8039a8:	83 c4 10             	add    $0x10,%esp
  8039ab:	89 f0                	mov    %esi,%eax
  8039ad:	3b 75 10             	cmp    0x10(%ebp),%esi
  8039b0:	72 cc                	jb     80397e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8039b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8039b5:	5b                   	pop    %ebx
  8039b6:	5e                   	pop    %esi
  8039b7:	5f                   	pop    %edi
  8039b8:	5d                   	pop    %ebp
  8039b9:	c3                   	ret    

008039ba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8039ba:	55                   	push   %ebp
  8039bb:	89 e5                	mov    %esp,%ebp
  8039bd:	83 ec 08             	sub    $0x8,%esp
  8039c0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8039c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8039c9:	74 2a                	je     8039f5 <devcons_read+0x3b>
  8039cb:	eb 05                	jmp    8039d2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8039cd:	e8 a3 eb ff ff       	call   802575 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8039d2:	e8 1f eb ff ff       	call   8024f6 <sys_cgetc>
  8039d7:	85 c0                	test   %eax,%eax
  8039d9:	74 f2                	je     8039cd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8039db:	85 c0                	test   %eax,%eax
  8039dd:	78 16                	js     8039f5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8039df:	83 f8 04             	cmp    $0x4,%eax
  8039e2:	74 0c                	je     8039f0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8039e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8039e7:	88 02                	mov    %al,(%edx)
	return 1;
  8039e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8039ee:	eb 05                	jmp    8039f5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8039f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8039f5:	c9                   	leave  
  8039f6:	c3                   	ret    

008039f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8039f7:	55                   	push   %ebp
  8039f8:	89 e5                	mov    %esp,%ebp
  8039fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8039fd:	8b 45 08             	mov    0x8(%ebp),%eax
  803a00:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803a03:	6a 01                	push   $0x1
  803a05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a08:	50                   	push   %eax
  803a09:	e8 ca ea ff ff       	call   8024d8 <sys_cputs>
}
  803a0e:	83 c4 10             	add    $0x10,%esp
  803a11:	c9                   	leave  
  803a12:	c3                   	ret    

00803a13 <getchar>:

int
getchar(void)
{
  803a13:	55                   	push   %ebp
  803a14:	89 e5                	mov    %esp,%ebp
  803a16:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803a19:	6a 01                	push   $0x1
  803a1b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803a1e:	50                   	push   %eax
  803a1f:	6a 00                	push   $0x0
  803a21:	e8 fb f1 ff ff       	call   802c21 <read>
	if (r < 0)
  803a26:	83 c4 10             	add    $0x10,%esp
  803a29:	85 c0                	test   %eax,%eax
  803a2b:	78 0f                	js     803a3c <getchar+0x29>
		return r;
	if (r < 1)
  803a2d:	85 c0                	test   %eax,%eax
  803a2f:	7e 06                	jle    803a37 <getchar+0x24>
		return -E_EOF;
	return c;
  803a31:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803a35:	eb 05                	jmp    803a3c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803a37:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803a3c:	c9                   	leave  
  803a3d:	c3                   	ret    

00803a3e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803a3e:	55                   	push   %ebp
  803a3f:	89 e5                	mov    %esp,%ebp
  803a41:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803a44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a47:	50                   	push   %eax
  803a48:	ff 75 08             	pushl  0x8(%ebp)
  803a4b:	e8 6b ef ff ff       	call   8029bb <fd_lookup>
  803a50:	83 c4 10             	add    $0x10,%esp
  803a53:	85 c0                	test   %eax,%eax
  803a55:	78 11                	js     803a68 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a5a:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803a60:	39 10                	cmp    %edx,(%eax)
  803a62:	0f 94 c0             	sete   %al
  803a65:	0f b6 c0             	movzbl %al,%eax
}
  803a68:	c9                   	leave  
  803a69:	c3                   	ret    

00803a6a <opencons>:

int
opencons(void)
{
  803a6a:	55                   	push   %ebp
  803a6b:	89 e5                	mov    %esp,%ebp
  803a6d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803a73:	50                   	push   %eax
  803a74:	e8 f3 ee ff ff       	call   80296c <fd_alloc>
  803a79:	83 c4 10             	add    $0x10,%esp
		return r;
  803a7c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803a7e:	85 c0                	test   %eax,%eax
  803a80:	78 3e                	js     803ac0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a82:	83 ec 04             	sub    $0x4,%esp
  803a85:	68 07 04 00 00       	push   $0x407
  803a8a:	ff 75 f4             	pushl  -0xc(%ebp)
  803a8d:	6a 00                	push   $0x0
  803a8f:	e8 00 eb ff ff       	call   802594 <sys_page_alloc>
  803a94:	83 c4 10             	add    $0x10,%esp
		return r;
  803a97:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a99:	85 c0                	test   %eax,%eax
  803a9b:	78 23                	js     803ac0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803a9d:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803aa6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803aab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803ab2:	83 ec 0c             	sub    $0xc,%esp
  803ab5:	50                   	push   %eax
  803ab6:	e8 8a ee ff ff       	call   802945 <fd2num>
  803abb:	89 c2                	mov    %eax,%edx
  803abd:	83 c4 10             	add    $0x10,%esp
}
  803ac0:	89 d0                	mov    %edx,%eax
  803ac2:	c9                   	leave  
  803ac3:	c3                   	ret    
  803ac4:	66 90                	xchg   %ax,%ax
  803ac6:	66 90                	xchg   %ax,%ax
  803ac8:	66 90                	xchg   %ax,%ax
  803aca:	66 90                	xchg   %ax,%ax
  803acc:	66 90                	xchg   %ax,%ax
  803ace:	66 90                	xchg   %ax,%ax

00803ad0 <__udivdi3>:
  803ad0:	55                   	push   %ebp
  803ad1:	57                   	push   %edi
  803ad2:	56                   	push   %esi
  803ad3:	53                   	push   %ebx
  803ad4:	83 ec 1c             	sub    $0x1c,%esp
  803ad7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803adb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803adf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803ae3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803ae7:	85 f6                	test   %esi,%esi
  803ae9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803aed:	89 ca                	mov    %ecx,%edx
  803aef:	89 f8                	mov    %edi,%eax
  803af1:	75 3d                	jne    803b30 <__udivdi3+0x60>
  803af3:	39 cf                	cmp    %ecx,%edi
  803af5:	0f 87 c5 00 00 00    	ja     803bc0 <__udivdi3+0xf0>
  803afb:	85 ff                	test   %edi,%edi
  803afd:	89 fd                	mov    %edi,%ebp
  803aff:	75 0b                	jne    803b0c <__udivdi3+0x3c>
  803b01:	b8 01 00 00 00       	mov    $0x1,%eax
  803b06:	31 d2                	xor    %edx,%edx
  803b08:	f7 f7                	div    %edi
  803b0a:	89 c5                	mov    %eax,%ebp
  803b0c:	89 c8                	mov    %ecx,%eax
  803b0e:	31 d2                	xor    %edx,%edx
  803b10:	f7 f5                	div    %ebp
  803b12:	89 c1                	mov    %eax,%ecx
  803b14:	89 d8                	mov    %ebx,%eax
  803b16:	89 cf                	mov    %ecx,%edi
  803b18:	f7 f5                	div    %ebp
  803b1a:	89 c3                	mov    %eax,%ebx
  803b1c:	89 d8                	mov    %ebx,%eax
  803b1e:	89 fa                	mov    %edi,%edx
  803b20:	83 c4 1c             	add    $0x1c,%esp
  803b23:	5b                   	pop    %ebx
  803b24:	5e                   	pop    %esi
  803b25:	5f                   	pop    %edi
  803b26:	5d                   	pop    %ebp
  803b27:	c3                   	ret    
  803b28:	90                   	nop
  803b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b30:	39 ce                	cmp    %ecx,%esi
  803b32:	77 74                	ja     803ba8 <__udivdi3+0xd8>
  803b34:	0f bd fe             	bsr    %esi,%edi
  803b37:	83 f7 1f             	xor    $0x1f,%edi
  803b3a:	0f 84 98 00 00 00    	je     803bd8 <__udivdi3+0x108>
  803b40:	bb 20 00 00 00       	mov    $0x20,%ebx
  803b45:	89 f9                	mov    %edi,%ecx
  803b47:	89 c5                	mov    %eax,%ebp
  803b49:	29 fb                	sub    %edi,%ebx
  803b4b:	d3 e6                	shl    %cl,%esi
  803b4d:	89 d9                	mov    %ebx,%ecx
  803b4f:	d3 ed                	shr    %cl,%ebp
  803b51:	89 f9                	mov    %edi,%ecx
  803b53:	d3 e0                	shl    %cl,%eax
  803b55:	09 ee                	or     %ebp,%esi
  803b57:	89 d9                	mov    %ebx,%ecx
  803b59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803b5d:	89 d5                	mov    %edx,%ebp
  803b5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803b63:	d3 ed                	shr    %cl,%ebp
  803b65:	89 f9                	mov    %edi,%ecx
  803b67:	d3 e2                	shl    %cl,%edx
  803b69:	89 d9                	mov    %ebx,%ecx
  803b6b:	d3 e8                	shr    %cl,%eax
  803b6d:	09 c2                	or     %eax,%edx
  803b6f:	89 d0                	mov    %edx,%eax
  803b71:	89 ea                	mov    %ebp,%edx
  803b73:	f7 f6                	div    %esi
  803b75:	89 d5                	mov    %edx,%ebp
  803b77:	89 c3                	mov    %eax,%ebx
  803b79:	f7 64 24 0c          	mull   0xc(%esp)
  803b7d:	39 d5                	cmp    %edx,%ebp
  803b7f:	72 10                	jb     803b91 <__udivdi3+0xc1>
  803b81:	8b 74 24 08          	mov    0x8(%esp),%esi
  803b85:	89 f9                	mov    %edi,%ecx
  803b87:	d3 e6                	shl    %cl,%esi
  803b89:	39 c6                	cmp    %eax,%esi
  803b8b:	73 07                	jae    803b94 <__udivdi3+0xc4>
  803b8d:	39 d5                	cmp    %edx,%ebp
  803b8f:	75 03                	jne    803b94 <__udivdi3+0xc4>
  803b91:	83 eb 01             	sub    $0x1,%ebx
  803b94:	31 ff                	xor    %edi,%edi
  803b96:	89 d8                	mov    %ebx,%eax
  803b98:	89 fa                	mov    %edi,%edx
  803b9a:	83 c4 1c             	add    $0x1c,%esp
  803b9d:	5b                   	pop    %ebx
  803b9e:	5e                   	pop    %esi
  803b9f:	5f                   	pop    %edi
  803ba0:	5d                   	pop    %ebp
  803ba1:	c3                   	ret    
  803ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ba8:	31 ff                	xor    %edi,%edi
  803baa:	31 db                	xor    %ebx,%ebx
  803bac:	89 d8                	mov    %ebx,%eax
  803bae:	89 fa                	mov    %edi,%edx
  803bb0:	83 c4 1c             	add    $0x1c,%esp
  803bb3:	5b                   	pop    %ebx
  803bb4:	5e                   	pop    %esi
  803bb5:	5f                   	pop    %edi
  803bb6:	5d                   	pop    %ebp
  803bb7:	c3                   	ret    
  803bb8:	90                   	nop
  803bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803bc0:	89 d8                	mov    %ebx,%eax
  803bc2:	f7 f7                	div    %edi
  803bc4:	31 ff                	xor    %edi,%edi
  803bc6:	89 c3                	mov    %eax,%ebx
  803bc8:	89 d8                	mov    %ebx,%eax
  803bca:	89 fa                	mov    %edi,%edx
  803bcc:	83 c4 1c             	add    $0x1c,%esp
  803bcf:	5b                   	pop    %ebx
  803bd0:	5e                   	pop    %esi
  803bd1:	5f                   	pop    %edi
  803bd2:	5d                   	pop    %ebp
  803bd3:	c3                   	ret    
  803bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803bd8:	39 ce                	cmp    %ecx,%esi
  803bda:	72 0c                	jb     803be8 <__udivdi3+0x118>
  803bdc:	31 db                	xor    %ebx,%ebx
  803bde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803be2:	0f 87 34 ff ff ff    	ja     803b1c <__udivdi3+0x4c>
  803be8:	bb 01 00 00 00       	mov    $0x1,%ebx
  803bed:	e9 2a ff ff ff       	jmp    803b1c <__udivdi3+0x4c>
  803bf2:	66 90                	xchg   %ax,%ax
  803bf4:	66 90                	xchg   %ax,%ax
  803bf6:	66 90                	xchg   %ax,%ax
  803bf8:	66 90                	xchg   %ax,%ax
  803bfa:	66 90                	xchg   %ax,%ax
  803bfc:	66 90                	xchg   %ax,%ax
  803bfe:	66 90                	xchg   %ax,%ax

00803c00 <__umoddi3>:
  803c00:	55                   	push   %ebp
  803c01:	57                   	push   %edi
  803c02:	56                   	push   %esi
  803c03:	53                   	push   %ebx
  803c04:	83 ec 1c             	sub    $0x1c,%esp
  803c07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803c0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803c0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803c13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803c17:	85 d2                	test   %edx,%edx
  803c19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803c21:	89 f3                	mov    %esi,%ebx
  803c23:	89 3c 24             	mov    %edi,(%esp)
  803c26:	89 74 24 04          	mov    %esi,0x4(%esp)
  803c2a:	75 1c                	jne    803c48 <__umoddi3+0x48>
  803c2c:	39 f7                	cmp    %esi,%edi
  803c2e:	76 50                	jbe    803c80 <__umoddi3+0x80>
  803c30:	89 c8                	mov    %ecx,%eax
  803c32:	89 f2                	mov    %esi,%edx
  803c34:	f7 f7                	div    %edi
  803c36:	89 d0                	mov    %edx,%eax
  803c38:	31 d2                	xor    %edx,%edx
  803c3a:	83 c4 1c             	add    $0x1c,%esp
  803c3d:	5b                   	pop    %ebx
  803c3e:	5e                   	pop    %esi
  803c3f:	5f                   	pop    %edi
  803c40:	5d                   	pop    %ebp
  803c41:	c3                   	ret    
  803c42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803c48:	39 f2                	cmp    %esi,%edx
  803c4a:	89 d0                	mov    %edx,%eax
  803c4c:	77 52                	ja     803ca0 <__umoddi3+0xa0>
  803c4e:	0f bd ea             	bsr    %edx,%ebp
  803c51:	83 f5 1f             	xor    $0x1f,%ebp
  803c54:	75 5a                	jne    803cb0 <__umoddi3+0xb0>
  803c56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803c5a:	0f 82 e0 00 00 00    	jb     803d40 <__umoddi3+0x140>
  803c60:	39 0c 24             	cmp    %ecx,(%esp)
  803c63:	0f 86 d7 00 00 00    	jbe    803d40 <__umoddi3+0x140>
  803c69:	8b 44 24 08          	mov    0x8(%esp),%eax
  803c6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803c71:	83 c4 1c             	add    $0x1c,%esp
  803c74:	5b                   	pop    %ebx
  803c75:	5e                   	pop    %esi
  803c76:	5f                   	pop    %edi
  803c77:	5d                   	pop    %ebp
  803c78:	c3                   	ret    
  803c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803c80:	85 ff                	test   %edi,%edi
  803c82:	89 fd                	mov    %edi,%ebp
  803c84:	75 0b                	jne    803c91 <__umoddi3+0x91>
  803c86:	b8 01 00 00 00       	mov    $0x1,%eax
  803c8b:	31 d2                	xor    %edx,%edx
  803c8d:	f7 f7                	div    %edi
  803c8f:	89 c5                	mov    %eax,%ebp
  803c91:	89 f0                	mov    %esi,%eax
  803c93:	31 d2                	xor    %edx,%edx
  803c95:	f7 f5                	div    %ebp
  803c97:	89 c8                	mov    %ecx,%eax
  803c99:	f7 f5                	div    %ebp
  803c9b:	89 d0                	mov    %edx,%eax
  803c9d:	eb 99                	jmp    803c38 <__umoddi3+0x38>
  803c9f:	90                   	nop
  803ca0:	89 c8                	mov    %ecx,%eax
  803ca2:	89 f2                	mov    %esi,%edx
  803ca4:	83 c4 1c             	add    $0x1c,%esp
  803ca7:	5b                   	pop    %ebx
  803ca8:	5e                   	pop    %esi
  803ca9:	5f                   	pop    %edi
  803caa:	5d                   	pop    %ebp
  803cab:	c3                   	ret    
  803cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803cb0:	8b 34 24             	mov    (%esp),%esi
  803cb3:	bf 20 00 00 00       	mov    $0x20,%edi
  803cb8:	89 e9                	mov    %ebp,%ecx
  803cba:	29 ef                	sub    %ebp,%edi
  803cbc:	d3 e0                	shl    %cl,%eax
  803cbe:	89 f9                	mov    %edi,%ecx
  803cc0:	89 f2                	mov    %esi,%edx
  803cc2:	d3 ea                	shr    %cl,%edx
  803cc4:	89 e9                	mov    %ebp,%ecx
  803cc6:	09 c2                	or     %eax,%edx
  803cc8:	89 d8                	mov    %ebx,%eax
  803cca:	89 14 24             	mov    %edx,(%esp)
  803ccd:	89 f2                	mov    %esi,%edx
  803ccf:	d3 e2                	shl    %cl,%edx
  803cd1:	89 f9                	mov    %edi,%ecx
  803cd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  803cd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803cdb:	d3 e8                	shr    %cl,%eax
  803cdd:	89 e9                	mov    %ebp,%ecx
  803cdf:	89 c6                	mov    %eax,%esi
  803ce1:	d3 e3                	shl    %cl,%ebx
  803ce3:	89 f9                	mov    %edi,%ecx
  803ce5:	89 d0                	mov    %edx,%eax
  803ce7:	d3 e8                	shr    %cl,%eax
  803ce9:	89 e9                	mov    %ebp,%ecx
  803ceb:	09 d8                	or     %ebx,%eax
  803ced:	89 d3                	mov    %edx,%ebx
  803cef:	89 f2                	mov    %esi,%edx
  803cf1:	f7 34 24             	divl   (%esp)
  803cf4:	89 d6                	mov    %edx,%esi
  803cf6:	d3 e3                	shl    %cl,%ebx
  803cf8:	f7 64 24 04          	mull   0x4(%esp)
  803cfc:	39 d6                	cmp    %edx,%esi
  803cfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803d02:	89 d1                	mov    %edx,%ecx
  803d04:	89 c3                	mov    %eax,%ebx
  803d06:	72 08                	jb     803d10 <__umoddi3+0x110>
  803d08:	75 11                	jne    803d1b <__umoddi3+0x11b>
  803d0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803d0e:	73 0b                	jae    803d1b <__umoddi3+0x11b>
  803d10:	2b 44 24 04          	sub    0x4(%esp),%eax
  803d14:	1b 14 24             	sbb    (%esp),%edx
  803d17:	89 d1                	mov    %edx,%ecx
  803d19:	89 c3                	mov    %eax,%ebx
  803d1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803d1f:	29 da                	sub    %ebx,%edx
  803d21:	19 ce                	sbb    %ecx,%esi
  803d23:	89 f9                	mov    %edi,%ecx
  803d25:	89 f0                	mov    %esi,%eax
  803d27:	d3 e0                	shl    %cl,%eax
  803d29:	89 e9                	mov    %ebp,%ecx
  803d2b:	d3 ea                	shr    %cl,%edx
  803d2d:	89 e9                	mov    %ebp,%ecx
  803d2f:	d3 ee                	shr    %cl,%esi
  803d31:	09 d0                	or     %edx,%eax
  803d33:	89 f2                	mov    %esi,%edx
  803d35:	83 c4 1c             	add    $0x1c,%esp
  803d38:	5b                   	pop    %ebx
  803d39:	5e                   	pop    %esi
  803d3a:	5f                   	pop    %edi
  803d3b:	5d                   	pop    %ebp
  803d3c:	c3                   	ret    
  803d3d:	8d 76 00             	lea    0x0(%esi),%esi
  803d40:	29 f9                	sub    %edi,%ecx
  803d42:	19 d6                	sbb    %edx,%esi
  803d44:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803d4c:	e9 18 ff ff ff       	jmp    803c69 <__umoddi3+0x69>
