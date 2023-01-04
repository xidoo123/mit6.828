
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 8a 1d 80 00       	push   $0x801d8a
  80010c:	6a 23                	push   $0x23
  80010e:	68 a7 1d 80 00       	push   $0x801da7
  800113:	e8 f5 0e 00 00       	call   80100d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 8a 1d 80 00       	push   $0x801d8a
  80018d:	6a 23                	push   $0x23
  80018f:	68 a7 1d 80 00       	push   $0x801da7
  800194:	e8 74 0e 00 00       	call   80100d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 8a 1d 80 00       	push   $0x801d8a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 a7 1d 80 00       	push   $0x801da7
  8001d6:	e8 32 0e 00 00       	call   80100d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 8a 1d 80 00       	push   $0x801d8a
  800211:	6a 23                	push   $0x23
  800213:	68 a7 1d 80 00       	push   $0x801da7
  800218:	e8 f0 0d 00 00       	call   80100d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 8a 1d 80 00       	push   $0x801d8a
  800253:	6a 23                	push   $0x23
  800255:	68 a7 1d 80 00       	push   $0x801da7
  80025a:	e8 ae 0d 00 00       	call   80100d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 8a 1d 80 00       	push   $0x801d8a
  800295:	6a 23                	push   $0x23
  800297:	68 a7 1d 80 00       	push   $0x801da7
  80029c:	e8 6c 0d 00 00       	call   80100d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 8a 1d 80 00       	push   $0x801d8a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 a7 1d 80 00       	push   $0x801da7
  8002de:	e8 2a 0d 00 00       	call   80100d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 8a 1d 80 00       	push   $0x801d8a
  80033b:	6a 23                	push   $0x23
  80033d:	68 a7 1d 80 00       	push   $0x801da7
  800342:	e8 c6 0c 00 00       	call   80100d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba 34 1e 80 00       	mov    $0x801e34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 b8 1d 80 00       	push   $0x801db8
  800456:	e8 8b 0c 00 00       	call   8010e6 <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 f9 1d 80 00       	push   $0x801df9
  800680:	e8 61 0a 00 00       	call   8010e6 <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 15 1e 80 00       	push   $0x801e15
  800755:	e8 8c 09 00 00       	call   8010e6 <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 d8 1d 80 00       	push   $0x801dd8
  80080a:	e8 d7 08 00 00       	call   8010e6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 b7 01 00 00       	call   800a8a <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 53 11 00 00       	call   801a6d <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 e4 10 00 00       	call   801a19 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 70 10 00 00       	call   8019b2 <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 a0 0c 00 00       	call   80166b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009f4:	68 44 1e 80 00       	push   $0x801e44
  8009f9:	68 90 00 00 00       	push   $0x90
  8009fe:	68 62 1e 80 00       	push   $0x801e62
  800a03:	e8 05 06 00 00       	call   80100d <_panic>

00800a08 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 40 0c             	mov    0xc(%eax),%eax
  800a16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2b:	e8 ce fe ff ff       	call   8008fe <fsipc>
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 4b                	js     800a81 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a36:	39 c6                	cmp    %eax,%esi
  800a38:	73 16                	jae    800a50 <devfile_read+0x48>
  800a3a:	68 6d 1e 80 00       	push   $0x801e6d
  800a3f:	68 74 1e 80 00       	push   $0x801e74
  800a44:	6a 7c                	push   $0x7c
  800a46:	68 62 1e 80 00       	push   $0x801e62
  800a4b:	e8 bd 05 00 00       	call   80100d <_panic>
	assert(r <= PGSIZE);
  800a50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a55:	7e 16                	jle    800a6d <devfile_read+0x65>
  800a57:	68 89 1e 80 00       	push   $0x801e89
  800a5c:	68 74 1e 80 00       	push   $0x801e74
  800a61:	6a 7d                	push   $0x7d
  800a63:	68 62 1e 80 00       	push   $0x801e62
  800a68:	e8 a0 05 00 00       	call   80100d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a6d:	83 ec 04             	sub    $0x4,%esp
  800a70:	50                   	push   %eax
  800a71:	68 00 50 80 00       	push   $0x805000
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	e8 7f 0d 00 00       	call   8017fd <memmove>
	return r;
  800a7e:	83 c4 10             	add    $0x10,%esp
}
  800a81:	89 d8                	mov    %ebx,%eax
  800a83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	53                   	push   %ebx
  800a8e:	83 ec 20             	sub    $0x20,%esp
  800a91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a94:	53                   	push   %ebx
  800a95:	e8 98 0b 00 00       	call   801632 <strlen>
  800a9a:	83 c4 10             	add    $0x10,%esp
  800a9d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa2:	7f 67                	jg     800b0b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aaa:	50                   	push   %eax
  800aab:	e8 c6 f8 ff ff       	call   800376 <fd_alloc>
  800ab0:	83 c4 10             	add    $0x10,%esp
		return r;
  800ab3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ab5:	85 c0                	test   %eax,%eax
  800ab7:	78 57                	js     800b10 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab9:	83 ec 08             	sub    $0x8,%esp
  800abc:	53                   	push   %ebx
  800abd:	68 00 50 80 00       	push   $0x805000
  800ac2:	e8 a4 0b 00 00       	call   80166b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad7:	e8 22 fe ff ff       	call   8008fe <fsipc>
  800adc:	89 c3                	mov    %eax,%ebx
  800ade:	83 c4 10             	add    $0x10,%esp
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	79 14                	jns    800af9 <open+0x6f>
		fd_close(fd, 0);
  800ae5:	83 ec 08             	sub    $0x8,%esp
  800ae8:	6a 00                	push   $0x0
  800aea:	ff 75 f4             	pushl  -0xc(%ebp)
  800aed:	e8 7c f9 ff ff       	call   80046e <fd_close>
		return r;
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	89 da                	mov    %ebx,%edx
  800af7:	eb 17                	jmp    800b10 <open+0x86>
	}

	return fd2num(fd);
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	ff 75 f4             	pushl  -0xc(%ebp)
  800aff:	e8 4b f8 ff ff       	call   80034f <fd2num>
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	eb 05                	jmp    800b10 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b0b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b10:	89 d0                	mov    %edx,%eax
  800b12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 08 00 00 00       	mov    $0x8,%eax
  800b27:	e8 d2 fd ff ff       	call   8008fe <fsipc>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	ff 75 08             	pushl  0x8(%ebp)
  800b3c:	e8 1e f8 ff ff       	call   80035f <fd2data>
  800b41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b43:	83 c4 08             	add    $0x8,%esp
  800b46:	68 95 1e 80 00       	push   $0x801e95
  800b4b:	53                   	push   %ebx
  800b4c:	e8 1a 0b 00 00       	call   80166b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b51:	8b 46 04             	mov    0x4(%esi),%eax
  800b54:	2b 06                	sub    (%esi),%eax
  800b56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b63:	00 00 00 
	stat->st_dev = &devpipe;
  800b66:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b6d:	30 80 00 
	return 0;
}
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b86:	53                   	push   %ebx
  800b87:	6a 00                	push   $0x0
  800b89:	e8 55 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8e:	89 1c 24             	mov    %ebx,(%esp)
  800b91:	e8 c9 f7 ff ff       	call   80035f <fd2data>
  800b96:	83 c4 08             	add    $0x8,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 00                	push   $0x0
  800b9c:	e8 42 f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 1c             	sub    $0x1c,%esp
  800baf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bb2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bb4:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc2:	e8 df 0e 00 00       	call   801aa6 <pageref>
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 3c 24             	mov    %edi,(%esp)
  800bcc:	e8 d5 0e 00 00       	call   801aa6 <pageref>
  800bd1:	83 c4 10             	add    $0x10,%esp
  800bd4:	39 c3                	cmp    %eax,%ebx
  800bd6:	0f 94 c1             	sete   %cl
  800bd9:	0f b6 c9             	movzbl %cl,%ecx
  800bdc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bdf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800be5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be8:	39 ce                	cmp    %ecx,%esi
  800bea:	74 1b                	je     800c07 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bec:	39 c3                	cmp    %eax,%ebx
  800bee:	75 c4                	jne    800bb4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf0:	8b 42 58             	mov    0x58(%edx),%eax
  800bf3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf6:	50                   	push   %eax
  800bf7:	56                   	push   %esi
  800bf8:	68 9c 1e 80 00       	push   $0x801e9c
  800bfd:	e8 e4 04 00 00       	call   8010e6 <cprintf>
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	eb ad                	jmp    800bb4 <_pipeisclosed+0xe>
	}
}
  800c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 28             	sub    $0x28,%esp
  800c1b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c1e:	56                   	push   %esi
  800c1f:	e8 3b f7 ff ff       	call   80035f <fd2data>
  800c24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2e:	eb 4b                	jmp    800c7b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c30:	89 da                	mov    %ebx,%edx
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	e8 6d ff ff ff       	call   800ba6 <_pipeisclosed>
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	75 48                	jne    800c85 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c3d:	e8 fd f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c42:	8b 43 04             	mov    0x4(%ebx),%eax
  800c45:	8b 0b                	mov    (%ebx),%ecx
  800c47:	8d 51 20             	lea    0x20(%ecx),%edx
  800c4a:	39 d0                	cmp    %edx,%eax
  800c4c:	73 e2                	jae    800c30 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c55:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c58:	89 c2                	mov    %eax,%edx
  800c5a:	c1 fa 1f             	sar    $0x1f,%edx
  800c5d:	89 d1                	mov    %edx,%ecx
  800c5f:	c1 e9 1b             	shr    $0x1b,%ecx
  800c62:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c65:	83 e2 1f             	and    $0x1f,%edx
  800c68:	29 ca                	sub    %ecx,%edx
  800c6a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c72:	83 c0 01             	add    $0x1,%eax
  800c75:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c78:	83 c7 01             	add    $0x1,%edi
  800c7b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c7e:	75 c2                	jne    800c42 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c80:	8b 45 10             	mov    0x10(%ebp),%eax
  800c83:	eb 05                	jmp    800c8a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 18             	sub    $0x18,%esp
  800c9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c9e:	57                   	push   %edi
  800c9f:	e8 bb f6 ff ff       	call   80035f <fd2data>
  800ca4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cae:	eb 3d                	jmp    800ced <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cb0:	85 db                	test   %ebx,%ebx
  800cb2:	74 04                	je     800cb8 <devpipe_read+0x26>
				return i;
  800cb4:	89 d8                	mov    %ebx,%eax
  800cb6:	eb 44                	jmp    800cfc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cb8:	89 f2                	mov    %esi,%edx
  800cba:	89 f8                	mov    %edi,%eax
  800cbc:	e8 e5 fe ff ff       	call   800ba6 <_pipeisclosed>
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	75 32                	jne    800cf7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cc5:	e8 75 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cca:	8b 06                	mov    (%esi),%eax
  800ccc:	3b 46 04             	cmp    0x4(%esi),%eax
  800ccf:	74 df                	je     800cb0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd1:	99                   	cltd   
  800cd2:	c1 ea 1b             	shr    $0x1b,%edx
  800cd5:	01 d0                	add    %edx,%eax
  800cd7:	83 e0 1f             	and    $0x1f,%eax
  800cda:	29 d0                	sub    %edx,%eax
  800cdc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800ce7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cea:	83 c3 01             	add    $0x1,%ebx
  800ced:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cf0:	75 d8                	jne    800cca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf5:	eb 05                	jmp    800cfc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0f:	50                   	push   %eax
  800d10:	e8 61 f6 ff ff       	call   800376 <fd_alloc>
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	89 c2                	mov    %eax,%edx
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	0f 88 2c 01 00 00    	js     800e4e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	68 07 04 00 00       	push   $0x407
  800d2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d2d:	6a 00                	push   $0x0
  800d2f:	e8 2a f4 ff ff       	call   80015e <sys_page_alloc>
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	89 c2                	mov    %eax,%edx
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	0f 88 0d 01 00 00    	js     800e4e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 29 f6 ff ff       	call   800376 <fd_alloc>
  800d4d:	89 c3                	mov    %eax,%ebx
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	85 c0                	test   %eax,%eax
  800d54:	0f 88 e2 00 00 00    	js     800e3c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 04 00 00       	push   $0x407
  800d62:	ff 75 f0             	pushl  -0x10(%ebp)
  800d65:	6a 00                	push   $0x0
  800d67:	e8 f2 f3 ff ff       	call   80015e <sys_page_alloc>
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 c3 00 00 00    	js     800e3c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7f:	e8 db f5 ff ff       	call   80035f <fd2data>
  800d84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 c4 0c             	add    $0xc,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	50                   	push   %eax
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 c8 f3 ff ff       	call   80015e <sys_page_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 89 00 00 00    	js     800e2c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	ff 75 f0             	pushl  -0x10(%ebp)
  800da9:	e8 b1 f5 ff ff       	call   80035f <fd2data>
  800dae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db5:	50                   	push   %eax
  800db6:	6a 00                	push   $0x0
  800db8:	56                   	push   %esi
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 e1 f3 ff ff       	call   8001a1 <sys_page_map>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 20             	add    $0x20,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	78 55                	js     800e1e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dde:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	e8 51 f5 ff ff       	call   80034f <fd2num>
  800dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e01:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e03:	83 c4 04             	add    $0x4,%esp
  800e06:	ff 75 f0             	pushl  -0x10(%ebp)
  800e09:	e8 41 f5 ff ff       	call   80034f <fd2num>
  800e0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e11:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1c:	eb 30                	jmp    800e4e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	56                   	push   %esi
  800e22:	6a 00                	push   $0x0
  800e24:	e8 ba f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e32:	6a 00                	push   $0x0
  800e34:	e8 aa f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e39:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e42:	6a 00                	push   $0x0
  800e44:	e8 9a f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e4e:	89 d0                	mov    %edx,%eax
  800e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e60:	50                   	push   %eax
  800e61:	ff 75 08             	pushl  0x8(%ebp)
  800e64:	e8 5c f5 ff ff       	call   8003c5 <fd_lookup>
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	78 18                	js     800e88 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	ff 75 f4             	pushl  -0xc(%ebp)
  800e76:	e8 e4 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e80:	e8 21 fd ff ff       	call   800ba6 <_pipeisclosed>
  800e85:	83 c4 10             	add    $0x10,%esp
}
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    

00800e8a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e9a:	68 b4 1e 80 00       	push   $0x801eb4
  800e9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ea2:	e8 c4 07 00 00       	call   80166b <strcpy>
	return 0;
}
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eba:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ebf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec5:	eb 2d                	jmp    800ef4 <devcons_write+0x46>
		m = n - tot;
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ecc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ecf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ed4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ed7:	83 ec 04             	sub    $0x4,%esp
  800eda:	53                   	push   %ebx
  800edb:	03 45 0c             	add    0xc(%ebp),%eax
  800ede:	50                   	push   %eax
  800edf:	57                   	push   %edi
  800ee0:	e8 18 09 00 00       	call   8017fd <memmove>
		sys_cputs(buf, m);
  800ee5:	83 c4 08             	add    $0x8,%esp
  800ee8:	53                   	push   %ebx
  800ee9:	57                   	push   %edi
  800eea:	e8 b3 f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eef:	01 de                	add    %ebx,%esi
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef9:	72 cc                	jb     800ec7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 08             	sub    $0x8,%esp
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f12:	74 2a                	je     800f3e <devcons_read+0x3b>
  800f14:	eb 05                	jmp    800f1b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f16:	e8 24 f2 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f1b:	e8 a0 f1 ff ff       	call   8000c0 <sys_cgetc>
  800f20:	85 c0                	test   %eax,%eax
  800f22:	74 f2                	je     800f16 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 16                	js     800f3e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f28:	83 f8 04             	cmp    $0x4,%eax
  800f2b:	74 0c                	je     800f39 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f30:	88 02                	mov    %al,(%edx)
	return 1;
  800f32:	b8 01 00 00 00       	mov    $0x1,%eax
  800f37:	eb 05                	jmp    800f3e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    

00800f40 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
  800f49:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f4c:	6a 01                	push   $0x1
  800f4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f51:	50                   	push   %eax
  800f52:	e8 4b f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <getchar>:

int
getchar(void)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f62:	6a 01                	push   $0x1
  800f64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 bc f6 ff ff       	call   80062b <read>
	if (r < 0)
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 0f                	js     800f85 <getchar+0x29>
		return r;
	if (r < 1)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	7e 06                	jle    800f80 <getchar+0x24>
		return -E_EOF;
	return c;
  800f7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f7e:	eb 05                	jmp    800f85 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f80:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f90:	50                   	push   %eax
  800f91:	ff 75 08             	pushl  0x8(%ebp)
  800f94:	e8 2c f4 ff ff       	call   8003c5 <fd_lookup>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 11                	js     800fb1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa9:	39 10                	cmp    %edx,(%eax)
  800fab:	0f 94 c0             	sete   %al
  800fae:	0f b6 c0             	movzbl %al,%eax
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <opencons>:

int
opencons(void)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	e8 b4 f3 ff ff       	call   800376 <fd_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
		return r;
  800fc5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 3e                	js     801009 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	68 07 04 00 00       	push   $0x407
  800fd3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 81 f1 ff ff       	call   80015e <sys_page_alloc>
  800fdd:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 23                	js     801009 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fe6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	50                   	push   %eax
  800fff:	e8 4b f3 ff ff       	call   80034f <fd2num>
  801004:	89 c2                	mov    %eax,%edx
  801006:	83 c4 10             	add    $0x10,%esp
}
  801009:	89 d0                	mov    %edx,%eax
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801012:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801015:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80101b:	e8 00 f1 ff ff       	call   800120 <sys_getenvid>
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	ff 75 0c             	pushl  0xc(%ebp)
  801026:	ff 75 08             	pushl  0x8(%ebp)
  801029:	56                   	push   %esi
  80102a:	50                   	push   %eax
  80102b:	68 c0 1e 80 00       	push   $0x801ec0
  801030:	e8 b1 00 00 00       	call   8010e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801035:	83 c4 18             	add    $0x18,%esp
  801038:	53                   	push   %ebx
  801039:	ff 75 10             	pushl  0x10(%ebp)
  80103c:	e8 54 00 00 00       	call   801095 <vcprintf>
	cprintf("\n");
  801041:	c7 04 24 ad 1e 80 00 	movl   $0x801ead,(%esp)
  801048:	e8 99 00 00 00       	call   8010e6 <cprintf>
  80104d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801050:	cc                   	int3   
  801051:	eb fd                	jmp    801050 <_panic+0x43>

00801053 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 04             	sub    $0x4,%esp
  80105a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80105d:	8b 13                	mov    (%ebx),%edx
  80105f:	8d 42 01             	lea    0x1(%edx),%eax
  801062:	89 03                	mov    %eax,(%ebx)
  801064:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801067:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80106b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801070:	75 1a                	jne    80108c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801072:	83 ec 08             	sub    $0x8,%esp
  801075:	68 ff 00 00 00       	push   $0xff
  80107a:	8d 43 08             	lea    0x8(%ebx),%eax
  80107d:	50                   	push   %eax
  80107e:	e8 1f f0 ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  801083:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801089:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80108c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801090:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80109e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a5:	00 00 00 
	b.cnt = 0;
  8010a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b2:	ff 75 0c             	pushl  0xc(%ebp)
  8010b5:	ff 75 08             	pushl  0x8(%ebp)
  8010b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	68 53 10 80 00       	push   $0x801053
  8010c4:	e8 54 01 00 00       	call   80121d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	e8 c4 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8010de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010ef:	50                   	push   %eax
  8010f0:	ff 75 08             	pushl  0x8(%ebp)
  8010f3:	e8 9d ff ff ff       	call   801095 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f8:	c9                   	leave  
  8010f9:	c3                   	ret    

008010fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	57                   	push   %edi
  8010fe:	56                   	push   %esi
  8010ff:	53                   	push   %ebx
  801100:	83 ec 1c             	sub    $0x1c,%esp
  801103:	89 c7                	mov    %eax,%edi
  801105:	89 d6                	mov    %edx,%esi
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801110:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801113:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80111e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801121:	39 d3                	cmp    %edx,%ebx
  801123:	72 05                	jb     80112a <printnum+0x30>
  801125:	39 45 10             	cmp    %eax,0x10(%ebp)
  801128:	77 45                	ja     80116f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	ff 75 18             	pushl  0x18(%ebp)
  801130:	8b 45 14             	mov    0x14(%ebp),%eax
  801133:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801136:	53                   	push   %ebx
  801137:	ff 75 10             	pushl  0x10(%ebp)
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801140:	ff 75 e0             	pushl  -0x20(%ebp)
  801143:	ff 75 dc             	pushl  -0x24(%ebp)
  801146:	ff 75 d8             	pushl  -0x28(%ebp)
  801149:	e8 a2 09 00 00       	call   801af0 <__udivdi3>
  80114e:	83 c4 18             	add    $0x18,%esp
  801151:	52                   	push   %edx
  801152:	50                   	push   %eax
  801153:	89 f2                	mov    %esi,%edx
  801155:	89 f8                	mov    %edi,%eax
  801157:	e8 9e ff ff ff       	call   8010fa <printnum>
  80115c:	83 c4 20             	add    $0x20,%esp
  80115f:	eb 18                	jmp    801179 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	56                   	push   %esi
  801165:	ff 75 18             	pushl  0x18(%ebp)
  801168:	ff d7                	call   *%edi
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	eb 03                	jmp    801172 <printnum+0x78>
  80116f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801172:	83 eb 01             	sub    $0x1,%ebx
  801175:	85 db                	test   %ebx,%ebx
  801177:	7f e8                	jg     801161 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801179:	83 ec 08             	sub    $0x8,%esp
  80117c:	56                   	push   %esi
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	ff 75 e4             	pushl  -0x1c(%ebp)
  801183:	ff 75 e0             	pushl  -0x20(%ebp)
  801186:	ff 75 dc             	pushl  -0x24(%ebp)
  801189:	ff 75 d8             	pushl  -0x28(%ebp)
  80118c:	e8 8f 0a 00 00       	call   801c20 <__umoddi3>
  801191:	83 c4 14             	add    $0x14,%esp
  801194:	0f be 80 e3 1e 80 00 	movsbl 0x801ee3(%eax),%eax
  80119b:	50                   	push   %eax
  80119c:	ff d7                	call   *%edi
}
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ac:	83 fa 01             	cmp    $0x1,%edx
  8011af:	7e 0e                	jle    8011bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011b1:	8b 10                	mov    (%eax),%edx
  8011b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b6:	89 08                	mov    %ecx,(%eax)
  8011b8:	8b 02                	mov    (%edx),%eax
  8011ba:	8b 52 04             	mov    0x4(%edx),%edx
  8011bd:	eb 22                	jmp    8011e1 <getuint+0x38>
	else if (lflag)
  8011bf:	85 d2                	test   %edx,%edx
  8011c1:	74 10                	je     8011d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011c3:	8b 10                	mov    (%eax),%edx
  8011c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c8:	89 08                	mov    %ecx,(%eax)
  8011ca:	8b 02                	mov    (%edx),%eax
  8011cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d1:	eb 0e                	jmp    8011e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011d3:	8b 10                	mov    (%eax),%edx
  8011d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d8:	89 08                	mov    %ecx,(%eax)
  8011da:	8b 02                	mov    (%edx),%eax
  8011dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ed:	8b 10                	mov    (%eax),%edx
  8011ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f2:	73 0a                	jae    8011fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f7:	89 08                	mov    %ecx,(%eax)
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	88 02                	mov    %al,(%edx)
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801206:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801209:	50                   	push   %eax
  80120a:	ff 75 10             	pushl  0x10(%ebp)
  80120d:	ff 75 0c             	pushl  0xc(%ebp)
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 05 00 00 00       	call   80121d <vprintfmt>
	va_end(ap);
}
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	57                   	push   %edi
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 2c             	sub    $0x2c,%esp
  801226:	8b 75 08             	mov    0x8(%ebp),%esi
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80122c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122f:	eb 12                	jmp    801243 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801231:	85 c0                	test   %eax,%eax
  801233:	0f 84 89 03 00 00    	je     8015c2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	53                   	push   %ebx
  80123d:	50                   	push   %eax
  80123e:	ff d6                	call   *%esi
  801240:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801243:	83 c7 01             	add    $0x1,%edi
  801246:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80124a:	83 f8 25             	cmp    $0x25,%eax
  80124d:	75 e2                	jne    801231 <vprintfmt+0x14>
  80124f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801253:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80125a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801261:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801268:	ba 00 00 00 00       	mov    $0x0,%edx
  80126d:	eb 07                	jmp    801276 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801272:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801276:	8d 47 01             	lea    0x1(%edi),%eax
  801279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127c:	0f b6 07             	movzbl (%edi),%eax
  80127f:	0f b6 c8             	movzbl %al,%ecx
  801282:	83 e8 23             	sub    $0x23,%eax
  801285:	3c 55                	cmp    $0x55,%al
  801287:	0f 87 1a 03 00 00    	ja     8015a7 <vprintfmt+0x38a>
  80128d:	0f b6 c0             	movzbl %al,%eax
  801290:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80129a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80129e:	eb d6                	jmp    801276 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ae:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012b2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012b5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012b8:	83 fa 09             	cmp    $0x9,%edx
  8012bb:	77 39                	ja     8012f6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012c0:	eb e9                	jmp    8012ab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8012c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012cb:	8b 00                	mov    (%eax),%eax
  8012cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d3:	eb 27                	jmp    8012fc <vprintfmt+0xdf>
  8012d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012df:	0f 49 c8             	cmovns %eax,%ecx
  8012e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e8:	eb 8c                	jmp    801276 <vprintfmt+0x59>
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f4:	eb 80                	jmp    801276 <vprintfmt+0x59>
  8012f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801300:	0f 89 70 ff ff ff    	jns    801276 <vprintfmt+0x59>
				width = precision, precision = -1;
  801306:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801309:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80130c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801313:	e9 5e ff ff ff       	jmp    801276 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801318:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80131e:	e9 53 ff ff ff       	jmp    801276 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	8d 50 04             	lea    0x4(%eax),%edx
  801329:	89 55 14             	mov    %edx,0x14(%ebp)
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	53                   	push   %ebx
  801330:	ff 30                	pushl  (%eax)
  801332:	ff d6                	call   *%esi
			break;
  801334:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80133a:	e9 04 ff ff ff       	jmp    801243 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133f:	8b 45 14             	mov    0x14(%ebp),%eax
  801342:	8d 50 04             	lea    0x4(%eax),%edx
  801345:	89 55 14             	mov    %edx,0x14(%ebp)
  801348:	8b 00                	mov    (%eax),%eax
  80134a:	99                   	cltd   
  80134b:	31 d0                	xor    %edx,%eax
  80134d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134f:	83 f8 0f             	cmp    $0xf,%eax
  801352:	7f 0b                	jg     80135f <vprintfmt+0x142>
  801354:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	75 18                	jne    801377 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80135f:	50                   	push   %eax
  801360:	68 fb 1e 80 00       	push   $0x801efb
  801365:	53                   	push   %ebx
  801366:	56                   	push   %esi
  801367:	e8 94 fe ff ff       	call   801200 <printfmt>
  80136c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801372:	e9 cc fe ff ff       	jmp    801243 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801377:	52                   	push   %edx
  801378:	68 86 1e 80 00       	push   $0x801e86
  80137d:	53                   	push   %ebx
  80137e:	56                   	push   %esi
  80137f:	e8 7c fe ff ff       	call   801200 <printfmt>
  801384:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80138a:	e9 b4 fe ff ff       	jmp    801243 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138f:	8b 45 14             	mov    0x14(%ebp),%eax
  801392:	8d 50 04             	lea    0x4(%eax),%edx
  801395:	89 55 14             	mov    %edx,0x14(%ebp)
  801398:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80139a:	85 ff                	test   %edi,%edi
  80139c:	b8 f4 1e 80 00       	mov    $0x801ef4,%eax
  8013a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a8:	0f 8e 94 00 00 00    	jle    801442 <vprintfmt+0x225>
  8013ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b2:	0f 84 98 00 00 00    	je     801450 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8013be:	57                   	push   %edi
  8013bf:	e8 86 02 00 00       	call   80164a <strnlen>
  8013c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c7:	29 c1                	sub    %eax,%ecx
  8013c9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	eb 0f                	jmp    8013ec <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e6:	83 ef 01             	sub    $0x1,%edi
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 ff                	test   %edi,%edi
  8013ee:	7f ed                	jg     8013dd <vprintfmt+0x1c0>
  8013f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8013f6:	85 c9                	test   %ecx,%ecx
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	0f 49 c1             	cmovns %ecx,%eax
  801400:	29 c1                	sub    %eax,%ecx
  801402:	89 75 08             	mov    %esi,0x8(%ebp)
  801405:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801408:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80140b:	89 cb                	mov    %ecx,%ebx
  80140d:	eb 4d                	jmp    80145c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801413:	74 1b                	je     801430 <vprintfmt+0x213>
  801415:	0f be c0             	movsbl %al,%eax
  801418:	83 e8 20             	sub    $0x20,%eax
  80141b:	83 f8 5e             	cmp    $0x5e,%eax
  80141e:	76 10                	jbe    801430 <vprintfmt+0x213>
					putch('?', putdat);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 0c             	pushl  0xc(%ebp)
  801426:	6a 3f                	push   $0x3f
  801428:	ff 55 08             	call   *0x8(%ebp)
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	eb 0d                	jmp    80143d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 0c             	pushl  0xc(%ebp)
  801436:	52                   	push   %edx
  801437:	ff 55 08             	call   *0x8(%ebp)
  80143a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143d:	83 eb 01             	sub    $0x1,%ebx
  801440:	eb 1a                	jmp    80145c <vprintfmt+0x23f>
  801442:	89 75 08             	mov    %esi,0x8(%ebp)
  801445:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801448:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144e:	eb 0c                	jmp    80145c <vprintfmt+0x23f>
  801450:	89 75 08             	mov    %esi,0x8(%ebp)
  801453:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801456:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801459:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145c:	83 c7 01             	add    $0x1,%edi
  80145f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801463:	0f be d0             	movsbl %al,%edx
  801466:	85 d2                	test   %edx,%edx
  801468:	74 23                	je     80148d <vprintfmt+0x270>
  80146a:	85 f6                	test   %esi,%esi
  80146c:	78 a1                	js     80140f <vprintfmt+0x1f2>
  80146e:	83 ee 01             	sub    $0x1,%esi
  801471:	79 9c                	jns    80140f <vprintfmt+0x1f2>
  801473:	89 df                	mov    %ebx,%edi
  801475:	8b 75 08             	mov    0x8(%ebp),%esi
  801478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147b:	eb 18                	jmp    801495 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	53                   	push   %ebx
  801481:	6a 20                	push   $0x20
  801483:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801485:	83 ef 01             	sub    $0x1,%edi
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 08                	jmp    801495 <vprintfmt+0x278>
  80148d:	89 df                	mov    %ebx,%edi
  80148f:	8b 75 08             	mov    0x8(%ebp),%esi
  801492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801495:	85 ff                	test   %edi,%edi
  801497:	7f e4                	jg     80147d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80149c:	e9 a2 fd ff ff       	jmp    801243 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a1:	83 fa 01             	cmp    $0x1,%edx
  8014a4:	7e 16                	jle    8014bc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a9:	8d 50 08             	lea    0x8(%eax),%edx
  8014ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8014af:	8b 50 04             	mov    0x4(%eax),%edx
  8014b2:	8b 00                	mov    (%eax),%eax
  8014b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ba:	eb 32                	jmp    8014ee <vprintfmt+0x2d1>
	else if (lflag)
  8014bc:	85 d2                	test   %edx,%edx
  8014be:	74 18                	je     8014d8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c3:	8d 50 04             	lea    0x4(%eax),%edx
  8014c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c9:	8b 00                	mov    (%eax),%eax
  8014cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ce:	89 c1                	mov    %eax,%ecx
  8014d0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d6:	eb 16                	jmp    8014ee <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014db:	8d 50 04             	lea    0x4(%eax),%edx
  8014de:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e1:	8b 00                	mov    (%eax),%eax
  8014e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e6:	89 c1                	mov    %eax,%ecx
  8014e8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014fd:	79 74                	jns    801573 <vprintfmt+0x356>
				putch('-', putdat);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	53                   	push   %ebx
  801503:	6a 2d                	push   $0x2d
  801505:	ff d6                	call   *%esi
				num = -(long long) num;
  801507:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80150a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80150d:	f7 d8                	neg    %eax
  80150f:	83 d2 00             	adc    $0x0,%edx
  801512:	f7 da                	neg    %edx
  801514:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801517:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80151c:	eb 55                	jmp    801573 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80151e:	8d 45 14             	lea    0x14(%ebp),%eax
  801521:	e8 83 fc ff ff       	call   8011a9 <getuint>
			base = 10;
  801526:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80152b:	eb 46                	jmp    801573 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80152d:	8d 45 14             	lea    0x14(%ebp),%eax
  801530:	e8 74 fc ff ff       	call   8011a9 <getuint>
			base = 8;
  801535:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80153a:	eb 37                	jmp    801573 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	53                   	push   %ebx
  801540:	6a 30                	push   $0x30
  801542:	ff d6                	call   *%esi
			putch('x', putdat);
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	53                   	push   %ebx
  801548:	6a 78                	push   $0x78
  80154a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8d 50 04             	lea    0x4(%eax),%edx
  801552:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801555:	8b 00                	mov    (%eax),%eax
  801557:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80155c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80155f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801564:	eb 0d                	jmp    801573 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801566:	8d 45 14             	lea    0x14(%ebp),%eax
  801569:	e8 3b fc ff ff       	call   8011a9 <getuint>
			base = 16;
  80156e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80157a:	57                   	push   %edi
  80157b:	ff 75 e0             	pushl  -0x20(%ebp)
  80157e:	51                   	push   %ecx
  80157f:	52                   	push   %edx
  801580:	50                   	push   %eax
  801581:	89 da                	mov    %ebx,%edx
  801583:	89 f0                	mov    %esi,%eax
  801585:	e8 70 fb ff ff       	call   8010fa <printnum>
			break;
  80158a:	83 c4 20             	add    $0x20,%esp
  80158d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801590:	e9 ae fc ff ff       	jmp    801243 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	51                   	push   %ecx
  80159a:	ff d6                	call   *%esi
			break;
  80159c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015a2:	e9 9c fc ff ff       	jmp    801243 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	6a 25                	push   $0x25
  8015ad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 03                	jmp    8015b7 <vprintfmt+0x39a>
  8015b4:	83 ef 01             	sub    $0x1,%edi
  8015b7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015bb:	75 f7                	jne    8015b4 <vprintfmt+0x397>
  8015bd:	e9 81 fc ff ff       	jmp    801243 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5f                   	pop    %edi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 18             	sub    $0x18,%esp
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	74 26                	je     801611 <vsnprintf+0x47>
  8015eb:	85 d2                	test   %edx,%edx
  8015ed:	7e 22                	jle    801611 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015ef:	ff 75 14             	pushl  0x14(%ebp)
  8015f2:	ff 75 10             	pushl  0x10(%ebp)
  8015f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	68 e3 11 80 00       	push   $0x8011e3
  8015fe:	e8 1a fc ff ff       	call   80121d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801603:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801606:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801609:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb 05                	jmp    801616 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801611:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80161e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801621:	50                   	push   %eax
  801622:	ff 75 10             	pushl  0x10(%ebp)
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 9a ff ff ff       	call   8015ca <vsnprintf>
	va_end(ap);

	return rc;
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801638:	b8 00 00 00 00       	mov    $0x0,%eax
  80163d:	eb 03                	jmp    801642 <strlen+0x10>
		n++;
  80163f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801642:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801646:	75 f7                	jne    80163f <strlen+0xd>
		n++;
	return n;
}
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801650:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801653:	ba 00 00 00 00       	mov    $0x0,%edx
  801658:	eb 03                	jmp    80165d <strnlen+0x13>
		n++;
  80165a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80165d:	39 c2                	cmp    %eax,%edx
  80165f:	74 08                	je     801669 <strnlen+0x1f>
  801661:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801665:	75 f3                	jne    80165a <strnlen+0x10>
  801667:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801675:	89 c2                	mov    %eax,%edx
  801677:	83 c2 01             	add    $0x1,%edx
  80167a:	83 c1 01             	add    $0x1,%ecx
  80167d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801681:	88 5a ff             	mov    %bl,-0x1(%edx)
  801684:	84 db                	test   %bl,%bl
  801686:	75 ef                	jne    801677 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801688:	5b                   	pop    %ebx
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801692:	53                   	push   %ebx
  801693:	e8 9a ff ff ff       	call   801632 <strlen>
  801698:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80169b:	ff 75 0c             	pushl  0xc(%ebp)
  80169e:	01 d8                	add    %ebx,%eax
  8016a0:	50                   	push   %eax
  8016a1:	e8 c5 ff ff ff       	call   80166b <strcpy>
	return dst;
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8016b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b8:	89 f3                	mov    %esi,%ebx
  8016ba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016bd:	89 f2                	mov    %esi,%edx
  8016bf:	eb 0f                	jmp    8016d0 <strncpy+0x23>
		*dst++ = *src;
  8016c1:	83 c2 01             	add    $0x1,%edx
  8016c4:	0f b6 01             	movzbl (%ecx),%eax
  8016c7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ca:	80 39 01             	cmpb   $0x1,(%ecx)
  8016cd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d0:	39 da                	cmp    %ebx,%edx
  8016d2:	75 ed                	jne    8016c1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016d4:	89 f0                	mov    %esi,%eax
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
  8016df:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8016e8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 21                	je     80170f <strlcpy+0x35>
  8016ee:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016f2:	89 f2                	mov    %esi,%edx
  8016f4:	eb 09                	jmp    8016ff <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016f6:	83 c2 01             	add    $0x1,%edx
  8016f9:	83 c1 01             	add    $0x1,%ecx
  8016fc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016ff:	39 c2                	cmp    %eax,%edx
  801701:	74 09                	je     80170c <strlcpy+0x32>
  801703:	0f b6 19             	movzbl (%ecx),%ebx
  801706:	84 db                	test   %bl,%bl
  801708:	75 ec                	jne    8016f6 <strlcpy+0x1c>
  80170a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80170c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80170f:	29 f0                	sub    %esi,%eax
}
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80171e:	eb 06                	jmp    801726 <strcmp+0x11>
		p++, q++;
  801720:	83 c1 01             	add    $0x1,%ecx
  801723:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801726:	0f b6 01             	movzbl (%ecx),%eax
  801729:	84 c0                	test   %al,%al
  80172b:	74 04                	je     801731 <strcmp+0x1c>
  80172d:	3a 02                	cmp    (%edx),%al
  80172f:	74 ef                	je     801720 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801731:	0f b6 c0             	movzbl %al,%eax
  801734:	0f b6 12             	movzbl (%edx),%edx
  801737:	29 d0                	sub    %edx,%eax
}
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 55 0c             	mov    0xc(%ebp),%edx
  801745:	89 c3                	mov    %eax,%ebx
  801747:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80174a:	eb 06                	jmp    801752 <strncmp+0x17>
		n--, p++, q++;
  80174c:	83 c0 01             	add    $0x1,%eax
  80174f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801752:	39 d8                	cmp    %ebx,%eax
  801754:	74 15                	je     80176b <strncmp+0x30>
  801756:	0f b6 08             	movzbl (%eax),%ecx
  801759:	84 c9                	test   %cl,%cl
  80175b:	74 04                	je     801761 <strncmp+0x26>
  80175d:	3a 0a                	cmp    (%edx),%cl
  80175f:	74 eb                	je     80174c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801761:	0f b6 00             	movzbl (%eax),%eax
  801764:	0f b6 12             	movzbl (%edx),%edx
  801767:	29 d0                	sub    %edx,%eax
  801769:	eb 05                	jmp    801770 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80176b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801770:	5b                   	pop    %ebx
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80177d:	eb 07                	jmp    801786 <strchr+0x13>
		if (*s == c)
  80177f:	38 ca                	cmp    %cl,%dl
  801781:	74 0f                	je     801792 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801783:	83 c0 01             	add    $0x1,%eax
  801786:	0f b6 10             	movzbl (%eax),%edx
  801789:	84 d2                	test   %dl,%dl
  80178b:	75 f2                	jne    80177f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80179e:	eb 03                	jmp    8017a3 <strfind+0xf>
  8017a0:	83 c0 01             	add    $0x1,%eax
  8017a3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017a6:	38 ca                	cmp    %cl,%dl
  8017a8:	74 04                	je     8017ae <strfind+0x1a>
  8017aa:	84 d2                	test   %dl,%dl
  8017ac:	75 f2                	jne    8017a0 <strfind+0xc>
			break;
	return (char *) s;
}
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	57                   	push   %edi
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017bc:	85 c9                	test   %ecx,%ecx
  8017be:	74 36                	je     8017f6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017c6:	75 28                	jne    8017f0 <memset+0x40>
  8017c8:	f6 c1 03             	test   $0x3,%cl
  8017cb:	75 23                	jne    8017f0 <memset+0x40>
		c &= 0xFF;
  8017cd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017d1:	89 d3                	mov    %edx,%ebx
  8017d3:	c1 e3 08             	shl    $0x8,%ebx
  8017d6:	89 d6                	mov    %edx,%esi
  8017d8:	c1 e6 18             	shl    $0x18,%esi
  8017db:	89 d0                	mov    %edx,%eax
  8017dd:	c1 e0 10             	shl    $0x10,%eax
  8017e0:	09 f0                	or     %esi,%eax
  8017e2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	09 d0                	or     %edx,%eax
  8017e8:	c1 e9 02             	shr    $0x2,%ecx
  8017eb:	fc                   	cld    
  8017ec:	f3 ab                	rep stos %eax,%es:(%edi)
  8017ee:	eb 06                	jmp    8017f6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f3:	fc                   	cld    
  8017f4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017f6:	89 f8                	mov    %edi,%eax
  8017f8:	5b                   	pop    %ebx
  8017f9:	5e                   	pop    %esi
  8017fa:	5f                   	pop    %edi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 75 0c             	mov    0xc(%ebp),%esi
  801808:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80180b:	39 c6                	cmp    %eax,%esi
  80180d:	73 35                	jae    801844 <memmove+0x47>
  80180f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801812:	39 d0                	cmp    %edx,%eax
  801814:	73 2e                	jae    801844 <memmove+0x47>
		s += n;
		d += n;
  801816:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801819:	89 d6                	mov    %edx,%esi
  80181b:	09 fe                	or     %edi,%esi
  80181d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801823:	75 13                	jne    801838 <memmove+0x3b>
  801825:	f6 c1 03             	test   $0x3,%cl
  801828:	75 0e                	jne    801838 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80182a:	83 ef 04             	sub    $0x4,%edi
  80182d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801830:	c1 e9 02             	shr    $0x2,%ecx
  801833:	fd                   	std    
  801834:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801836:	eb 09                	jmp    801841 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801838:	83 ef 01             	sub    $0x1,%edi
  80183b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80183e:	fd                   	std    
  80183f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801841:	fc                   	cld    
  801842:	eb 1d                	jmp    801861 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801844:	89 f2                	mov    %esi,%edx
  801846:	09 c2                	or     %eax,%edx
  801848:	f6 c2 03             	test   $0x3,%dl
  80184b:	75 0f                	jne    80185c <memmove+0x5f>
  80184d:	f6 c1 03             	test   $0x3,%cl
  801850:	75 0a                	jne    80185c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801852:	c1 e9 02             	shr    $0x2,%ecx
  801855:	89 c7                	mov    %eax,%edi
  801857:	fc                   	cld    
  801858:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185a:	eb 05                	jmp    801861 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80185c:	89 c7                	mov    %eax,%edi
  80185e:	fc                   	cld    
  80185f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801861:	5e                   	pop    %esi
  801862:	5f                   	pop    %edi
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801868:	ff 75 10             	pushl  0x10(%ebp)
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	ff 75 08             	pushl  0x8(%ebp)
  801871:	e8 87 ff ff ff       	call   8017fd <memmove>
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	8b 55 0c             	mov    0xc(%ebp),%edx
  801883:	89 c6                	mov    %eax,%esi
  801885:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801888:	eb 1a                	jmp    8018a4 <memcmp+0x2c>
		if (*s1 != *s2)
  80188a:	0f b6 08             	movzbl (%eax),%ecx
  80188d:	0f b6 1a             	movzbl (%edx),%ebx
  801890:	38 d9                	cmp    %bl,%cl
  801892:	74 0a                	je     80189e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801894:	0f b6 c1             	movzbl %cl,%eax
  801897:	0f b6 db             	movzbl %bl,%ebx
  80189a:	29 d8                	sub    %ebx,%eax
  80189c:	eb 0f                	jmp    8018ad <memcmp+0x35>
		s1++, s2++;
  80189e:	83 c0 01             	add    $0x1,%eax
  8018a1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a4:	39 f0                	cmp    %esi,%eax
  8018a6:	75 e2                	jne    80188a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	53                   	push   %ebx
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018b8:	89 c1                	mov    %eax,%ecx
  8018ba:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018bd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018c1:	eb 0a                	jmp    8018cd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018c3:	0f b6 10             	movzbl (%eax),%edx
  8018c6:	39 da                	cmp    %ebx,%edx
  8018c8:	74 07                	je     8018d1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018ca:	83 c0 01             	add    $0x1,%eax
  8018cd:	39 c8                	cmp    %ecx,%eax
  8018cf:	72 f2                	jb     8018c3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018d1:	5b                   	pop    %ebx
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018e0:	eb 03                	jmp    8018e5 <strtol+0x11>
		s++;
  8018e2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018e5:	0f b6 01             	movzbl (%ecx),%eax
  8018e8:	3c 20                	cmp    $0x20,%al
  8018ea:	74 f6                	je     8018e2 <strtol+0xe>
  8018ec:	3c 09                	cmp    $0x9,%al
  8018ee:	74 f2                	je     8018e2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018f0:	3c 2b                	cmp    $0x2b,%al
  8018f2:	75 0a                	jne    8018fe <strtol+0x2a>
		s++;
  8018f4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8018fc:	eb 11                	jmp    80190f <strtol+0x3b>
  8018fe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801903:	3c 2d                	cmp    $0x2d,%al
  801905:	75 08                	jne    80190f <strtol+0x3b>
		s++, neg = 1;
  801907:	83 c1 01             	add    $0x1,%ecx
  80190a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80190f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801915:	75 15                	jne    80192c <strtol+0x58>
  801917:	80 39 30             	cmpb   $0x30,(%ecx)
  80191a:	75 10                	jne    80192c <strtol+0x58>
  80191c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801920:	75 7c                	jne    80199e <strtol+0xca>
		s += 2, base = 16;
  801922:	83 c1 02             	add    $0x2,%ecx
  801925:	bb 10 00 00 00       	mov    $0x10,%ebx
  80192a:	eb 16                	jmp    801942 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80192c:	85 db                	test   %ebx,%ebx
  80192e:	75 12                	jne    801942 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801930:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801935:	80 39 30             	cmpb   $0x30,(%ecx)
  801938:	75 08                	jne    801942 <strtol+0x6e>
		s++, base = 8;
  80193a:	83 c1 01             	add    $0x1,%ecx
  80193d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801942:	b8 00 00 00 00       	mov    $0x0,%eax
  801947:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80194a:	0f b6 11             	movzbl (%ecx),%edx
  80194d:	8d 72 d0             	lea    -0x30(%edx),%esi
  801950:	89 f3                	mov    %esi,%ebx
  801952:	80 fb 09             	cmp    $0x9,%bl
  801955:	77 08                	ja     80195f <strtol+0x8b>
			dig = *s - '0';
  801957:	0f be d2             	movsbl %dl,%edx
  80195a:	83 ea 30             	sub    $0x30,%edx
  80195d:	eb 22                	jmp    801981 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80195f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801962:	89 f3                	mov    %esi,%ebx
  801964:	80 fb 19             	cmp    $0x19,%bl
  801967:	77 08                	ja     801971 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801969:	0f be d2             	movsbl %dl,%edx
  80196c:	83 ea 57             	sub    $0x57,%edx
  80196f:	eb 10                	jmp    801981 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801971:	8d 72 bf             	lea    -0x41(%edx),%esi
  801974:	89 f3                	mov    %esi,%ebx
  801976:	80 fb 19             	cmp    $0x19,%bl
  801979:	77 16                	ja     801991 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80197b:	0f be d2             	movsbl %dl,%edx
  80197e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801981:	3b 55 10             	cmp    0x10(%ebp),%edx
  801984:	7d 0b                	jge    801991 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801986:	83 c1 01             	add    $0x1,%ecx
  801989:	0f af 45 10          	imul   0x10(%ebp),%eax
  80198d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80198f:	eb b9                	jmp    80194a <strtol+0x76>

	if (endptr)
  801991:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801995:	74 0d                	je     8019a4 <strtol+0xd0>
		*endptr = (char *) s;
  801997:	8b 75 0c             	mov    0xc(%ebp),%esi
  80199a:	89 0e                	mov    %ecx,(%esi)
  80199c:	eb 06                	jmp    8019a4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80199e:	85 db                	test   %ebx,%ebx
  8019a0:	74 98                	je     80193a <strtol+0x66>
  8019a2:	eb 9e                	jmp    801942 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	f7 da                	neg    %edx
  8019a8:	85 ff                	test   %edi,%edi
  8019aa:	0f 45 c2             	cmovne %edx,%eax
}
  8019ad:	5b                   	pop    %ebx
  8019ae:	5e                   	pop    %esi
  8019af:	5f                   	pop    %edi
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    

008019b2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	56                   	push   %esi
  8019b6:	53                   	push   %ebx
  8019b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019c0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019c2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019c7:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019ca:	83 ec 0c             	sub    $0xc,%esp
  8019cd:	50                   	push   %eax
  8019ce:	e8 3b e9 ff ff       	call   80030e <sys_ipc_recv>

	if (from_env_store != NULL)
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	85 f6                	test   %esi,%esi
  8019d8:	74 14                	je     8019ee <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	78 09                	js     8019ec <ipc_recv+0x3a>
  8019e3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e9:	8b 52 74             	mov    0x74(%edx),%edx
  8019ec:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019ee:	85 db                	test   %ebx,%ebx
  8019f0:	74 14                	je     801a06 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 09                	js     801a04 <ipc_recv+0x52>
  8019fb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a01:	8b 52 78             	mov    0x78(%edx),%edx
  801a04:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 08                	js     801a12 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	57                   	push   %edi
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a2b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a2d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a32:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a35:	ff 75 14             	pushl  0x14(%ebp)
  801a38:	53                   	push   %ebx
  801a39:	56                   	push   %esi
  801a3a:	57                   	push   %edi
  801a3b:	e8 ab e8 ff ff       	call   8002eb <sys_ipc_try_send>

		if (err < 0) {
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	79 1e                	jns    801a65 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a47:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a4a:	75 07                	jne    801a53 <ipc_send+0x3a>
				sys_yield();
  801a4c:	e8 ee e6 ff ff       	call   80013f <sys_yield>
  801a51:	eb e2                	jmp    801a35 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a53:	50                   	push   %eax
  801a54:	68 e0 21 80 00       	push   $0x8021e0
  801a59:	6a 49                	push   $0x49
  801a5b:	68 ed 21 80 00       	push   $0x8021ed
  801a60:	e8 a8 f5 ff ff       	call   80100d <_panic>
		}

	} while (err < 0);

}
  801a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a73:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a78:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a7b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a81:	8b 52 50             	mov    0x50(%edx),%edx
  801a84:	39 ca                	cmp    %ecx,%edx
  801a86:	75 0d                	jne    801a95 <ipc_find_env+0x28>
			return envs[i].env_id;
  801a88:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a8b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a90:	8b 40 48             	mov    0x48(%eax),%eax
  801a93:	eb 0f                	jmp    801aa4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a95:	83 c0 01             	add    $0x1,%eax
  801a98:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a9d:	75 d9                	jne    801a78 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aac:	89 d0                	mov    %edx,%eax
  801aae:	c1 e8 16             	shr    $0x16,%eax
  801ab1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801abd:	f6 c1 01             	test   $0x1,%cl
  801ac0:	74 1d                	je     801adf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ac2:	c1 ea 0c             	shr    $0xc,%edx
  801ac5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801acc:	f6 c2 01             	test   $0x1,%dl
  801acf:	74 0e                	je     801adf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ad1:	c1 ea 0c             	shr    $0xc,%edx
  801ad4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801adb:	ef 
  801adc:	0f b7 c0             	movzwl %ax,%eax
}
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    
  801ae1:	66 90                	xchg   %ax,%ax
  801ae3:	66 90                	xchg   %ax,%ax
  801ae5:	66 90                	xchg   %ax,%ax
  801ae7:	66 90                	xchg   %ax,%ax
  801ae9:	66 90                	xchg   %ax,%ax
  801aeb:	66 90                	xchg   %ax,%ax
  801aed:	66 90                	xchg   %ax,%ax
  801aef:	90                   	nop

00801af0 <__udivdi3>:
  801af0:	55                   	push   %ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
  801af7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801afb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801aff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b07:	85 f6                	test   %esi,%esi
  801b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0d:	89 ca                	mov    %ecx,%edx
  801b0f:	89 f8                	mov    %edi,%eax
  801b11:	75 3d                	jne    801b50 <__udivdi3+0x60>
  801b13:	39 cf                	cmp    %ecx,%edi
  801b15:	0f 87 c5 00 00 00    	ja     801be0 <__udivdi3+0xf0>
  801b1b:	85 ff                	test   %edi,%edi
  801b1d:	89 fd                	mov    %edi,%ebp
  801b1f:	75 0b                	jne    801b2c <__udivdi3+0x3c>
  801b21:	b8 01 00 00 00       	mov    $0x1,%eax
  801b26:	31 d2                	xor    %edx,%edx
  801b28:	f7 f7                	div    %edi
  801b2a:	89 c5                	mov    %eax,%ebp
  801b2c:	89 c8                	mov    %ecx,%eax
  801b2e:	31 d2                	xor    %edx,%edx
  801b30:	f7 f5                	div    %ebp
  801b32:	89 c1                	mov    %eax,%ecx
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	89 cf                	mov    %ecx,%edi
  801b38:	f7 f5                	div    %ebp
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	89 d8                	mov    %ebx,%eax
  801b3e:	89 fa                	mov    %edi,%edx
  801b40:	83 c4 1c             	add    $0x1c,%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    
  801b48:	90                   	nop
  801b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b50:	39 ce                	cmp    %ecx,%esi
  801b52:	77 74                	ja     801bc8 <__udivdi3+0xd8>
  801b54:	0f bd fe             	bsr    %esi,%edi
  801b57:	83 f7 1f             	xor    $0x1f,%edi
  801b5a:	0f 84 98 00 00 00    	je     801bf8 <__udivdi3+0x108>
  801b60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b65:	89 f9                	mov    %edi,%ecx
  801b67:	89 c5                	mov    %eax,%ebp
  801b69:	29 fb                	sub    %edi,%ebx
  801b6b:	d3 e6                	shl    %cl,%esi
  801b6d:	89 d9                	mov    %ebx,%ecx
  801b6f:	d3 ed                	shr    %cl,%ebp
  801b71:	89 f9                	mov    %edi,%ecx
  801b73:	d3 e0                	shl    %cl,%eax
  801b75:	09 ee                	or     %ebp,%esi
  801b77:	89 d9                	mov    %ebx,%ecx
  801b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b7d:	89 d5                	mov    %edx,%ebp
  801b7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b83:	d3 ed                	shr    %cl,%ebp
  801b85:	89 f9                	mov    %edi,%ecx
  801b87:	d3 e2                	shl    %cl,%edx
  801b89:	89 d9                	mov    %ebx,%ecx
  801b8b:	d3 e8                	shr    %cl,%eax
  801b8d:	09 c2                	or     %eax,%edx
  801b8f:	89 d0                	mov    %edx,%eax
  801b91:	89 ea                	mov    %ebp,%edx
  801b93:	f7 f6                	div    %esi
  801b95:	89 d5                	mov    %edx,%ebp
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	f7 64 24 0c          	mull   0xc(%esp)
  801b9d:	39 d5                	cmp    %edx,%ebp
  801b9f:	72 10                	jb     801bb1 <__udivdi3+0xc1>
  801ba1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	d3 e6                	shl    %cl,%esi
  801ba9:	39 c6                	cmp    %eax,%esi
  801bab:	73 07                	jae    801bb4 <__udivdi3+0xc4>
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	75 03                	jne    801bb4 <__udivdi3+0xc4>
  801bb1:	83 eb 01             	sub    $0x1,%ebx
  801bb4:	31 ff                	xor    %edi,%edi
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	89 fa                	mov    %edi,%edx
  801bba:	83 c4 1c             	add    $0x1c,%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
  801bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc8:	31 ff                	xor    %edi,%edi
  801bca:	31 db                	xor    %ebx,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	f7 f7                	div    %edi
  801be4:	31 ff                	xor    %edi,%edi
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	89 d8                	mov    %ebx,%eax
  801bea:	89 fa                	mov    %edi,%edx
  801bec:	83 c4 1c             	add    $0x1c,%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5f                   	pop    %edi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	39 ce                	cmp    %ecx,%esi
  801bfa:	72 0c                	jb     801c08 <__udivdi3+0x118>
  801bfc:	31 db                	xor    %ebx,%ebx
  801bfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c02:	0f 87 34 ff ff ff    	ja     801b3c <__udivdi3+0x4c>
  801c08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c0d:	e9 2a ff ff ff       	jmp    801b3c <__udivdi3+0x4c>
  801c12:	66 90                	xchg   %ax,%ax
  801c14:	66 90                	xchg   %ax,%ax
  801c16:	66 90                	xchg   %ax,%ax
  801c18:	66 90                	xchg   %ax,%ax
  801c1a:	66 90                	xchg   %ax,%ax
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <__umoddi3>:
  801c20:	55                   	push   %ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c37:	85 d2                	test   %edx,%edx
  801c39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c41:	89 f3                	mov    %esi,%ebx
  801c43:	89 3c 24             	mov    %edi,(%esp)
  801c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4a:	75 1c                	jne    801c68 <__umoddi3+0x48>
  801c4c:	39 f7                	cmp    %esi,%edi
  801c4e:	76 50                	jbe    801ca0 <__umoddi3+0x80>
  801c50:	89 c8                	mov    %ecx,%eax
  801c52:	89 f2                	mov    %esi,%edx
  801c54:	f7 f7                	div    %edi
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	31 d2                	xor    %edx,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	39 f2                	cmp    %esi,%edx
  801c6a:	89 d0                	mov    %edx,%eax
  801c6c:	77 52                	ja     801cc0 <__umoddi3+0xa0>
  801c6e:	0f bd ea             	bsr    %edx,%ebp
  801c71:	83 f5 1f             	xor    $0x1f,%ebp
  801c74:	75 5a                	jne    801cd0 <__umoddi3+0xb0>
  801c76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c7a:	0f 82 e0 00 00 00    	jb     801d60 <__umoddi3+0x140>
  801c80:	39 0c 24             	cmp    %ecx,(%esp)
  801c83:	0f 86 d7 00 00 00    	jbe    801d60 <__umoddi3+0x140>
  801c89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c91:	83 c4 1c             	add    $0x1c,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	85 ff                	test   %edi,%edi
  801ca2:	89 fd                	mov    %edi,%ebp
  801ca4:	75 0b                	jne    801cb1 <__umoddi3+0x91>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f7                	div    %edi
  801caf:	89 c5                	mov    %eax,%ebp
  801cb1:	89 f0                	mov    %esi,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  801cb5:	f7 f5                	div    %ebp
  801cb7:	89 c8                	mov    %ecx,%eax
  801cb9:	f7 f5                	div    %ebp
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	eb 99                	jmp    801c58 <__umoddi3+0x38>
  801cbf:	90                   	nop
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	83 c4 1c             	add    $0x1c,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	8b 34 24             	mov    (%esp),%esi
  801cd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cd8:	89 e9                	mov    %ebp,%ecx
  801cda:	29 ef                	sub    %ebp,%edi
  801cdc:	d3 e0                	shl    %cl,%eax
  801cde:	89 f9                	mov    %edi,%ecx
  801ce0:	89 f2                	mov    %esi,%edx
  801ce2:	d3 ea                	shr    %cl,%edx
  801ce4:	89 e9                	mov    %ebp,%ecx
  801ce6:	09 c2                	or     %eax,%edx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 14 24             	mov    %edx,(%esp)
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	d3 e2                	shl    %cl,%edx
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	89 e9                	mov    %ebp,%ecx
  801cff:	89 c6                	mov    %eax,%esi
  801d01:	d3 e3                	shl    %cl,%ebx
  801d03:	89 f9                	mov    %edi,%ecx
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	d3 e8                	shr    %cl,%eax
  801d09:	89 e9                	mov    %ebp,%ecx
  801d0b:	09 d8                	or     %ebx,%eax
  801d0d:	89 d3                	mov    %edx,%ebx
  801d0f:	89 f2                	mov    %esi,%edx
  801d11:	f7 34 24             	divl   (%esp)
  801d14:	89 d6                	mov    %edx,%esi
  801d16:	d3 e3                	shl    %cl,%ebx
  801d18:	f7 64 24 04          	mull   0x4(%esp)
  801d1c:	39 d6                	cmp    %edx,%esi
  801d1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d22:	89 d1                	mov    %edx,%ecx
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	72 08                	jb     801d30 <__umoddi3+0x110>
  801d28:	75 11                	jne    801d3b <__umoddi3+0x11b>
  801d2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d2e:	73 0b                	jae    801d3b <__umoddi3+0x11b>
  801d30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d34:	1b 14 24             	sbb    (%esp),%edx
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d3f:	29 da                	sub    %ebx,%edx
  801d41:	19 ce                	sbb    %ecx,%esi
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 f0                	mov    %esi,%eax
  801d47:	d3 e0                	shl    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	d3 ea                	shr    %cl,%edx
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	d3 ee                	shr    %cl,%esi
  801d51:	09 d0                	or     %edx,%eax
  801d53:	89 f2                	mov    %esi,%edx
  801d55:	83 c4 1c             	add    $0x1c,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
  801d60:	29 f9                	sub    %edi,%ecx
  801d62:	19 d6                	sbb    %edx,%esi
  801d64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d6c:	e9 18 ff ff ff       	jmp    801c89 <__umoddi3+0x69>
