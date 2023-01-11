
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 c0 	movl   $0x8022c0,0x803000
  800040:	22 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 2a 05 00 00       	call   8005c5 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 cf 22 80 00       	push   $0x8022cf
  800114:	6a 23                	push   $0x23
  800116:	68 ec 22 80 00       	push   $0x8022ec
  80011b:	e8 1e 14 00 00       	call   80153e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 cf 22 80 00       	push   $0x8022cf
  800195:	6a 23                	push   $0x23
  800197:	68 ec 22 80 00       	push   $0x8022ec
  80019c:	e8 9d 13 00 00       	call   80153e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 cf 22 80 00       	push   $0x8022cf
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 ec 22 80 00       	push   $0x8022ec
  8001de:	e8 5b 13 00 00       	call   80153e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 cf 22 80 00       	push   $0x8022cf
  800219:	6a 23                	push   $0x23
  80021b:	68 ec 22 80 00       	push   $0x8022ec
  800220:	e8 19 13 00 00       	call   80153e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 cf 22 80 00       	push   $0x8022cf
  80025b:	6a 23                	push   $0x23
  80025d:	68 ec 22 80 00       	push   $0x8022ec
  800262:	e8 d7 12 00 00       	call   80153e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 cf 22 80 00       	push   $0x8022cf
  80029d:	6a 23                	push   $0x23
  80029f:	68 ec 22 80 00       	push   $0x8022ec
  8002a4:	e8 95 12 00 00       	call   80153e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 cf 22 80 00       	push   $0x8022cf
  8002df:	6a 23                	push   $0x23
  8002e1:	68 ec 22 80 00       	push   $0x8022ec
  8002e6:	e8 53 12 00 00       	call   80153e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 cf 22 80 00       	push   $0x8022cf
  800343:	6a 23                	push   $0x23
  800345:	68 ec 22 80 00       	push   $0x8022ec
  80034a:	e8 ef 11 00 00       	call   80153e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800384:	b8 0f 00 00 00       	mov    $0xf,%eax
  800389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038c:	8b 55 08             	mov    0x8(%ebp),%edx
  80038f:	89 df                	mov    %ebx,%edi
  800391:	89 de                	mov    %ebx,%esi
  800393:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800395:	85 c0                	test   %eax,%eax
  800397:	7e 17                	jle    8003b0 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800399:	83 ec 0c             	sub    $0xc,%esp
  80039c:	50                   	push   %eax
  80039d:	6a 0f                	push   $0xf
  80039f:	68 cf 22 80 00       	push   $0x8022cf
  8003a4:	6a 23                	push   $0x23
  8003a6:	68 ec 22 80 00       	push   $0x8022ec
  8003ab:	e8 8e 11 00 00       	call   80153e <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	57                   	push   %edi
  8003bc:	56                   	push   %esi
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8003cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d1:	89 df                	mov    %ebx,%edi
  8003d3:	89 de                	mov    %ebx,%esi
  8003d5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	7e 17                	jle    8003f2 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003db:	83 ec 0c             	sub    $0xc,%esp
  8003de:	50                   	push   %eax
  8003df:	6a 10                	push   $0x10
  8003e1:	68 cf 22 80 00       	push   $0x8022cf
  8003e6:	6a 23                	push   $0x23
  8003e8:	68 ec 22 80 00       	push   $0x8022ec
  8003ed:	e8 4c 11 00 00       	call   80153e <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f5:	5b                   	pop    %ebx
  8003f6:	5e                   	pop    %esi
  8003f7:	5f                   	pop    %edi
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	05 00 00 00 30       	add    $0x30000000,%eax
  800405:	c1 e8 0c             	shr    $0xc,%eax
}
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	05 00 00 00 30       	add    $0x30000000,%eax
  800415:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80041a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800427:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80042c:	89 c2                	mov    %eax,%edx
  80042e:	c1 ea 16             	shr    $0x16,%edx
  800431:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800438:	f6 c2 01             	test   $0x1,%dl
  80043b:	74 11                	je     80044e <fd_alloc+0x2d>
  80043d:	89 c2                	mov    %eax,%edx
  80043f:	c1 ea 0c             	shr    $0xc,%edx
  800442:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800449:	f6 c2 01             	test   $0x1,%dl
  80044c:	75 09                	jne    800457 <fd_alloc+0x36>
			*fd_store = fd;
  80044e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	eb 17                	jmp    80046e <fd_alloc+0x4d>
  800457:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80045c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800461:	75 c9                	jne    80042c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800463:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800469:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800476:	83 f8 1f             	cmp    $0x1f,%eax
  800479:	77 36                	ja     8004b1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80047b:	c1 e0 0c             	shl    $0xc,%eax
  80047e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800483:	89 c2                	mov    %eax,%edx
  800485:	c1 ea 16             	shr    $0x16,%edx
  800488:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048f:	f6 c2 01             	test   $0x1,%dl
  800492:	74 24                	je     8004b8 <fd_lookup+0x48>
  800494:	89 c2                	mov    %eax,%edx
  800496:	c1 ea 0c             	shr    $0xc,%edx
  800499:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a0:	f6 c2 01             	test   $0x1,%dl
  8004a3:	74 1a                	je     8004bf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a8:	89 02                	mov    %eax,(%edx)
	return 0;
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	eb 13                	jmp    8004c4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b6:	eb 0c                	jmp    8004c4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bd:	eb 05                	jmp    8004c4 <fd_lookup+0x54>
  8004bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cf:	ba 78 23 80 00       	mov    $0x802378,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d4:	eb 13                	jmp    8004e9 <dev_lookup+0x23>
  8004d6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004d9:	39 08                	cmp    %ecx,(%eax)
  8004db:	75 0c                	jne    8004e9 <dev_lookup+0x23>
			*dev = devtab[i];
  8004dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e7:	eb 2e                	jmp    800517 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 e7                	jne    8004d6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8004f4:	8b 40 48             	mov    0x48(%eax),%eax
  8004f7:	83 ec 04             	sub    $0x4,%esp
  8004fa:	51                   	push   %ecx
  8004fb:	50                   	push   %eax
  8004fc:	68 fc 22 80 00       	push   $0x8022fc
  800501:	e8 11 11 00 00       	call   801617 <cprintf>
	*dev = 0;
  800506:	8b 45 0c             	mov    0xc(%ebp),%eax
  800509:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800517:	c9                   	leave  
  800518:	c3                   	ret    

00800519 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	83 ec 10             	sub    $0x10,%esp
  800521:	8b 75 08             	mov    0x8(%ebp),%esi
  800524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052a:	50                   	push   %eax
  80052b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800531:	c1 e8 0c             	shr    $0xc,%eax
  800534:	50                   	push   %eax
  800535:	e8 36 ff ff ff       	call   800470 <fd_lookup>
  80053a:	83 c4 08             	add    $0x8,%esp
  80053d:	85 c0                	test   %eax,%eax
  80053f:	78 05                	js     800546 <fd_close+0x2d>
	    || fd != fd2)
  800541:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800544:	74 0c                	je     800552 <fd_close+0x39>
		return (must_exist ? r : 0);
  800546:	84 db                	test   %bl,%bl
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
  80054d:	0f 44 c2             	cmove  %edx,%eax
  800550:	eb 41                	jmp    800593 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 36                	pushl  (%esi)
  80055b:	e8 66 ff ff ff       	call   8004c6 <dev_lookup>
  800560:	89 c3                	mov    %eax,%ebx
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	85 c0                	test   %eax,%eax
  800567:	78 1a                	js     800583 <fd_close+0x6a>
		if (dev->dev_close)
  800569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80056c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80056f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800574:	85 c0                	test   %eax,%eax
  800576:	74 0b                	je     800583 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	56                   	push   %esi
  80057c:	ff d0                	call   *%eax
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	56                   	push   %esi
  800587:	6a 00                	push   $0x0
  800589:	e8 5d fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	89 d8                	mov    %ebx,%eax
}
  800593:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5d                   	pop    %ebp
  800599:	c3                   	ret    

0080059a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	ff 75 08             	pushl  0x8(%ebp)
  8005a7:	e8 c4 fe ff ff       	call   800470 <fd_lookup>
  8005ac:	83 c4 08             	add    $0x8,%esp
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	78 10                	js     8005c3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	6a 01                	push   $0x1
  8005b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8005bb:	e8 59 ff ff ff       	call   800519 <fd_close>
  8005c0:	83 c4 10             	add    $0x10,%esp
}
  8005c3:	c9                   	leave  
  8005c4:	c3                   	ret    

008005c5 <close_all>:

void
close_all(void)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
  8005c8:	53                   	push   %ebx
  8005c9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d1:	83 ec 0c             	sub    $0xc,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	e8 c0 ff ff ff       	call   80059a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005da:	83 c3 01             	add    $0x1,%ebx
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	83 fb 20             	cmp    $0x20,%ebx
  8005e3:	75 ec                	jne    8005d1 <close_all+0xc>
		close(i);
}
  8005e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005e8:	c9                   	leave  
  8005e9:	c3                   	ret    

008005ea <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	57                   	push   %edi
  8005ee:	56                   	push   %esi
  8005ef:	53                   	push   %ebx
  8005f0:	83 ec 2c             	sub    $0x2c,%esp
  8005f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 08             	pushl  0x8(%ebp)
  8005fd:	e8 6e fe ff ff       	call   800470 <fd_lookup>
  800602:	83 c4 08             	add    $0x8,%esp
  800605:	85 c0                	test   %eax,%eax
  800607:	0f 88 c1 00 00 00    	js     8006ce <dup+0xe4>
		return r;
	close(newfdnum);
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	56                   	push   %esi
  800611:	e8 84 ff ff ff       	call   80059a <close>

	newfd = INDEX2FD(newfdnum);
  800616:	89 f3                	mov    %esi,%ebx
  800618:	c1 e3 0c             	shl    $0xc,%ebx
  80061b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800621:	83 c4 04             	add    $0x4,%esp
  800624:	ff 75 e4             	pushl  -0x1c(%ebp)
  800627:	e8 de fd ff ff       	call   80040a <fd2data>
  80062c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80062e:	89 1c 24             	mov    %ebx,(%esp)
  800631:	e8 d4 fd ff ff       	call   80040a <fd2data>
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80063c:	89 f8                	mov    %edi,%eax
  80063e:	c1 e8 16             	shr    $0x16,%eax
  800641:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800648:	a8 01                	test   $0x1,%al
  80064a:	74 37                	je     800683 <dup+0x99>
  80064c:	89 f8                	mov    %edi,%eax
  80064e:	c1 e8 0c             	shr    $0xc,%eax
  800651:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800658:	f6 c2 01             	test   $0x1,%dl
  80065b:	74 26                	je     800683 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	25 07 0e 00 00       	and    $0xe07,%eax
  80066c:	50                   	push   %eax
  80066d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800670:	6a 00                	push   $0x0
  800672:	57                   	push   %edi
  800673:	6a 00                	push   $0x0
  800675:	e8 2f fb ff ff       	call   8001a9 <sys_page_map>
  80067a:	89 c7                	mov    %eax,%edi
  80067c:	83 c4 20             	add    $0x20,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 2e                	js     8006b1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800683:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800686:	89 d0                	mov    %edx,%eax
  800688:	c1 e8 0c             	shr    $0xc,%eax
  80068b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800692:	83 ec 0c             	sub    $0xc,%esp
  800695:	25 07 0e 00 00       	and    $0xe07,%eax
  80069a:	50                   	push   %eax
  80069b:	53                   	push   %ebx
  80069c:	6a 00                	push   $0x0
  80069e:	52                   	push   %edx
  80069f:	6a 00                	push   $0x0
  8006a1:	e8 03 fb ff ff       	call   8001a9 <sys_page_map>
  8006a6:	89 c7                	mov    %eax,%edi
  8006a8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006ab:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ad:	85 ff                	test   %edi,%edi
  8006af:	79 1d                	jns    8006ce <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 00                	push   $0x0
  8006b7:	e8 2f fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006bc:	83 c4 08             	add    $0x8,%esp
  8006bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006c2:	6a 00                	push   $0x0
  8006c4:	e8 22 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	89 f8                	mov    %edi,%eax
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 14             	sub    $0x14,%esp
  8006dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e3:	50                   	push   %eax
  8006e4:	53                   	push   %ebx
  8006e5:	e8 86 fd ff ff       	call   800470 <fd_lookup>
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	89 c2                	mov    %eax,%edx
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	78 6d                	js     800760 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fd:	ff 30                	pushl  (%eax)
  8006ff:	e8 c2 fd ff ff       	call   8004c6 <dev_lookup>
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 c0                	test   %eax,%eax
  800709:	78 4c                	js     800757 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80070b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80070e:	8b 42 08             	mov    0x8(%edx),%eax
  800711:	83 e0 03             	and    $0x3,%eax
  800714:	83 f8 01             	cmp    $0x1,%eax
  800717:	75 21                	jne    80073a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800719:	a1 08 40 80 00       	mov    0x804008,%eax
  80071e:	8b 40 48             	mov    0x48(%eax),%eax
  800721:	83 ec 04             	sub    $0x4,%esp
  800724:	53                   	push   %ebx
  800725:	50                   	push   %eax
  800726:	68 3d 23 80 00       	push   $0x80233d
  80072b:	e8 e7 0e 00 00       	call   801617 <cprintf>
		return -E_INVAL;
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800738:	eb 26                	jmp    800760 <read+0x8a>
	}
	if (!dev->dev_read)
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	8b 40 08             	mov    0x8(%eax),%eax
  800740:	85 c0                	test   %eax,%eax
  800742:	74 17                	je     80075b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800744:	83 ec 04             	sub    $0x4,%esp
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff d0                	call   *%eax
  800750:	89 c2                	mov    %eax,%edx
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	eb 09                	jmp    800760 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800757:	89 c2                	mov    %eax,%edx
  800759:	eb 05                	jmp    800760 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80075b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800760:	89 d0                	mov    %edx,%eax
  800762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	57                   	push   %edi
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	83 ec 0c             	sub    $0xc,%esp
  800770:	8b 7d 08             	mov    0x8(%ebp),%edi
  800773:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077b:	eb 21                	jmp    80079e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80077d:	83 ec 04             	sub    $0x4,%esp
  800780:	89 f0                	mov    %esi,%eax
  800782:	29 d8                	sub    %ebx,%eax
  800784:	50                   	push   %eax
  800785:	89 d8                	mov    %ebx,%eax
  800787:	03 45 0c             	add    0xc(%ebp),%eax
  80078a:	50                   	push   %eax
  80078b:	57                   	push   %edi
  80078c:	e8 45 ff ff ff       	call   8006d6 <read>
		if (m < 0)
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	85 c0                	test   %eax,%eax
  800796:	78 10                	js     8007a8 <readn+0x41>
			return m;
		if (m == 0)
  800798:	85 c0                	test   %eax,%eax
  80079a:	74 0a                	je     8007a6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80079c:	01 c3                	add    %eax,%ebx
  80079e:	39 f3                	cmp    %esi,%ebx
  8007a0:	72 db                	jb     80077d <readn+0x16>
  8007a2:	89 d8                	mov    %ebx,%eax
  8007a4:	eb 02                	jmp    8007a8 <readn+0x41>
  8007a6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5f                   	pop    %edi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 14             	sub    $0x14,%esp
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	53                   	push   %ebx
  8007bf:	e8 ac fc ff ff       	call   800470 <fd_lookup>
  8007c4:	83 c4 08             	add    $0x8,%esp
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 68                	js     800835 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d7:	ff 30                	pushl  (%eax)
  8007d9:	e8 e8 fc ff ff       	call   8004c6 <dev_lookup>
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	78 47                	js     80082c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ec:	75 21                	jne    80080f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f3:	8b 40 48             	mov    0x48(%eax),%eax
  8007f6:	83 ec 04             	sub    $0x4,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	50                   	push   %eax
  8007fb:	68 59 23 80 00       	push   $0x802359
  800800:	e8 12 0e 00 00       	call   801617 <cprintf>
		return -E_INVAL;
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080d:	eb 26                	jmp    800835 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80080f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800812:	8b 52 0c             	mov    0xc(%edx),%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 17                	je     800830 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800819:	83 ec 04             	sub    $0x4,%esp
  80081c:	ff 75 10             	pushl  0x10(%ebp)
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	50                   	push   %eax
  800823:	ff d2                	call   *%edx
  800825:	89 c2                	mov    %eax,%edx
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	eb 09                	jmp    800835 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	eb 05                	jmp    800835 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800830:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800835:	89 d0                	mov    %edx,%eax
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <seek>:

int
seek(int fdnum, off_t offset)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800842:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	ff 75 08             	pushl  0x8(%ebp)
  800849:	e8 22 fc ff ff       	call   800470 <fd_lookup>
  80084e:	83 c4 08             	add    $0x8,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 0e                	js     800863 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800855:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	83 ec 14             	sub    $0x14,%esp
  80086c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800872:	50                   	push   %eax
  800873:	53                   	push   %ebx
  800874:	e8 f7 fb ff ff       	call   800470 <fd_lookup>
  800879:	83 c4 08             	add    $0x8,%esp
  80087c:	89 c2                	mov    %eax,%edx
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 65                	js     8008e7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088c:	ff 30                	pushl  (%eax)
  80088e:	e8 33 fc ff ff       	call   8004c6 <dev_lookup>
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	85 c0                	test   %eax,%eax
  800898:	78 44                	js     8008de <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80089a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a1:	75 21                	jne    8008c4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008a3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a8:	8b 40 48             	mov    0x48(%eax),%eax
  8008ab:	83 ec 04             	sub    $0x4,%esp
  8008ae:	53                   	push   %ebx
  8008af:	50                   	push   %eax
  8008b0:	68 1c 23 80 00       	push   $0x80231c
  8008b5:	e8 5d 0d 00 00       	call   801617 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008c2:	eb 23                	jmp    8008e7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c7:	8b 52 18             	mov    0x18(%edx),%edx
  8008ca:	85 d2                	test   %edx,%edx
  8008cc:	74 14                	je     8008e2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	50                   	push   %eax
  8008d5:	ff d2                	call   *%edx
  8008d7:	89 c2                	mov    %eax,%edx
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	eb 09                	jmp    8008e7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008de:	89 c2                	mov    %eax,%edx
  8008e0:	eb 05                	jmp    8008e7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	53                   	push   %ebx
  8008f2:	83 ec 14             	sub    $0x14,%esp
  8008f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 6c fb ff ff       	call   800470 <fd_lookup>
  800904:	83 c4 08             	add    $0x8,%esp
  800907:	89 c2                	mov    %eax,%edx
  800909:	85 c0                	test   %eax,%eax
  80090b:	78 58                	js     800965 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800917:	ff 30                	pushl  (%eax)
  800919:	e8 a8 fb ff ff       	call   8004c6 <dev_lookup>
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	85 c0                	test   %eax,%eax
  800923:	78 37                	js     80095c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800928:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80092c:	74 32                	je     800960 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80092e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800931:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800938:	00 00 00 
	stat->st_isdir = 0;
  80093b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800942:	00 00 00 
	stat->st_dev = dev;
  800945:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	53                   	push   %ebx
  80094f:	ff 75 f0             	pushl  -0x10(%ebp)
  800952:	ff 50 14             	call   *0x14(%eax)
  800955:	89 c2                	mov    %eax,%edx
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	eb 09                	jmp    800965 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80095c:	89 c2                	mov    %eax,%edx
  80095e:	eb 05                	jmp    800965 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800960:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800965:	89 d0                	mov    %edx,%eax
  800967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800971:	83 ec 08             	sub    $0x8,%esp
  800974:	6a 00                	push   $0x0
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 d6 01 00 00       	call   800b54 <open>
  80097e:	89 c3                	mov    %eax,%ebx
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	85 c0                	test   %eax,%eax
  800985:	78 1b                	js     8009a2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	50                   	push   %eax
  80098e:	e8 5b ff ff ff       	call   8008ee <fstat>
  800993:	89 c6                	mov    %eax,%esi
	close(fd);
  800995:	89 1c 24             	mov    %ebx,(%esp)
  800998:	e8 fd fb ff ff       	call   80059a <close>
	return r;
  80099d:	83 c4 10             	add    $0x10,%esp
  8009a0:	89 f0                	mov    %esi,%eax
}
  8009a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	89 c6                	mov    %eax,%esi
  8009b0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009b2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b9:	75 12                	jne    8009cd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009bb:	83 ec 0c             	sub    $0xc,%esp
  8009be:	6a 01                	push   $0x1
  8009c0:	e8 d9 15 00 00       	call   801f9e <ipc_find_env>
  8009c5:	a3 00 40 80 00       	mov    %eax,0x804000
  8009ca:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009cd:	6a 07                	push   $0x7
  8009cf:	68 00 50 80 00       	push   $0x805000
  8009d4:	56                   	push   %esi
  8009d5:	ff 35 00 40 80 00    	pushl  0x804000
  8009db:	e8 6a 15 00 00       	call   801f4a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009e0:	83 c4 0c             	add    $0xc,%esp
  8009e3:	6a 00                	push   $0x0
  8009e5:	53                   	push   %ebx
  8009e6:	6a 00                	push   $0x0
  8009e8:	e8 f6 14 00 00       	call   801ee3 <ipc_recv>
}
  8009ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 40 0c             	mov    0xc(%eax),%eax
  800a00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 02 00 00 00       	mov    $0x2,%eax
  800a17:	e8 8d ff ff ff       	call   8009a9 <fsipc>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 06 00 00 00       	mov    $0x6,%eax
  800a39:	e8 6b ff ff ff       	call   8009a9 <fsipc>
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	83 ec 04             	sub    $0x4,%esp
  800a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a50:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a5f:	e8 45 ff ff ff       	call   8009a9 <fsipc>
  800a64:	85 c0                	test   %eax,%eax
  800a66:	78 2c                	js     800a94 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	68 00 50 80 00       	push   $0x805000
  800a70:	53                   	push   %ebx
  800a71:	e8 26 11 00 00       	call   801b9c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a76:	a1 80 50 80 00       	mov    0x805080,%eax
  800a7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a81:	a1 84 50 80 00       	mov    0x805084,%eax
  800a86:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a8c:	83 c4 10             	add    $0x10,%esp
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 52 0c             	mov    0xc(%edx),%edx
  800aa8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800aae:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ab3:	50                   	push   %eax
  800ab4:	ff 75 0c             	pushl  0xc(%ebp)
  800ab7:	68 08 50 80 00       	push   $0x805008
  800abc:	e8 6d 12 00 00       	call   801d2e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	b8 04 00 00 00       	mov    $0x4,%eax
  800acb:	e8 d9 fe ff ff       	call   8009a9 <fsipc>

}
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ae5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 03 00 00 00       	mov    $0x3,%eax
  800af5:	e8 af fe ff ff       	call   8009a9 <fsipc>
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	85 c0                	test   %eax,%eax
  800afe:	78 4b                	js     800b4b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b00:	39 c6                	cmp    %eax,%esi
  800b02:	73 16                	jae    800b1a <devfile_read+0x48>
  800b04:	68 8c 23 80 00       	push   $0x80238c
  800b09:	68 93 23 80 00       	push   $0x802393
  800b0e:	6a 7c                	push   $0x7c
  800b10:	68 a8 23 80 00       	push   $0x8023a8
  800b15:	e8 24 0a 00 00       	call   80153e <_panic>
	assert(r <= PGSIZE);
  800b1a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b1f:	7e 16                	jle    800b37 <devfile_read+0x65>
  800b21:	68 b3 23 80 00       	push   $0x8023b3
  800b26:	68 93 23 80 00       	push   $0x802393
  800b2b:	6a 7d                	push   $0x7d
  800b2d:	68 a8 23 80 00       	push   $0x8023a8
  800b32:	e8 07 0a 00 00       	call   80153e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b37:	83 ec 04             	sub    $0x4,%esp
  800b3a:	50                   	push   %eax
  800b3b:	68 00 50 80 00       	push   $0x805000
  800b40:	ff 75 0c             	pushl  0xc(%ebp)
  800b43:	e8 e6 11 00 00       	call   801d2e <memmove>
	return r;
  800b48:	83 c4 10             	add    $0x10,%esp
}
  800b4b:	89 d8                	mov    %ebx,%eax
  800b4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	53                   	push   %ebx
  800b58:	83 ec 20             	sub    $0x20,%esp
  800b5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b5e:	53                   	push   %ebx
  800b5f:	e8 ff 0f 00 00       	call   801b63 <strlen>
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b6c:	7f 67                	jg     800bd5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b74:	50                   	push   %eax
  800b75:	e8 a7 f8 ff ff       	call   800421 <fd_alloc>
  800b7a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b7d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	78 57                	js     800bda <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b83:	83 ec 08             	sub    $0x8,%esp
  800b86:	53                   	push   %ebx
  800b87:	68 00 50 80 00       	push   $0x805000
  800b8c:	e8 0b 10 00 00       	call   801b9c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b94:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba1:	e8 03 fe ff ff       	call   8009a9 <fsipc>
  800ba6:	89 c3                	mov    %eax,%ebx
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	85 c0                	test   %eax,%eax
  800bad:	79 14                	jns    800bc3 <open+0x6f>
		fd_close(fd, 0);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	6a 00                	push   $0x0
  800bb4:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb7:	e8 5d f9 ff ff       	call   800519 <fd_close>
		return r;
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	89 da                	mov    %ebx,%edx
  800bc1:	eb 17                	jmp    800bda <open+0x86>
	}

	return fd2num(fd);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	ff 75 f4             	pushl  -0xc(%ebp)
  800bc9:	e8 2c f8 ff ff       	call   8003fa <fd2num>
  800bce:	89 c2                	mov    %eax,%edx
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	eb 05                	jmp    800bda <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bd5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bda:	89 d0                	mov    %edx,%eax
  800bdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf1:	e8 b3 fd ff ff       	call   8009a9 <fsipc>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bfe:	68 bf 23 80 00       	push   $0x8023bf
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	e8 91 0f 00 00       	call   801b9c <strcpy>
	return 0;
}
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	83 ec 10             	sub    $0x10,%esp
  800c19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c1c:	53                   	push   %ebx
  800c1d:	e8 b5 13 00 00       	call   801fd7 <pageref>
  800c22:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c2a:	83 f8 01             	cmp    $0x1,%eax
  800c2d:	75 10                	jne    800c3f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	ff 73 0c             	pushl  0xc(%ebx)
  800c35:	e8 c0 02 00 00       	call   800efa <nsipc_close>
  800c3a:	89 c2                	mov    %eax,%edx
  800c3c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c3f:	89 d0                	mov    %edx,%eax
  800c41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c4c:	6a 00                	push   $0x0
  800c4e:	ff 75 10             	pushl  0x10(%ebp)
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	ff 70 0c             	pushl  0xc(%eax)
  800c5a:	e8 78 03 00 00       	call   800fd7 <nsipc_send>
}
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c67:	6a 00                	push   $0x0
  800c69:	ff 75 10             	pushl  0x10(%ebp)
  800c6c:	ff 75 0c             	pushl  0xc(%ebp)
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	ff 70 0c             	pushl  0xc(%eax)
  800c75:	e8 f1 02 00 00       	call   800f6b <nsipc_recv>
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c85:	52                   	push   %edx
  800c86:	50                   	push   %eax
  800c87:	e8 e4 f7 ff ff       	call   800470 <fd_lookup>
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	78 17                	js     800caa <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c96:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c9c:	39 08                	cmp    %ecx,(%eax)
  800c9e:	75 05                	jne    800ca5 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800ca0:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca3:	eb 05                	jmp    800caa <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800ca5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 1c             	sub    $0x1c,%esp
  800cb4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb9:	50                   	push   %eax
  800cba:	e8 62 f7 ff ff       	call   800421 <fd_alloc>
  800cbf:	89 c3                	mov    %eax,%ebx
  800cc1:	83 c4 10             	add    $0x10,%esp
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	78 1b                	js     800ce3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cc8:	83 ec 04             	sub    $0x4,%esp
  800ccb:	68 07 04 00 00       	push   $0x407
  800cd0:	ff 75 f4             	pushl  -0xc(%ebp)
  800cd3:	6a 00                	push   $0x0
  800cd5:	e8 8c f4 ff ff       	call   800166 <sys_page_alloc>
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	79 10                	jns    800cf3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	56                   	push   %esi
  800ce7:	e8 0e 02 00 00       	call   800efa <nsipc_close>
		return r;
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	89 d8                	mov    %ebx,%eax
  800cf1:	eb 24                	jmp    800d17 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cf3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d01:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d08:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	e8 e6 f6 ff ff       	call   8003fa <fd2num>
  800d14:	83 c4 10             	add    $0x10,%esp
}
  800d17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	e8 50 ff ff ff       	call   800c7c <fd2sockid>
		return r;
  800d2c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	78 1f                	js     800d51 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d32:	83 ec 04             	sub    $0x4,%esp
  800d35:	ff 75 10             	pushl  0x10(%ebp)
  800d38:	ff 75 0c             	pushl  0xc(%ebp)
  800d3b:	50                   	push   %eax
  800d3c:	e8 12 01 00 00       	call   800e53 <nsipc_accept>
  800d41:	83 c4 10             	add    $0x10,%esp
		return r;
  800d44:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 07                	js     800d51 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d4a:	e8 5d ff ff ff       	call   800cac <alloc_sockfd>
  800d4f:	89 c1                	mov    %eax,%ecx
}
  800d51:	89 c8                	mov    %ecx,%eax
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    

00800d55 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	e8 19 ff ff ff       	call   800c7c <fd2sockid>
  800d63:	85 c0                	test   %eax,%eax
  800d65:	78 12                	js     800d79 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d67:	83 ec 04             	sub    $0x4,%esp
  800d6a:	ff 75 10             	pushl  0x10(%ebp)
  800d6d:	ff 75 0c             	pushl  0xc(%ebp)
  800d70:	50                   	push   %eax
  800d71:	e8 2d 01 00 00       	call   800ea3 <nsipc_bind>
  800d76:	83 c4 10             	add    $0x10,%esp
}
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    

00800d7b <shutdown>:

int
shutdown(int s, int how)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	e8 f3 fe ff ff       	call   800c7c <fd2sockid>
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	78 0f                	js     800d9c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d8d:	83 ec 08             	sub    $0x8,%esp
  800d90:	ff 75 0c             	pushl  0xc(%ebp)
  800d93:	50                   	push   %eax
  800d94:	e8 3f 01 00 00       	call   800ed8 <nsipc_shutdown>
  800d99:	83 c4 10             	add    $0x10,%esp
}
  800d9c:	c9                   	leave  
  800d9d:	c3                   	ret    

00800d9e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	e8 d0 fe ff ff       	call   800c7c <fd2sockid>
  800dac:	85 c0                	test   %eax,%eax
  800dae:	78 12                	js     800dc2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	ff 75 10             	pushl  0x10(%ebp)
  800db6:	ff 75 0c             	pushl  0xc(%ebp)
  800db9:	50                   	push   %eax
  800dba:	e8 55 01 00 00       	call   800f14 <nsipc_connect>
  800dbf:	83 c4 10             	add    $0x10,%esp
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <listen>:

int
listen(int s, int backlog)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	e8 aa fe ff ff       	call   800c7c <fd2sockid>
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 0f                	js     800de5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dd6:	83 ec 08             	sub    $0x8,%esp
  800dd9:	ff 75 0c             	pushl  0xc(%ebp)
  800ddc:	50                   	push   %eax
  800ddd:	e8 67 01 00 00       	call   800f49 <nsipc_listen>
  800de2:	83 c4 10             	add    $0x10,%esp
}
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    

00800de7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ded:	ff 75 10             	pushl  0x10(%ebp)
  800df0:	ff 75 0c             	pushl  0xc(%ebp)
  800df3:	ff 75 08             	pushl  0x8(%ebp)
  800df6:	e8 3a 02 00 00       	call   801035 <nsipc_socket>
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	78 05                	js     800e07 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e02:	e8 a5 fe ff ff       	call   800cac <alloc_sockfd>
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e12:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e19:	75 12                	jne    800e2d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	6a 02                	push   $0x2
  800e20:	e8 79 11 00 00       	call   801f9e <ipc_find_env>
  800e25:	a3 04 40 80 00       	mov    %eax,0x804004
  800e2a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e2d:	6a 07                	push   $0x7
  800e2f:	68 00 60 80 00       	push   $0x806000
  800e34:	53                   	push   %ebx
  800e35:	ff 35 04 40 80 00    	pushl  0x804004
  800e3b:	e8 0a 11 00 00       	call   801f4a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e40:	83 c4 0c             	add    $0xc,%esp
  800e43:	6a 00                	push   $0x0
  800e45:	6a 00                	push   $0x0
  800e47:	6a 00                	push   $0x0
  800e49:	e8 95 10 00 00       	call   801ee3 <ipc_recv>
}
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e63:	8b 06                	mov    (%esi),%eax
  800e65:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6f:	e8 95 ff ff ff       	call   800e09 <nsipc>
  800e74:	89 c3                	mov    %eax,%ebx
  800e76:	85 c0                	test   %eax,%eax
  800e78:	78 20                	js     800e9a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	ff 35 10 60 80 00    	pushl  0x806010
  800e83:	68 00 60 80 00       	push   $0x806000
  800e88:	ff 75 0c             	pushl  0xc(%ebp)
  800e8b:	e8 9e 0e 00 00       	call   801d2e <memmove>
		*addrlen = ret->ret_addrlen;
  800e90:	a1 10 60 80 00       	mov    0x806010,%eax
  800e95:	89 06                	mov    %eax,(%esi)
  800e97:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800eb5:	53                   	push   %ebx
  800eb6:	ff 75 0c             	pushl  0xc(%ebp)
  800eb9:	68 04 60 80 00       	push   $0x806004
  800ebe:	e8 6b 0e 00 00       	call   801d2e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ec3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ec9:	b8 02 00 00 00       	mov    $0x2,%eax
  800ece:	e8 36 ff ff ff       	call   800e09 <nsipc>
}
  800ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eee:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef3:	e8 11 ff ff ff       	call   800e09 <nsipc>
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <nsipc_close>:

int
nsipc_close(int s)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f00:	8b 45 08             	mov    0x8(%ebp),%eax
  800f03:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f08:	b8 04 00 00 00       	mov    $0x4,%eax
  800f0d:	e8 f7 fe ff ff       	call   800e09 <nsipc>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	53                   	push   %ebx
  800f18:	83 ec 08             	sub    $0x8,%esp
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f26:	53                   	push   %ebx
  800f27:	ff 75 0c             	pushl  0xc(%ebp)
  800f2a:	68 04 60 80 00       	push   $0x806004
  800f2f:	e8 fa 0d 00 00       	call   801d2e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f34:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f3f:	e8 c5 fe ff ff       	call   800e09 <nsipc>
}
  800f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f5f:	b8 06 00 00 00       	mov    $0x6,%eax
  800f64:	e8 a0 fe ff ff       	call   800e09 <nsipc>
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f7b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f81:	8b 45 14             	mov    0x14(%ebp),%eax
  800f84:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f89:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8e:	e8 76 fe ff ff       	call   800e09 <nsipc>
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 35                	js     800fce <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f99:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f9e:	7f 04                	jg     800fa4 <nsipc_recv+0x39>
  800fa0:	39 c6                	cmp    %eax,%esi
  800fa2:	7d 16                	jge    800fba <nsipc_recv+0x4f>
  800fa4:	68 cb 23 80 00       	push   $0x8023cb
  800fa9:	68 93 23 80 00       	push   $0x802393
  800fae:	6a 62                	push   $0x62
  800fb0:	68 e0 23 80 00       	push   $0x8023e0
  800fb5:	e8 84 05 00 00       	call   80153e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fba:	83 ec 04             	sub    $0x4,%esp
  800fbd:	50                   	push   %eax
  800fbe:	68 00 60 80 00       	push   $0x806000
  800fc3:	ff 75 0c             	pushl  0xc(%ebp)
  800fc6:	e8 63 0d 00 00       	call   801d2e <memmove>
  800fcb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 04             	sub    $0x4,%esp
  800fde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fe9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fef:	7e 16                	jle    801007 <nsipc_send+0x30>
  800ff1:	68 ec 23 80 00       	push   $0x8023ec
  800ff6:	68 93 23 80 00       	push   $0x802393
  800ffb:	6a 6d                	push   $0x6d
  800ffd:	68 e0 23 80 00       	push   $0x8023e0
  801002:	e8 37 05 00 00       	call   80153e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	53                   	push   %ebx
  80100b:	ff 75 0c             	pushl  0xc(%ebp)
  80100e:	68 0c 60 80 00       	push   $0x80600c
  801013:	e8 16 0d 00 00       	call   801d2e <memmove>
	nsipcbuf.send.req_size = size;
  801018:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80101e:	8b 45 14             	mov    0x14(%ebp),%eax
  801021:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801026:	b8 08 00 00 00       	mov    $0x8,%eax
  80102b:	e8 d9 fd ff ff       	call   800e09 <nsipc>
}
  801030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801043:	8b 45 0c             	mov    0xc(%ebp),%eax
  801046:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80104b:	8b 45 10             	mov    0x10(%ebp),%eax
  80104e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801053:	b8 09 00 00 00       	mov    $0x9,%eax
  801058:	e8 ac fd ff ff       	call   800e09 <nsipc>
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	ff 75 08             	pushl  0x8(%ebp)
  80106d:	e8 98 f3 ff ff       	call   80040a <fd2data>
  801072:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	68 f8 23 80 00       	push   $0x8023f8
  80107c:	53                   	push   %ebx
  80107d:	e8 1a 0b 00 00       	call   801b9c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801082:	8b 46 04             	mov    0x4(%esi),%eax
  801085:	2b 06                	sub    (%esi),%eax
  801087:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80108d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801094:	00 00 00 
	stat->st_dev = &devpipe;
  801097:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80109e:	30 80 00 
	return 0;
}
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010b7:	53                   	push   %ebx
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 2c f1 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010bf:	89 1c 24             	mov    %ebx,(%esp)
  8010c2:	e8 43 f3 ff ff       	call   80040a <fd2data>
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	50                   	push   %eax
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 19 f1 ff ff       	call   8001eb <sys_page_unmap>
}
  8010d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 1c             	sub    $0x1c,%esp
  8010e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010e3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f3:	e8 df 0e 00 00       	call   801fd7 <pageref>
  8010f8:	89 c3                	mov    %eax,%ebx
  8010fa:	89 3c 24             	mov    %edi,(%esp)
  8010fd:	e8 d5 0e 00 00       	call   801fd7 <pageref>
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	39 c3                	cmp    %eax,%ebx
  801107:	0f 94 c1             	sete   %cl
  80110a:	0f b6 c9             	movzbl %cl,%ecx
  80110d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801110:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801116:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801119:	39 ce                	cmp    %ecx,%esi
  80111b:	74 1b                	je     801138 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80111d:	39 c3                	cmp    %eax,%ebx
  80111f:	75 c4                	jne    8010e5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801121:	8b 42 58             	mov    0x58(%edx),%eax
  801124:	ff 75 e4             	pushl  -0x1c(%ebp)
  801127:	50                   	push   %eax
  801128:	56                   	push   %esi
  801129:	68 ff 23 80 00       	push   $0x8023ff
  80112e:	e8 e4 04 00 00       	call   801617 <cprintf>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	eb ad                	jmp    8010e5 <_pipeisclosed+0xe>
	}
}
  801138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 28             	sub    $0x28,%esp
  80114c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80114f:	56                   	push   %esi
  801150:	e8 b5 f2 ff ff       	call   80040a <fd2data>
  801155:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	bf 00 00 00 00       	mov    $0x0,%edi
  80115f:	eb 4b                	jmp    8011ac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801161:	89 da                	mov    %ebx,%edx
  801163:	89 f0                	mov    %esi,%eax
  801165:	e8 6d ff ff ff       	call   8010d7 <_pipeisclosed>
  80116a:	85 c0                	test   %eax,%eax
  80116c:	75 48                	jne    8011b6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80116e:	e8 d4 ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801173:	8b 43 04             	mov    0x4(%ebx),%eax
  801176:	8b 0b                	mov    (%ebx),%ecx
  801178:	8d 51 20             	lea    0x20(%ecx),%edx
  80117b:	39 d0                	cmp    %edx,%eax
  80117d:	73 e2                	jae    801161 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80117f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801182:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801186:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801189:	89 c2                	mov    %eax,%edx
  80118b:	c1 fa 1f             	sar    $0x1f,%edx
  80118e:	89 d1                	mov    %edx,%ecx
  801190:	c1 e9 1b             	shr    $0x1b,%ecx
  801193:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801196:	83 e2 1f             	and    $0x1f,%edx
  801199:	29 ca                	sub    %ecx,%edx
  80119b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80119f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011a3:	83 c0 01             	add    $0x1,%eax
  8011a6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011a9:	83 c7 01             	add    $0x1,%edi
  8011ac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011af:	75 c2                	jne    801173 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b4:	eb 05                	jmp    8011bb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	57                   	push   %edi
  8011c7:	56                   	push   %esi
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 18             	sub    $0x18,%esp
  8011cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011cf:	57                   	push   %edi
  8011d0:	e8 35 f2 ff ff       	call   80040a <fd2data>
  8011d5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011df:	eb 3d                	jmp    80121e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011e1:	85 db                	test   %ebx,%ebx
  8011e3:	74 04                	je     8011e9 <devpipe_read+0x26>
				return i;
  8011e5:	89 d8                	mov    %ebx,%eax
  8011e7:	eb 44                	jmp    80122d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011e9:	89 f2                	mov    %esi,%edx
  8011eb:	89 f8                	mov    %edi,%eax
  8011ed:	e8 e5 fe ff ff       	call   8010d7 <_pipeisclosed>
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	75 32                	jne    801228 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011f6:	e8 4c ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011fb:	8b 06                	mov    (%esi),%eax
  8011fd:	3b 46 04             	cmp    0x4(%esi),%eax
  801200:	74 df                	je     8011e1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801202:	99                   	cltd   
  801203:	c1 ea 1b             	shr    $0x1b,%edx
  801206:	01 d0                	add    %edx,%eax
  801208:	83 e0 1f             	and    $0x1f,%eax
  80120b:	29 d0                	sub    %edx,%eax
  80120d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801215:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801218:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80121b:	83 c3 01             	add    $0x1,%ebx
  80121e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801221:	75 d8                	jne    8011fb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801223:	8b 45 10             	mov    0x10(%ebp),%eax
  801226:	eb 05                	jmp    80122d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	e8 db f1 ff ff       	call   800421 <fd_alloc>
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	89 c2                	mov    %eax,%edx
  80124b:	85 c0                	test   %eax,%eax
  80124d:	0f 88 2c 01 00 00    	js     80137f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801253:	83 ec 04             	sub    $0x4,%esp
  801256:	68 07 04 00 00       	push   $0x407
  80125b:	ff 75 f4             	pushl  -0xc(%ebp)
  80125e:	6a 00                	push   $0x0
  801260:	e8 01 ef ff ff       	call   800166 <sys_page_alloc>
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	89 c2                	mov    %eax,%edx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	0f 88 0d 01 00 00    	js     80137f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	e8 a3 f1 ff ff       	call   800421 <fd_alloc>
  80127e:	89 c3                	mov    %eax,%ebx
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	0f 88 e2 00 00 00    	js     80136d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	68 07 04 00 00       	push   $0x407
  801293:	ff 75 f0             	pushl  -0x10(%ebp)
  801296:	6a 00                	push   $0x0
  801298:	e8 c9 ee ff ff       	call   800166 <sys_page_alloc>
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	0f 88 c3 00 00 00    	js     80136d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b0:	e8 55 f1 ff ff       	call   80040a <fd2data>
  8012b5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012b7:	83 c4 0c             	add    $0xc,%esp
  8012ba:	68 07 04 00 00       	push   $0x407
  8012bf:	50                   	push   %eax
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 9f ee ff ff       	call   800166 <sys_page_alloc>
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	0f 88 89 00 00 00    	js     80135d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012da:	e8 2b f1 ff ff       	call   80040a <fd2data>
  8012df:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012e6:	50                   	push   %eax
  8012e7:	6a 00                	push   $0x0
  8012e9:	56                   	push   %esi
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 b8 ee ff ff       	call   8001a9 <sys_page_map>
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	83 c4 20             	add    $0x20,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 55                	js     80134f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012fa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801300:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801303:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801308:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80130f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80131a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	ff 75 f4             	pushl  -0xc(%ebp)
  80132a:	e8 cb f0 ff ff       	call   8003fa <fd2num>
  80132f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801332:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801334:	83 c4 04             	add    $0x4,%esp
  801337:	ff 75 f0             	pushl  -0x10(%ebp)
  80133a:	e8 bb f0 ff ff       	call   8003fa <fd2num>
  80133f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801342:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	ba 00 00 00 00       	mov    $0x0,%edx
  80134d:	eb 30                	jmp    80137f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	56                   	push   %esi
  801353:	6a 00                	push   $0x0
  801355:	e8 91 ee ff ff       	call   8001eb <sys_page_unmap>
  80135a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	ff 75 f0             	pushl  -0x10(%ebp)
  801363:	6a 00                	push   $0x0
  801365:	e8 81 ee ff ff       	call   8001eb <sys_page_unmap>
  80136a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	ff 75 f4             	pushl  -0xc(%ebp)
  801373:	6a 00                	push   $0x0
  801375:	e8 71 ee ff ff       	call   8001eb <sys_page_unmap>
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80137f:	89 d0                	mov    %edx,%eax
  801381:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	ff 75 08             	pushl  0x8(%ebp)
  801395:	e8 d6 f0 ff ff       	call   800470 <fd_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 18                	js     8013b9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a7:	e8 5e f0 ff ff       	call   80040a <fd2data>
	return _pipeisclosed(fd, p);
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b1:	e8 21 fd ff ff       	call   8010d7 <_pipeisclosed>
  8013b6:	83 c4 10             	add    $0x10,%esp
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013cb:	68 17 24 80 00       	push   $0x802417
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	e8 c4 07 00 00       	call   801b9c <strcpy>
	return 0;
}
  8013d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	57                   	push   %edi
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013eb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013f0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013f6:	eb 2d                	jmp    801425 <devcons_write+0x46>
		m = n - tot;
  8013f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013fb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013fd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801400:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801405:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801408:	83 ec 04             	sub    $0x4,%esp
  80140b:	53                   	push   %ebx
  80140c:	03 45 0c             	add    0xc(%ebp),%eax
  80140f:	50                   	push   %eax
  801410:	57                   	push   %edi
  801411:	e8 18 09 00 00       	call   801d2e <memmove>
		sys_cputs(buf, m);
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	53                   	push   %ebx
  80141a:	57                   	push   %edi
  80141b:	e8 8a ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801420:	01 de                	add    %ebx,%esi
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	89 f0                	mov    %esi,%eax
  801427:	3b 75 10             	cmp    0x10(%ebp),%esi
  80142a:	72 cc                	jb     8013f8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80143f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801443:	74 2a                	je     80146f <devcons_read+0x3b>
  801445:	eb 05                	jmp    80144c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801447:	e8 fb ec ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80144c:	e8 77 ec ff ff       	call   8000c8 <sys_cgetc>
  801451:	85 c0                	test   %eax,%eax
  801453:	74 f2                	je     801447 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801455:	85 c0                	test   %eax,%eax
  801457:	78 16                	js     80146f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801459:	83 f8 04             	cmp    $0x4,%eax
  80145c:	74 0c                	je     80146a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80145e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801461:	88 02                	mov    %al,(%edx)
	return 1;
  801463:	b8 01 00 00 00       	mov    $0x1,%eax
  801468:	eb 05                	jmp    80146f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80147d:	6a 01                	push   $0x1
  80147f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	e8 22 ec ff ff       	call   8000aa <sys_cputs>
}
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <getchar>:

int
getchar(void)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801493:	6a 01                	push   $0x1
  801495:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	6a 00                	push   $0x0
  80149b:	e8 36 f2 ff ff       	call   8006d6 <read>
	if (r < 0)
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 0f                	js     8014b6 <getchar+0x29>
		return r;
	if (r < 1)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	7e 06                	jle    8014b1 <getchar+0x24>
		return -E_EOF;
	return c;
  8014ab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014af:	eb 05                	jmp    8014b6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014b1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 08             	pushl  0x8(%ebp)
  8014c5:	e8 a6 ef ff ff       	call   800470 <fd_lookup>
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 11                	js     8014e2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014da:	39 10                	cmp    %edx,(%eax)
  8014dc:	0f 94 c0             	sete   %al
  8014df:	0f b6 c0             	movzbl %al,%eax
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <opencons>:

int
opencons(void)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	e8 2e ef ff ff       	call   800421 <fd_alloc>
  8014f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014f6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 3e                	js     80153a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	68 07 04 00 00       	push   $0x407
  801504:	ff 75 f4             	pushl  -0xc(%ebp)
  801507:	6a 00                	push   $0x0
  801509:	e8 58 ec ff ff       	call   800166 <sys_page_alloc>
  80150e:	83 c4 10             	add    $0x10,%esp
		return r;
  801511:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	78 23                	js     80153a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801517:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801520:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801522:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801525:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	50                   	push   %eax
  801530:	e8 c5 ee ff ff       	call   8003fa <fd2num>
  801535:	89 c2                	mov    %eax,%edx
  801537:	83 c4 10             	add    $0x10,%esp
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	c9                   	leave  
  80153d:	c3                   	ret    

0080153e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	56                   	push   %esi
  801542:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801543:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801546:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80154c:	e8 d7 eb ff ff       	call   800128 <sys_getenvid>
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	ff 75 0c             	pushl  0xc(%ebp)
  801557:	ff 75 08             	pushl  0x8(%ebp)
  80155a:	56                   	push   %esi
  80155b:	50                   	push   %eax
  80155c:	68 24 24 80 00       	push   $0x802424
  801561:	e8 b1 00 00 00       	call   801617 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801566:	83 c4 18             	add    $0x18,%esp
  801569:	53                   	push   %ebx
  80156a:	ff 75 10             	pushl  0x10(%ebp)
  80156d:	e8 54 00 00 00       	call   8015c6 <vcprintf>
	cprintf("\n");
  801572:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801579:	e8 99 00 00 00       	call   801617 <cprintf>
  80157e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801581:	cc                   	int3   
  801582:	eb fd                	jmp    801581 <_panic+0x43>

00801584 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80158e:	8b 13                	mov    (%ebx),%edx
  801590:	8d 42 01             	lea    0x1(%edx),%eax
  801593:	89 03                	mov    %eax,(%ebx)
  801595:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801598:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80159c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015a1:	75 1a                	jne    8015bd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	68 ff 00 00 00       	push   $0xff
  8015ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8015ae:	50                   	push   %eax
  8015af:	e8 f6 ea ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8015b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015ba:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015d6:	00 00 00 
	b.cnt = 0;
  8015d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015e3:	ff 75 0c             	pushl  0xc(%ebp)
  8015e6:	ff 75 08             	pushl  0x8(%ebp)
  8015e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	68 84 15 80 00       	push   $0x801584
  8015f5:	e8 54 01 00 00       	call   80174e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015fa:	83 c4 08             	add    $0x8,%esp
  8015fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801603:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	e8 9b ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80160f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80161d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801620:	50                   	push   %eax
  801621:	ff 75 08             	pushl  0x8(%ebp)
  801624:	e8 9d ff ff ff       	call   8015c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	57                   	push   %edi
  80162f:	56                   	push   %esi
  801630:	53                   	push   %ebx
  801631:	83 ec 1c             	sub    $0x1c,%esp
  801634:	89 c7                	mov    %eax,%edi
  801636:	89 d6                	mov    %edx,%esi
  801638:	8b 45 08             	mov    0x8(%ebp),%eax
  80163b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801641:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801644:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801647:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80164f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801652:	39 d3                	cmp    %edx,%ebx
  801654:	72 05                	jb     80165b <printnum+0x30>
  801656:	39 45 10             	cmp    %eax,0x10(%ebp)
  801659:	77 45                	ja     8016a0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	ff 75 18             	pushl  0x18(%ebp)
  801661:	8b 45 14             	mov    0x14(%ebp),%eax
  801664:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801667:	53                   	push   %ebx
  801668:	ff 75 10             	pushl  0x10(%ebp)
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801671:	ff 75 e0             	pushl  -0x20(%ebp)
  801674:	ff 75 dc             	pushl  -0x24(%ebp)
  801677:	ff 75 d8             	pushl  -0x28(%ebp)
  80167a:	e8 a1 09 00 00       	call   802020 <__udivdi3>
  80167f:	83 c4 18             	add    $0x18,%esp
  801682:	52                   	push   %edx
  801683:	50                   	push   %eax
  801684:	89 f2                	mov    %esi,%edx
  801686:	89 f8                	mov    %edi,%eax
  801688:	e8 9e ff ff ff       	call   80162b <printnum>
  80168d:	83 c4 20             	add    $0x20,%esp
  801690:	eb 18                	jmp    8016aa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	56                   	push   %esi
  801696:	ff 75 18             	pushl  0x18(%ebp)
  801699:	ff d7                	call   *%edi
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	eb 03                	jmp    8016a3 <printnum+0x78>
  8016a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016a3:	83 eb 01             	sub    $0x1,%ebx
  8016a6:	85 db                	test   %ebx,%ebx
  8016a8:	7f e8                	jg     801692 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	56                   	push   %esi
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8016bd:	e8 8e 0a 00 00       	call   802150 <__umoddi3>
  8016c2:	83 c4 14             	add    $0x14,%esp
  8016c5:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  8016cc:	50                   	push   %eax
  8016cd:	ff d7                	call   *%edi
}
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5f                   	pop    %edi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016dd:	83 fa 01             	cmp    $0x1,%edx
  8016e0:	7e 0e                	jle    8016f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016e2:	8b 10                	mov    (%eax),%edx
  8016e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016e7:	89 08                	mov    %ecx,(%eax)
  8016e9:	8b 02                	mov    (%edx),%eax
  8016eb:	8b 52 04             	mov    0x4(%edx),%edx
  8016ee:	eb 22                	jmp    801712 <getuint+0x38>
	else if (lflag)
  8016f0:	85 d2                	test   %edx,%edx
  8016f2:	74 10                	je     801704 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016f4:	8b 10                	mov    (%eax),%edx
  8016f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f9:	89 08                	mov    %ecx,(%eax)
  8016fb:	8b 02                	mov    (%edx),%eax
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	eb 0e                	jmp    801712 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801704:	8b 10                	mov    (%eax),%edx
  801706:	8d 4a 04             	lea    0x4(%edx),%ecx
  801709:	89 08                	mov    %ecx,(%eax)
  80170b:	8b 02                	mov    (%edx),%eax
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80171a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80171e:	8b 10                	mov    (%eax),%edx
  801720:	3b 50 04             	cmp    0x4(%eax),%edx
  801723:	73 0a                	jae    80172f <sprintputch+0x1b>
		*b->buf++ = ch;
  801725:	8d 4a 01             	lea    0x1(%edx),%ecx
  801728:	89 08                	mov    %ecx,(%eax)
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	88 02                	mov    %al,(%edx)
}
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801737:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80173a:	50                   	push   %eax
  80173b:	ff 75 10             	pushl  0x10(%ebp)
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	ff 75 08             	pushl  0x8(%ebp)
  801744:	e8 05 00 00 00       	call   80174e <vprintfmt>
	va_end(ap);
}
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	57                   	push   %edi
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
  801754:	83 ec 2c             	sub    $0x2c,%esp
  801757:	8b 75 08             	mov    0x8(%ebp),%esi
  80175a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80175d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801760:	eb 12                	jmp    801774 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801762:	85 c0                	test   %eax,%eax
  801764:	0f 84 89 03 00 00    	je     801af3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	53                   	push   %ebx
  80176e:	50                   	push   %eax
  80176f:	ff d6                	call   *%esi
  801771:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801774:	83 c7 01             	add    $0x1,%edi
  801777:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80177b:	83 f8 25             	cmp    $0x25,%eax
  80177e:	75 e2                	jne    801762 <vprintfmt+0x14>
  801780:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801784:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80178b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801792:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	eb 07                	jmp    8017a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a7:	8d 47 01             	lea    0x1(%edi),%eax
  8017aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017ad:	0f b6 07             	movzbl (%edi),%eax
  8017b0:	0f b6 c8             	movzbl %al,%ecx
  8017b3:	83 e8 23             	sub    $0x23,%eax
  8017b6:	3c 55                	cmp    $0x55,%al
  8017b8:	0f 87 1a 03 00 00    	ja     801ad8 <vprintfmt+0x38a>
  8017be:	0f b6 c0             	movzbl %al,%eax
  8017c1:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017cf:	eb d6                	jmp    8017a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017df:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017e3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017e6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017e9:	83 fa 09             	cmp    $0x9,%edx
  8017ec:	77 39                	ja     801827 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017f1:	eb e9                	jmp    8017dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8017f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017fc:	8b 00                	mov    (%eax),%eax
  8017fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801804:	eb 27                	jmp    80182d <vprintfmt+0xdf>
  801806:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801809:	85 c0                	test   %eax,%eax
  80180b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801810:	0f 49 c8             	cmovns %eax,%ecx
  801813:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801816:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801819:	eb 8c                	jmp    8017a7 <vprintfmt+0x59>
  80181b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80181e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801825:	eb 80                	jmp    8017a7 <vprintfmt+0x59>
  801827:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80182a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80182d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801831:	0f 89 70 ff ff ff    	jns    8017a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801837:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80183a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80183d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801844:	e9 5e ff ff ff       	jmp    8017a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801849:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80184f:	e9 53 ff ff ff       	jmp    8017a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801854:	8b 45 14             	mov    0x14(%ebp),%eax
  801857:	8d 50 04             	lea    0x4(%eax),%edx
  80185a:	89 55 14             	mov    %edx,0x14(%ebp)
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	53                   	push   %ebx
  801861:	ff 30                	pushl  (%eax)
  801863:	ff d6                	call   *%esi
			break;
  801865:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80186b:	e9 04 ff ff ff       	jmp    801774 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801870:	8b 45 14             	mov    0x14(%ebp),%eax
  801873:	8d 50 04             	lea    0x4(%eax),%edx
  801876:	89 55 14             	mov    %edx,0x14(%ebp)
  801879:	8b 00                	mov    (%eax),%eax
  80187b:	99                   	cltd   
  80187c:	31 d0                	xor    %edx,%eax
  80187e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801880:	83 f8 0f             	cmp    $0xf,%eax
  801883:	7f 0b                	jg     801890 <vprintfmt+0x142>
  801885:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	75 18                	jne    8018a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801890:	50                   	push   %eax
  801891:	68 5f 24 80 00       	push   $0x80245f
  801896:	53                   	push   %ebx
  801897:	56                   	push   %esi
  801898:	e8 94 fe ff ff       	call   801731 <printfmt>
  80189d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018a3:	e9 cc fe ff ff       	jmp    801774 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018a8:	52                   	push   %edx
  8018a9:	68 a5 23 80 00       	push   $0x8023a5
  8018ae:	53                   	push   %ebx
  8018af:	56                   	push   %esi
  8018b0:	e8 7c fe ff ff       	call   801731 <printfmt>
  8018b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018bb:	e9 b4 fe ff ff       	jmp    801774 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c3:	8d 50 04             	lea    0x4(%eax),%edx
  8018c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018cb:	85 ff                	test   %edi,%edi
  8018cd:	b8 58 24 80 00       	mov    $0x802458,%eax
  8018d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018d9:	0f 8e 94 00 00 00    	jle    801973 <vprintfmt+0x225>
  8018df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018e3:	0f 84 98 00 00 00    	je     801981 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	ff 75 d0             	pushl  -0x30(%ebp)
  8018ef:	57                   	push   %edi
  8018f0:	e8 86 02 00 00       	call   801b7b <strnlen>
  8018f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018f8:	29 c1                	sub    %eax,%ecx
  8018fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801900:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801904:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801907:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80190a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80190c:	eb 0f                	jmp    80191d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	53                   	push   %ebx
  801912:	ff 75 e0             	pushl  -0x20(%ebp)
  801915:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801917:	83 ef 01             	sub    $0x1,%edi
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 ff                	test   %edi,%edi
  80191f:	7f ed                	jg     80190e <vprintfmt+0x1c0>
  801921:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801924:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801927:	85 c9                	test   %ecx,%ecx
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
  80192e:	0f 49 c1             	cmovns %ecx,%eax
  801931:	29 c1                	sub    %eax,%ecx
  801933:	89 75 08             	mov    %esi,0x8(%ebp)
  801936:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801939:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193c:	89 cb                	mov    %ecx,%ebx
  80193e:	eb 4d                	jmp    80198d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801940:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801944:	74 1b                	je     801961 <vprintfmt+0x213>
  801946:	0f be c0             	movsbl %al,%eax
  801949:	83 e8 20             	sub    $0x20,%eax
  80194c:	83 f8 5e             	cmp    $0x5e,%eax
  80194f:	76 10                	jbe    801961 <vprintfmt+0x213>
					putch('?', putdat);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	6a 3f                	push   $0x3f
  801959:	ff 55 08             	call   *0x8(%ebp)
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	eb 0d                	jmp    80196e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	ff 75 0c             	pushl  0xc(%ebp)
  801967:	52                   	push   %edx
  801968:	ff 55 08             	call   *0x8(%ebp)
  80196b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80196e:	83 eb 01             	sub    $0x1,%ebx
  801971:	eb 1a                	jmp    80198d <vprintfmt+0x23f>
  801973:	89 75 08             	mov    %esi,0x8(%ebp)
  801976:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801979:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80197c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80197f:	eb 0c                	jmp    80198d <vprintfmt+0x23f>
  801981:	89 75 08             	mov    %esi,0x8(%ebp)
  801984:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801987:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80198a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80198d:	83 c7 01             	add    $0x1,%edi
  801990:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801994:	0f be d0             	movsbl %al,%edx
  801997:	85 d2                	test   %edx,%edx
  801999:	74 23                	je     8019be <vprintfmt+0x270>
  80199b:	85 f6                	test   %esi,%esi
  80199d:	78 a1                	js     801940 <vprintfmt+0x1f2>
  80199f:	83 ee 01             	sub    $0x1,%esi
  8019a2:	79 9c                	jns    801940 <vprintfmt+0x1f2>
  8019a4:	89 df                	mov    %ebx,%edi
  8019a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8019a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ac:	eb 18                	jmp    8019c6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	53                   	push   %ebx
  8019b2:	6a 20                	push   $0x20
  8019b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019b6:	83 ef 01             	sub    $0x1,%edi
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	eb 08                	jmp    8019c6 <vprintfmt+0x278>
  8019be:	89 df                	mov    %ebx,%edi
  8019c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019c6:	85 ff                	test   %edi,%edi
  8019c8:	7f e4                	jg     8019ae <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019cd:	e9 a2 fd ff ff       	jmp    801774 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019d2:	83 fa 01             	cmp    $0x1,%edx
  8019d5:	7e 16                	jle    8019ed <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8d 50 08             	lea    0x8(%eax),%edx
  8019dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e0:	8b 50 04             	mov    0x4(%eax),%edx
  8019e3:	8b 00                	mov    (%eax),%eax
  8019e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019eb:	eb 32                	jmp    801a1f <vprintfmt+0x2d1>
	else if (lflag)
  8019ed:	85 d2                	test   %edx,%edx
  8019ef:	74 18                	je     801a09 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	8d 50 04             	lea    0x4(%eax),%edx
  8019f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8019fa:	8b 00                	mov    (%eax),%eax
  8019fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ff:	89 c1                	mov    %eax,%ecx
  801a01:	c1 f9 1f             	sar    $0x1f,%ecx
  801a04:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a07:	eb 16                	jmp    801a1f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a09:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0c:	8d 50 04             	lea    0x4(%eax),%edx
  801a0f:	89 55 14             	mov    %edx,0x14(%ebp)
  801a12:	8b 00                	mov    (%eax),%eax
  801a14:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a17:	89 c1                	mov    %eax,%ecx
  801a19:	c1 f9 1f             	sar    $0x1f,%ecx
  801a1c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a22:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a25:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a2a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a2e:	79 74                	jns    801aa4 <vprintfmt+0x356>
				putch('-', putdat);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	53                   	push   %ebx
  801a34:	6a 2d                	push   $0x2d
  801a36:	ff d6                	call   *%esi
				num = -(long long) num;
  801a38:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a3e:	f7 d8                	neg    %eax
  801a40:	83 d2 00             	adc    $0x0,%edx
  801a43:	f7 da                	neg    %edx
  801a45:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a48:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a4d:	eb 55                	jmp    801aa4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a4f:	8d 45 14             	lea    0x14(%ebp),%eax
  801a52:	e8 83 fc ff ff       	call   8016da <getuint>
			base = 10;
  801a57:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a5c:	eb 46                	jmp    801aa4 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a5e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a61:	e8 74 fc ff ff       	call   8016da <getuint>
			base = 8;
  801a66:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a6b:	eb 37                	jmp    801aa4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a6d:	83 ec 08             	sub    $0x8,%esp
  801a70:	53                   	push   %ebx
  801a71:	6a 30                	push   $0x30
  801a73:	ff d6                	call   *%esi
			putch('x', putdat);
  801a75:	83 c4 08             	add    $0x8,%esp
  801a78:	53                   	push   %ebx
  801a79:	6a 78                	push   $0x78
  801a7b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a7d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a80:	8d 50 04             	lea    0x4(%eax),%edx
  801a83:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a86:	8b 00                	mov    (%eax),%eax
  801a88:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a8d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a90:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a95:	eb 0d                	jmp    801aa4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a97:	8d 45 14             	lea    0x14(%ebp),%eax
  801a9a:	e8 3b fc ff ff       	call   8016da <getuint>
			base = 16;
  801a9f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aab:	57                   	push   %edi
  801aac:	ff 75 e0             	pushl  -0x20(%ebp)
  801aaf:	51                   	push   %ecx
  801ab0:	52                   	push   %edx
  801ab1:	50                   	push   %eax
  801ab2:	89 da                	mov    %ebx,%edx
  801ab4:	89 f0                	mov    %esi,%eax
  801ab6:	e8 70 fb ff ff       	call   80162b <printnum>
			break;
  801abb:	83 c4 20             	add    $0x20,%esp
  801abe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ac1:	e9 ae fc ff ff       	jmp    801774 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	53                   	push   %ebx
  801aca:	51                   	push   %ecx
  801acb:	ff d6                	call   *%esi
			break;
  801acd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ad3:	e9 9c fc ff ff       	jmp    801774 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	53                   	push   %ebx
  801adc:	6a 25                	push   $0x25
  801ade:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	eb 03                	jmp    801ae8 <vprintfmt+0x39a>
  801ae5:	83 ef 01             	sub    $0x1,%edi
  801ae8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aec:	75 f7                	jne    801ae5 <vprintfmt+0x397>
  801aee:	e9 81 fc ff ff       	jmp    801774 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 18             	sub    $0x18,%esp
  801b01:	8b 45 08             	mov    0x8(%ebp),%eax
  801b04:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b0a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b0e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	74 26                	je     801b42 <vsnprintf+0x47>
  801b1c:	85 d2                	test   %edx,%edx
  801b1e:	7e 22                	jle    801b42 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b20:	ff 75 14             	pushl  0x14(%ebp)
  801b23:	ff 75 10             	pushl  0x10(%ebp)
  801b26:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b29:	50                   	push   %eax
  801b2a:	68 14 17 80 00       	push   $0x801714
  801b2f:	e8 1a fc ff ff       	call   80174e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b37:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	eb 05                	jmp    801b47 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b4f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b52:	50                   	push   %eax
  801b53:	ff 75 10             	pushl  0x10(%ebp)
  801b56:	ff 75 0c             	pushl  0xc(%ebp)
  801b59:	ff 75 08             	pushl  0x8(%ebp)
  801b5c:	e8 9a ff ff ff       	call   801afb <vsnprintf>
	va_end(ap);

	return rc;
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	eb 03                	jmp    801b73 <strlen+0x10>
		n++;
  801b70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b77:	75 f7                	jne    801b70 <strlen+0xd>
		n++;
	return n;
}
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b81:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b84:	ba 00 00 00 00       	mov    $0x0,%edx
  801b89:	eb 03                	jmp    801b8e <strnlen+0x13>
		n++;
  801b8b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b8e:	39 c2                	cmp    %eax,%edx
  801b90:	74 08                	je     801b9a <strnlen+0x1f>
  801b92:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b96:	75 f3                	jne    801b8b <strnlen+0x10>
  801b98:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	53                   	push   %ebx
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ba6:	89 c2                	mov    %eax,%edx
  801ba8:	83 c2 01             	add    $0x1,%edx
  801bab:	83 c1 01             	add    $0x1,%ecx
  801bae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bb2:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bb5:	84 db                	test   %bl,%bl
  801bb7:	75 ef                	jne    801ba8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bb9:	5b                   	pop    %ebx
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bc3:	53                   	push   %ebx
  801bc4:	e8 9a ff ff ff       	call   801b63 <strlen>
  801bc9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bcc:	ff 75 0c             	pushl  0xc(%ebp)
  801bcf:	01 d8                	add    %ebx,%eax
  801bd1:	50                   	push   %eax
  801bd2:	e8 c5 ff ff ff       	call   801b9c <strcpy>
	return dst;
}
  801bd7:	89 d8                	mov    %ebx,%eax
  801bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	8b 75 08             	mov    0x8(%ebp),%esi
  801be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be9:	89 f3                	mov    %esi,%ebx
  801beb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bee:	89 f2                	mov    %esi,%edx
  801bf0:	eb 0f                	jmp    801c01 <strncpy+0x23>
		*dst++ = *src;
  801bf2:	83 c2 01             	add    $0x1,%edx
  801bf5:	0f b6 01             	movzbl (%ecx),%eax
  801bf8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bfb:	80 39 01             	cmpb   $0x1,(%ecx)
  801bfe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c01:	39 da                	cmp    %ebx,%edx
  801c03:	75 ed                	jne    801bf2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c05:	89 f0                	mov    %esi,%eax
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	56                   	push   %esi
  801c0f:	53                   	push   %ebx
  801c10:	8b 75 08             	mov    0x8(%ebp),%esi
  801c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c16:	8b 55 10             	mov    0x10(%ebp),%edx
  801c19:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c1b:	85 d2                	test   %edx,%edx
  801c1d:	74 21                	je     801c40 <strlcpy+0x35>
  801c1f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c23:	89 f2                	mov    %esi,%edx
  801c25:	eb 09                	jmp    801c30 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c27:	83 c2 01             	add    $0x1,%edx
  801c2a:	83 c1 01             	add    $0x1,%ecx
  801c2d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c30:	39 c2                	cmp    %eax,%edx
  801c32:	74 09                	je     801c3d <strlcpy+0x32>
  801c34:	0f b6 19             	movzbl (%ecx),%ebx
  801c37:	84 db                	test   %bl,%bl
  801c39:	75 ec                	jne    801c27 <strlcpy+0x1c>
  801c3b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c3d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c40:	29 f0                	sub    %esi,%eax
}
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c4f:	eb 06                	jmp    801c57 <strcmp+0x11>
		p++, q++;
  801c51:	83 c1 01             	add    $0x1,%ecx
  801c54:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c57:	0f b6 01             	movzbl (%ecx),%eax
  801c5a:	84 c0                	test   %al,%al
  801c5c:	74 04                	je     801c62 <strcmp+0x1c>
  801c5e:	3a 02                	cmp    (%edx),%al
  801c60:	74 ef                	je     801c51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c62:	0f b6 c0             	movzbl %al,%eax
  801c65:	0f b6 12             	movzbl (%edx),%edx
  801c68:	29 d0                	sub    %edx,%eax
}
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	53                   	push   %ebx
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c7b:	eb 06                	jmp    801c83 <strncmp+0x17>
		n--, p++, q++;
  801c7d:	83 c0 01             	add    $0x1,%eax
  801c80:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c83:	39 d8                	cmp    %ebx,%eax
  801c85:	74 15                	je     801c9c <strncmp+0x30>
  801c87:	0f b6 08             	movzbl (%eax),%ecx
  801c8a:	84 c9                	test   %cl,%cl
  801c8c:	74 04                	je     801c92 <strncmp+0x26>
  801c8e:	3a 0a                	cmp    (%edx),%cl
  801c90:	74 eb                	je     801c7d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c92:	0f b6 00             	movzbl (%eax),%eax
  801c95:	0f b6 12             	movzbl (%edx),%edx
  801c98:	29 d0                	sub    %edx,%eax
  801c9a:	eb 05                	jmp    801ca1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ca1:	5b                   	pop    %ebx
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cae:	eb 07                	jmp    801cb7 <strchr+0x13>
		if (*s == c)
  801cb0:	38 ca                	cmp    %cl,%dl
  801cb2:	74 0f                	je     801cc3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cb4:	83 c0 01             	add    $0x1,%eax
  801cb7:	0f b6 10             	movzbl (%eax),%edx
  801cba:	84 d2                	test   %dl,%dl
  801cbc:	75 f2                	jne    801cb0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ccf:	eb 03                	jmp    801cd4 <strfind+0xf>
  801cd1:	83 c0 01             	add    $0x1,%eax
  801cd4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cd7:	38 ca                	cmp    %cl,%dl
  801cd9:	74 04                	je     801cdf <strfind+0x1a>
  801cdb:	84 d2                	test   %dl,%dl
  801cdd:	75 f2                	jne    801cd1 <strfind+0xc>
			break;
	return (char *) s;
}
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	57                   	push   %edi
  801ce5:	56                   	push   %esi
  801ce6:	53                   	push   %ebx
  801ce7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ced:	85 c9                	test   %ecx,%ecx
  801cef:	74 36                	je     801d27 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cf1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cf7:	75 28                	jne    801d21 <memset+0x40>
  801cf9:	f6 c1 03             	test   $0x3,%cl
  801cfc:	75 23                	jne    801d21 <memset+0x40>
		c &= 0xFF;
  801cfe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d02:	89 d3                	mov    %edx,%ebx
  801d04:	c1 e3 08             	shl    $0x8,%ebx
  801d07:	89 d6                	mov    %edx,%esi
  801d09:	c1 e6 18             	shl    $0x18,%esi
  801d0c:	89 d0                	mov    %edx,%eax
  801d0e:	c1 e0 10             	shl    $0x10,%eax
  801d11:	09 f0                	or     %esi,%eax
  801d13:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d15:	89 d8                	mov    %ebx,%eax
  801d17:	09 d0                	or     %edx,%eax
  801d19:	c1 e9 02             	shr    $0x2,%ecx
  801d1c:	fc                   	cld    
  801d1d:	f3 ab                	rep stos %eax,%es:(%edi)
  801d1f:	eb 06                	jmp    801d27 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d24:	fc                   	cld    
  801d25:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d27:	89 f8                	mov    %edi,%eax
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	8b 45 08             	mov    0x8(%ebp),%eax
  801d36:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d3c:	39 c6                	cmp    %eax,%esi
  801d3e:	73 35                	jae    801d75 <memmove+0x47>
  801d40:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d43:	39 d0                	cmp    %edx,%eax
  801d45:	73 2e                	jae    801d75 <memmove+0x47>
		s += n;
		d += n;
  801d47:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4a:	89 d6                	mov    %edx,%esi
  801d4c:	09 fe                	or     %edi,%esi
  801d4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d54:	75 13                	jne    801d69 <memmove+0x3b>
  801d56:	f6 c1 03             	test   $0x3,%cl
  801d59:	75 0e                	jne    801d69 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d5b:	83 ef 04             	sub    $0x4,%edi
  801d5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d61:	c1 e9 02             	shr    $0x2,%ecx
  801d64:	fd                   	std    
  801d65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d67:	eb 09                	jmp    801d72 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d69:	83 ef 01             	sub    $0x1,%edi
  801d6c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d6f:	fd                   	std    
  801d70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d72:	fc                   	cld    
  801d73:	eb 1d                	jmp    801d92 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d75:	89 f2                	mov    %esi,%edx
  801d77:	09 c2                	or     %eax,%edx
  801d79:	f6 c2 03             	test   $0x3,%dl
  801d7c:	75 0f                	jne    801d8d <memmove+0x5f>
  801d7e:	f6 c1 03             	test   $0x3,%cl
  801d81:	75 0a                	jne    801d8d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d83:	c1 e9 02             	shr    $0x2,%ecx
  801d86:	89 c7                	mov    %eax,%edi
  801d88:	fc                   	cld    
  801d89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d8b:	eb 05                	jmp    801d92 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d8d:	89 c7                	mov    %eax,%edi
  801d8f:	fc                   	cld    
  801d90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d92:	5e                   	pop    %esi
  801d93:	5f                   	pop    %edi
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d99:	ff 75 10             	pushl  0x10(%ebp)
  801d9c:	ff 75 0c             	pushl  0xc(%ebp)
  801d9f:	ff 75 08             	pushl  0x8(%ebp)
  801da2:	e8 87 ff ff ff       	call   801d2e <memmove>
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db4:	89 c6                	mov    %eax,%esi
  801db6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801db9:	eb 1a                	jmp    801dd5 <memcmp+0x2c>
		if (*s1 != *s2)
  801dbb:	0f b6 08             	movzbl (%eax),%ecx
  801dbe:	0f b6 1a             	movzbl (%edx),%ebx
  801dc1:	38 d9                	cmp    %bl,%cl
  801dc3:	74 0a                	je     801dcf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dc5:	0f b6 c1             	movzbl %cl,%eax
  801dc8:	0f b6 db             	movzbl %bl,%ebx
  801dcb:	29 d8                	sub    %ebx,%eax
  801dcd:	eb 0f                	jmp    801dde <memcmp+0x35>
		s1++, s2++;
  801dcf:	83 c0 01             	add    $0x1,%eax
  801dd2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd5:	39 f0                	cmp    %esi,%eax
  801dd7:	75 e2                	jne    801dbb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    

00801de2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	53                   	push   %ebx
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801de9:	89 c1                	mov    %eax,%ecx
  801deb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801df2:	eb 0a                	jmp    801dfe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801df4:	0f b6 10             	movzbl (%eax),%edx
  801df7:	39 da                	cmp    %ebx,%edx
  801df9:	74 07                	je     801e02 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dfb:	83 c0 01             	add    $0x1,%eax
  801dfe:	39 c8                	cmp    %ecx,%eax
  801e00:	72 f2                	jb     801df4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e02:	5b                   	pop    %ebx
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    

00801e05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	57                   	push   %edi
  801e09:	56                   	push   %esi
  801e0a:	53                   	push   %ebx
  801e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e11:	eb 03                	jmp    801e16 <strtol+0x11>
		s++;
  801e13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e16:	0f b6 01             	movzbl (%ecx),%eax
  801e19:	3c 20                	cmp    $0x20,%al
  801e1b:	74 f6                	je     801e13 <strtol+0xe>
  801e1d:	3c 09                	cmp    $0x9,%al
  801e1f:	74 f2                	je     801e13 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e21:	3c 2b                	cmp    $0x2b,%al
  801e23:	75 0a                	jne    801e2f <strtol+0x2a>
		s++;
  801e25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e28:	bf 00 00 00 00       	mov    $0x0,%edi
  801e2d:	eb 11                	jmp    801e40 <strtol+0x3b>
  801e2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e34:	3c 2d                	cmp    $0x2d,%al
  801e36:	75 08                	jne    801e40 <strtol+0x3b>
		s++, neg = 1;
  801e38:	83 c1 01             	add    $0x1,%ecx
  801e3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e46:	75 15                	jne    801e5d <strtol+0x58>
  801e48:	80 39 30             	cmpb   $0x30,(%ecx)
  801e4b:	75 10                	jne    801e5d <strtol+0x58>
  801e4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e51:	75 7c                	jne    801ecf <strtol+0xca>
		s += 2, base = 16;
  801e53:	83 c1 02             	add    $0x2,%ecx
  801e56:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e5b:	eb 16                	jmp    801e73 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e5d:	85 db                	test   %ebx,%ebx
  801e5f:	75 12                	jne    801e73 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e66:	80 39 30             	cmpb   $0x30,(%ecx)
  801e69:	75 08                	jne    801e73 <strtol+0x6e>
		s++, base = 8;
  801e6b:	83 c1 01             	add    $0x1,%ecx
  801e6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
  801e78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e7b:	0f b6 11             	movzbl (%ecx),%edx
  801e7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e81:	89 f3                	mov    %esi,%ebx
  801e83:	80 fb 09             	cmp    $0x9,%bl
  801e86:	77 08                	ja     801e90 <strtol+0x8b>
			dig = *s - '0';
  801e88:	0f be d2             	movsbl %dl,%edx
  801e8b:	83 ea 30             	sub    $0x30,%edx
  801e8e:	eb 22                	jmp    801eb2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e90:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e93:	89 f3                	mov    %esi,%ebx
  801e95:	80 fb 19             	cmp    $0x19,%bl
  801e98:	77 08                	ja     801ea2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e9a:	0f be d2             	movsbl %dl,%edx
  801e9d:	83 ea 57             	sub    $0x57,%edx
  801ea0:	eb 10                	jmp    801eb2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ea2:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ea5:	89 f3                	mov    %esi,%ebx
  801ea7:	80 fb 19             	cmp    $0x19,%bl
  801eaa:	77 16                	ja     801ec2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801eac:	0f be d2             	movsbl %dl,%edx
  801eaf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eb2:	3b 55 10             	cmp    0x10(%ebp),%edx
  801eb5:	7d 0b                	jge    801ec2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801eb7:	83 c1 01             	add    $0x1,%ecx
  801eba:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ebe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ec0:	eb b9                	jmp    801e7b <strtol+0x76>

	if (endptr)
  801ec2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ec6:	74 0d                	je     801ed5 <strtol+0xd0>
		*endptr = (char *) s;
  801ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecb:	89 0e                	mov    %ecx,(%esi)
  801ecd:	eb 06                	jmp    801ed5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ecf:	85 db                	test   %ebx,%ebx
  801ed1:	74 98                	je     801e6b <strtol+0x66>
  801ed3:	eb 9e                	jmp    801e73 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ed5:	89 c2                	mov    %eax,%edx
  801ed7:	f7 da                	neg    %edx
  801ed9:	85 ff                	test   %edi,%edi
  801edb:	0f 45 c2             	cmovne %edx,%eax
}
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    

00801ee3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	8b 75 08             	mov    0x8(%ebp),%esi
  801eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ef1:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ef3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ef8:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	50                   	push   %eax
  801eff:	e8 12 e4 ff ff       	call   800316 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 f6                	test   %esi,%esi
  801f09:	74 14                	je     801f1f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 09                	js     801f1d <ipc_recv+0x3a>
  801f14:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f1a:	8b 52 74             	mov    0x74(%edx),%edx
  801f1d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f1f:	85 db                	test   %ebx,%ebx
  801f21:	74 14                	je     801f37 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f23:	ba 00 00 00 00       	mov    $0x0,%edx
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 09                	js     801f35 <ipc_recv+0x52>
  801f2c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f32:	8b 52 78             	mov    0x78(%edx),%edx
  801f35:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 08                	js     801f43 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f3b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f40:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	57                   	push   %edi
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	83 ec 0c             	sub    $0xc,%esp
  801f53:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f56:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f5c:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f5e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f63:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f66:	ff 75 14             	pushl  0x14(%ebp)
  801f69:	53                   	push   %ebx
  801f6a:	56                   	push   %esi
  801f6b:	57                   	push   %edi
  801f6c:	e8 82 e3 ff ff       	call   8002f3 <sys_ipc_try_send>

		if (err < 0) {
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	85 c0                	test   %eax,%eax
  801f76:	79 1e                	jns    801f96 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f78:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7b:	75 07                	jne    801f84 <ipc_send+0x3a>
				sys_yield();
  801f7d:	e8 c5 e1 ff ff       	call   800147 <sys_yield>
  801f82:	eb e2                	jmp    801f66 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f84:	50                   	push   %eax
  801f85:	68 40 27 80 00       	push   $0x802740
  801f8a:	6a 49                	push   $0x49
  801f8c:	68 4d 27 80 00       	push   $0x80274d
  801f91:	e8 a8 f5 ff ff       	call   80153e <_panic>
		}

	} while (err < 0);

}
  801f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb2:	8b 52 50             	mov    0x50(%edx),%edx
  801fb5:	39 ca                	cmp    %ecx,%edx
  801fb7:	75 0d                	jne    801fc6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fb9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fbc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc1:	8b 40 48             	mov    0x48(%eax),%eax
  801fc4:	eb 0f                	jmp    801fd5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fc6:	83 c0 01             	add    $0x1,%eax
  801fc9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fce:	75 d9                	jne    801fa9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdd:	89 d0                	mov    %edx,%eax
  801fdf:	c1 e8 16             	shr    $0x16,%eax
  801fe2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fee:	f6 c1 01             	test   $0x1,%cl
  801ff1:	74 1d                	je     802010 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff3:	c1 ea 0c             	shr    $0xc,%edx
  801ff6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ffd:	f6 c2 01             	test   $0x1,%dl
  802000:	74 0e                	je     802010 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802002:	c1 ea 0c             	shr    $0xc,%edx
  802005:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80200c:	ef 
  80200d:	0f b7 c0             	movzwl %ax,%eax
}
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	66 90                	xchg   %ax,%ax
  802014:	66 90                	xchg   %ax,%ax
  802016:	66 90                	xchg   %ax,%ax
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
