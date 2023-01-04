
obj/user/evilhello.debug:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

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
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800096:	e8 87 04 00 00       	call   800522 <close_all>
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
  80010f:	68 aa 1d 80 00       	push   $0x801daa
  800114:	6a 23                	push   $0x23
  800116:	68 c7 1d 80 00       	push   $0x801dc7
  80011b:	e8 14 0f 00 00       	call   801034 <_panic>

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
  800190:	68 aa 1d 80 00       	push   $0x801daa
  800195:	6a 23                	push   $0x23
  800197:	68 c7 1d 80 00       	push   $0x801dc7
  80019c:	e8 93 0e 00 00       	call   801034 <_panic>

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
  8001d2:	68 aa 1d 80 00       	push   $0x801daa
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 c7 1d 80 00       	push   $0x801dc7
  8001de:	e8 51 0e 00 00       	call   801034 <_panic>

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
  800214:	68 aa 1d 80 00       	push   $0x801daa
  800219:	6a 23                	push   $0x23
  80021b:	68 c7 1d 80 00       	push   $0x801dc7
  800220:	e8 0f 0e 00 00       	call   801034 <_panic>

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
  800256:	68 aa 1d 80 00       	push   $0x801daa
  80025b:	6a 23                	push   $0x23
  80025d:	68 c7 1d 80 00       	push   $0x801dc7
  800262:	e8 cd 0d 00 00       	call   801034 <_panic>

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
  800298:	68 aa 1d 80 00       	push   $0x801daa
  80029d:	6a 23                	push   $0x23
  80029f:	68 c7 1d 80 00       	push   $0x801dc7
  8002a4:	e8 8b 0d 00 00       	call   801034 <_panic>

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
  8002da:	68 aa 1d 80 00       	push   $0x801daa
  8002df:	6a 23                	push   $0x23
  8002e1:	68 c7 1d 80 00       	push   $0x801dc7
  8002e6:	e8 49 0d 00 00       	call   801034 <_panic>

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
  80033e:	68 aa 1d 80 00       	push   $0x801daa
  800343:	6a 23                	push   $0x23
  800345:	68 c7 1d 80 00       	push   $0x801dc7
  80034a:	e8 e5 0c 00 00       	call   801034 <_panic>

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

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 d8 1d 80 00       	push   $0x801dd8
  80045e:	e8 aa 0c 00 00       	call   80110d <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 19 1e 80 00       	push   $0x801e19
  800688:	e8 80 0a 00 00       	call   80110d <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 35 1e 80 00       	push   $0x801e35
  80075d:	e8 ab 09 00 00       	call   80110d <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 f8 1d 80 00       	push   $0x801df8
  800812:	e8 f6 08 00 00       	call   80110d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 d6 01 00 00       	call   800ab1 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 72 11 00 00       	call   801a94 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 03 11 00 00       	call   801a40 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 8f 10 00 00       	call   8019d9 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 bf 0c 00 00       	call   801692 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800a02:	8b 52 0c             	mov    0xc(%edx),%edx
  800a05:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a0b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a10:	50                   	push   %eax
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	68 08 50 80 00       	push   $0x805008
  800a19:	e8 06 0e 00 00       	call   801824 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	b8 04 00 00 00       	mov    $0x4,%eax
  800a28:	e8 d9 fe ff ff       	call   800906 <fsipc>

}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a42:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a52:	e8 af fe ff ff       	call   800906 <fsipc>
  800a57:	89 c3                	mov    %eax,%ebx
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	78 4b                	js     800aa8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a5d:	39 c6                	cmp    %eax,%esi
  800a5f:	73 16                	jae    800a77 <devfile_read+0x48>
  800a61:	68 64 1e 80 00       	push   $0x801e64
  800a66:	68 6b 1e 80 00       	push   $0x801e6b
  800a6b:	6a 7c                	push   $0x7c
  800a6d:	68 80 1e 80 00       	push   $0x801e80
  800a72:	e8 bd 05 00 00       	call   801034 <_panic>
	assert(r <= PGSIZE);
  800a77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7c:	7e 16                	jle    800a94 <devfile_read+0x65>
  800a7e:	68 8b 1e 80 00       	push   $0x801e8b
  800a83:	68 6b 1e 80 00       	push   $0x801e6b
  800a88:	6a 7d                	push   $0x7d
  800a8a:	68 80 1e 80 00       	push   $0x801e80
  800a8f:	e8 a0 05 00 00       	call   801034 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a94:	83 ec 04             	sub    $0x4,%esp
  800a97:	50                   	push   %eax
  800a98:	68 00 50 80 00       	push   $0x805000
  800a9d:	ff 75 0c             	pushl  0xc(%ebp)
  800aa0:	e8 7f 0d 00 00       	call   801824 <memmove>
	return r;
  800aa5:	83 c4 10             	add    $0x10,%esp
}
  800aa8:	89 d8                	mov    %ebx,%eax
  800aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	53                   	push   %ebx
  800ab5:	83 ec 20             	sub    $0x20,%esp
  800ab8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800abb:	53                   	push   %ebx
  800abc:	e8 98 0b 00 00       	call   801659 <strlen>
  800ac1:	83 c4 10             	add    $0x10,%esp
  800ac4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac9:	7f 67                	jg     800b32 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad1:	50                   	push   %eax
  800ad2:	e8 a7 f8 ff ff       	call   80037e <fd_alloc>
  800ad7:	83 c4 10             	add    $0x10,%esp
		return r;
  800ada:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adc:	85 c0                	test   %eax,%eax
  800ade:	78 57                	js     800b37 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae0:	83 ec 08             	sub    $0x8,%esp
  800ae3:	53                   	push   %ebx
  800ae4:	68 00 50 80 00       	push   $0x805000
  800ae9:	e8 a4 0b 00 00       	call   801692 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af9:	b8 01 00 00 00       	mov    $0x1,%eax
  800afe:	e8 03 fe ff ff       	call   800906 <fsipc>
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	79 14                	jns    800b20 <open+0x6f>
		fd_close(fd, 0);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	6a 00                	push   $0x0
  800b11:	ff 75 f4             	pushl  -0xc(%ebp)
  800b14:	e8 5d f9 ff ff       	call   800476 <fd_close>
		return r;
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	89 da                	mov    %ebx,%edx
  800b1e:	eb 17                	jmp    800b37 <open+0x86>
	}

	return fd2num(fd);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	ff 75 f4             	pushl  -0xc(%ebp)
  800b26:	e8 2c f8 ff ff       	call   800357 <fd2num>
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	eb 05                	jmp    800b37 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b32:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b37:	89 d0                	mov    %edx,%eax
  800b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4e:	e8 b3 fd ff ff       	call   800906 <fsipc>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	ff 75 08             	pushl  0x8(%ebp)
  800b63:	e8 ff f7 ff ff       	call   800367 <fd2data>
  800b68:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6a:	83 c4 08             	add    $0x8,%esp
  800b6d:	68 97 1e 80 00       	push   $0x801e97
  800b72:	53                   	push   %ebx
  800b73:	e8 1a 0b 00 00       	call   801692 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b78:	8b 46 04             	mov    0x4(%esi),%eax
  800b7b:	2b 06                	sub    (%esi),%eax
  800b7d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b83:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8a:	00 00 00 
	stat->st_dev = &devpipe;
  800b8d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b94:	30 80 00 
	return 0;
}
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bad:	53                   	push   %ebx
  800bae:	6a 00                	push   $0x0
  800bb0:	e8 36 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb5:	89 1c 24             	mov    %ebx,(%esp)
  800bb8:	e8 aa f7 ff ff       	call   800367 <fd2data>
  800bbd:	83 c4 08             	add    $0x8,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 00                	push   $0x0
  800bc3:	e8 23 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 1c             	sub    $0x1c,%esp
  800bd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bdb:	a1 04 40 80 00       	mov    0x804004,%eax
  800be0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	ff 75 e0             	pushl  -0x20(%ebp)
  800be9:	e8 df 0e 00 00       	call   801acd <pageref>
  800bee:	89 c3                	mov    %eax,%ebx
  800bf0:	89 3c 24             	mov    %edi,(%esp)
  800bf3:	e8 d5 0e 00 00       	call   801acd <pageref>
  800bf8:	83 c4 10             	add    $0x10,%esp
  800bfb:	39 c3                	cmp    %eax,%ebx
  800bfd:	0f 94 c1             	sete   %cl
  800c00:	0f b6 c9             	movzbl %cl,%ecx
  800c03:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c06:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0f:	39 ce                	cmp    %ecx,%esi
  800c11:	74 1b                	je     800c2e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c13:	39 c3                	cmp    %eax,%ebx
  800c15:	75 c4                	jne    800bdb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c17:	8b 42 58             	mov    0x58(%edx),%eax
  800c1a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1d:	50                   	push   %eax
  800c1e:	56                   	push   %esi
  800c1f:	68 9e 1e 80 00       	push   $0x801e9e
  800c24:	e8 e4 04 00 00       	call   80110d <cprintf>
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	eb ad                	jmp    800bdb <_pipeisclosed+0xe>
	}
}
  800c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 28             	sub    $0x28,%esp
  800c42:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c45:	56                   	push   %esi
  800c46:	e8 1c f7 ff ff       	call   800367 <fd2data>
  800c4b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	bf 00 00 00 00       	mov    $0x0,%edi
  800c55:	eb 4b                	jmp    800ca2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c57:	89 da                	mov    %ebx,%edx
  800c59:	89 f0                	mov    %esi,%eax
  800c5b:	e8 6d ff ff ff       	call   800bcd <_pipeisclosed>
  800c60:	85 c0                	test   %eax,%eax
  800c62:	75 48                	jne    800cac <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c64:	e8 de f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c69:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6c:	8b 0b                	mov    (%ebx),%ecx
  800c6e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c71:	39 d0                	cmp    %edx,%eax
  800c73:	73 e2                	jae    800c57 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7f:	89 c2                	mov    %eax,%edx
  800c81:	c1 fa 1f             	sar    $0x1f,%edx
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	c1 e9 1b             	shr    $0x1b,%ecx
  800c89:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8c:	83 e2 1f             	and    $0x1f,%edx
  800c8f:	29 ca                	sub    %ecx,%edx
  800c91:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c95:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c99:	83 c0 01             	add    $0x1,%eax
  800c9c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9f:	83 c7 01             	add    $0x1,%edi
  800ca2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca5:	75 c2                	jne    800c69 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca7:	8b 45 10             	mov    0x10(%ebp),%eax
  800caa:	eb 05                	jmp    800cb1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 18             	sub    $0x18,%esp
  800cc2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc5:	57                   	push   %edi
  800cc6:	e8 9c f6 ff ff       	call   800367 <fd2data>
  800ccb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	eb 3d                	jmp    800d14 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd7:	85 db                	test   %ebx,%ebx
  800cd9:	74 04                	je     800cdf <devpipe_read+0x26>
				return i;
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	eb 44                	jmp    800d23 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdf:	89 f2                	mov    %esi,%edx
  800ce1:	89 f8                	mov    %edi,%eax
  800ce3:	e8 e5 fe ff ff       	call   800bcd <_pipeisclosed>
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	75 32                	jne    800d1e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cec:	e8 56 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf1:	8b 06                	mov    (%esi),%eax
  800cf3:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf6:	74 df                	je     800cd7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf8:	99                   	cltd   
  800cf9:	c1 ea 1b             	shr    $0x1b,%edx
  800cfc:	01 d0                	add    %edx,%eax
  800cfe:	83 e0 1f             	and    $0x1f,%eax
  800d01:	29 d0                	sub    %edx,%eax
  800d03:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d11:	83 c3 01             	add    $0x1,%ebx
  800d14:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d17:	75 d8                	jne    800cf1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d19:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1c:	eb 05                	jmp    800d23 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d36:	50                   	push   %eax
  800d37:	e8 42 f6 ff ff       	call   80037e <fd_alloc>
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	89 c2                	mov    %eax,%edx
  800d41:	85 c0                	test   %eax,%eax
  800d43:	0f 88 2c 01 00 00    	js     800e75 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	68 07 04 00 00       	push   $0x407
  800d51:	ff 75 f4             	pushl  -0xc(%ebp)
  800d54:	6a 00                	push   $0x0
  800d56:	e8 0b f4 ff ff       	call   800166 <sys_page_alloc>
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	89 c2                	mov    %eax,%edx
  800d60:	85 c0                	test   %eax,%eax
  800d62:	0f 88 0d 01 00 00    	js     800e75 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6e:	50                   	push   %eax
  800d6f:	e8 0a f6 ff ff       	call   80037e <fd_alloc>
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	0f 88 e2 00 00 00    	js     800e63 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	68 07 04 00 00       	push   $0x407
  800d89:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8c:	6a 00                	push   $0x0
  800d8e:	e8 d3 f3 ff ff       	call   800166 <sys_page_alloc>
  800d93:	89 c3                	mov    %eax,%ebx
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	0f 88 c3 00 00 00    	js     800e63 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	ff 75 f4             	pushl  -0xc(%ebp)
  800da6:	e8 bc f5 ff ff       	call   800367 <fd2data>
  800dab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dad:	83 c4 0c             	add    $0xc,%esp
  800db0:	68 07 04 00 00       	push   $0x407
  800db5:	50                   	push   %eax
  800db6:	6a 00                	push   $0x0
  800db8:	e8 a9 f3 ff ff       	call   800166 <sys_page_alloc>
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	0f 88 89 00 00 00    	js     800e53 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd0:	e8 92 f5 ff ff       	call   800367 <fd2data>
  800dd5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ddc:	50                   	push   %eax
  800ddd:	6a 00                	push   $0x0
  800ddf:	56                   	push   %esi
  800de0:	6a 00                	push   $0x0
  800de2:	e8 c2 f3 ff ff       	call   8001a9 <sys_page_map>
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	83 c4 20             	add    $0x20,%esp
  800dec:	85 c0                	test   %eax,%eax
  800dee:	78 55                	js     800e45 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e13:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e20:	e8 32 f5 ff ff       	call   800357 <fd2num>
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2a:	83 c4 04             	add    $0x4,%esp
  800e2d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e30:	e8 22 f5 ff ff       	call   800357 <fd2num>
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e38:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e43:	eb 30                	jmp    800e75 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e45:	83 ec 08             	sub    $0x8,%esp
  800e48:	56                   	push   %esi
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 9b f3 ff ff       	call   8001eb <sys_page_unmap>
  800e50:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	ff 75 f0             	pushl  -0x10(%ebp)
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 8b f3 ff ff       	call   8001eb <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	ff 75 f4             	pushl  -0xc(%ebp)
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 7b f3 ff ff       	call   8001eb <sys_page_unmap>
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e75:	89 d0                	mov    %edx,%eax
  800e77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e87:	50                   	push   %eax
  800e88:	ff 75 08             	pushl  0x8(%ebp)
  800e8b:	e8 3d f5 ff ff       	call   8003cd <fd_lookup>
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	78 18                	js     800eaf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9d:	e8 c5 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea7:	e8 21 fd ff ff       	call   800bcd <_pipeisclosed>
  800eac:	83 c4 10             	add    $0x10,%esp
}
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec1:	68 b6 1e 80 00       	push   $0x801eb6
  800ec6:	ff 75 0c             	pushl  0xc(%ebp)
  800ec9:	e8 c4 07 00 00       	call   801692 <strcpy>
	return 0;
}
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eec:	eb 2d                	jmp    800f1b <devcons_write+0x46>
		m = n - tot;
  800eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800efb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	53                   	push   %ebx
  800f02:	03 45 0c             	add    0xc(%ebp),%eax
  800f05:	50                   	push   %eax
  800f06:	57                   	push   %edi
  800f07:	e8 18 09 00 00       	call   801824 <memmove>
		sys_cputs(buf, m);
  800f0c:	83 c4 08             	add    $0x8,%esp
  800f0f:	53                   	push   %ebx
  800f10:	57                   	push   %edi
  800f11:	e8 94 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f16:	01 de                	add    %ebx,%esi
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	89 f0                	mov    %esi,%eax
  800f1d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f20:	72 cc                	jb     800eee <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f39:	74 2a                	je     800f65 <devcons_read+0x3b>
  800f3b:	eb 05                	jmp    800f42 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3d:	e8 05 f2 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f42:	e8 81 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f47:	85 c0                	test   %eax,%eax
  800f49:	74 f2                	je     800f3d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 16                	js     800f65 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4f:	83 f8 04             	cmp    $0x4,%eax
  800f52:	74 0c                	je     800f60 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f57:	88 02                	mov    %al,(%edx)
	return 1;
  800f59:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5e:	eb 05                	jmp    800f65 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f60:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f70:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f73:	6a 01                	push   $0x1
  800f75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f78:	50                   	push   %eax
  800f79:	e8 2c f1 ff ff       	call   8000aa <sys_cputs>
}
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <getchar>:

int
getchar(void)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f89:	6a 01                	push   $0x1
  800f8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 9d f6 ff ff       	call   800633 <read>
	if (r < 0)
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 0f                	js     800fac <getchar+0x29>
		return r;
	if (r < 1)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	7e 06                	jle    800fa7 <getchar+0x24>
		return -E_EOF;
	return c;
  800fa1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa5:	eb 05                	jmp    800fac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fac:	c9                   	leave  
  800fad:	c3                   	ret    

00800fae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 75 08             	pushl  0x8(%ebp)
  800fbb:	e8 0d f4 ff ff       	call   8003cd <fd_lookup>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 11                	js     800fd8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd0:	39 10                	cmp    %edx,(%eax)
  800fd2:	0f 94 c0             	sete   %al
  800fd5:	0f b6 c0             	movzbl %al,%eax
}
  800fd8:	c9                   	leave  
  800fd9:	c3                   	ret    

00800fda <opencons>:

int
opencons(void)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe3:	50                   	push   %eax
  800fe4:	e8 95 f3 ff ff       	call   80037e <fd_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fec:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 3e                	js     801030 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	68 07 04 00 00       	push   $0x407
  800ffa:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 62 f1 ff ff       	call   800166 <sys_page_alloc>
  801004:	83 c4 10             	add    $0x10,%esp
		return r;
  801007:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 23                	js     801030 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80100d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801016:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	50                   	push   %eax
  801026:	e8 2c f3 ff ff       	call   800357 <fd2num>
  80102b:	89 c2                	mov    %eax,%edx
  80102d:	83 c4 10             	add    $0x10,%esp
}
  801030:	89 d0                	mov    %edx,%eax
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801039:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801042:	e8 e1 f0 ff ff       	call   800128 <sys_getenvid>
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	ff 75 0c             	pushl  0xc(%ebp)
  80104d:	ff 75 08             	pushl  0x8(%ebp)
  801050:	56                   	push   %esi
  801051:	50                   	push   %eax
  801052:	68 c4 1e 80 00       	push   $0x801ec4
  801057:	e8 b1 00 00 00       	call   80110d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105c:	83 c4 18             	add    $0x18,%esp
  80105f:	53                   	push   %ebx
  801060:	ff 75 10             	pushl  0x10(%ebp)
  801063:	e8 54 00 00 00       	call   8010bc <vcprintf>
	cprintf("\n");
  801068:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80106f:	e8 99 00 00 00       	call   80110d <cprintf>
  801074:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801077:	cc                   	int3   
  801078:	eb fd                	jmp    801077 <_panic+0x43>

0080107a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801084:	8b 13                	mov    (%ebx),%edx
  801086:	8d 42 01             	lea    0x1(%edx),%eax
  801089:	89 03                	mov    %eax,(%ebx)
  80108b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801092:	3d ff 00 00 00       	cmp    $0xff,%eax
  801097:	75 1a                	jne    8010b3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	68 ff 00 00 00       	push   $0xff
  8010a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a4:	50                   	push   %eax
  8010a5:	e8 00 f0 ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010cc:	00 00 00 
	b.cnt = 0;
  8010cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d9:	ff 75 0c             	pushl  0xc(%ebp)
  8010dc:	ff 75 08             	pushl  0x8(%ebp)
  8010df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	68 7a 10 80 00       	push   $0x80107a
  8010eb:	e8 54 01 00 00       	call   801244 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f0:	83 c4 08             	add    $0x8,%esp
  8010f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ff:	50                   	push   %eax
  801100:	e8 a5 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801105:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801113:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801116:	50                   	push   %eax
  801117:	ff 75 08             	pushl  0x8(%ebp)
  80111a:	e8 9d ff ff ff       	call   8010bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80111f:	c9                   	leave  
  801120:	c3                   	ret    

00801121 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 1c             	sub    $0x1c,%esp
  80112a:	89 c7                	mov    %eax,%edi
  80112c:	89 d6                	mov    %edx,%esi
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	8b 55 0c             	mov    0xc(%ebp),%edx
  801134:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801137:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801145:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801148:	39 d3                	cmp    %edx,%ebx
  80114a:	72 05                	jb     801151 <printnum+0x30>
  80114c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114f:	77 45                	ja     801196 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	ff 75 18             	pushl  0x18(%ebp)
  801157:	8b 45 14             	mov    0x14(%ebp),%eax
  80115a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115d:	53                   	push   %ebx
  80115e:	ff 75 10             	pushl  0x10(%ebp)
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	ff 75 e4             	pushl  -0x1c(%ebp)
  801167:	ff 75 e0             	pushl  -0x20(%ebp)
  80116a:	ff 75 dc             	pushl  -0x24(%ebp)
  80116d:	ff 75 d8             	pushl  -0x28(%ebp)
  801170:	e8 9b 09 00 00       	call   801b10 <__udivdi3>
  801175:	83 c4 18             	add    $0x18,%esp
  801178:	52                   	push   %edx
  801179:	50                   	push   %eax
  80117a:	89 f2                	mov    %esi,%edx
  80117c:	89 f8                	mov    %edi,%eax
  80117e:	e8 9e ff ff ff       	call   801121 <printnum>
  801183:	83 c4 20             	add    $0x20,%esp
  801186:	eb 18                	jmp    8011a0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	56                   	push   %esi
  80118c:	ff 75 18             	pushl  0x18(%ebp)
  80118f:	ff d7                	call   *%edi
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	eb 03                	jmp    801199 <printnum+0x78>
  801196:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801199:	83 eb 01             	sub    $0x1,%ebx
  80119c:	85 db                	test   %ebx,%ebx
  80119e:	7f e8                	jg     801188 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	56                   	push   %esi
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b3:	e8 88 0a 00 00       	call   801c40 <__umoddi3>
  8011b8:	83 c4 14             	add    $0x14,%esp
  8011bb:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011c2:	50                   	push   %eax
  8011c3:	ff d7                	call   *%edi
}
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d3:	83 fa 01             	cmp    $0x1,%edx
  8011d6:	7e 0e                	jle    8011e6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d8:	8b 10                	mov    (%eax),%edx
  8011da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011dd:	89 08                	mov    %ecx,(%eax)
  8011df:	8b 02                	mov    (%edx),%eax
  8011e1:	8b 52 04             	mov    0x4(%edx),%edx
  8011e4:	eb 22                	jmp    801208 <getuint+0x38>
	else if (lflag)
  8011e6:	85 d2                	test   %edx,%edx
  8011e8:	74 10                	je     8011fa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ea:	8b 10                	mov    (%eax),%edx
  8011ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ef:	89 08                	mov    %ecx,(%eax)
  8011f1:	8b 02                	mov    (%edx),%eax
  8011f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f8:	eb 0e                	jmp    801208 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011fa:	8b 10                	mov    (%eax),%edx
  8011fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ff:	89 08                	mov    %ecx,(%eax)
  801201:	8b 02                	mov    (%edx),%eax
  801203:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801210:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801214:	8b 10                	mov    (%eax),%edx
  801216:	3b 50 04             	cmp    0x4(%eax),%edx
  801219:	73 0a                	jae    801225 <sprintputch+0x1b>
		*b->buf++ = ch;
  80121b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121e:	89 08                	mov    %ecx,(%eax)
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	88 02                	mov    %al,(%edx)
}
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801230:	50                   	push   %eax
  801231:	ff 75 10             	pushl  0x10(%ebp)
  801234:	ff 75 0c             	pushl  0xc(%ebp)
  801237:	ff 75 08             	pushl  0x8(%ebp)
  80123a:	e8 05 00 00 00       	call   801244 <vprintfmt>
	va_end(ap);
}
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	83 ec 2c             	sub    $0x2c,%esp
  80124d:	8b 75 08             	mov    0x8(%ebp),%esi
  801250:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801253:	8b 7d 10             	mov    0x10(%ebp),%edi
  801256:	eb 12                	jmp    80126a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 84 89 03 00 00    	je     8015e9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	53                   	push   %ebx
  801264:	50                   	push   %eax
  801265:	ff d6                	call   *%esi
  801267:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126a:	83 c7 01             	add    $0x1,%edi
  80126d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801271:	83 f8 25             	cmp    $0x25,%eax
  801274:	75 e2                	jne    801258 <vprintfmt+0x14>
  801276:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801281:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801288:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80128f:	ba 00 00 00 00       	mov    $0x0,%edx
  801294:	eb 07                	jmp    80129d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801296:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801299:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129d:	8d 47 01             	lea    0x1(%edi),%eax
  8012a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a3:	0f b6 07             	movzbl (%edi),%eax
  8012a6:	0f b6 c8             	movzbl %al,%ecx
  8012a9:	83 e8 23             	sub    $0x23,%eax
  8012ac:	3c 55                	cmp    $0x55,%al
  8012ae:	0f 87 1a 03 00 00    	ja     8015ce <vprintfmt+0x38a>
  8012b4:	0f b6 c0             	movzbl %al,%eax
  8012b7:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c5:	eb d6                	jmp    80129d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012d9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012dc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012df:	83 fa 09             	cmp    $0x9,%edx
  8012e2:	77 39                	ja     80131d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012e7:	eb e9                	jmp    8012d2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ec:	8d 48 04             	lea    0x4(%eax),%ecx
  8012ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012f2:	8b 00                	mov    (%eax),%eax
  8012f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012fa:	eb 27                	jmp    801323 <vprintfmt+0xdf>
  8012fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ff:	85 c0                	test   %eax,%eax
  801301:	b9 00 00 00 00       	mov    $0x0,%ecx
  801306:	0f 49 c8             	cmovns %eax,%ecx
  801309:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130f:	eb 8c                	jmp    80129d <vprintfmt+0x59>
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801314:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80131b:	eb 80                	jmp    80129d <vprintfmt+0x59>
  80131d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801320:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801323:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801327:	0f 89 70 ff ff ff    	jns    80129d <vprintfmt+0x59>
				width = precision, precision = -1;
  80132d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801333:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80133a:	e9 5e ff ff ff       	jmp    80129d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80133f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801345:	e9 53 ff ff ff       	jmp    80129d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80134a:	8b 45 14             	mov    0x14(%ebp),%eax
  80134d:	8d 50 04             	lea    0x4(%eax),%edx
  801350:	89 55 14             	mov    %edx,0x14(%ebp)
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	53                   	push   %ebx
  801357:	ff 30                	pushl  (%eax)
  801359:	ff d6                	call   *%esi
			break;
  80135b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801361:	e9 04 ff ff ff       	jmp    80126a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801366:	8b 45 14             	mov    0x14(%ebp),%eax
  801369:	8d 50 04             	lea    0x4(%eax),%edx
  80136c:	89 55 14             	mov    %edx,0x14(%ebp)
  80136f:	8b 00                	mov    (%eax),%eax
  801371:	99                   	cltd   
  801372:	31 d0                	xor    %edx,%eax
  801374:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801376:	83 f8 0f             	cmp    $0xf,%eax
  801379:	7f 0b                	jg     801386 <vprintfmt+0x142>
  80137b:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801382:	85 d2                	test   %edx,%edx
  801384:	75 18                	jne    80139e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801386:	50                   	push   %eax
  801387:	68 ff 1e 80 00       	push   $0x801eff
  80138c:	53                   	push   %ebx
  80138d:	56                   	push   %esi
  80138e:	e8 94 fe ff ff       	call   801227 <printfmt>
  801393:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801399:	e9 cc fe ff ff       	jmp    80126a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80139e:	52                   	push   %edx
  80139f:	68 7d 1e 80 00       	push   $0x801e7d
  8013a4:	53                   	push   %ebx
  8013a5:	56                   	push   %esi
  8013a6:	e8 7c fe ff ff       	call   801227 <printfmt>
  8013ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b1:	e9 b4 fe ff ff       	jmp    80126a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	8d 50 04             	lea    0x4(%eax),%edx
  8013bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c1:	85 ff                	test   %edi,%edi
  8013c3:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013c8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013cf:	0f 8e 94 00 00 00    	jle    801469 <vprintfmt+0x225>
  8013d5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d9:	0f 84 98 00 00 00    	je     801477 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	ff 75 d0             	pushl  -0x30(%ebp)
  8013e5:	57                   	push   %edi
  8013e6:	e8 86 02 00 00       	call   801671 <strnlen>
  8013eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ee:	29 c1                	sub    %eax,%ecx
  8013f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801400:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801402:	eb 0f                	jmp    801413 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	53                   	push   %ebx
  801408:	ff 75 e0             	pushl  -0x20(%ebp)
  80140b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140d:	83 ef 01             	sub    $0x1,%edi
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 ff                	test   %edi,%edi
  801415:	7f ed                	jg     801404 <vprintfmt+0x1c0>
  801417:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80141a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80141d:	85 c9                	test   %ecx,%ecx
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
  801424:	0f 49 c1             	cmovns %ecx,%eax
  801427:	29 c1                	sub    %eax,%ecx
  801429:	89 75 08             	mov    %esi,0x8(%ebp)
  80142c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80142f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801432:	89 cb                	mov    %ecx,%ebx
  801434:	eb 4d                	jmp    801483 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801436:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80143a:	74 1b                	je     801457 <vprintfmt+0x213>
  80143c:	0f be c0             	movsbl %al,%eax
  80143f:	83 e8 20             	sub    $0x20,%eax
  801442:	83 f8 5e             	cmp    $0x5e,%eax
  801445:	76 10                	jbe    801457 <vprintfmt+0x213>
					putch('?', putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	6a 3f                	push   $0x3f
  80144f:	ff 55 08             	call   *0x8(%ebp)
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb 0d                	jmp    801464 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	ff 75 0c             	pushl  0xc(%ebp)
  80145d:	52                   	push   %edx
  80145e:	ff 55 08             	call   *0x8(%ebp)
  801461:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801464:	83 eb 01             	sub    $0x1,%ebx
  801467:	eb 1a                	jmp    801483 <vprintfmt+0x23f>
  801469:	89 75 08             	mov    %esi,0x8(%ebp)
  80146c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801472:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801475:	eb 0c                	jmp    801483 <vprintfmt+0x23f>
  801477:	89 75 08             	mov    %esi,0x8(%ebp)
  80147a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801480:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801483:	83 c7 01             	add    $0x1,%edi
  801486:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80148a:	0f be d0             	movsbl %al,%edx
  80148d:	85 d2                	test   %edx,%edx
  80148f:	74 23                	je     8014b4 <vprintfmt+0x270>
  801491:	85 f6                	test   %esi,%esi
  801493:	78 a1                	js     801436 <vprintfmt+0x1f2>
  801495:	83 ee 01             	sub    $0x1,%esi
  801498:	79 9c                	jns    801436 <vprintfmt+0x1f2>
  80149a:	89 df                	mov    %ebx,%edi
  80149c:	8b 75 08             	mov    0x8(%ebp),%esi
  80149f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a2:	eb 18                	jmp    8014bc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	6a 20                	push   $0x20
  8014aa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ac:	83 ef 01             	sub    $0x1,%edi
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	eb 08                	jmp    8014bc <vprintfmt+0x278>
  8014b4:	89 df                	mov    %ebx,%edi
  8014b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bc:	85 ff                	test   %edi,%edi
  8014be:	7f e4                	jg     8014a4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c3:	e9 a2 fd ff ff       	jmp    80126a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c8:	83 fa 01             	cmp    $0x1,%edx
  8014cb:	7e 16                	jle    8014e3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d0:	8d 50 08             	lea    0x8(%eax),%edx
  8014d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d6:	8b 50 04             	mov    0x4(%eax),%edx
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e1:	eb 32                	jmp    801515 <vprintfmt+0x2d1>
	else if (lflag)
  8014e3:	85 d2                	test   %edx,%edx
  8014e5:	74 18                	je     8014ff <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8d 50 04             	lea    0x4(%eax),%edx
  8014ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f0:	8b 00                	mov    (%eax),%eax
  8014f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f5:	89 c1                	mov    %eax,%ecx
  8014f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fd:	eb 16                	jmp    801515 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801502:	8d 50 04             	lea    0x4(%eax),%edx
  801505:	89 55 14             	mov    %edx,0x14(%ebp)
  801508:	8b 00                	mov    (%eax),%eax
  80150a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	c1 f9 1f             	sar    $0x1f,%ecx
  801512:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801515:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801518:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80151b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801520:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801524:	79 74                	jns    80159a <vprintfmt+0x356>
				putch('-', putdat);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	53                   	push   %ebx
  80152a:	6a 2d                	push   $0x2d
  80152c:	ff d6                	call   *%esi
				num = -(long long) num;
  80152e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801531:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801534:	f7 d8                	neg    %eax
  801536:	83 d2 00             	adc    $0x0,%edx
  801539:	f7 da                	neg    %edx
  80153b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80153e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801543:	eb 55                	jmp    80159a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801545:	8d 45 14             	lea    0x14(%ebp),%eax
  801548:	e8 83 fc ff ff       	call   8011d0 <getuint>
			base = 10;
  80154d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801552:	eb 46                	jmp    80159a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801554:	8d 45 14             	lea    0x14(%ebp),%eax
  801557:	e8 74 fc ff ff       	call   8011d0 <getuint>
			base = 8;
  80155c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801561:	eb 37                	jmp    80159a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	53                   	push   %ebx
  801567:	6a 30                	push   $0x30
  801569:	ff d6                	call   *%esi
			putch('x', putdat);
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	53                   	push   %ebx
  80156f:	6a 78                	push   $0x78
  801571:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8d 50 04             	lea    0x4(%eax),%edx
  801579:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80157c:	8b 00                	mov    (%eax),%eax
  80157e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801583:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801586:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80158b:	eb 0d                	jmp    80159a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80158d:	8d 45 14             	lea    0x14(%ebp),%eax
  801590:	e8 3b fc ff ff       	call   8011d0 <getuint>
			base = 16;
  801595:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015a1:	57                   	push   %edi
  8015a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a5:	51                   	push   %ecx
  8015a6:	52                   	push   %edx
  8015a7:	50                   	push   %eax
  8015a8:	89 da                	mov    %ebx,%edx
  8015aa:	89 f0                	mov    %esi,%eax
  8015ac:	e8 70 fb ff ff       	call   801121 <printnum>
			break;
  8015b1:	83 c4 20             	add    $0x20,%esp
  8015b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015b7:	e9 ae fc ff ff       	jmp    80126a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	51                   	push   %ecx
  8015c1:	ff d6                	call   *%esi
			break;
  8015c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015c9:	e9 9c fc ff ff       	jmp    80126a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	53                   	push   %ebx
  8015d2:	6a 25                	push   $0x25
  8015d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	eb 03                	jmp    8015de <vprintfmt+0x39a>
  8015db:	83 ef 01             	sub    $0x1,%edi
  8015de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015e2:	75 f7                	jne    8015db <vprintfmt+0x397>
  8015e4:	e9 81 fc ff ff       	jmp    80126a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ec:	5b                   	pop    %ebx
  8015ed:	5e                   	pop    %esi
  8015ee:	5f                   	pop    %edi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    

008015f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	83 ec 18             	sub    $0x18,%esp
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801600:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801604:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801607:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80160e:	85 c0                	test   %eax,%eax
  801610:	74 26                	je     801638 <vsnprintf+0x47>
  801612:	85 d2                	test   %edx,%edx
  801614:	7e 22                	jle    801638 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801616:	ff 75 14             	pushl  0x14(%ebp)
  801619:	ff 75 10             	pushl  0x10(%ebp)
  80161c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	68 0a 12 80 00       	push   $0x80120a
  801625:	e8 1a fc ff ff       	call   801244 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80162d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 05                	jmp    80163d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801638:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801645:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801648:	50                   	push   %eax
  801649:	ff 75 10             	pushl  0x10(%ebp)
  80164c:	ff 75 0c             	pushl  0xc(%ebp)
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 9a ff ff ff       	call   8015f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
  801664:	eb 03                	jmp    801669 <strlen+0x10>
		n++;
  801666:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801669:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80166d:	75 f7                	jne    801666 <strlen+0xd>
		n++;
	return n;
}
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801677:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	eb 03                	jmp    801684 <strnlen+0x13>
		n++;
  801681:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801684:	39 c2                	cmp    %eax,%edx
  801686:	74 08                	je     801690 <strnlen+0x1f>
  801688:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80168c:	75 f3                	jne    801681 <strnlen+0x10>
  80168e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	83 c2 01             	add    $0x1,%edx
  8016a1:	83 c1 01             	add    $0x1,%ecx
  8016a4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016a8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ab:	84 db                	test   %bl,%bl
  8016ad:	75 ef                	jne    80169e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016af:	5b                   	pop    %ebx
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016b9:	53                   	push   %ebx
  8016ba:	e8 9a ff ff ff       	call   801659 <strlen>
  8016bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	01 d8                	add    %ebx,%eax
  8016c7:	50                   	push   %eax
  8016c8:	e8 c5 ff ff ff       	call   801692 <strcpy>
	return dst;
}
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016df:	89 f3                	mov    %esi,%ebx
  8016e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016e4:	89 f2                	mov    %esi,%edx
  8016e6:	eb 0f                	jmp    8016f7 <strncpy+0x23>
		*dst++ = *src;
  8016e8:	83 c2 01             	add    $0x1,%edx
  8016eb:	0f b6 01             	movzbl (%ecx),%eax
  8016ee:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016f1:	80 39 01             	cmpb   $0x1,(%ecx)
  8016f4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f7:	39 da                	cmp    %ebx,%edx
  8016f9:	75 ed                	jne    8016e8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016fb:	89 f0                	mov    %esi,%eax
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	8b 75 08             	mov    0x8(%ebp),%esi
  801709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170c:	8b 55 10             	mov    0x10(%ebp),%edx
  80170f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801711:	85 d2                	test   %edx,%edx
  801713:	74 21                	je     801736 <strlcpy+0x35>
  801715:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801719:	89 f2                	mov    %esi,%edx
  80171b:	eb 09                	jmp    801726 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80171d:	83 c2 01             	add    $0x1,%edx
  801720:	83 c1 01             	add    $0x1,%ecx
  801723:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801726:	39 c2                	cmp    %eax,%edx
  801728:	74 09                	je     801733 <strlcpy+0x32>
  80172a:	0f b6 19             	movzbl (%ecx),%ebx
  80172d:	84 db                	test   %bl,%bl
  80172f:	75 ec                	jne    80171d <strlcpy+0x1c>
  801731:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801733:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801736:	29 f0                	sub    %esi,%eax
}
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801742:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801745:	eb 06                	jmp    80174d <strcmp+0x11>
		p++, q++;
  801747:	83 c1 01             	add    $0x1,%ecx
  80174a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80174d:	0f b6 01             	movzbl (%ecx),%eax
  801750:	84 c0                	test   %al,%al
  801752:	74 04                	je     801758 <strcmp+0x1c>
  801754:	3a 02                	cmp    (%edx),%al
  801756:	74 ef                	je     801747 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801758:	0f b6 c0             	movzbl %al,%eax
  80175b:	0f b6 12             	movzbl (%edx),%edx
  80175e:	29 d0                	sub    %edx,%eax
}
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801771:	eb 06                	jmp    801779 <strncmp+0x17>
		n--, p++, q++;
  801773:	83 c0 01             	add    $0x1,%eax
  801776:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801779:	39 d8                	cmp    %ebx,%eax
  80177b:	74 15                	je     801792 <strncmp+0x30>
  80177d:	0f b6 08             	movzbl (%eax),%ecx
  801780:	84 c9                	test   %cl,%cl
  801782:	74 04                	je     801788 <strncmp+0x26>
  801784:	3a 0a                	cmp    (%edx),%cl
  801786:	74 eb                	je     801773 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801788:	0f b6 00             	movzbl (%eax),%eax
  80178b:	0f b6 12             	movzbl (%edx),%edx
  80178e:	29 d0                	sub    %edx,%eax
  801790:	eb 05                	jmp    801797 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801797:	5b                   	pop    %ebx
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017a4:	eb 07                	jmp    8017ad <strchr+0x13>
		if (*s == c)
  8017a6:	38 ca                	cmp    %cl,%dl
  8017a8:	74 0f                	je     8017b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017aa:	83 c0 01             	add    $0x1,%eax
  8017ad:	0f b6 10             	movzbl (%eax),%edx
  8017b0:	84 d2                	test   %dl,%dl
  8017b2:	75 f2                	jne    8017a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c5:	eb 03                	jmp    8017ca <strfind+0xf>
  8017c7:	83 c0 01             	add    $0x1,%eax
  8017ca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017cd:	38 ca                	cmp    %cl,%dl
  8017cf:	74 04                	je     8017d5 <strfind+0x1a>
  8017d1:	84 d2                	test   %dl,%dl
  8017d3:	75 f2                	jne    8017c7 <strfind+0xc>
			break;
	return (char *) s;
}
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	57                   	push   %edi
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017e3:	85 c9                	test   %ecx,%ecx
  8017e5:	74 36                	je     80181d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ed:	75 28                	jne    801817 <memset+0x40>
  8017ef:	f6 c1 03             	test   $0x3,%cl
  8017f2:	75 23                	jne    801817 <memset+0x40>
		c &= 0xFF;
  8017f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f8:	89 d3                	mov    %edx,%ebx
  8017fa:	c1 e3 08             	shl    $0x8,%ebx
  8017fd:	89 d6                	mov    %edx,%esi
  8017ff:	c1 e6 18             	shl    $0x18,%esi
  801802:	89 d0                	mov    %edx,%eax
  801804:	c1 e0 10             	shl    $0x10,%eax
  801807:	09 f0                	or     %esi,%eax
  801809:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80180b:	89 d8                	mov    %ebx,%eax
  80180d:	09 d0                	or     %edx,%eax
  80180f:	c1 e9 02             	shr    $0x2,%ecx
  801812:	fc                   	cld    
  801813:	f3 ab                	rep stos %eax,%es:(%edi)
  801815:	eb 06                	jmp    80181d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801817:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181a:	fc                   	cld    
  80181b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80181d:	89 f8                	mov    %edi,%eax
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5f                   	pop    %edi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80182f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801832:	39 c6                	cmp    %eax,%esi
  801834:	73 35                	jae    80186b <memmove+0x47>
  801836:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801839:	39 d0                	cmp    %edx,%eax
  80183b:	73 2e                	jae    80186b <memmove+0x47>
		s += n;
		d += n;
  80183d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801840:	89 d6                	mov    %edx,%esi
  801842:	09 fe                	or     %edi,%esi
  801844:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80184a:	75 13                	jne    80185f <memmove+0x3b>
  80184c:	f6 c1 03             	test   $0x3,%cl
  80184f:	75 0e                	jne    80185f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801851:	83 ef 04             	sub    $0x4,%edi
  801854:	8d 72 fc             	lea    -0x4(%edx),%esi
  801857:	c1 e9 02             	shr    $0x2,%ecx
  80185a:	fd                   	std    
  80185b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185d:	eb 09                	jmp    801868 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80185f:	83 ef 01             	sub    $0x1,%edi
  801862:	8d 72 ff             	lea    -0x1(%edx),%esi
  801865:	fd                   	std    
  801866:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801868:	fc                   	cld    
  801869:	eb 1d                	jmp    801888 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186b:	89 f2                	mov    %esi,%edx
  80186d:	09 c2                	or     %eax,%edx
  80186f:	f6 c2 03             	test   $0x3,%dl
  801872:	75 0f                	jne    801883 <memmove+0x5f>
  801874:	f6 c1 03             	test   $0x3,%cl
  801877:	75 0a                	jne    801883 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801879:	c1 e9 02             	shr    $0x2,%ecx
  80187c:	89 c7                	mov    %eax,%edi
  80187e:	fc                   	cld    
  80187f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801881:	eb 05                	jmp    801888 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801883:	89 c7                	mov    %eax,%edi
  801885:	fc                   	cld    
  801886:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801888:	5e                   	pop    %esi
  801889:	5f                   	pop    %edi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80188f:	ff 75 10             	pushl  0x10(%ebp)
  801892:	ff 75 0c             	pushl  0xc(%ebp)
  801895:	ff 75 08             	pushl  0x8(%ebp)
  801898:	e8 87 ff ff ff       	call   801824 <memmove>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018aa:	89 c6                	mov    %eax,%esi
  8018ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018af:	eb 1a                	jmp    8018cb <memcmp+0x2c>
		if (*s1 != *s2)
  8018b1:	0f b6 08             	movzbl (%eax),%ecx
  8018b4:	0f b6 1a             	movzbl (%edx),%ebx
  8018b7:	38 d9                	cmp    %bl,%cl
  8018b9:	74 0a                	je     8018c5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018bb:	0f b6 c1             	movzbl %cl,%eax
  8018be:	0f b6 db             	movzbl %bl,%ebx
  8018c1:	29 d8                	sub    %ebx,%eax
  8018c3:	eb 0f                	jmp    8018d4 <memcmp+0x35>
		s1++, s2++;
  8018c5:	83 c0 01             	add    $0x1,%eax
  8018c8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cb:	39 f0                	cmp    %esi,%eax
  8018cd:	75 e2                	jne    8018b1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	53                   	push   %ebx
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018df:	89 c1                	mov    %eax,%ecx
  8018e1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e8:	eb 0a                	jmp    8018f4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ea:	0f b6 10             	movzbl (%eax),%edx
  8018ed:	39 da                	cmp    %ebx,%edx
  8018ef:	74 07                	je     8018f8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018f1:	83 c0 01             	add    $0x1,%eax
  8018f4:	39 c8                	cmp    %ecx,%eax
  8018f6:	72 f2                	jb     8018ea <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018f8:	5b                   	pop    %ebx
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	57                   	push   %edi
  8018ff:	56                   	push   %esi
  801900:	53                   	push   %ebx
  801901:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801904:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801907:	eb 03                	jmp    80190c <strtol+0x11>
		s++;
  801909:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80190c:	0f b6 01             	movzbl (%ecx),%eax
  80190f:	3c 20                	cmp    $0x20,%al
  801911:	74 f6                	je     801909 <strtol+0xe>
  801913:	3c 09                	cmp    $0x9,%al
  801915:	74 f2                	je     801909 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801917:	3c 2b                	cmp    $0x2b,%al
  801919:	75 0a                	jne    801925 <strtol+0x2a>
		s++;
  80191b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80191e:	bf 00 00 00 00       	mov    $0x0,%edi
  801923:	eb 11                	jmp    801936 <strtol+0x3b>
  801925:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80192a:	3c 2d                	cmp    $0x2d,%al
  80192c:	75 08                	jne    801936 <strtol+0x3b>
		s++, neg = 1;
  80192e:	83 c1 01             	add    $0x1,%ecx
  801931:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801936:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80193c:	75 15                	jne    801953 <strtol+0x58>
  80193e:	80 39 30             	cmpb   $0x30,(%ecx)
  801941:	75 10                	jne    801953 <strtol+0x58>
  801943:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801947:	75 7c                	jne    8019c5 <strtol+0xca>
		s += 2, base = 16;
  801949:	83 c1 02             	add    $0x2,%ecx
  80194c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801951:	eb 16                	jmp    801969 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801953:	85 db                	test   %ebx,%ebx
  801955:	75 12                	jne    801969 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801957:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80195c:	80 39 30             	cmpb   $0x30,(%ecx)
  80195f:	75 08                	jne    801969 <strtol+0x6e>
		s++, base = 8;
  801961:	83 c1 01             	add    $0x1,%ecx
  801964:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801969:	b8 00 00 00 00       	mov    $0x0,%eax
  80196e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801971:	0f b6 11             	movzbl (%ecx),%edx
  801974:	8d 72 d0             	lea    -0x30(%edx),%esi
  801977:	89 f3                	mov    %esi,%ebx
  801979:	80 fb 09             	cmp    $0x9,%bl
  80197c:	77 08                	ja     801986 <strtol+0x8b>
			dig = *s - '0';
  80197e:	0f be d2             	movsbl %dl,%edx
  801981:	83 ea 30             	sub    $0x30,%edx
  801984:	eb 22                	jmp    8019a8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801986:	8d 72 9f             	lea    -0x61(%edx),%esi
  801989:	89 f3                	mov    %esi,%ebx
  80198b:	80 fb 19             	cmp    $0x19,%bl
  80198e:	77 08                	ja     801998 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801990:	0f be d2             	movsbl %dl,%edx
  801993:	83 ea 57             	sub    $0x57,%edx
  801996:	eb 10                	jmp    8019a8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801998:	8d 72 bf             	lea    -0x41(%edx),%esi
  80199b:	89 f3                	mov    %esi,%ebx
  80199d:	80 fb 19             	cmp    $0x19,%bl
  8019a0:	77 16                	ja     8019b8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019a2:	0f be d2             	movsbl %dl,%edx
  8019a5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019a8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ab:	7d 0b                	jge    8019b8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019ad:	83 c1 01             	add    $0x1,%ecx
  8019b0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019b4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019b6:	eb b9                	jmp    801971 <strtol+0x76>

	if (endptr)
  8019b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019bc:	74 0d                	je     8019cb <strtol+0xd0>
		*endptr = (char *) s;
  8019be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019c1:	89 0e                	mov    %ecx,(%esi)
  8019c3:	eb 06                	jmp    8019cb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c5:	85 db                	test   %ebx,%ebx
  8019c7:	74 98                	je     801961 <strtol+0x66>
  8019c9:	eb 9e                	jmp    801969 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019cb:	89 c2                	mov    %eax,%edx
  8019cd:	f7 da                	neg    %edx
  8019cf:	85 ff                	test   %edi,%edi
  8019d1:	0f 45 c2             	cmovne %edx,%eax
}
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5f                   	pop    %edi
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	56                   	push   %esi
  8019dd:	53                   	push   %ebx
  8019de:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019e7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019e9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019ee:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	50                   	push   %eax
  8019f5:	e8 1c e9 ff ff       	call   800316 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 f6                	test   %esi,%esi
  8019ff:	74 14                	je     801a15 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a01:	ba 00 00 00 00       	mov    $0x0,%edx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 09                	js     801a13 <ipc_recv+0x3a>
  801a0a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a10:	8b 52 74             	mov    0x74(%edx),%edx
  801a13:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a15:	85 db                	test   %ebx,%ebx
  801a17:	74 14                	je     801a2d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 09                	js     801a2b <ipc_recv+0x52>
  801a22:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a28:	8b 52 78             	mov    0x78(%edx),%edx
  801a2b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 08                	js     801a39 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a31:	a1 04 40 80 00       	mov    0x804004,%eax
  801a36:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	57                   	push   %edi
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a52:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a54:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a59:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a5c:	ff 75 14             	pushl  0x14(%ebp)
  801a5f:	53                   	push   %ebx
  801a60:	56                   	push   %esi
  801a61:	57                   	push   %edi
  801a62:	e8 8c e8 ff ff       	call   8002f3 <sys_ipc_try_send>

		if (err < 0) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	79 1e                	jns    801a8c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a6e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a71:	75 07                	jne    801a7a <ipc_send+0x3a>
				sys_yield();
  801a73:	e8 cf e6 ff ff       	call   800147 <sys_yield>
  801a78:	eb e2                	jmp    801a5c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a7a:	50                   	push   %eax
  801a7b:	68 e0 21 80 00       	push   $0x8021e0
  801a80:	6a 49                	push   $0x49
  801a82:	68 ed 21 80 00       	push   $0x8021ed
  801a87:	e8 a8 f5 ff ff       	call   801034 <_panic>
		}

	} while (err < 0);

}
  801a8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5f                   	pop    %edi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a9f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aa2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa8:	8b 52 50             	mov    0x50(%edx),%edx
  801aab:	39 ca                	cmp    %ecx,%edx
  801aad:	75 0d                	jne    801abc <ipc_find_env+0x28>
			return envs[i].env_id;
  801aaf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ab2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ab7:	8b 40 48             	mov    0x48(%eax),%eax
  801aba:	eb 0f                	jmp    801acb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801abc:	83 c0 01             	add    $0x1,%eax
  801abf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac4:	75 d9                	jne    801a9f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad3:	89 d0                	mov    %edx,%eax
  801ad5:	c1 e8 16             	shr    $0x16,%eax
  801ad8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae4:	f6 c1 01             	test   $0x1,%cl
  801ae7:	74 1d                	je     801b06 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae9:	c1 ea 0c             	shr    $0xc,%edx
  801aec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801af3:	f6 c2 01             	test   $0x1,%dl
  801af6:	74 0e                	je     801b06 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af8:	c1 ea 0c             	shr    $0xc,%edx
  801afb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b02:	ef 
  801b03:	0f b7 c0             	movzwl %ax,%eax
}
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    
  801b08:	66 90                	xchg   %ax,%ax
  801b0a:	66 90                	xchg   %ax,%ax
  801b0c:	66 90                	xchg   %ax,%ax
  801b0e:	66 90                	xchg   %ax,%ax

00801b10 <__udivdi3>:
  801b10:	55                   	push   %ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 1c             	sub    $0x1c,%esp
  801b17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b27:	85 f6                	test   %esi,%esi
  801b29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2d:	89 ca                	mov    %ecx,%edx
  801b2f:	89 f8                	mov    %edi,%eax
  801b31:	75 3d                	jne    801b70 <__udivdi3+0x60>
  801b33:	39 cf                	cmp    %ecx,%edi
  801b35:	0f 87 c5 00 00 00    	ja     801c00 <__udivdi3+0xf0>
  801b3b:	85 ff                	test   %edi,%edi
  801b3d:	89 fd                	mov    %edi,%ebp
  801b3f:	75 0b                	jne    801b4c <__udivdi3+0x3c>
  801b41:	b8 01 00 00 00       	mov    $0x1,%eax
  801b46:	31 d2                	xor    %edx,%edx
  801b48:	f7 f7                	div    %edi
  801b4a:	89 c5                	mov    %eax,%ebp
  801b4c:	89 c8                	mov    %ecx,%eax
  801b4e:	31 d2                	xor    %edx,%edx
  801b50:	f7 f5                	div    %ebp
  801b52:	89 c1                	mov    %eax,%ecx
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	89 cf                	mov    %ecx,%edi
  801b58:	f7 f5                	div    %ebp
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	89 d8                	mov    %ebx,%eax
  801b5e:	89 fa                	mov    %edi,%edx
  801b60:	83 c4 1c             	add    $0x1c,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
  801b68:	90                   	nop
  801b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b70:	39 ce                	cmp    %ecx,%esi
  801b72:	77 74                	ja     801be8 <__udivdi3+0xd8>
  801b74:	0f bd fe             	bsr    %esi,%edi
  801b77:	83 f7 1f             	xor    $0x1f,%edi
  801b7a:	0f 84 98 00 00 00    	je     801c18 <__udivdi3+0x108>
  801b80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	89 c5                	mov    %eax,%ebp
  801b89:	29 fb                	sub    %edi,%ebx
  801b8b:	d3 e6                	shl    %cl,%esi
  801b8d:	89 d9                	mov    %ebx,%ecx
  801b8f:	d3 ed                	shr    %cl,%ebp
  801b91:	89 f9                	mov    %edi,%ecx
  801b93:	d3 e0                	shl    %cl,%eax
  801b95:	09 ee                	or     %ebp,%esi
  801b97:	89 d9                	mov    %ebx,%ecx
  801b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9d:	89 d5                	mov    %edx,%ebp
  801b9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ba3:	d3 ed                	shr    %cl,%ebp
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e2                	shl    %cl,%edx
  801ba9:	89 d9                	mov    %ebx,%ecx
  801bab:	d3 e8                	shr    %cl,%eax
  801bad:	09 c2                	or     %eax,%edx
  801baf:	89 d0                	mov    %edx,%eax
  801bb1:	89 ea                	mov    %ebp,%edx
  801bb3:	f7 f6                	div    %esi
  801bb5:	89 d5                	mov    %edx,%ebp
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	f7 64 24 0c          	mull   0xc(%esp)
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	72 10                	jb     801bd1 <__udivdi3+0xc1>
  801bc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e6                	shl    %cl,%esi
  801bc9:	39 c6                	cmp    %eax,%esi
  801bcb:	73 07                	jae    801bd4 <__udivdi3+0xc4>
  801bcd:	39 d5                	cmp    %edx,%ebp
  801bcf:	75 03                	jne    801bd4 <__udivdi3+0xc4>
  801bd1:	83 eb 01             	sub    $0x1,%ebx
  801bd4:	31 ff                	xor    %edi,%edi
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	89 fa                	mov    %edi,%edx
  801bda:	83 c4 1c             	add    $0x1c,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    
  801be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801be8:	31 ff                	xor    %edi,%edi
  801bea:	31 db                	xor    %ebx,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	f7 f7                	div    %edi
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	89 d8                	mov    %ebx,%eax
  801c0a:	89 fa                	mov    %edi,%edx
  801c0c:	83 c4 1c             	add    $0x1c,%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	39 ce                	cmp    %ecx,%esi
  801c1a:	72 0c                	jb     801c28 <__udivdi3+0x118>
  801c1c:	31 db                	xor    %ebx,%ebx
  801c1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c22:	0f 87 34 ff ff ff    	ja     801b5c <__udivdi3+0x4c>
  801c28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c2d:	e9 2a ff ff ff       	jmp    801b5c <__udivdi3+0x4c>
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__umoddi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 d2                	test   %edx,%edx
  801c59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f3                	mov    %esi,%ebx
  801c63:	89 3c 24             	mov    %edi,(%esp)
  801c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6a:	75 1c                	jne    801c88 <__umoddi3+0x48>
  801c6c:	39 f7                	cmp    %esi,%edi
  801c6e:	76 50                	jbe    801cc0 <__umoddi3+0x80>
  801c70:	89 c8                	mov    %ecx,%eax
  801c72:	89 f2                	mov    %esi,%edx
  801c74:	f7 f7                	div    %edi
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	31 d2                	xor    %edx,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	89 d0                	mov    %edx,%eax
  801c8c:	77 52                	ja     801ce0 <__umoddi3+0xa0>
  801c8e:	0f bd ea             	bsr    %edx,%ebp
  801c91:	83 f5 1f             	xor    $0x1f,%ebp
  801c94:	75 5a                	jne    801cf0 <__umoddi3+0xb0>
  801c96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c9a:	0f 82 e0 00 00 00    	jb     801d80 <__umoddi3+0x140>
  801ca0:	39 0c 24             	cmp    %ecx,(%esp)
  801ca3:	0f 86 d7 00 00 00    	jbe    801d80 <__umoddi3+0x140>
  801ca9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cb1:	83 c4 1c             	add    $0x1c,%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	85 ff                	test   %edi,%edi
  801cc2:	89 fd                	mov    %edi,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0x91>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f7                	div    %edi
  801ccf:	89 c5                	mov    %eax,%ebp
  801cd1:	89 f0                	mov    %esi,%eax
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	f7 f5                	div    %ebp
  801cd7:	89 c8                	mov    %ecx,%eax
  801cd9:	f7 f5                	div    %ebp
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	eb 99                	jmp    801c78 <__umoddi3+0x38>
  801cdf:	90                   	nop
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	83 c4 1c             	add    $0x1c,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	8b 34 24             	mov    (%esp),%esi
  801cf3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cf8:	89 e9                	mov    %ebp,%ecx
  801cfa:	29 ef                	sub    %ebp,%edi
  801cfc:	d3 e0                	shl    %cl,%eax
  801cfe:	89 f9                	mov    %edi,%ecx
  801d00:	89 f2                	mov    %esi,%edx
  801d02:	d3 ea                	shr    %cl,%edx
  801d04:	89 e9                	mov    %ebp,%ecx
  801d06:	09 c2                	or     %eax,%edx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 14 24             	mov    %edx,(%esp)
  801d0d:	89 f2                	mov    %esi,%edx
  801d0f:	d3 e2                	shl    %cl,%edx
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	89 e9                	mov    %ebp,%ecx
  801d1f:	89 c6                	mov    %eax,%esi
  801d21:	d3 e3                	shl    %cl,%ebx
  801d23:	89 f9                	mov    %edi,%ecx
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	d3 e8                	shr    %cl,%eax
  801d29:	89 e9                	mov    %ebp,%ecx
  801d2b:	09 d8                	or     %ebx,%eax
  801d2d:	89 d3                	mov    %edx,%ebx
  801d2f:	89 f2                	mov    %esi,%edx
  801d31:	f7 34 24             	divl   (%esp)
  801d34:	89 d6                	mov    %edx,%esi
  801d36:	d3 e3                	shl    %cl,%ebx
  801d38:	f7 64 24 04          	mull   0x4(%esp)
  801d3c:	39 d6                	cmp    %edx,%esi
  801d3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	72 08                	jb     801d50 <__umoddi3+0x110>
  801d48:	75 11                	jne    801d5b <__umoddi3+0x11b>
  801d4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d4e:	73 0b                	jae    801d5b <__umoddi3+0x11b>
  801d50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d54:	1b 14 24             	sbb    (%esp),%edx
  801d57:	89 d1                	mov    %edx,%ecx
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d5f:	29 da                	sub    %ebx,%edx
  801d61:	19 ce                	sbb    %ecx,%esi
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e0                	shl    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	d3 ea                	shr    %cl,%edx
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	d3 ee                	shr    %cl,%esi
  801d71:	09 d0                	or     %edx,%eax
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	83 c4 1c             	add    $0x1c,%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    
  801d7d:	8d 76 00             	lea    0x0(%esi),%esi
  801d80:	29 f9                	sub    %edi,%ecx
  801d82:	19 d6                	sbb    %edx,%esi
  801d84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d8c:	e9 18 ff ff ff       	jmp    801ca9 <__umoddi3+0x69>
