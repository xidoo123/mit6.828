
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 a6 04 00 00       	call   800545 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 58 22 80 00       	push   $0x802258
  800118:	6a 23                	push   $0x23
  80011a:	68 75 22 80 00       	push   $0x802275
  80011f:	e8 9a 13 00 00       	call   8014be <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 58 22 80 00       	push   $0x802258
  800199:	6a 23                	push   $0x23
  80019b:	68 75 22 80 00       	push   $0x802275
  8001a0:	e8 19 13 00 00       	call   8014be <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 58 22 80 00       	push   $0x802258
  8001db:	6a 23                	push   $0x23
  8001dd:	68 75 22 80 00       	push   $0x802275
  8001e2:	e8 d7 12 00 00       	call   8014be <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 58 22 80 00       	push   $0x802258
  80021d:	6a 23                	push   $0x23
  80021f:	68 75 22 80 00       	push   $0x802275
  800224:	e8 95 12 00 00       	call   8014be <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 58 22 80 00       	push   $0x802258
  80025f:	6a 23                	push   $0x23
  800261:	68 75 22 80 00       	push   $0x802275
  800266:	e8 53 12 00 00       	call   8014be <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 58 22 80 00       	push   $0x802258
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 75 22 80 00       	push   $0x802275
  8002a8:	e8 11 12 00 00       	call   8014be <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 58 22 80 00       	push   $0x802258
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 75 22 80 00       	push   $0x802275
  8002ea:	e8 cf 11 00 00       	call   8014be <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 58 22 80 00       	push   $0x802258
  800347:	6a 23                	push   $0x23
  800349:	68 75 22 80 00       	push   $0x802275
  80034e:	e8 6b 11 00 00       	call   8014be <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	c1 e8 0c             	shr    $0xc,%eax
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	05 00 00 00 30       	add    $0x30000000,%eax
  800395:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80039a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ac:	89 c2                	mov    %eax,%edx
  8003ae:	c1 ea 16             	shr    $0x16,%edx
  8003b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b8:	f6 c2 01             	test   $0x1,%dl
  8003bb:	74 11                	je     8003ce <fd_alloc+0x2d>
  8003bd:	89 c2                	mov    %eax,%edx
  8003bf:	c1 ea 0c             	shr    $0xc,%edx
  8003c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c9:	f6 c2 01             	test   $0x1,%dl
  8003cc:	75 09                	jne    8003d7 <fd_alloc+0x36>
			*fd_store = fd;
  8003ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	eb 17                	jmp    8003ee <fd_alloc+0x4d>
  8003d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e1:	75 c9                	jne    8003ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f6:	83 f8 1f             	cmp    $0x1f,%eax
  8003f9:	77 36                	ja     800431 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fb:	c1 e0 0c             	shl    $0xc,%eax
  8003fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800403:	89 c2                	mov    %eax,%edx
  800405:	c1 ea 16             	shr    $0x16,%edx
  800408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040f:	f6 c2 01             	test   $0x1,%dl
  800412:	74 24                	je     800438 <fd_lookup+0x48>
  800414:	89 c2                	mov    %eax,%edx
  800416:	c1 ea 0c             	shr    $0xc,%edx
  800419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800420:	f6 c2 01             	test   $0x1,%dl
  800423:	74 1a                	je     80043f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 02                	mov    %eax,(%edx)
	return 0;
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb 13                	jmp    800444 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 0c                	jmp    800444 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043d:	eb 05                	jmp    800444 <fd_lookup+0x54>
  80043f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044f:	ba 00 23 80 00       	mov    $0x802300,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	eb 13                	jmp    800469 <dev_lookup+0x23>
  800456:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800459:	39 08                	cmp    %ecx,(%eax)
  80045b:	75 0c                	jne    800469 <dev_lookup+0x23>
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb 2e                	jmp    800497 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 e7                	jne    800456 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046f:	a1 08 40 80 00       	mov    0x804008,%eax
  800474:	8b 40 48             	mov    0x48(%eax),%eax
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	51                   	push   %ecx
  80047b:	50                   	push   %eax
  80047c:	68 84 22 80 00       	push   $0x802284
  800481:	e8 11 11 00 00       	call   801597 <cprintf>
	*dev = 0;
  800486:	8b 45 0c             	mov    0xc(%ebp),%eax
  800489:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800497:	c9                   	leave  
  800498:	c3                   	ret    

00800499 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 10             	sub    $0x10,%esp
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004aa:	50                   	push   %eax
  8004ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004b1:	c1 e8 0c             	shr    $0xc,%eax
  8004b4:	50                   	push   %eax
  8004b5:	e8 36 ff ff ff       	call   8003f0 <fd_lookup>
  8004ba:	83 c4 08             	add    $0x8,%esp
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	78 05                	js     8004c6 <fd_close+0x2d>
	    || fd != fd2)
  8004c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c4:	74 0c                	je     8004d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004c6:	84 db                	test   %bl,%bl
  8004c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cd:	0f 44 c2             	cmove  %edx,%eax
  8004d0:	eb 41                	jmp    800513 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d8:	50                   	push   %eax
  8004d9:	ff 36                	pushl  (%esi)
  8004db:	e8 66 ff ff ff       	call   800446 <dev_lookup>
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	78 1a                	js     800503 <fd_close+0x6a>
		if (dev->dev_close)
  8004e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	74 0b                	je     800503 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f8:	83 ec 0c             	sub    $0xc,%esp
  8004fb:	56                   	push   %esi
  8004fc:	ff d0                	call   *%eax
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	56                   	push   %esi
  800507:	6a 00                	push   $0x0
  800509:	e8 e1 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	89 d8                	mov    %ebx,%eax
}
  800513:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800516:	5b                   	pop    %ebx
  800517:	5e                   	pop    %esi
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 c4 fe ff ff       	call   8003f0 <fd_lookup>
  80052c:	83 c4 08             	add    $0x8,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 10                	js     800543 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	6a 01                	push   $0x1
  800538:	ff 75 f4             	pushl  -0xc(%ebp)
  80053b:	e8 59 ff ff ff       	call   800499 <fd_close>
  800540:	83 c4 10             	add    $0x10,%esp
}
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <close_all>:

void
close_all(void)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	53                   	push   %ebx
  800549:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	53                   	push   %ebx
  800555:	e8 c0 ff ff ff       	call   80051a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80055a:	83 c3 01             	add    $0x1,%ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	83 fb 20             	cmp    $0x20,%ebx
  800563:	75 ec                	jne    800551 <close_all+0xc>
		close(i);
}
  800565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800568:	c9                   	leave  
  800569:	c3                   	ret    

0080056a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	57                   	push   %edi
  80056e:	56                   	push   %esi
  80056f:	53                   	push   %ebx
  800570:	83 ec 2c             	sub    $0x2c,%esp
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800579:	50                   	push   %eax
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 6e fe ff ff       	call   8003f0 <fd_lookup>
  800582:	83 c4 08             	add    $0x8,%esp
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 88 c1 00 00 00    	js     80064e <dup+0xe4>
		return r;
	close(newfdnum);
  80058d:	83 ec 0c             	sub    $0xc,%esp
  800590:	56                   	push   %esi
  800591:	e8 84 ff ff ff       	call   80051a <close>

	newfd = INDEX2FD(newfdnum);
  800596:	89 f3                	mov    %esi,%ebx
  800598:	c1 e3 0c             	shl    $0xc,%ebx
  80059b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005a1:	83 c4 04             	add    $0x4,%esp
  8005a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a7:	e8 de fd ff ff       	call   80038a <fd2data>
  8005ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ae:	89 1c 24             	mov    %ebx,(%esp)
  8005b1:	e8 d4 fd ff ff       	call   80038a <fd2data>
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005bc:	89 f8                	mov    %edi,%eax
  8005be:	c1 e8 16             	shr    $0x16,%eax
  8005c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c8:	a8 01                	test   $0x1,%al
  8005ca:	74 37                	je     800603 <dup+0x99>
  8005cc:	89 f8                	mov    %edi,%eax
  8005ce:	c1 e8 0c             	shr    $0xc,%eax
  8005d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d8:	f6 c2 01             	test   $0x1,%dl
  8005db:	74 26                	je     800603 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ec:	50                   	push   %eax
  8005ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f0:	6a 00                	push   $0x0
  8005f2:	57                   	push   %edi
  8005f3:	6a 00                	push   $0x0
  8005f5:	e8 b3 fb ff ff       	call   8001ad <sys_page_map>
  8005fa:	89 c7                	mov    %eax,%edi
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	85 c0                	test   %eax,%eax
  800601:	78 2e                	js     800631 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800603:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800606:	89 d0                	mov    %edx,%eax
  800608:	c1 e8 0c             	shr    $0xc,%eax
  80060b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	25 07 0e 00 00       	and    $0xe07,%eax
  80061a:	50                   	push   %eax
  80061b:	53                   	push   %ebx
  80061c:	6a 00                	push   $0x0
  80061e:	52                   	push   %edx
  80061f:	6a 00                	push   $0x0
  800621:	e8 87 fb ff ff       	call   8001ad <sys_page_map>
  800626:	89 c7                	mov    %eax,%edi
  800628:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80062b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062d:	85 ff                	test   %edi,%edi
  80062f:	79 1d                	jns    80064e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	e8 b3 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063c:	83 c4 08             	add    $0x8,%esp
  80063f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800642:	6a 00                	push   $0x0
  800644:	e8 a6 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	89 f8                	mov    %edi,%eax
}
  80064e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	53                   	push   %ebx
  80065a:	83 ec 14             	sub    $0x14,%esp
  80065d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800660:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	53                   	push   %ebx
  800665:	e8 86 fd ff ff       	call   8003f0 <fd_lookup>
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	89 c2                	mov    %eax,%edx
  80066f:	85 c0                	test   %eax,%eax
  800671:	78 6d                	js     8006e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800679:	50                   	push   %eax
  80067a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067d:	ff 30                	pushl  (%eax)
  80067f:	e8 c2 fd ff ff       	call   800446 <dev_lookup>
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	78 4c                	js     8006d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068e:	8b 42 08             	mov    0x8(%edx),%eax
  800691:	83 e0 03             	and    $0x3,%eax
  800694:	83 f8 01             	cmp    $0x1,%eax
  800697:	75 21                	jne    8006ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800699:	a1 08 40 80 00       	mov    0x804008,%eax
  80069e:	8b 40 48             	mov    0x48(%eax),%eax
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	50                   	push   %eax
  8006a6:	68 c5 22 80 00       	push   $0x8022c5
  8006ab:	e8 e7 0e 00 00       	call   801597 <cprintf>
		return -E_INVAL;
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b8:	eb 26                	jmp    8006e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	8b 40 08             	mov    0x8(%eax),%eax
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	74 17                	je     8006db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c4:	83 ec 04             	sub    $0x4,%esp
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	ff 75 0c             	pushl  0xc(%ebp)
  8006cd:	52                   	push   %edx
  8006ce:	ff d0                	call   *%eax
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb 09                	jmp    8006e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	eb 05                	jmp    8006e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006e0:	89 d0                	mov    %edx,%eax
  8006e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	57                   	push   %edi
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fb:	eb 21                	jmp    80071e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fd:	83 ec 04             	sub    $0x4,%esp
  800700:	89 f0                	mov    %esi,%eax
  800702:	29 d8                	sub    %ebx,%eax
  800704:	50                   	push   %eax
  800705:	89 d8                	mov    %ebx,%eax
  800707:	03 45 0c             	add    0xc(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	57                   	push   %edi
  80070c:	e8 45 ff ff ff       	call   800656 <read>
		if (m < 0)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 c0                	test   %eax,%eax
  800716:	78 10                	js     800728 <readn+0x41>
			return m;
		if (m == 0)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 0a                	je     800726 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071c:	01 c3                	add    %eax,%ebx
  80071e:	39 f3                	cmp    %esi,%ebx
  800720:	72 db                	jb     8006fd <readn+0x16>
  800722:	89 d8                	mov    %ebx,%eax
  800724:	eb 02                	jmp    800728 <readn+0x41>
  800726:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	83 ec 14             	sub    $0x14,%esp
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80073a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	53                   	push   %ebx
  80073f:	e8 ac fc ff ff       	call   8003f0 <fd_lookup>
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	89 c2                	mov    %eax,%edx
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 68                	js     8007b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800757:	ff 30                	pushl  (%eax)
  800759:	e8 e8 fc ff ff       	call   800446 <dev_lookup>
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	85 c0                	test   %eax,%eax
  800763:	78 47                	js     8007ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800765:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800768:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80076c:	75 21                	jne    80078f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076e:	a1 08 40 80 00       	mov    0x804008,%eax
  800773:	8b 40 48             	mov    0x48(%eax),%eax
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	53                   	push   %ebx
  80077a:	50                   	push   %eax
  80077b:	68 e1 22 80 00       	push   $0x8022e1
  800780:	e8 12 0e 00 00       	call   801597 <cprintf>
		return -E_INVAL;
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80078d:	eb 26                	jmp    8007b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800792:	8b 52 0c             	mov    0xc(%edx),%edx
  800795:	85 d2                	test   %edx,%edx
  800797:	74 17                	je     8007b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	50                   	push   %eax
  8007a3:	ff d2                	call   *%edx
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 09                	jmp    8007b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	eb 05                	jmp    8007b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b5:	89 d0                	mov    %edx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	ff 75 08             	pushl  0x8(%ebp)
  8007c9:	e8 22 fc ff ff       	call   8003f0 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	78 0e                	js     8007e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 14             	sub    $0x14,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	53                   	push   %ebx
  8007f4:	e8 f7 fb ff ff       	call   8003f0 <fd_lookup>
  8007f9:	83 c4 08             	add    $0x8,%esp
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 65                	js     800867 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	ff 30                	pushl  (%eax)
  80080e:	e8 33 fc ff ff       	call   800446 <dev_lookup>
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 44                	js     80085e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800821:	75 21                	jne    800844 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800823:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800828:	8b 40 48             	mov    0x48(%eax),%eax
  80082b:	83 ec 04             	sub    $0x4,%esp
  80082e:	53                   	push   %ebx
  80082f:	50                   	push   %eax
  800830:	68 a4 22 80 00       	push   $0x8022a4
  800835:	e8 5d 0d 00 00       	call   801597 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800842:	eb 23                	jmp    800867 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800847:	8b 52 18             	mov    0x18(%edx),%edx
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 14                	je     800862 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	50                   	push   %eax
  800855:	ff d2                	call   *%edx
  800857:	89 c2                	mov    %eax,%edx
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	eb 09                	jmp    800867 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	89 c2                	mov    %eax,%edx
  800860:	eb 05                	jmp    800867 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800862:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800867:	89 d0                	mov    %edx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	83 ec 14             	sub    $0x14,%esp
  800875:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80087b:	50                   	push   %eax
  80087c:	ff 75 08             	pushl  0x8(%ebp)
  80087f:	e8 6c fb ff ff       	call   8003f0 <fd_lookup>
  800884:	83 c4 08             	add    $0x8,%esp
  800887:	89 c2                	mov    %eax,%edx
  800889:	85 c0                	test   %eax,%eax
  80088b:	78 58                	js     8008e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800897:	ff 30                	pushl  (%eax)
  800899:	e8 a8 fb ff ff       	call   800446 <dev_lookup>
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 37                	js     8008dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ac:	74 32                	je     8008e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b8:	00 00 00 
	stat->st_isdir = 0;
  8008bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c2:	00 00 00 
	stat->st_dev = dev;
  8008c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d2:	ff 50 14             	call   *0x14(%eax)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	eb 09                	jmp    8008e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008dc:	89 c2                	mov    %eax,%edx
  8008de:	eb 05                	jmp    8008e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	6a 00                	push   $0x0
  8008f6:	ff 75 08             	pushl  0x8(%ebp)
  8008f9:	e8 d6 01 00 00       	call   800ad4 <open>
  8008fe:	89 c3                	mov    %eax,%ebx
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	85 c0                	test   %eax,%eax
  800905:	78 1b                	js     800922 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	50                   	push   %eax
  80090e:	e8 5b ff ff ff       	call   80086e <fstat>
  800913:	89 c6                	mov    %eax,%esi
	close(fd);
  800915:	89 1c 24             	mov    %ebx,(%esp)
  800918:	e8 fd fb ff ff       	call   80051a <close>
	return r;
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	89 f0                	mov    %esi,%eax
}
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800932:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800939:	75 12                	jne    80094d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	6a 01                	push   $0x1
  800940:	e8 d9 15 00 00       	call   801f1e <ipc_find_env>
  800945:	a3 00 40 80 00       	mov    %eax,0x804000
  80094a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094d:	6a 07                	push   $0x7
  80094f:	68 00 50 80 00       	push   $0x805000
  800954:	56                   	push   %esi
  800955:	ff 35 00 40 80 00    	pushl  0x804000
  80095b:	e8 6a 15 00 00       	call   801eca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800960:	83 c4 0c             	add    $0xc,%esp
  800963:	6a 00                	push   $0x0
  800965:	53                   	push   %ebx
  800966:	6a 00                	push   $0x0
  800968:	e8 f6 14 00 00       	call   801e63 <ipc_recv>
}
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 40 0c             	mov    0xc(%eax),%eax
  800980:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	b8 02 00 00 00       	mov    $0x2,%eax
  800997:	e8 8d ff ff ff       	call   800929 <fsipc>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b9:	e8 6b ff ff ff       	call   800929 <fsipc>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	b8 05 00 00 00       	mov    $0x5,%eax
  8009df:	e8 45 ff ff ff       	call   800929 <fsipc>
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	78 2c                	js     800a14 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	68 00 50 80 00       	push   $0x805000
  8009f0:	53                   	push   %ebx
  8009f1:	e8 26 11 00 00       	call   801b1c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a01:	a1 84 50 80 00       	mov    0x805084,%eax
  800a06:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a0c:	83 c4 10             	add    $0x10,%esp
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 0c             	sub    $0xc,%esp
  800a1f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a22:	8b 55 08             	mov    0x8(%ebp),%edx
  800a25:	8b 52 0c             	mov    0xc(%edx),%edx
  800a28:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a2e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a33:	50                   	push   %eax
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	68 08 50 80 00       	push   $0x805008
  800a3c:	e8 6d 12 00 00       	call   801cae <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4b:	e8 d9 fe ff ff       	call   800929 <fsipc>

}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a65:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 03 00 00 00       	mov    $0x3,%eax
  800a75:	e8 af fe ff ff       	call   800929 <fsipc>
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	85 c0                	test   %eax,%eax
  800a7e:	78 4b                	js     800acb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a80:	39 c6                	cmp    %eax,%esi
  800a82:	73 16                	jae    800a9a <devfile_read+0x48>
  800a84:	68 14 23 80 00       	push   $0x802314
  800a89:	68 1b 23 80 00       	push   $0x80231b
  800a8e:	6a 7c                	push   $0x7c
  800a90:	68 30 23 80 00       	push   $0x802330
  800a95:	e8 24 0a 00 00       	call   8014be <_panic>
	assert(r <= PGSIZE);
  800a9a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9f:	7e 16                	jle    800ab7 <devfile_read+0x65>
  800aa1:	68 3b 23 80 00       	push   $0x80233b
  800aa6:	68 1b 23 80 00       	push   $0x80231b
  800aab:	6a 7d                	push   $0x7d
  800aad:	68 30 23 80 00       	push   $0x802330
  800ab2:	e8 07 0a 00 00       	call   8014be <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab7:	83 ec 04             	sub    $0x4,%esp
  800aba:	50                   	push   %eax
  800abb:	68 00 50 80 00       	push   $0x805000
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	e8 e6 11 00 00       	call   801cae <memmove>
	return r;
  800ac8:	83 c4 10             	add    $0x10,%esp
}
  800acb:	89 d8                	mov    %ebx,%eax
  800acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 20             	sub    $0x20,%esp
  800adb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ade:	53                   	push   %ebx
  800adf:	e8 ff 0f 00 00       	call   801ae3 <strlen>
  800ae4:	83 c4 10             	add    $0x10,%esp
  800ae7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aec:	7f 67                	jg     800b55 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af4:	50                   	push   %eax
  800af5:	e8 a7 f8 ff ff       	call   8003a1 <fd_alloc>
  800afa:	83 c4 10             	add    $0x10,%esp
		return r;
  800afd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 57                	js     800b5a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b03:	83 ec 08             	sub    $0x8,%esp
  800b06:	53                   	push   %ebx
  800b07:	68 00 50 80 00       	push   $0x805000
  800b0c:	e8 0b 10 00 00       	call   801b1c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	e8 03 fe ff ff       	call   800929 <fsipc>
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	79 14                	jns    800b43 <open+0x6f>
		fd_close(fd, 0);
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	6a 00                	push   $0x0
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 5d f9 ff ff       	call   800499 <fd_close>
		return r;
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	89 da                	mov    %ebx,%edx
  800b41:	eb 17                	jmp    800b5a <open+0x86>
	}

	return fd2num(fd);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	ff 75 f4             	pushl  -0xc(%ebp)
  800b49:	e8 2c f8 ff ff       	call   80037a <fd2num>
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	eb 05                	jmp    800b5a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b55:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5a:	89 d0                	mov    %edx,%eax
  800b5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b71:	e8 b3 fd ff ff       	call   800929 <fsipc>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b7e:	68 47 23 80 00       	push   $0x802347
  800b83:	ff 75 0c             	pushl  0xc(%ebp)
  800b86:	e8 91 0f 00 00       	call   801b1c <strcpy>
	return 0;
}
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	53                   	push   %ebx
  800b96:	83 ec 10             	sub    $0x10,%esp
  800b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b9c:	53                   	push   %ebx
  800b9d:	e8 b5 13 00 00       	call   801f57 <pageref>
  800ba2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800baa:	83 f8 01             	cmp    $0x1,%eax
  800bad:	75 10                	jne    800bbf <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	ff 73 0c             	pushl  0xc(%ebx)
  800bb5:	e8 c0 02 00 00       	call   800e7a <nsipc_close>
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bcc:	6a 00                	push   $0x0
  800bce:	ff 75 10             	pushl  0x10(%ebp)
  800bd1:	ff 75 0c             	pushl  0xc(%ebp)
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	ff 70 0c             	pushl  0xc(%eax)
  800bda:	e8 78 03 00 00       	call   800f57 <nsipc_send>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	ff 75 10             	pushl  0x10(%ebp)
  800bec:	ff 75 0c             	pushl  0xc(%ebp)
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	ff 70 0c             	pushl  0xc(%eax)
  800bf5:	e8 f1 02 00 00       	call   800eeb <nsipc_recv>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c02:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c05:	52                   	push   %edx
  800c06:	50                   	push   %eax
  800c07:	e8 e4 f7 ff ff       	call   8003f0 <fd_lookup>
  800c0c:	83 c4 10             	add    $0x10,%esp
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	78 17                	js     800c2a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c16:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c1c:	39 08                	cmp    %ecx,(%eax)
  800c1e:	75 05                	jne    800c25 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c20:	8b 40 0c             	mov    0xc(%eax),%eax
  800c23:	eb 05                	jmp    800c2a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c25:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 1c             	sub    $0x1c,%esp
  800c34:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c39:	50                   	push   %eax
  800c3a:	e8 62 f7 ff ff       	call   8003a1 <fd_alloc>
  800c3f:	89 c3                	mov    %eax,%ebx
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	85 c0                	test   %eax,%eax
  800c46:	78 1b                	js     800c63 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c48:	83 ec 04             	sub    $0x4,%esp
  800c4b:	68 07 04 00 00       	push   $0x407
  800c50:	ff 75 f4             	pushl  -0xc(%ebp)
  800c53:	6a 00                	push   $0x0
  800c55:	e8 10 f5 ff ff       	call   80016a <sys_page_alloc>
  800c5a:	89 c3                	mov    %eax,%ebx
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	79 10                	jns    800c73 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	56                   	push   %esi
  800c67:	e8 0e 02 00 00       	call   800e7a <nsipc_close>
		return r;
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	89 d8                	mov    %ebx,%eax
  800c71:	eb 24                	jmp    800c97 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c73:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c81:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c88:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	e8 e6 f6 ff ff       	call   80037a <fd2num>
  800c94:	83 c4 10             	add    $0x10,%esp
}
  800c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	e8 50 ff ff ff       	call   800bfc <fd2sockid>
		return r;
  800cac:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	78 1f                	js     800cd1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cb2:	83 ec 04             	sub    $0x4,%esp
  800cb5:	ff 75 10             	pushl  0x10(%ebp)
  800cb8:	ff 75 0c             	pushl  0xc(%ebp)
  800cbb:	50                   	push   %eax
  800cbc:	e8 12 01 00 00       	call   800dd3 <nsipc_accept>
  800cc1:	83 c4 10             	add    $0x10,%esp
		return r;
  800cc4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	78 07                	js     800cd1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cca:	e8 5d ff ff ff       	call   800c2c <alloc_sockfd>
  800ccf:	89 c1                	mov    %eax,%ecx
}
  800cd1:	89 c8                	mov    %ecx,%eax
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	e8 19 ff ff ff       	call   800bfc <fd2sockid>
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	78 12                	js     800cf9 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800ce7:	83 ec 04             	sub    $0x4,%esp
  800cea:	ff 75 10             	pushl  0x10(%ebp)
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	50                   	push   %eax
  800cf1:	e8 2d 01 00 00       	call   800e23 <nsipc_bind>
  800cf6:	83 c4 10             	add    $0x10,%esp
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <shutdown>:

int
shutdown(int s, int how)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	e8 f3 fe ff ff       	call   800bfc <fd2sockid>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 0f                	js     800d1c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d0d:	83 ec 08             	sub    $0x8,%esp
  800d10:	ff 75 0c             	pushl  0xc(%ebp)
  800d13:	50                   	push   %eax
  800d14:	e8 3f 01 00 00       	call   800e58 <nsipc_shutdown>
  800d19:	83 c4 10             	add    $0x10,%esp
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	e8 d0 fe ff ff       	call   800bfc <fd2sockid>
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	78 12                	js     800d42 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	ff 75 10             	pushl  0x10(%ebp)
  800d36:	ff 75 0c             	pushl  0xc(%ebp)
  800d39:	50                   	push   %eax
  800d3a:	e8 55 01 00 00       	call   800e94 <nsipc_connect>
  800d3f:	83 c4 10             	add    $0x10,%esp
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <listen>:

int
listen(int s, int backlog)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	e8 aa fe ff ff       	call   800bfc <fd2sockid>
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 0f                	js     800d65 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d56:	83 ec 08             	sub    $0x8,%esp
  800d59:	ff 75 0c             	pushl  0xc(%ebp)
  800d5c:	50                   	push   %eax
  800d5d:	e8 67 01 00 00       	call   800ec9 <nsipc_listen>
  800d62:	83 c4 10             	add    $0x10,%esp
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d6d:	ff 75 10             	pushl  0x10(%ebp)
  800d70:	ff 75 0c             	pushl  0xc(%ebp)
  800d73:	ff 75 08             	pushl  0x8(%ebp)
  800d76:	e8 3a 02 00 00       	call   800fb5 <nsipc_socket>
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	78 05                	js     800d87 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d82:	e8 a5 fe ff ff       	call   800c2c <alloc_sockfd>
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d92:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d99:	75 12                	jne    800dad <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	6a 02                	push   $0x2
  800da0:	e8 79 11 00 00       	call   801f1e <ipc_find_env>
  800da5:	a3 04 40 80 00       	mov    %eax,0x804004
  800daa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dad:	6a 07                	push   $0x7
  800daf:	68 00 60 80 00       	push   $0x806000
  800db4:	53                   	push   %ebx
  800db5:	ff 35 04 40 80 00    	pushl  0x804004
  800dbb:	e8 0a 11 00 00       	call   801eca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dc0:	83 c4 0c             	add    $0xc,%esp
  800dc3:	6a 00                	push   $0x0
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 95 10 00 00       	call   801e63 <ipc_recv>
}
  800dce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800de3:	8b 06                	mov    (%esi),%eax
  800de5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dea:	b8 01 00 00 00       	mov    $0x1,%eax
  800def:	e8 95 ff ff ff       	call   800d89 <nsipc>
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 20                	js     800e1a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	ff 35 10 60 80 00    	pushl  0x806010
  800e03:	68 00 60 80 00       	push   $0x806000
  800e08:	ff 75 0c             	pushl  0xc(%ebp)
  800e0b:	e8 9e 0e 00 00       	call   801cae <memmove>
		*addrlen = ret->ret_addrlen;
  800e10:	a1 10 60 80 00       	mov    0x806010,%eax
  800e15:	89 06                	mov    %eax,(%esi)
  800e17:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e1a:	89 d8                	mov    %ebx,%eax
  800e1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	53                   	push   %ebx
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e35:	53                   	push   %ebx
  800e36:	ff 75 0c             	pushl  0xc(%ebp)
  800e39:	68 04 60 80 00       	push   $0x806004
  800e3e:	e8 6b 0e 00 00       	call   801cae <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e43:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e49:	b8 02 00 00 00       	mov    $0x2,%eax
  800e4e:	e8 36 ff ff ff       	call   800d89 <nsipc>
}
  800e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e69:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e73:	e8 11 ff ff ff       	call   800d89 <nsipc>
}
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    

00800e7a <nsipc_close>:

int
nsipc_close(int s)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e88:	b8 04 00 00 00       	mov    $0x4,%eax
  800e8d:	e8 f7 fe ff ff       	call   800d89 <nsipc>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	53                   	push   %ebx
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ea6:	53                   	push   %ebx
  800ea7:	ff 75 0c             	pushl  0xc(%ebp)
  800eaa:	68 04 60 80 00       	push   $0x806004
  800eaf:	e8 fa 0d 00 00       	call   801cae <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eb4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eba:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebf:	e8 c5 fe ff ff       	call   800d89 <nsipc>
}
  800ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eda:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800edf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee4:	e8 a0 fe ff ff       	call   800d89 <nsipc>
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800efb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f01:	8b 45 14             	mov    0x14(%ebp),%eax
  800f04:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f09:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0e:	e8 76 fe ff ff       	call   800d89 <nsipc>
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	85 c0                	test   %eax,%eax
  800f17:	78 35                	js     800f4e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f19:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f1e:	7f 04                	jg     800f24 <nsipc_recv+0x39>
  800f20:	39 c6                	cmp    %eax,%esi
  800f22:	7d 16                	jge    800f3a <nsipc_recv+0x4f>
  800f24:	68 53 23 80 00       	push   $0x802353
  800f29:	68 1b 23 80 00       	push   $0x80231b
  800f2e:	6a 62                	push   $0x62
  800f30:	68 68 23 80 00       	push   $0x802368
  800f35:	e8 84 05 00 00       	call   8014be <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f3a:	83 ec 04             	sub    $0x4,%esp
  800f3d:	50                   	push   %eax
  800f3e:	68 00 60 80 00       	push   $0x806000
  800f43:	ff 75 0c             	pushl  0xc(%ebp)
  800f46:	e8 63 0d 00 00       	call   801cae <memmove>
  800f4b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f4e:	89 d8                	mov    %ebx,%eax
  800f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	53                   	push   %ebx
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f69:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f6f:	7e 16                	jle    800f87 <nsipc_send+0x30>
  800f71:	68 74 23 80 00       	push   $0x802374
  800f76:	68 1b 23 80 00       	push   $0x80231b
  800f7b:	6a 6d                	push   $0x6d
  800f7d:	68 68 23 80 00       	push   $0x802368
  800f82:	e8 37 05 00 00       	call   8014be <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	53                   	push   %ebx
  800f8b:	ff 75 0c             	pushl  0xc(%ebp)
  800f8e:	68 0c 60 80 00       	push   $0x80600c
  800f93:	e8 16 0d 00 00       	call   801cae <memmove>
	nsipcbuf.send.req_size = size;
  800f98:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fa6:	b8 08 00 00 00       	mov    $0x8,%eax
  800fab:	e8 d9 fd ff ff       	call   800d89 <nsipc>
}
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800fce:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800fd8:	e8 ac fd ff ff       	call   800d89 <nsipc>
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
  800fe4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	ff 75 08             	pushl  0x8(%ebp)
  800fed:	e8 98 f3 ff ff       	call   80038a <fd2data>
  800ff2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	68 80 23 80 00       	push   $0x802380
  800ffc:	53                   	push   %ebx
  800ffd:	e8 1a 0b 00 00       	call   801b1c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801002:	8b 46 04             	mov    0x4(%esi),%eax
  801005:	2b 06                	sub    (%esi),%eax
  801007:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80100d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801014:	00 00 00 
	stat->st_dev = &devpipe;
  801017:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  80101e:	30 80 00 
	return 0;
}
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	53                   	push   %ebx
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801037:	53                   	push   %ebx
  801038:	6a 00                	push   $0x0
  80103a:	e8 b0 f1 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80103f:	89 1c 24             	mov    %ebx,(%esp)
  801042:	e8 43 f3 ff ff       	call   80038a <fd2data>
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	50                   	push   %eax
  80104b:	6a 00                	push   $0x0
  80104d:	e8 9d f1 ff ff       	call   8001ef <sys_page_unmap>
}
  801052:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 1c             	sub    $0x1c,%esp
  801060:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801063:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801065:	a1 08 40 80 00       	mov    0x804008,%eax
  80106a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	ff 75 e0             	pushl  -0x20(%ebp)
  801073:	e8 df 0e 00 00       	call   801f57 <pageref>
  801078:	89 c3                	mov    %eax,%ebx
  80107a:	89 3c 24             	mov    %edi,(%esp)
  80107d:	e8 d5 0e 00 00       	call   801f57 <pageref>
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	39 c3                	cmp    %eax,%ebx
  801087:	0f 94 c1             	sete   %cl
  80108a:	0f b6 c9             	movzbl %cl,%ecx
  80108d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801090:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801096:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801099:	39 ce                	cmp    %ecx,%esi
  80109b:	74 1b                	je     8010b8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80109d:	39 c3                	cmp    %eax,%ebx
  80109f:	75 c4                	jne    801065 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010a1:	8b 42 58             	mov    0x58(%edx),%eax
  8010a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a7:	50                   	push   %eax
  8010a8:	56                   	push   %esi
  8010a9:	68 87 23 80 00       	push   $0x802387
  8010ae:	e8 e4 04 00 00       	call   801597 <cprintf>
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	eb ad                	jmp    801065 <_pipeisclosed+0xe>
	}
}
  8010b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 28             	sub    $0x28,%esp
  8010cc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010cf:	56                   	push   %esi
  8010d0:	e8 b5 f2 ff ff       	call   80038a <fd2data>
  8010d5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	bf 00 00 00 00       	mov    $0x0,%edi
  8010df:	eb 4b                	jmp    80112c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010e1:	89 da                	mov    %ebx,%edx
  8010e3:	89 f0                	mov    %esi,%eax
  8010e5:	e8 6d ff ff ff       	call   801057 <_pipeisclosed>
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	75 48                	jne    801136 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010ee:	e8 58 f0 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8010f6:	8b 0b                	mov    (%ebx),%ecx
  8010f8:	8d 51 20             	lea    0x20(%ecx),%edx
  8010fb:	39 d0                	cmp    %edx,%eax
  8010fd:	73 e2                	jae    8010e1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801102:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801106:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801109:	89 c2                	mov    %eax,%edx
  80110b:	c1 fa 1f             	sar    $0x1f,%edx
  80110e:	89 d1                	mov    %edx,%ecx
  801110:	c1 e9 1b             	shr    $0x1b,%ecx
  801113:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801116:	83 e2 1f             	and    $0x1f,%edx
  801119:	29 ca                	sub    %ecx,%edx
  80111b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80111f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801123:	83 c0 01             	add    $0x1,%eax
  801126:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801129:	83 c7 01             	add    $0x1,%edi
  80112c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80112f:	75 c2                	jne    8010f3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801131:	8b 45 10             	mov    0x10(%ebp),%eax
  801134:	eb 05                	jmp    80113b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801136:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 18             	sub    $0x18,%esp
  80114c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80114f:	57                   	push   %edi
  801150:	e8 35 f2 ff ff       	call   80038a <fd2data>
  801155:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115f:	eb 3d                	jmp    80119e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801161:	85 db                	test   %ebx,%ebx
  801163:	74 04                	je     801169 <devpipe_read+0x26>
				return i;
  801165:	89 d8                	mov    %ebx,%eax
  801167:	eb 44                	jmp    8011ad <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801169:	89 f2                	mov    %esi,%edx
  80116b:	89 f8                	mov    %edi,%eax
  80116d:	e8 e5 fe ff ff       	call   801057 <_pipeisclosed>
  801172:	85 c0                	test   %eax,%eax
  801174:	75 32                	jne    8011a8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801176:	e8 d0 ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80117b:	8b 06                	mov    (%esi),%eax
  80117d:	3b 46 04             	cmp    0x4(%esi),%eax
  801180:	74 df                	je     801161 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801182:	99                   	cltd   
  801183:	c1 ea 1b             	shr    $0x1b,%edx
  801186:	01 d0                	add    %edx,%eax
  801188:	83 e0 1f             	and    $0x1f,%eax
  80118b:	29 d0                	sub    %edx,%eax
  80118d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801195:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801198:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80119b:	83 c3 01             	add    $0x1,%ebx
  80119e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011a1:	75 d8                	jne    80117b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a6:	eb 05                	jmp    8011ad <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	e8 db f1 ff ff       	call   8003a1 <fd_alloc>
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	0f 88 2c 01 00 00    	js     8012ff <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	68 07 04 00 00       	push   $0x407
  8011db:	ff 75 f4             	pushl  -0xc(%ebp)
  8011de:	6a 00                	push   $0x0
  8011e0:	e8 85 ef ff ff       	call   80016a <sys_page_alloc>
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	0f 88 0d 01 00 00    	js     8012ff <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011f2:	83 ec 0c             	sub    $0xc,%esp
  8011f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	e8 a3 f1 ff ff       	call   8003a1 <fd_alloc>
  8011fe:	89 c3                	mov    %eax,%ebx
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	0f 88 e2 00 00 00    	js     8012ed <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	68 07 04 00 00       	push   $0x407
  801213:	ff 75 f0             	pushl  -0x10(%ebp)
  801216:	6a 00                	push   $0x0
  801218:	e8 4d ef ff ff       	call   80016a <sys_page_alloc>
  80121d:	89 c3                	mov    %eax,%ebx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	0f 88 c3 00 00 00    	js     8012ed <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	ff 75 f4             	pushl  -0xc(%ebp)
  801230:	e8 55 f1 ff ff       	call   80038a <fd2data>
  801235:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801237:	83 c4 0c             	add    $0xc,%esp
  80123a:	68 07 04 00 00       	push   $0x407
  80123f:	50                   	push   %eax
  801240:	6a 00                	push   $0x0
  801242:	e8 23 ef ff ff       	call   80016a <sys_page_alloc>
  801247:	89 c3                	mov    %eax,%ebx
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	0f 88 89 00 00 00    	js     8012dd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	ff 75 f0             	pushl  -0x10(%ebp)
  80125a:	e8 2b f1 ff ff       	call   80038a <fd2data>
  80125f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801266:	50                   	push   %eax
  801267:	6a 00                	push   $0x0
  801269:	56                   	push   %esi
  80126a:	6a 00                	push   $0x0
  80126c:	e8 3c ef ff ff       	call   8001ad <sys_page_map>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 20             	add    $0x20,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 55                	js     8012cf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80127a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801280:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801283:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801288:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80128f:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801298:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012aa:	e8 cb f0 ff ff       	call   80037a <fd2num>
  8012af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012b4:	83 c4 04             	add    $0x4,%esp
  8012b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ba:	e8 bb f0 ff ff       	call   80037a <fd2num>
  8012bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cd:	eb 30                	jmp    8012ff <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	56                   	push   %esi
  8012d3:	6a 00                	push   $0x0
  8012d5:	e8 15 ef ff ff       	call   8001ef <sys_page_unmap>
  8012da:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e3:	6a 00                	push   $0x0
  8012e5:	e8 05 ef ff ff       	call   8001ef <sys_page_unmap>
  8012ea:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 f5 ee ff ff       	call   8001ef <sys_page_unmap>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012ff:	89 d0                	mov    %edx,%eax
  801301:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 d6 f0 ff ff       	call   8003f0 <fd_lookup>
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 18                	js     801339 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	ff 75 f4             	pushl  -0xc(%ebp)
  801327:	e8 5e f0 ff ff       	call   80038a <fd2data>
	return _pipeisclosed(fd, p);
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801331:	e8 21 fd ff ff       	call   801057 <_pipeisclosed>
  801336:	83 c4 10             	add    $0x10,%esp
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80134b:	68 9f 23 80 00       	push   $0x80239f
  801350:	ff 75 0c             	pushl  0xc(%ebp)
  801353:	e8 c4 07 00 00       	call   801b1c <strcpy>
	return 0;
}
  801358:	b8 00 00 00 00       	mov    $0x0,%eax
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	57                   	push   %edi
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80136b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801370:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801376:	eb 2d                	jmp    8013a5 <devcons_write+0x46>
		m = n - tot;
  801378:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80137d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801380:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801385:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801388:	83 ec 04             	sub    $0x4,%esp
  80138b:	53                   	push   %ebx
  80138c:	03 45 0c             	add    0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	57                   	push   %edi
  801391:	e8 18 09 00 00       	call   801cae <memmove>
		sys_cputs(buf, m);
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	53                   	push   %ebx
  80139a:	57                   	push   %edi
  80139b:	e8 0e ed ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a0:	01 de                	add    %ebx,%esi
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	89 f0                	mov    %esi,%eax
  8013a7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013aa:	72 cc                	jb     801378 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5f                   	pop    %edi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c3:	74 2a                	je     8013ef <devcons_read+0x3b>
  8013c5:	eb 05                	jmp    8013cc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013c7:	e8 7f ed ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013cc:	e8 fb ec ff ff       	call   8000cc <sys_cgetc>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	74 f2                	je     8013c7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 16                	js     8013ef <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013d9:	83 f8 04             	cmp    $0x4,%eax
  8013dc:	74 0c                	je     8013ea <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e1:	88 02                	mov    %al,(%edx)
	return 1;
  8013e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e8:	eb 05                	jmp    8013ef <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013fd:	6a 01                	push   $0x1
  8013ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	e8 a6 ec ff ff       	call   8000ae <sys_cputs>
}
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <getchar>:

int
getchar(void)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801413:	6a 01                	push   $0x1
  801415:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	6a 00                	push   $0x0
  80141b:	e8 36 f2 ff ff       	call   800656 <read>
	if (r < 0)
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 0f                	js     801436 <getchar+0x29>
		return r;
	if (r < 1)
  801427:	85 c0                	test   %eax,%eax
  801429:	7e 06                	jle    801431 <getchar+0x24>
		return -E_EOF;
	return c;
  80142b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80142f:	eb 05                	jmp    801436 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801431:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	ff 75 08             	pushl  0x8(%ebp)
  801445:	e8 a6 ef ff ff       	call   8003f0 <fd_lookup>
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 11                	js     801462 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801454:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80145a:	39 10                	cmp    %edx,(%eax)
  80145c:	0f 94 c0             	sete   %al
  80145f:	0f b6 c0             	movzbl %al,%eax
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <opencons>:

int
opencons(void)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	e8 2e ef ff ff       	call   8003a1 <fd_alloc>
  801473:	83 c4 10             	add    $0x10,%esp
		return r;
  801476:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 3e                	js     8014ba <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	68 07 04 00 00       	push   $0x407
  801484:	ff 75 f4             	pushl  -0xc(%ebp)
  801487:	6a 00                	push   $0x0
  801489:	e8 dc ec ff ff       	call   80016a <sys_page_alloc>
  80148e:	83 c4 10             	add    $0x10,%esp
		return r;
  801491:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801493:	85 c0                	test   %eax,%eax
  801495:	78 23                	js     8014ba <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801497:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	50                   	push   %eax
  8014b0:	e8 c5 ee ff ff       	call   80037a <fd2num>
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	83 c4 10             	add    $0x10,%esp
}
  8014ba:	89 d0                	mov    %edx,%eax
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014c3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014c6:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8014cc:	e8 5b ec ff ff       	call   80012c <sys_getenvid>
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	ff 75 08             	pushl  0x8(%ebp)
  8014da:	56                   	push   %esi
  8014db:	50                   	push   %eax
  8014dc:	68 ac 23 80 00       	push   $0x8023ac
  8014e1:	e8 b1 00 00 00       	call   801597 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014e6:	83 c4 18             	add    $0x18,%esp
  8014e9:	53                   	push   %ebx
  8014ea:	ff 75 10             	pushl  0x10(%ebp)
  8014ed:	e8 54 00 00 00       	call   801546 <vcprintf>
	cprintf("\n");
  8014f2:	c7 04 24 98 23 80 00 	movl   $0x802398,(%esp)
  8014f9:	e8 99 00 00 00       	call   801597 <cprintf>
  8014fe:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801501:	cc                   	int3   
  801502:	eb fd                	jmp    801501 <_panic+0x43>

00801504 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	53                   	push   %ebx
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80150e:	8b 13                	mov    (%ebx),%edx
  801510:	8d 42 01             	lea    0x1(%edx),%eax
  801513:	89 03                	mov    %eax,(%ebx)
  801515:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801518:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80151c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801521:	75 1a                	jne    80153d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	68 ff 00 00 00       	push   $0xff
  80152b:	8d 43 08             	lea    0x8(%ebx),%eax
  80152e:	50                   	push   %eax
  80152f:	e8 7a eb ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801534:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80153d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80154f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801556:	00 00 00 
	b.cnt = 0;
  801559:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801560:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	ff 75 08             	pushl  0x8(%ebp)
  801569:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	68 04 15 80 00       	push   $0x801504
  801575:	e8 54 01 00 00       	call   8016ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801583:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	e8 1f eb ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80158f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80159d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015a0:	50                   	push   %eax
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 9d ff ff ff       	call   801546 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 1c             	sub    $0x1c,%esp
  8015b4:	89 c7                	mov    %eax,%edi
  8015b6:	89 d6                	mov    %edx,%esi
  8015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015d2:	39 d3                	cmp    %edx,%ebx
  8015d4:	72 05                	jb     8015db <printnum+0x30>
  8015d6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015d9:	77 45                	ja     801620 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	ff 75 18             	pushl  0x18(%ebp)
  8015e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015e7:	53                   	push   %ebx
  8015e8:	ff 75 10             	pushl  0x10(%ebp)
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015fa:	e8 a1 09 00 00       	call   801fa0 <__udivdi3>
  8015ff:	83 c4 18             	add    $0x18,%esp
  801602:	52                   	push   %edx
  801603:	50                   	push   %eax
  801604:	89 f2                	mov    %esi,%edx
  801606:	89 f8                	mov    %edi,%eax
  801608:	e8 9e ff ff ff       	call   8015ab <printnum>
  80160d:	83 c4 20             	add    $0x20,%esp
  801610:	eb 18                	jmp    80162a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	56                   	push   %esi
  801616:	ff 75 18             	pushl  0x18(%ebp)
  801619:	ff d7                	call   *%edi
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 03                	jmp    801623 <printnum+0x78>
  801620:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801623:	83 eb 01             	sub    $0x1,%ebx
  801626:	85 db                	test   %ebx,%ebx
  801628:	7f e8                	jg     801612 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	56                   	push   %esi
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	ff 75 e4             	pushl  -0x1c(%ebp)
  801634:	ff 75 e0             	pushl  -0x20(%ebp)
  801637:	ff 75 dc             	pushl  -0x24(%ebp)
  80163a:	ff 75 d8             	pushl  -0x28(%ebp)
  80163d:	e8 8e 0a 00 00       	call   8020d0 <__umoddi3>
  801642:	83 c4 14             	add    $0x14,%esp
  801645:	0f be 80 cf 23 80 00 	movsbl 0x8023cf(%eax),%eax
  80164c:	50                   	push   %eax
  80164d:	ff d7                	call   *%edi
}
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5f                   	pop    %edi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80165d:	83 fa 01             	cmp    $0x1,%edx
  801660:	7e 0e                	jle    801670 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801662:	8b 10                	mov    (%eax),%edx
  801664:	8d 4a 08             	lea    0x8(%edx),%ecx
  801667:	89 08                	mov    %ecx,(%eax)
  801669:	8b 02                	mov    (%edx),%eax
  80166b:	8b 52 04             	mov    0x4(%edx),%edx
  80166e:	eb 22                	jmp    801692 <getuint+0x38>
	else if (lflag)
  801670:	85 d2                	test   %edx,%edx
  801672:	74 10                	je     801684 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801674:	8b 10                	mov    (%eax),%edx
  801676:	8d 4a 04             	lea    0x4(%edx),%ecx
  801679:	89 08                	mov    %ecx,(%eax)
  80167b:	8b 02                	mov    (%edx),%eax
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
  801682:	eb 0e                	jmp    801692 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801684:	8b 10                	mov    (%eax),%edx
  801686:	8d 4a 04             	lea    0x4(%edx),%ecx
  801689:	89 08                	mov    %ecx,(%eax)
  80168b:	8b 02                	mov    (%edx),%eax
  80168d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80169a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80169e:	8b 10                	mov    (%eax),%edx
  8016a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8016a3:	73 0a                	jae    8016af <sprintputch+0x1b>
		*b->buf++ = ch;
  8016a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016a8:	89 08                	mov    %ecx,(%eax)
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	88 02                	mov    %al,(%edx)
}
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ba:	50                   	push   %eax
  8016bb:	ff 75 10             	pushl  0x10(%ebp)
  8016be:	ff 75 0c             	pushl  0xc(%ebp)
  8016c1:	ff 75 08             	pushl  0x8(%ebp)
  8016c4:	e8 05 00 00 00       	call   8016ce <vprintfmt>
	va_end(ap);
}
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	57                   	push   %edi
  8016d2:	56                   	push   %esi
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 2c             	sub    $0x2c,%esp
  8016d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016e0:	eb 12                	jmp    8016f4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	0f 84 89 03 00 00    	je     801a73 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	50                   	push   %eax
  8016ef:	ff d6                	call   *%esi
  8016f1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016f4:	83 c7 01             	add    $0x1,%edi
  8016f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016fb:	83 f8 25             	cmp    $0x25,%eax
  8016fe:	75 e2                	jne    8016e2 <vprintfmt+0x14>
  801700:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801704:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80170b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801712:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801719:	ba 00 00 00 00       	mov    $0x0,%edx
  80171e:	eb 07                	jmp    801727 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801720:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801723:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801727:	8d 47 01             	lea    0x1(%edi),%eax
  80172a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80172d:	0f b6 07             	movzbl (%edi),%eax
  801730:	0f b6 c8             	movzbl %al,%ecx
  801733:	83 e8 23             	sub    $0x23,%eax
  801736:	3c 55                	cmp    $0x55,%al
  801738:	0f 87 1a 03 00 00    	ja     801a58 <vprintfmt+0x38a>
  80173e:	0f b6 c0             	movzbl %al,%eax
  801741:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80174b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80174f:	eb d6                	jmp    801727 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801754:	b8 00 00 00 00       	mov    $0x0,%eax
  801759:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80175c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80175f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801763:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801766:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801769:	83 fa 09             	cmp    $0x9,%edx
  80176c:	77 39                	ja     8017a7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80176e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801771:	eb e9                	jmp    80175c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801773:	8b 45 14             	mov    0x14(%ebp),%eax
  801776:	8d 48 04             	lea    0x4(%eax),%ecx
  801779:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80177c:	8b 00                	mov    (%eax),%eax
  80177e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801784:	eb 27                	jmp    8017ad <vprintfmt+0xdf>
  801786:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801789:	85 c0                	test   %eax,%eax
  80178b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801790:	0f 49 c8             	cmovns %eax,%ecx
  801793:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801796:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801799:	eb 8c                	jmp    801727 <vprintfmt+0x59>
  80179b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80179e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017a5:	eb 80                	jmp    801727 <vprintfmt+0x59>
  8017a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017aa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017b1:	0f 89 70 ff ff ff    	jns    801727 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c4:	e9 5e ff ff ff       	jmp    801727 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017cf:	e9 53 ff ff ff       	jmp    801727 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d7:	8d 50 04             	lea    0x4(%eax),%edx
  8017da:	89 55 14             	mov    %edx,0x14(%ebp)
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	53                   	push   %ebx
  8017e1:	ff 30                	pushl  (%eax)
  8017e3:	ff d6                	call   *%esi
			break;
  8017e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017eb:	e9 04 ff ff ff       	jmp    8016f4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f3:	8d 50 04             	lea    0x4(%eax),%edx
  8017f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f9:	8b 00                	mov    (%eax),%eax
  8017fb:	99                   	cltd   
  8017fc:	31 d0                	xor    %edx,%eax
  8017fe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801800:	83 f8 0f             	cmp    $0xf,%eax
  801803:	7f 0b                	jg     801810 <vprintfmt+0x142>
  801805:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80180c:	85 d2                	test   %edx,%edx
  80180e:	75 18                	jne    801828 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801810:	50                   	push   %eax
  801811:	68 e7 23 80 00       	push   $0x8023e7
  801816:	53                   	push   %ebx
  801817:	56                   	push   %esi
  801818:	e8 94 fe ff ff       	call   8016b1 <printfmt>
  80181d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801820:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801823:	e9 cc fe ff ff       	jmp    8016f4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801828:	52                   	push   %edx
  801829:	68 2d 23 80 00       	push   $0x80232d
  80182e:	53                   	push   %ebx
  80182f:	56                   	push   %esi
  801830:	e8 7c fe ff ff       	call   8016b1 <printfmt>
  801835:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801838:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80183b:	e9 b4 fe ff ff       	jmp    8016f4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801840:	8b 45 14             	mov    0x14(%ebp),%eax
  801843:	8d 50 04             	lea    0x4(%eax),%edx
  801846:	89 55 14             	mov    %edx,0x14(%ebp)
  801849:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80184b:	85 ff                	test   %edi,%edi
  80184d:	b8 e0 23 80 00       	mov    $0x8023e0,%eax
  801852:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801855:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801859:	0f 8e 94 00 00 00    	jle    8018f3 <vprintfmt+0x225>
  80185f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801863:	0f 84 98 00 00 00    	je     801901 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801869:	83 ec 08             	sub    $0x8,%esp
  80186c:	ff 75 d0             	pushl  -0x30(%ebp)
  80186f:	57                   	push   %edi
  801870:	e8 86 02 00 00       	call   801afb <strnlen>
  801875:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801878:	29 c1                	sub    %eax,%ecx
  80187a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80187d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801880:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801884:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801887:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80188a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80188c:	eb 0f                	jmp    80189d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	53                   	push   %ebx
  801892:	ff 75 e0             	pushl  -0x20(%ebp)
  801895:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801897:	83 ef 01             	sub    $0x1,%edi
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 ff                	test   %edi,%edi
  80189f:	7f ed                	jg     80188e <vprintfmt+0x1c0>
  8018a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018a7:	85 c9                	test   %ecx,%ecx
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ae:	0f 49 c1             	cmovns %ecx,%eax
  8018b1:	29 c1                	sub    %eax,%ecx
  8018b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018bc:	89 cb                	mov    %ecx,%ebx
  8018be:	eb 4d                	jmp    80190d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c4:	74 1b                	je     8018e1 <vprintfmt+0x213>
  8018c6:	0f be c0             	movsbl %al,%eax
  8018c9:	83 e8 20             	sub    $0x20,%eax
  8018cc:	83 f8 5e             	cmp    $0x5e,%eax
  8018cf:	76 10                	jbe    8018e1 <vprintfmt+0x213>
					putch('?', putdat);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	6a 3f                	push   $0x3f
  8018d9:	ff 55 08             	call   *0x8(%ebp)
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	eb 0d                	jmp    8018ee <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	52                   	push   %edx
  8018e8:	ff 55 08             	call   *0x8(%ebp)
  8018eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ee:	83 eb 01             	sub    $0x1,%ebx
  8018f1:	eb 1a                	jmp    80190d <vprintfmt+0x23f>
  8018f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ff:	eb 0c                	jmp    80190d <vprintfmt+0x23f>
  801901:	89 75 08             	mov    %esi,0x8(%ebp)
  801904:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801907:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80190a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80190d:	83 c7 01             	add    $0x1,%edi
  801910:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801914:	0f be d0             	movsbl %al,%edx
  801917:	85 d2                	test   %edx,%edx
  801919:	74 23                	je     80193e <vprintfmt+0x270>
  80191b:	85 f6                	test   %esi,%esi
  80191d:	78 a1                	js     8018c0 <vprintfmt+0x1f2>
  80191f:	83 ee 01             	sub    $0x1,%esi
  801922:	79 9c                	jns    8018c0 <vprintfmt+0x1f2>
  801924:	89 df                	mov    %ebx,%edi
  801926:	8b 75 08             	mov    0x8(%ebp),%esi
  801929:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80192c:	eb 18                	jmp    801946 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	53                   	push   %ebx
  801932:	6a 20                	push   $0x20
  801934:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801936:	83 ef 01             	sub    $0x1,%edi
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	eb 08                	jmp    801946 <vprintfmt+0x278>
  80193e:	89 df                	mov    %ebx,%edi
  801940:	8b 75 08             	mov    0x8(%ebp),%esi
  801943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801946:	85 ff                	test   %edi,%edi
  801948:	7f e4                	jg     80192e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80194d:	e9 a2 fd ff ff       	jmp    8016f4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801952:	83 fa 01             	cmp    $0x1,%edx
  801955:	7e 16                	jle    80196d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801957:	8b 45 14             	mov    0x14(%ebp),%eax
  80195a:	8d 50 08             	lea    0x8(%eax),%edx
  80195d:	89 55 14             	mov    %edx,0x14(%ebp)
  801960:	8b 50 04             	mov    0x4(%eax),%edx
  801963:	8b 00                	mov    (%eax),%eax
  801965:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801968:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80196b:	eb 32                	jmp    80199f <vprintfmt+0x2d1>
	else if (lflag)
  80196d:	85 d2                	test   %edx,%edx
  80196f:	74 18                	je     801989 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801971:	8b 45 14             	mov    0x14(%ebp),%eax
  801974:	8d 50 04             	lea    0x4(%eax),%edx
  801977:	89 55 14             	mov    %edx,0x14(%ebp)
  80197a:	8b 00                	mov    (%eax),%eax
  80197c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197f:	89 c1                	mov    %eax,%ecx
  801981:	c1 f9 1f             	sar    $0x1f,%ecx
  801984:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801987:	eb 16                	jmp    80199f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801989:	8b 45 14             	mov    0x14(%ebp),%eax
  80198c:	8d 50 04             	lea    0x4(%eax),%edx
  80198f:	89 55 14             	mov    %edx,0x14(%ebp)
  801992:	8b 00                	mov    (%eax),%eax
  801994:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801997:	89 c1                	mov    %eax,%ecx
  801999:	c1 f9 1f             	sar    $0x1f,%ecx
  80199c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80199f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019ae:	79 74                	jns    801a24 <vprintfmt+0x356>
				putch('-', putdat);
  8019b0:	83 ec 08             	sub    $0x8,%esp
  8019b3:	53                   	push   %ebx
  8019b4:	6a 2d                	push   $0x2d
  8019b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8019b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019be:	f7 d8                	neg    %eax
  8019c0:	83 d2 00             	adc    $0x0,%edx
  8019c3:	f7 da                	neg    %edx
  8019c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019cd:	eb 55                	jmp    801a24 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8019d2:	e8 83 fc ff ff       	call   80165a <getuint>
			base = 10;
  8019d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019dc:	eb 46                	jmp    801a24 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019de:	8d 45 14             	lea    0x14(%ebp),%eax
  8019e1:	e8 74 fc ff ff       	call   80165a <getuint>
			base = 8;
  8019e6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019eb:	eb 37                	jmp    801a24 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019ed:	83 ec 08             	sub    $0x8,%esp
  8019f0:	53                   	push   %ebx
  8019f1:	6a 30                	push   $0x30
  8019f3:	ff d6                	call   *%esi
			putch('x', putdat);
  8019f5:	83 c4 08             	add    $0x8,%esp
  8019f8:	53                   	push   %ebx
  8019f9:	6a 78                	push   $0x78
  8019fb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801a00:	8d 50 04             	lea    0x4(%eax),%edx
  801a03:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a06:	8b 00                	mov    (%eax),%eax
  801a08:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a0d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a10:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a15:	eb 0d                	jmp    801a24 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a17:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1a:	e8 3b fc ff ff       	call   80165a <getuint>
			base = 16;
  801a1f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a2b:	57                   	push   %edi
  801a2c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a2f:	51                   	push   %ecx
  801a30:	52                   	push   %edx
  801a31:	50                   	push   %eax
  801a32:	89 da                	mov    %ebx,%edx
  801a34:	89 f0                	mov    %esi,%eax
  801a36:	e8 70 fb ff ff       	call   8015ab <printnum>
			break;
  801a3b:	83 c4 20             	add    $0x20,%esp
  801a3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a41:	e9 ae fc ff ff       	jmp    8016f4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	51                   	push   %ecx
  801a4b:	ff d6                	call   *%esi
			break;
  801a4d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a53:	e9 9c fc ff ff       	jmp    8016f4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	53                   	push   %ebx
  801a5c:	6a 25                	push   $0x25
  801a5e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	eb 03                	jmp    801a68 <vprintfmt+0x39a>
  801a65:	83 ef 01             	sub    $0x1,%edi
  801a68:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a6c:	75 f7                	jne    801a65 <vprintfmt+0x397>
  801a6e:	e9 81 fc ff ff       	jmp    8016f4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 18             	sub    $0x18,%esp
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a87:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a8a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a8e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	74 26                	je     801ac2 <vsnprintf+0x47>
  801a9c:	85 d2                	test   %edx,%edx
  801a9e:	7e 22                	jle    801ac2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aa0:	ff 75 14             	pushl  0x14(%ebp)
  801aa3:	ff 75 10             	pushl  0x10(%ebp)
  801aa6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	68 94 16 80 00       	push   $0x801694
  801aaf:	e8 1a fc ff ff       	call   8016ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ab7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb 05                	jmp    801ac7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ac2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801acf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ad2:	50                   	push   %eax
  801ad3:	ff 75 10             	pushl  0x10(%ebp)
  801ad6:	ff 75 0c             	pushl  0xc(%ebp)
  801ad9:	ff 75 08             	pushl  0x8(%ebp)
  801adc:	e8 9a ff ff ff       	call   801a7b <vsnprintf>
	va_end(ap);

	return rc;
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aee:	eb 03                	jmp    801af3 <strlen+0x10>
		n++;
  801af0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801af3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801af7:	75 f7                	jne    801af0 <strlen+0xd>
		n++;
	return n;
}
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b01:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	eb 03                	jmp    801b0e <strnlen+0x13>
		n++;
  801b0b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b0e:	39 c2                	cmp    %eax,%edx
  801b10:	74 08                	je     801b1a <strnlen+0x1f>
  801b12:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b16:	75 f3                	jne    801b0b <strnlen+0x10>
  801b18:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	53                   	push   %ebx
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
  801b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b26:	89 c2                	mov    %eax,%edx
  801b28:	83 c2 01             	add    $0x1,%edx
  801b2b:	83 c1 01             	add    $0x1,%ecx
  801b2e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b32:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b35:	84 db                	test   %bl,%bl
  801b37:	75 ef                	jne    801b28 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b39:	5b                   	pop    %ebx
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b43:	53                   	push   %ebx
  801b44:	e8 9a ff ff ff       	call   801ae3 <strlen>
  801b49:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b4c:	ff 75 0c             	pushl  0xc(%ebp)
  801b4f:	01 d8                	add    %ebx,%eax
  801b51:	50                   	push   %eax
  801b52:	e8 c5 ff ff ff       	call   801b1c <strcpy>
	return dst;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
  801b63:	8b 75 08             	mov    0x8(%ebp),%esi
  801b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b69:	89 f3                	mov    %esi,%ebx
  801b6b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b6e:	89 f2                	mov    %esi,%edx
  801b70:	eb 0f                	jmp    801b81 <strncpy+0x23>
		*dst++ = *src;
  801b72:	83 c2 01             	add    $0x1,%edx
  801b75:	0f b6 01             	movzbl (%ecx),%eax
  801b78:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b7b:	80 39 01             	cmpb   $0x1,(%ecx)
  801b7e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b81:	39 da                	cmp    %ebx,%edx
  801b83:	75 ed                	jne    801b72 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b85:	89 f0                	mov    %esi,%eax
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
  801b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b96:	8b 55 10             	mov    0x10(%ebp),%edx
  801b99:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b9b:	85 d2                	test   %edx,%edx
  801b9d:	74 21                	je     801bc0 <strlcpy+0x35>
  801b9f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ba3:	89 f2                	mov    %esi,%edx
  801ba5:	eb 09                	jmp    801bb0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ba7:	83 c2 01             	add    $0x1,%edx
  801baa:	83 c1 01             	add    $0x1,%ecx
  801bad:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bb0:	39 c2                	cmp    %eax,%edx
  801bb2:	74 09                	je     801bbd <strlcpy+0x32>
  801bb4:	0f b6 19             	movzbl (%ecx),%ebx
  801bb7:	84 db                	test   %bl,%bl
  801bb9:	75 ec                	jne    801ba7 <strlcpy+0x1c>
  801bbb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bbd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bc0:	29 f0                	sub    %esi,%eax
}
  801bc2:	5b                   	pop    %ebx
  801bc3:	5e                   	pop    %esi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bcf:	eb 06                	jmp    801bd7 <strcmp+0x11>
		p++, q++;
  801bd1:	83 c1 01             	add    $0x1,%ecx
  801bd4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bd7:	0f b6 01             	movzbl (%ecx),%eax
  801bda:	84 c0                	test   %al,%al
  801bdc:	74 04                	je     801be2 <strcmp+0x1c>
  801bde:	3a 02                	cmp    (%edx),%al
  801be0:	74 ef                	je     801bd1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801be2:	0f b6 c0             	movzbl %al,%eax
  801be5:	0f b6 12             	movzbl (%edx),%edx
  801be8:	29 d0                	sub    %edx,%eax
}
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	53                   	push   %ebx
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801bfb:	eb 06                	jmp    801c03 <strncmp+0x17>
		n--, p++, q++;
  801bfd:	83 c0 01             	add    $0x1,%eax
  801c00:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c03:	39 d8                	cmp    %ebx,%eax
  801c05:	74 15                	je     801c1c <strncmp+0x30>
  801c07:	0f b6 08             	movzbl (%eax),%ecx
  801c0a:	84 c9                	test   %cl,%cl
  801c0c:	74 04                	je     801c12 <strncmp+0x26>
  801c0e:	3a 0a                	cmp    (%edx),%cl
  801c10:	74 eb                	je     801bfd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c12:	0f b6 00             	movzbl (%eax),%eax
  801c15:	0f b6 12             	movzbl (%edx),%edx
  801c18:	29 d0                	sub    %edx,%eax
  801c1a:	eb 05                	jmp    801c21 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c1c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c21:	5b                   	pop    %ebx
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c2e:	eb 07                	jmp    801c37 <strchr+0x13>
		if (*s == c)
  801c30:	38 ca                	cmp    %cl,%dl
  801c32:	74 0f                	je     801c43 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c34:	83 c0 01             	add    $0x1,%eax
  801c37:	0f b6 10             	movzbl (%eax),%edx
  801c3a:	84 d2                	test   %dl,%dl
  801c3c:	75 f2                	jne    801c30 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c4f:	eb 03                	jmp    801c54 <strfind+0xf>
  801c51:	83 c0 01             	add    $0x1,%eax
  801c54:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c57:	38 ca                	cmp    %cl,%dl
  801c59:	74 04                	je     801c5f <strfind+0x1a>
  801c5b:	84 d2                	test   %dl,%dl
  801c5d:	75 f2                	jne    801c51 <strfind+0xc>
			break;
	return (char *) s;
}
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	57                   	push   %edi
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c6d:	85 c9                	test   %ecx,%ecx
  801c6f:	74 36                	je     801ca7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c77:	75 28                	jne    801ca1 <memset+0x40>
  801c79:	f6 c1 03             	test   $0x3,%cl
  801c7c:	75 23                	jne    801ca1 <memset+0x40>
		c &= 0xFF;
  801c7e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c82:	89 d3                	mov    %edx,%ebx
  801c84:	c1 e3 08             	shl    $0x8,%ebx
  801c87:	89 d6                	mov    %edx,%esi
  801c89:	c1 e6 18             	shl    $0x18,%esi
  801c8c:	89 d0                	mov    %edx,%eax
  801c8e:	c1 e0 10             	shl    $0x10,%eax
  801c91:	09 f0                	or     %esi,%eax
  801c93:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c95:	89 d8                	mov    %ebx,%eax
  801c97:	09 d0                	or     %edx,%eax
  801c99:	c1 e9 02             	shr    $0x2,%ecx
  801c9c:	fc                   	cld    
  801c9d:	f3 ab                	rep stos %eax,%es:(%edi)
  801c9f:	eb 06                	jmp    801ca7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca4:	fc                   	cld    
  801ca5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ca7:	89 f8                	mov    %edi,%eax
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5f                   	pop    %edi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cb9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cbc:	39 c6                	cmp    %eax,%esi
  801cbe:	73 35                	jae    801cf5 <memmove+0x47>
  801cc0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cc3:	39 d0                	cmp    %edx,%eax
  801cc5:	73 2e                	jae    801cf5 <memmove+0x47>
		s += n;
		d += n;
  801cc7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cca:	89 d6                	mov    %edx,%esi
  801ccc:	09 fe                	or     %edi,%esi
  801cce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cd4:	75 13                	jne    801ce9 <memmove+0x3b>
  801cd6:	f6 c1 03             	test   $0x3,%cl
  801cd9:	75 0e                	jne    801ce9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cdb:	83 ef 04             	sub    $0x4,%edi
  801cde:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ce1:	c1 e9 02             	shr    $0x2,%ecx
  801ce4:	fd                   	std    
  801ce5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ce7:	eb 09                	jmp    801cf2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801ce9:	83 ef 01             	sub    $0x1,%edi
  801cec:	8d 72 ff             	lea    -0x1(%edx),%esi
  801cef:	fd                   	std    
  801cf0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801cf2:	fc                   	cld    
  801cf3:	eb 1d                	jmp    801d12 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	09 c2                	or     %eax,%edx
  801cf9:	f6 c2 03             	test   $0x3,%dl
  801cfc:	75 0f                	jne    801d0d <memmove+0x5f>
  801cfe:	f6 c1 03             	test   $0x3,%cl
  801d01:	75 0a                	jne    801d0d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d03:	c1 e9 02             	shr    $0x2,%ecx
  801d06:	89 c7                	mov    %eax,%edi
  801d08:	fc                   	cld    
  801d09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d0b:	eb 05                	jmp    801d12 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d0d:	89 c7                	mov    %eax,%edi
  801d0f:	fc                   	cld    
  801d10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d19:	ff 75 10             	pushl  0x10(%ebp)
  801d1c:	ff 75 0c             	pushl  0xc(%ebp)
  801d1f:	ff 75 08             	pushl  0x8(%ebp)
  801d22:	e8 87 ff ff ff       	call   801cae <memmove>
}
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d34:	89 c6                	mov    %eax,%esi
  801d36:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d39:	eb 1a                	jmp    801d55 <memcmp+0x2c>
		if (*s1 != *s2)
  801d3b:	0f b6 08             	movzbl (%eax),%ecx
  801d3e:	0f b6 1a             	movzbl (%edx),%ebx
  801d41:	38 d9                	cmp    %bl,%cl
  801d43:	74 0a                	je     801d4f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d45:	0f b6 c1             	movzbl %cl,%eax
  801d48:	0f b6 db             	movzbl %bl,%ebx
  801d4b:	29 d8                	sub    %ebx,%eax
  801d4d:	eb 0f                	jmp    801d5e <memcmp+0x35>
		s1++, s2++;
  801d4f:	83 c0 01             	add    $0x1,%eax
  801d52:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d55:	39 f0                	cmp    %esi,%eax
  801d57:	75 e2                	jne    801d3b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	53                   	push   %ebx
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d69:	89 c1                	mov    %eax,%ecx
  801d6b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d6e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d72:	eb 0a                	jmp    801d7e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d74:	0f b6 10             	movzbl (%eax),%edx
  801d77:	39 da                	cmp    %ebx,%edx
  801d79:	74 07                	je     801d82 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d7b:	83 c0 01             	add    $0x1,%eax
  801d7e:	39 c8                	cmp    %ecx,%eax
  801d80:	72 f2                	jb     801d74 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d82:	5b                   	pop    %ebx
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	57                   	push   %edi
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d91:	eb 03                	jmp    801d96 <strtol+0x11>
		s++;
  801d93:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d96:	0f b6 01             	movzbl (%ecx),%eax
  801d99:	3c 20                	cmp    $0x20,%al
  801d9b:	74 f6                	je     801d93 <strtol+0xe>
  801d9d:	3c 09                	cmp    $0x9,%al
  801d9f:	74 f2                	je     801d93 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801da1:	3c 2b                	cmp    $0x2b,%al
  801da3:	75 0a                	jne    801daf <strtol+0x2a>
		s++;
  801da5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801da8:	bf 00 00 00 00       	mov    $0x0,%edi
  801dad:	eb 11                	jmp    801dc0 <strtol+0x3b>
  801daf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801db4:	3c 2d                	cmp    $0x2d,%al
  801db6:	75 08                	jne    801dc0 <strtol+0x3b>
		s++, neg = 1;
  801db8:	83 c1 01             	add    $0x1,%ecx
  801dbb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dc0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dc6:	75 15                	jne    801ddd <strtol+0x58>
  801dc8:	80 39 30             	cmpb   $0x30,(%ecx)
  801dcb:	75 10                	jne    801ddd <strtol+0x58>
  801dcd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dd1:	75 7c                	jne    801e4f <strtol+0xca>
		s += 2, base = 16;
  801dd3:	83 c1 02             	add    $0x2,%ecx
  801dd6:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ddb:	eb 16                	jmp    801df3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ddd:	85 db                	test   %ebx,%ebx
  801ddf:	75 12                	jne    801df3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801de1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801de6:	80 39 30             	cmpb   $0x30,(%ecx)
  801de9:	75 08                	jne    801df3 <strtol+0x6e>
		s++, base = 8;
  801deb:	83 c1 01             	add    $0x1,%ecx
  801dee:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
  801df8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801dfb:	0f b6 11             	movzbl (%ecx),%edx
  801dfe:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e01:	89 f3                	mov    %esi,%ebx
  801e03:	80 fb 09             	cmp    $0x9,%bl
  801e06:	77 08                	ja     801e10 <strtol+0x8b>
			dig = *s - '0';
  801e08:	0f be d2             	movsbl %dl,%edx
  801e0b:	83 ea 30             	sub    $0x30,%edx
  801e0e:	eb 22                	jmp    801e32 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e10:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e13:	89 f3                	mov    %esi,%ebx
  801e15:	80 fb 19             	cmp    $0x19,%bl
  801e18:	77 08                	ja     801e22 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e1a:	0f be d2             	movsbl %dl,%edx
  801e1d:	83 ea 57             	sub    $0x57,%edx
  801e20:	eb 10                	jmp    801e32 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e22:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e25:	89 f3                	mov    %esi,%ebx
  801e27:	80 fb 19             	cmp    $0x19,%bl
  801e2a:	77 16                	ja     801e42 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e2c:	0f be d2             	movsbl %dl,%edx
  801e2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e32:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e35:	7d 0b                	jge    801e42 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e37:	83 c1 01             	add    $0x1,%ecx
  801e3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e3e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e40:	eb b9                	jmp    801dfb <strtol+0x76>

	if (endptr)
  801e42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e46:	74 0d                	je     801e55 <strtol+0xd0>
		*endptr = (char *) s;
  801e48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4b:	89 0e                	mov    %ecx,(%esi)
  801e4d:	eb 06                	jmp    801e55 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e4f:	85 db                	test   %ebx,%ebx
  801e51:	74 98                	je     801deb <strtol+0x66>
  801e53:	eb 9e                	jmp    801df3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e55:	89 c2                	mov    %eax,%edx
  801e57:	f7 da                	neg    %edx
  801e59:	85 ff                	test   %edi,%edi
  801e5b:	0f 45 c2             	cmovne %edx,%eax
}
  801e5e:	5b                   	pop    %ebx
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    

00801e63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	56                   	push   %esi
  801e67:	53                   	push   %ebx
  801e68:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e71:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e73:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e78:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	50                   	push   %eax
  801e7f:	e8 96 e4 ff ff       	call   80031a <sys_ipc_recv>

	if (from_env_store != NULL)
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 f6                	test   %esi,%esi
  801e89:	74 14                	je     801e9f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 09                	js     801e9d <ipc_recv+0x3a>
  801e94:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e9a:	8b 52 74             	mov    0x74(%edx),%edx
  801e9d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	74 14                	je     801eb7 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ea3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	78 09                	js     801eb5 <ipc_recv+0x52>
  801eac:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eb2:	8b 52 78             	mov    0x78(%edx),%edx
  801eb5:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 08                	js     801ec3 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ebb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec6:	5b                   	pop    %ebx
  801ec7:	5e                   	pop    %esi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    

00801eca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801edc:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ede:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ee3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ee6:	ff 75 14             	pushl  0x14(%ebp)
  801ee9:	53                   	push   %ebx
  801eea:	56                   	push   %esi
  801eeb:	57                   	push   %edi
  801eec:	e8 06 e4 ff ff       	call   8002f7 <sys_ipc_try_send>

		if (err < 0) {
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	79 1e                	jns    801f16 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ef8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efb:	75 07                	jne    801f04 <ipc_send+0x3a>
				sys_yield();
  801efd:	e8 49 e2 ff ff       	call   80014b <sys_yield>
  801f02:	eb e2                	jmp    801ee6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f04:	50                   	push   %eax
  801f05:	68 e0 26 80 00       	push   $0x8026e0
  801f0a:	6a 49                	push   $0x49
  801f0c:	68 ed 26 80 00       	push   $0x8026ed
  801f11:	e8 a8 f5 ff ff       	call   8014be <_panic>
		}

	} while (err < 0);

}
  801f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5f                   	pop    %edi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f32:	8b 52 50             	mov    0x50(%edx),%edx
  801f35:	39 ca                	cmp    %ecx,%edx
  801f37:	75 0d                	jne    801f46 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f41:	8b 40 48             	mov    0x48(%eax),%eax
  801f44:	eb 0f                	jmp    801f55 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f46:	83 c0 01             	add    $0x1,%eax
  801f49:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f4e:	75 d9                	jne    801f29 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5d:	89 d0                	mov    %edx,%eax
  801f5f:	c1 e8 16             	shr    $0x16,%eax
  801f62:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f69:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6e:	f6 c1 01             	test   $0x1,%cl
  801f71:	74 1d                	je     801f90 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f73:	c1 ea 0c             	shr    $0xc,%edx
  801f76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f7d:	f6 c2 01             	test   $0x1,%dl
  801f80:	74 0e                	je     801f90 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f82:	c1 ea 0c             	shr    $0xc,%edx
  801f85:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f8c:	ef 
  801f8d:	0f b7 c0             	movzwl %ax,%eax
}
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	66 90                	xchg   %ax,%ax
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
