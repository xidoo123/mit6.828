
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
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80008e:	e8 2a 05 00 00       	call   8005bd <close_all>
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
  800107:	68 aa 22 80 00       	push   $0x8022aa
  80010c:	6a 23                	push   $0x23
  80010e:	68 c7 22 80 00       	push   $0x8022c7
  800113:	e8 1e 14 00 00       	call   801536 <_panic>

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
  800188:	68 aa 22 80 00       	push   $0x8022aa
  80018d:	6a 23                	push   $0x23
  80018f:	68 c7 22 80 00       	push   $0x8022c7
  800194:	e8 9d 13 00 00       	call   801536 <_panic>

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
  8001ca:	68 aa 22 80 00       	push   $0x8022aa
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 c7 22 80 00       	push   $0x8022c7
  8001d6:	e8 5b 13 00 00       	call   801536 <_panic>

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
  80020c:	68 aa 22 80 00       	push   $0x8022aa
  800211:	6a 23                	push   $0x23
  800213:	68 c7 22 80 00       	push   $0x8022c7
  800218:	e8 19 13 00 00       	call   801536 <_panic>

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
  80024e:	68 aa 22 80 00       	push   $0x8022aa
  800253:	6a 23                	push   $0x23
  800255:	68 c7 22 80 00       	push   $0x8022c7
  80025a:	e8 d7 12 00 00       	call   801536 <_panic>

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
  800290:	68 aa 22 80 00       	push   $0x8022aa
  800295:	6a 23                	push   $0x23
  800297:	68 c7 22 80 00       	push   $0x8022c7
  80029c:	e8 95 12 00 00       	call   801536 <_panic>

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
  8002d2:	68 aa 22 80 00       	push   $0x8022aa
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 c7 22 80 00       	push   $0x8022c7
  8002de:	e8 53 12 00 00       	call   801536 <_panic>

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
  800336:	68 aa 22 80 00       	push   $0x8022aa
  80033b:	6a 23                	push   $0x23
  80033d:	68 c7 22 80 00       	push   $0x8022c7
  800342:	e8 ef 11 00 00       	call   801536 <_panic>

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

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800377:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	89 df                	mov    %ebx,%edi
  800389:	89 de                	mov    %ebx,%esi
  80038b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80038d:	85 c0                	test   %eax,%eax
  80038f:	7e 17                	jle    8003a8 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	50                   	push   %eax
  800395:	6a 0f                	push   $0xf
  800397:	68 aa 22 80 00       	push   $0x8022aa
  80039c:	6a 23                	push   $0x23
  80039e:	68 c7 22 80 00       	push   $0x8022c7
  8003a3:	e8 8e 11 00 00       	call   801536 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8003a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ab:	5b                   	pop    %ebx
  8003ac:	5e                   	pop    %esi
  8003ad:	5f                   	pop    %edi
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	57                   	push   %edi
  8003b4:	56                   	push   %esi
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003be:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c9:	89 df                	mov    %ebx,%edi
  8003cb:	89 de                	mov    %ebx,%esi
  8003cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	7e 17                	jle    8003ea <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d3:	83 ec 0c             	sub    $0xc,%esp
  8003d6:	50                   	push   %eax
  8003d7:	6a 10                	push   $0x10
  8003d9:	68 aa 22 80 00       	push   $0x8022aa
  8003de:	6a 23                	push   $0x23
  8003e0:	68 c7 22 80 00       	push   $0x8022c7
  8003e5:	e8 4c 11 00 00       	call   801536 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  8003ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ed:	5b                   	pop    %ebx
  8003ee:	5e                   	pop    %esi
  8003ef:	5f                   	pop    %edi
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	05 00 00 00 30       	add    $0x30000000,%eax
  8003fd:	c1 e8 0c             	shr    $0xc,%eax
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	05 00 00 00 30       	add    $0x30000000,%eax
  80040d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800412:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800424:	89 c2                	mov    %eax,%edx
  800426:	c1 ea 16             	shr    $0x16,%edx
  800429:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800430:	f6 c2 01             	test   $0x1,%dl
  800433:	74 11                	je     800446 <fd_alloc+0x2d>
  800435:	89 c2                	mov    %eax,%edx
  800437:	c1 ea 0c             	shr    $0xc,%edx
  80043a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800441:	f6 c2 01             	test   $0x1,%dl
  800444:	75 09                	jne    80044f <fd_alloc+0x36>
			*fd_store = fd;
  800446:	89 01                	mov    %eax,(%ecx)
			return 0;
  800448:	b8 00 00 00 00       	mov    $0x0,%eax
  80044d:	eb 17                	jmp    800466 <fd_alloc+0x4d>
  80044f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800454:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800459:	75 c9                	jne    800424 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80045b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800461:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80046e:	83 f8 1f             	cmp    $0x1f,%eax
  800471:	77 36                	ja     8004a9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800473:	c1 e0 0c             	shl    $0xc,%eax
  800476:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	c1 ea 16             	shr    $0x16,%edx
  800480:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800487:	f6 c2 01             	test   $0x1,%dl
  80048a:	74 24                	je     8004b0 <fd_lookup+0x48>
  80048c:	89 c2                	mov    %eax,%edx
  80048e:	c1 ea 0c             	shr    $0xc,%edx
  800491:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800498:	f6 c2 01             	test   $0x1,%dl
  80049b:	74 1a                	je     8004b7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a0:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a7:	eb 13                	jmp    8004bc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ae:	eb 0c                	jmp    8004bc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b5:	eb 05                	jmp    8004bc <fd_lookup+0x54>
  8004b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c7:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004cc:	eb 13                	jmp    8004e1 <dev_lookup+0x23>
  8004ce:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004d1:	39 08                	cmp    %ecx,(%eax)
  8004d3:	75 0c                	jne    8004e1 <dev_lookup+0x23>
			*dev = devtab[i];
  8004d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	eb 2e                	jmp    80050f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	75 e7                	jne    8004ce <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8004ec:	8b 40 48             	mov    0x48(%eax),%eax
  8004ef:	83 ec 04             	sub    $0x4,%esp
  8004f2:	51                   	push   %ecx
  8004f3:	50                   	push   %eax
  8004f4:	68 d8 22 80 00       	push   $0x8022d8
  8004f9:	e8 11 11 00 00       	call   80160f <cprintf>
	*dev = 0;
  8004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800501:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	56                   	push   %esi
  800515:	53                   	push   %ebx
  800516:	83 ec 10             	sub    $0x10,%esp
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800522:	50                   	push   %eax
  800523:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800529:	c1 e8 0c             	shr    $0xc,%eax
  80052c:	50                   	push   %eax
  80052d:	e8 36 ff ff ff       	call   800468 <fd_lookup>
  800532:	83 c4 08             	add    $0x8,%esp
  800535:	85 c0                	test   %eax,%eax
  800537:	78 05                	js     80053e <fd_close+0x2d>
	    || fd != fd2)
  800539:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80053c:	74 0c                	je     80054a <fd_close+0x39>
		return (must_exist ? r : 0);
  80053e:	84 db                	test   %bl,%bl
  800540:	ba 00 00 00 00       	mov    $0x0,%edx
  800545:	0f 44 c2             	cmove  %edx,%eax
  800548:	eb 41                	jmp    80058b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 36                	pushl  (%esi)
  800553:	e8 66 ff ff ff       	call   8004be <dev_lookup>
  800558:	89 c3                	mov    %eax,%ebx
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 c0                	test   %eax,%eax
  80055f:	78 1a                	js     80057b <fd_close+0x6a>
		if (dev->dev_close)
  800561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800564:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800567:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80056c:	85 c0                	test   %eax,%eax
  80056e:	74 0b                	je     80057b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800570:	83 ec 0c             	sub    $0xc,%esp
  800573:	56                   	push   %esi
  800574:	ff d0                	call   *%eax
  800576:	89 c3                	mov    %eax,%ebx
  800578:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	56                   	push   %esi
  80057f:	6a 00                	push   $0x0
  800581:	e8 5d fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	89 d8                	mov    %ebx,%eax
}
  80058b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80058e:	5b                   	pop    %ebx
  80058f:	5e                   	pop    %esi
  800590:	5d                   	pop    %ebp
  800591:	c3                   	ret    

00800592 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80059b:	50                   	push   %eax
  80059c:	ff 75 08             	pushl  0x8(%ebp)
  80059f:	e8 c4 fe ff ff       	call   800468 <fd_lookup>
  8005a4:	83 c4 08             	add    $0x8,%esp
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	78 10                	js     8005bb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	6a 01                	push   $0x1
  8005b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8005b3:	e8 59 ff ff ff       	call   800511 <fd_close>
  8005b8:	83 c4 10             	add    $0x10,%esp
}
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <close_all>:

void
close_all(void)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	53                   	push   %ebx
  8005c1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	e8 c0 ff ff ff       	call   800592 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d2:	83 c3 01             	add    $0x1,%ebx
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	83 fb 20             	cmp    $0x20,%ebx
  8005db:	75 ec                	jne    8005c9 <close_all+0xc>
		close(i);
}
  8005dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	57                   	push   %edi
  8005e6:	56                   	push   %esi
  8005e7:	53                   	push   %ebx
  8005e8:	83 ec 2c             	sub    $0x2c,%esp
  8005eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f1:	50                   	push   %eax
  8005f2:	ff 75 08             	pushl  0x8(%ebp)
  8005f5:	e8 6e fe ff ff       	call   800468 <fd_lookup>
  8005fa:	83 c4 08             	add    $0x8,%esp
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	0f 88 c1 00 00 00    	js     8006c6 <dup+0xe4>
		return r;
	close(newfdnum);
  800605:	83 ec 0c             	sub    $0xc,%esp
  800608:	56                   	push   %esi
  800609:	e8 84 ff ff ff       	call   800592 <close>

	newfd = INDEX2FD(newfdnum);
  80060e:	89 f3                	mov    %esi,%ebx
  800610:	c1 e3 0c             	shl    $0xc,%ebx
  800613:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800619:	83 c4 04             	add    $0x4,%esp
  80061c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80061f:	e8 de fd ff ff       	call   800402 <fd2data>
  800624:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800626:	89 1c 24             	mov    %ebx,(%esp)
  800629:	e8 d4 fd ff ff       	call   800402 <fd2data>
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800634:	89 f8                	mov    %edi,%eax
  800636:	c1 e8 16             	shr    $0x16,%eax
  800639:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800640:	a8 01                	test   $0x1,%al
  800642:	74 37                	je     80067b <dup+0x99>
  800644:	89 f8                	mov    %edi,%eax
  800646:	c1 e8 0c             	shr    $0xc,%eax
  800649:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800650:	f6 c2 01             	test   $0x1,%dl
  800653:	74 26                	je     80067b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800655:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	25 07 0e 00 00       	and    $0xe07,%eax
  800664:	50                   	push   %eax
  800665:	ff 75 d4             	pushl  -0x2c(%ebp)
  800668:	6a 00                	push   $0x0
  80066a:	57                   	push   %edi
  80066b:	6a 00                	push   $0x0
  80066d:	e8 2f fb ff ff       	call   8001a1 <sys_page_map>
  800672:	89 c7                	mov    %eax,%edi
  800674:	83 c4 20             	add    $0x20,%esp
  800677:	85 c0                	test   %eax,%eax
  800679:	78 2e                	js     8006a9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80067b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067e:	89 d0                	mov    %edx,%eax
  800680:	c1 e8 0c             	shr    $0xc,%eax
  800683:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80068a:	83 ec 0c             	sub    $0xc,%esp
  80068d:	25 07 0e 00 00       	and    $0xe07,%eax
  800692:	50                   	push   %eax
  800693:	53                   	push   %ebx
  800694:	6a 00                	push   $0x0
  800696:	52                   	push   %edx
  800697:	6a 00                	push   $0x0
  800699:	e8 03 fb ff ff       	call   8001a1 <sys_page_map>
  80069e:	89 c7                	mov    %eax,%edi
  8006a0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006a3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	79 1d                	jns    8006c6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 00                	push   $0x0
  8006af:	e8 2f fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006ba:	6a 00                	push   $0x0
  8006bc:	e8 22 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	89 f8                	mov    %edi,%eax
}
  8006c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 14             	sub    $0x14,%esp
  8006d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	53                   	push   %ebx
  8006dd:	e8 86 fd ff ff       	call   800468 <fd_lookup>
  8006e2:	83 c4 08             	add    $0x8,%esp
  8006e5:	89 c2                	mov    %eax,%edx
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	78 6d                	js     800758 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f5:	ff 30                	pushl  (%eax)
  8006f7:	e8 c2 fd ff ff       	call   8004be <dev_lookup>
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	85 c0                	test   %eax,%eax
  800701:	78 4c                	js     80074f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800703:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800706:	8b 42 08             	mov    0x8(%edx),%eax
  800709:	83 e0 03             	and    $0x3,%eax
  80070c:	83 f8 01             	cmp    $0x1,%eax
  80070f:	75 21                	jne    800732 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800711:	a1 08 40 80 00       	mov    0x804008,%eax
  800716:	8b 40 48             	mov    0x48(%eax),%eax
  800719:	83 ec 04             	sub    $0x4,%esp
  80071c:	53                   	push   %ebx
  80071d:	50                   	push   %eax
  80071e:	68 19 23 80 00       	push   $0x802319
  800723:	e8 e7 0e 00 00       	call   80160f <cprintf>
		return -E_INVAL;
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800730:	eb 26                	jmp    800758 <read+0x8a>
	}
	if (!dev->dev_read)
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	8b 40 08             	mov    0x8(%eax),%eax
  800738:	85 c0                	test   %eax,%eax
  80073a:	74 17                	je     800753 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80073c:	83 ec 04             	sub    $0x4,%esp
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	52                   	push   %edx
  800746:	ff d0                	call   *%eax
  800748:	89 c2                	mov    %eax,%edx
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 09                	jmp    800758 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074f:	89 c2                	mov    %eax,%edx
  800751:	eb 05                	jmp    800758 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800753:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800758:	89 d0                	mov    %edx,%eax
  80075a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	57                   	push   %edi
  800763:	56                   	push   %esi
  800764:	53                   	push   %ebx
  800765:	83 ec 0c             	sub    $0xc,%esp
  800768:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80076e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800773:	eb 21                	jmp    800796 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800775:	83 ec 04             	sub    $0x4,%esp
  800778:	89 f0                	mov    %esi,%eax
  80077a:	29 d8                	sub    %ebx,%eax
  80077c:	50                   	push   %eax
  80077d:	89 d8                	mov    %ebx,%eax
  80077f:	03 45 0c             	add    0xc(%ebp),%eax
  800782:	50                   	push   %eax
  800783:	57                   	push   %edi
  800784:	e8 45 ff ff ff       	call   8006ce <read>
		if (m < 0)
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	85 c0                	test   %eax,%eax
  80078e:	78 10                	js     8007a0 <readn+0x41>
			return m;
		if (m == 0)
  800790:	85 c0                	test   %eax,%eax
  800792:	74 0a                	je     80079e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800794:	01 c3                	add    %eax,%ebx
  800796:	39 f3                	cmp    %esi,%ebx
  800798:	72 db                	jb     800775 <readn+0x16>
  80079a:	89 d8                	mov    %ebx,%eax
  80079c:	eb 02                	jmp    8007a0 <readn+0x41>
  80079e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5f                   	pop    %edi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 14             	sub    $0x14,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	53                   	push   %ebx
  8007b7:	e8 ac fc ff ff       	call   800468 <fd_lookup>
  8007bc:	83 c4 08             	add    $0x8,%esp
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 68                	js     80082d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cb:	50                   	push   %eax
  8007cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cf:	ff 30                	pushl  (%eax)
  8007d1:	e8 e8 fc ff ff       	call   8004be <dev_lookup>
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	78 47                	js     800824 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e4:	75 21                	jne    800807 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e6:	a1 08 40 80 00       	mov    0x804008,%eax
  8007eb:	8b 40 48             	mov    0x48(%eax),%eax
  8007ee:	83 ec 04             	sub    $0x4,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	50                   	push   %eax
  8007f3:	68 35 23 80 00       	push   $0x802335
  8007f8:	e8 12 0e 00 00       	call   80160f <cprintf>
		return -E_INVAL;
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800805:	eb 26                	jmp    80082d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800807:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80080a:	8b 52 0c             	mov    0xc(%edx),%edx
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 17                	je     800828 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800811:	83 ec 04             	sub    $0x4,%esp
  800814:	ff 75 10             	pushl  0x10(%ebp)
  800817:	ff 75 0c             	pushl  0xc(%ebp)
  80081a:	50                   	push   %eax
  80081b:	ff d2                	call   *%edx
  80081d:	89 c2                	mov    %eax,%edx
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb 09                	jmp    80082d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800824:	89 c2                	mov    %eax,%edx
  800826:	eb 05                	jmp    80082d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800828:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80082d:	89 d0                	mov    %edx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <seek>:

int
seek(int fdnum, off_t offset)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80083a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	ff 75 08             	pushl  0x8(%ebp)
  800841:	e8 22 fc ff ff       	call   800468 <fd_lookup>
  800846:	83 c4 08             	add    $0x8,%esp
  800849:	85 c0                	test   %eax,%eax
  80084b:	78 0e                	js     80085b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80084d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	83 ec 14             	sub    $0x14,%esp
  800864:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800867:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	53                   	push   %ebx
  80086c:	e8 f7 fb ff ff       	call   800468 <fd_lookup>
  800871:	83 c4 08             	add    $0x8,%esp
  800874:	89 c2                	mov    %eax,%edx
  800876:	85 c0                	test   %eax,%eax
  800878:	78 65                	js     8008df <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800880:	50                   	push   %eax
  800881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800884:	ff 30                	pushl  (%eax)
  800886:	e8 33 fc ff ff       	call   8004be <dev_lookup>
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	85 c0                	test   %eax,%eax
  800890:	78 44                	js     8008d6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800895:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800899:	75 21                	jne    8008bc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80089b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a0:	8b 40 48             	mov    0x48(%eax),%eax
  8008a3:	83 ec 04             	sub    $0x4,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	50                   	push   %eax
  8008a8:	68 f8 22 80 00       	push   $0x8022f8
  8008ad:	e8 5d 0d 00 00       	call   80160f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008ba:	eb 23                	jmp    8008df <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008bf:	8b 52 18             	mov    0x18(%edx),%edx
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	74 14                	je     8008da <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	ff 75 0c             	pushl  0xc(%ebp)
  8008cc:	50                   	push   %eax
  8008cd:	ff d2                	call   *%edx
  8008cf:	89 c2                	mov    %eax,%edx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	eb 09                	jmp    8008df <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d6:	89 c2                	mov    %eax,%edx
  8008d8:	eb 05                	jmp    8008df <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    

008008e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	83 ec 14             	sub    $0x14,%esp
  8008ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008f3:	50                   	push   %eax
  8008f4:	ff 75 08             	pushl  0x8(%ebp)
  8008f7:	e8 6c fb ff ff       	call   800468 <fd_lookup>
  8008fc:	83 c4 08             	add    $0x8,%esp
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	85 c0                	test   %eax,%eax
  800903:	78 58                	js     80095d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090b:	50                   	push   %eax
  80090c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090f:	ff 30                	pushl  (%eax)
  800911:	e8 a8 fb ff ff       	call   8004be <dev_lookup>
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	85 c0                	test   %eax,%eax
  80091b:	78 37                	js     800954 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80091d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800920:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800924:	74 32                	je     800958 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800926:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800929:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800930:	00 00 00 
	stat->st_isdir = 0;
  800933:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80093a:	00 00 00 
	stat->st_dev = dev;
  80093d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	53                   	push   %ebx
  800947:	ff 75 f0             	pushl  -0x10(%ebp)
  80094a:	ff 50 14             	call   *0x14(%eax)
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	83 c4 10             	add    $0x10,%esp
  800952:	eb 09                	jmp    80095d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800954:	89 c2                	mov    %eax,%edx
  800956:	eb 05                	jmp    80095d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800958:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	6a 00                	push   $0x0
  80096e:	ff 75 08             	pushl  0x8(%ebp)
  800971:	e8 d6 01 00 00       	call   800b4c <open>
  800976:	89 c3                	mov    %eax,%ebx
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	85 c0                	test   %eax,%eax
  80097d:	78 1b                	js     80099a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	ff 75 0c             	pushl  0xc(%ebp)
  800985:	50                   	push   %eax
  800986:	e8 5b ff ff ff       	call   8008e6 <fstat>
  80098b:	89 c6                	mov    %eax,%esi
	close(fd);
  80098d:	89 1c 24             	mov    %ebx,(%esp)
  800990:	e8 fd fb ff ff       	call   800592 <close>
	return r;
  800995:	83 c4 10             	add    $0x10,%esp
  800998:	89 f0                	mov    %esi,%eax
}
  80099a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	89 c6                	mov    %eax,%esi
  8009a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009aa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b1:	75 12                	jne    8009c5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009b3:	83 ec 0c             	sub    $0xc,%esp
  8009b6:	6a 01                	push   $0x1
  8009b8:	e8 d9 15 00 00       	call   801f96 <ipc_find_env>
  8009bd:	a3 00 40 80 00       	mov    %eax,0x804000
  8009c2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009c5:	6a 07                	push   $0x7
  8009c7:	68 00 50 80 00       	push   $0x805000
  8009cc:	56                   	push   %esi
  8009cd:	ff 35 00 40 80 00    	pushl  0x804000
  8009d3:	e8 6a 15 00 00       	call   801f42 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009d8:	83 c4 0c             	add    $0xc,%esp
  8009db:	6a 00                	push   $0x0
  8009dd:	53                   	push   %ebx
  8009de:	6a 00                	push   $0x0
  8009e0:	e8 f6 14 00 00       	call   801edb <ipc_recv>
}
  8009e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a00:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800a0f:	e8 8d ff ff ff       	call   8009a1 <fsipc>
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a22:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a27:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800a31:	e8 6b ff ff ff       	call   8009a1 <fsipc>
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	83 ec 04             	sub    $0x4,%esp
  800a3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 40 0c             	mov    0xc(%eax),%eax
  800a48:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 05 00 00 00       	mov    $0x5,%eax
  800a57:	e8 45 ff ff ff       	call   8009a1 <fsipc>
  800a5c:	85 c0                	test   %eax,%eax
  800a5e:	78 2c                	js     800a8c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	68 00 50 80 00       	push   $0x805000
  800a68:	53                   	push   %ebx
  800a69:	e8 26 11 00 00       	call   801b94 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a6e:	a1 80 50 80 00       	mov    0x805080,%eax
  800a73:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a79:	a1 84 50 80 00       	mov    0x805084,%eax
  800a7e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a84:	83 c4 10             	add    $0x10,%esp
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8f:	c9                   	leave  
  800a90:	c3                   	ret    

00800a91 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 0c             	sub    $0xc,%esp
  800a97:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	8b 52 0c             	mov    0xc(%edx),%edx
  800aa0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800aa6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800aab:	50                   	push   %eax
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	68 08 50 80 00       	push   $0x805008
  800ab4:	e8 6d 12 00 00       	call   801d26 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 04 00 00 00       	mov    $0x4,%eax
  800ac3:	e8 d9 fe ff ff       	call   8009a1 <fsipc>

}
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    

00800aca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800add:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 03 00 00 00       	mov    $0x3,%eax
  800aed:	e8 af fe ff ff       	call   8009a1 <fsipc>
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	85 c0                	test   %eax,%eax
  800af6:	78 4b                	js     800b43 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800af8:	39 c6                	cmp    %eax,%esi
  800afa:	73 16                	jae    800b12 <devfile_read+0x48>
  800afc:	68 68 23 80 00       	push   $0x802368
  800b01:	68 6f 23 80 00       	push   $0x80236f
  800b06:	6a 7c                	push   $0x7c
  800b08:	68 84 23 80 00       	push   $0x802384
  800b0d:	e8 24 0a 00 00       	call   801536 <_panic>
	assert(r <= PGSIZE);
  800b12:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b17:	7e 16                	jle    800b2f <devfile_read+0x65>
  800b19:	68 8f 23 80 00       	push   $0x80238f
  800b1e:	68 6f 23 80 00       	push   $0x80236f
  800b23:	6a 7d                	push   $0x7d
  800b25:	68 84 23 80 00       	push   $0x802384
  800b2a:	e8 07 0a 00 00       	call   801536 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b2f:	83 ec 04             	sub    $0x4,%esp
  800b32:	50                   	push   %eax
  800b33:	68 00 50 80 00       	push   $0x805000
  800b38:	ff 75 0c             	pushl  0xc(%ebp)
  800b3b:	e8 e6 11 00 00       	call   801d26 <memmove>
	return r;
  800b40:	83 c4 10             	add    $0x10,%esp
}
  800b43:	89 d8                	mov    %ebx,%eax
  800b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 20             	sub    $0x20,%esp
  800b53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b56:	53                   	push   %ebx
  800b57:	e8 ff 0f 00 00       	call   801b5b <strlen>
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b64:	7f 67                	jg     800bcd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b6c:	50                   	push   %eax
  800b6d:	e8 a7 f8 ff ff       	call   800419 <fd_alloc>
  800b72:	83 c4 10             	add    $0x10,%esp
		return r;
  800b75:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	78 57                	js     800bd2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b7b:	83 ec 08             	sub    $0x8,%esp
  800b7e:	53                   	push   %ebx
  800b7f:	68 00 50 80 00       	push   $0x805000
  800b84:	e8 0b 10 00 00       	call   801b94 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b94:	b8 01 00 00 00       	mov    $0x1,%eax
  800b99:	e8 03 fe ff ff       	call   8009a1 <fsipc>
  800b9e:	89 c3                	mov    %eax,%ebx
  800ba0:	83 c4 10             	add    $0x10,%esp
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	79 14                	jns    800bbb <open+0x6f>
		fd_close(fd, 0);
  800ba7:	83 ec 08             	sub    $0x8,%esp
  800baa:	6a 00                	push   $0x0
  800bac:	ff 75 f4             	pushl  -0xc(%ebp)
  800baf:	e8 5d f9 ff ff       	call   800511 <fd_close>
		return r;
  800bb4:	83 c4 10             	add    $0x10,%esp
  800bb7:	89 da                	mov    %ebx,%edx
  800bb9:	eb 17                	jmp    800bd2 <open+0x86>
	}

	return fd2num(fd);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	ff 75 f4             	pushl  -0xc(%ebp)
  800bc1:	e8 2c f8 ff ff       	call   8003f2 <fd2num>
  800bc6:	89 c2                	mov    %eax,%edx
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	eb 05                	jmp    800bd2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bcd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bd2:	89 d0                	mov    %edx,%eax
  800bd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 08 00 00 00       	mov    $0x8,%eax
  800be9:	e8 b3 fd ff ff       	call   8009a1 <fsipc>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bf6:	68 9b 23 80 00       	push   $0x80239b
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	e8 91 0f 00 00       	call   801b94 <strcpy>
	return 0;
}
  800c03:	b8 00 00 00 00       	mov    $0x0,%eax
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 10             	sub    $0x10,%esp
  800c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c14:	53                   	push   %ebx
  800c15:	e8 b5 13 00 00       	call   801fcf <pageref>
  800c1a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c22:	83 f8 01             	cmp    $0x1,%eax
  800c25:	75 10                	jne    800c37 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	ff 73 0c             	pushl  0xc(%ebx)
  800c2d:	e8 c0 02 00 00       	call   800ef2 <nsipc_close>
  800c32:	89 c2                	mov    %eax,%edx
  800c34:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c37:	89 d0                	mov    %edx,%eax
  800c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c44:	6a 00                	push   $0x0
  800c46:	ff 75 10             	pushl  0x10(%ebp)
  800c49:	ff 75 0c             	pushl  0xc(%ebp)
  800c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4f:	ff 70 0c             	pushl  0xc(%eax)
  800c52:	e8 78 03 00 00       	call   800fcf <nsipc_send>
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c5f:	6a 00                	push   $0x0
  800c61:	ff 75 10             	pushl  0x10(%ebp)
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	ff 70 0c             	pushl  0xc(%eax)
  800c6d:	e8 f1 02 00 00       	call   800f63 <nsipc_recv>
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c7a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c7d:	52                   	push   %edx
  800c7e:	50                   	push   %eax
  800c7f:	e8 e4 f7 ff ff       	call   800468 <fd_lookup>
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	85 c0                	test   %eax,%eax
  800c89:	78 17                	js     800ca2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c94:	39 08                	cmp    %ecx,(%eax)
  800c96:	75 05                	jne    800c9d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c98:	8b 40 0c             	mov    0xc(%eax),%eax
  800c9b:	eb 05                	jmp    800ca2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c9d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    

00800ca4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 1c             	sub    $0x1c,%esp
  800cac:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb1:	50                   	push   %eax
  800cb2:	e8 62 f7 ff ff       	call   800419 <fd_alloc>
  800cb7:	89 c3                	mov    %eax,%ebx
  800cb9:	83 c4 10             	add    $0x10,%esp
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	78 1b                	js     800cdb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cc0:	83 ec 04             	sub    $0x4,%esp
  800cc3:	68 07 04 00 00       	push   $0x407
  800cc8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ccb:	6a 00                	push   $0x0
  800ccd:	e8 8c f4 ff ff       	call   80015e <sys_page_alloc>
  800cd2:	89 c3                	mov    %eax,%ebx
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	79 10                	jns    800ceb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	56                   	push   %esi
  800cdf:	e8 0e 02 00 00       	call   800ef2 <nsipc_close>
		return r;
  800ce4:	83 c4 10             	add    $0x10,%esp
  800ce7:	89 d8                	mov    %ebx,%eax
  800ce9:	eb 24                	jmp    800d0f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ceb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d00:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	e8 e6 f6 ff ff       	call   8003f2 <fd2num>
  800d0c:	83 c4 10             	add    $0x10,%esp
}
  800d0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	e8 50 ff ff ff       	call   800c74 <fd2sockid>
		return r;
  800d24:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	78 1f                	js     800d49 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	ff 75 10             	pushl  0x10(%ebp)
  800d30:	ff 75 0c             	pushl  0xc(%ebp)
  800d33:	50                   	push   %eax
  800d34:	e8 12 01 00 00       	call   800e4b <nsipc_accept>
  800d39:	83 c4 10             	add    $0x10,%esp
		return r;
  800d3c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	78 07                	js     800d49 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d42:	e8 5d ff ff ff       	call   800ca4 <alloc_sockfd>
  800d47:	89 c1                	mov    %eax,%ecx
}
  800d49:	89 c8                	mov    %ecx,%eax
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	e8 19 ff ff ff       	call   800c74 <fd2sockid>
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	78 12                	js     800d71 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	ff 75 10             	pushl  0x10(%ebp)
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	50                   	push   %eax
  800d69:	e8 2d 01 00 00       	call   800e9b <nsipc_bind>
  800d6e:	83 c4 10             	add    $0x10,%esp
}
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <shutdown>:

int
shutdown(int s, int how)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	e8 f3 fe ff ff       	call   800c74 <fd2sockid>
  800d81:	85 c0                	test   %eax,%eax
  800d83:	78 0f                	js     800d94 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d85:	83 ec 08             	sub    $0x8,%esp
  800d88:	ff 75 0c             	pushl  0xc(%ebp)
  800d8b:	50                   	push   %eax
  800d8c:	e8 3f 01 00 00       	call   800ed0 <nsipc_shutdown>
  800d91:	83 c4 10             	add    $0x10,%esp
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	e8 d0 fe ff ff       	call   800c74 <fd2sockid>
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 12                	js     800dba <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	ff 75 10             	pushl  0x10(%ebp)
  800dae:	ff 75 0c             	pushl  0xc(%ebp)
  800db1:	50                   	push   %eax
  800db2:	e8 55 01 00 00       	call   800f0c <nsipc_connect>
  800db7:	83 c4 10             	add    $0x10,%esp
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <listen>:

int
listen(int s, int backlog)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc5:	e8 aa fe ff ff       	call   800c74 <fd2sockid>
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	78 0f                	js     800ddd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dce:	83 ec 08             	sub    $0x8,%esp
  800dd1:	ff 75 0c             	pushl  0xc(%ebp)
  800dd4:	50                   	push   %eax
  800dd5:	e8 67 01 00 00       	call   800f41 <nsipc_listen>
  800dda:	83 c4 10             	add    $0x10,%esp
}
  800ddd:	c9                   	leave  
  800dde:	c3                   	ret    

00800ddf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800de5:	ff 75 10             	pushl  0x10(%ebp)
  800de8:	ff 75 0c             	pushl  0xc(%ebp)
  800deb:	ff 75 08             	pushl  0x8(%ebp)
  800dee:	e8 3a 02 00 00       	call   80102d <nsipc_socket>
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 05                	js     800dff <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dfa:	e8 a5 fe ff ff       	call   800ca4 <alloc_sockfd>
}
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	53                   	push   %ebx
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e0a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e11:	75 12                	jne    800e25 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	6a 02                	push   $0x2
  800e18:	e8 79 11 00 00       	call   801f96 <ipc_find_env>
  800e1d:	a3 04 40 80 00       	mov    %eax,0x804004
  800e22:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e25:	6a 07                	push   $0x7
  800e27:	68 00 60 80 00       	push   $0x806000
  800e2c:	53                   	push   %ebx
  800e2d:	ff 35 04 40 80 00    	pushl  0x804004
  800e33:	e8 0a 11 00 00       	call   801f42 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e38:	83 c4 0c             	add    $0xc,%esp
  800e3b:	6a 00                	push   $0x0
  800e3d:	6a 00                	push   $0x0
  800e3f:	6a 00                	push   $0x0
  800e41:	e8 95 10 00 00       	call   801edb <ipc_recv>
}
  800e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e5b:	8b 06                	mov    (%esi),%eax
  800e5d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	e8 95 ff ff ff       	call   800e01 <nsipc>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 20                	js     800e92 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	ff 35 10 60 80 00    	pushl  0x806010
  800e7b:	68 00 60 80 00       	push   $0x806000
  800e80:	ff 75 0c             	pushl  0xc(%ebp)
  800e83:	e8 9e 0e 00 00       	call   801d26 <memmove>
		*addrlen = ret->ret_addrlen;
  800e88:	a1 10 60 80 00       	mov    0x806010,%eax
  800e8d:	89 06                	mov    %eax,(%esi)
  800e8f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e92:	89 d8                	mov    %ebx,%eax
  800e94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ead:	53                   	push   %ebx
  800eae:	ff 75 0c             	pushl  0xc(%ebp)
  800eb1:	68 04 60 80 00       	push   $0x806004
  800eb6:	e8 6b 0e 00 00       	call   801d26 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ebb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ec1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec6:	e8 36 ff ff ff       	call   800e01 <nsipc>
}
  800ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ee6:	b8 03 00 00 00       	mov    $0x3,%eax
  800eeb:	e8 11 ff ff ff       	call   800e01 <nsipc>
}
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <nsipc_close>:

int
nsipc_close(int s)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f00:	b8 04 00 00 00       	mov    $0x4,%eax
  800f05:	e8 f7 fe ff ff       	call   800e01 <nsipc>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f1e:	53                   	push   %ebx
  800f1f:	ff 75 0c             	pushl  0xc(%ebp)
  800f22:	68 04 60 80 00       	push   $0x806004
  800f27:	e8 fa 0d 00 00       	call   801d26 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f2c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f32:	b8 05 00 00 00       	mov    $0x5,%eax
  800f37:	e8 c5 fe ff ff       	call   800e01 <nsipc>
}
  800f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f52:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f57:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5c:	e8 a0 fe ff ff       	call   800e01 <nsipc>
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f73:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f79:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f81:	b8 07 00 00 00       	mov    $0x7,%eax
  800f86:	e8 76 fe ff ff       	call   800e01 <nsipc>
  800f8b:	89 c3                	mov    %eax,%ebx
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 35                	js     800fc6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f91:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f96:	7f 04                	jg     800f9c <nsipc_recv+0x39>
  800f98:	39 c6                	cmp    %eax,%esi
  800f9a:	7d 16                	jge    800fb2 <nsipc_recv+0x4f>
  800f9c:	68 a7 23 80 00       	push   $0x8023a7
  800fa1:	68 6f 23 80 00       	push   $0x80236f
  800fa6:	6a 62                	push   $0x62
  800fa8:	68 bc 23 80 00       	push   $0x8023bc
  800fad:	e8 84 05 00 00       	call   801536 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	50                   	push   %eax
  800fb6:	68 00 60 80 00       	push   $0x806000
  800fbb:	ff 75 0c             	pushl  0xc(%ebp)
  800fbe:	e8 63 0d 00 00       	call   801d26 <memmove>
  800fc3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 04             	sub    $0x4,%esp
  800fd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fe1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fe7:	7e 16                	jle    800fff <nsipc_send+0x30>
  800fe9:	68 c8 23 80 00       	push   $0x8023c8
  800fee:	68 6f 23 80 00       	push   $0x80236f
  800ff3:	6a 6d                	push   $0x6d
  800ff5:	68 bc 23 80 00       	push   $0x8023bc
  800ffa:	e8 37 05 00 00       	call   801536 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	53                   	push   %ebx
  801003:	ff 75 0c             	pushl  0xc(%ebp)
  801006:	68 0c 60 80 00       	push   $0x80600c
  80100b:	e8 16 0d 00 00       	call   801d26 <memmove>
	nsipcbuf.send.req_size = size;
  801010:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801016:	8b 45 14             	mov    0x14(%ebp),%eax
  801019:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80101e:	b8 08 00 00 00       	mov    $0x8,%eax
  801023:	e8 d9 fd ff ff       	call   800e01 <nsipc>
}
  801028:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80103b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801043:	8b 45 10             	mov    0x10(%ebp),%eax
  801046:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80104b:	b8 09 00 00 00       	mov    $0x9,%eax
  801050:	e8 ac fd ff ff       	call   800e01 <nsipc>
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 98 f3 ff ff       	call   800402 <fd2data>
  80106a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80106c:	83 c4 08             	add    $0x8,%esp
  80106f:	68 d4 23 80 00       	push   $0x8023d4
  801074:	53                   	push   %ebx
  801075:	e8 1a 0b 00 00       	call   801b94 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80107a:	8b 46 04             	mov    0x4(%esi),%eax
  80107d:	2b 06                	sub    (%esi),%eax
  80107f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801085:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80108c:	00 00 00 
	stat->st_dev = &devpipe;
  80108f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801096:	30 80 00 
	return 0;
}
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
  80109e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010af:	53                   	push   %ebx
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 2c f1 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010b7:	89 1c 24             	mov    %ebx,(%esp)
  8010ba:	e8 43 f3 ff ff       	call   800402 <fd2data>
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	50                   	push   %eax
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 19 f1 ff ff       	call   8001e3 <sys_page_unmap>
}
  8010ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 1c             	sub    $0x1c,%esp
  8010d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010db:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8010eb:	e8 df 0e 00 00       	call   801fcf <pageref>
  8010f0:	89 c3                	mov    %eax,%ebx
  8010f2:	89 3c 24             	mov    %edi,(%esp)
  8010f5:	e8 d5 0e 00 00       	call   801fcf <pageref>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	39 c3                	cmp    %eax,%ebx
  8010ff:	0f 94 c1             	sete   %cl
  801102:	0f b6 c9             	movzbl %cl,%ecx
  801105:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801108:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80110e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801111:	39 ce                	cmp    %ecx,%esi
  801113:	74 1b                	je     801130 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801115:	39 c3                	cmp    %eax,%ebx
  801117:	75 c4                	jne    8010dd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801119:	8b 42 58             	mov    0x58(%edx),%eax
  80111c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111f:	50                   	push   %eax
  801120:	56                   	push   %esi
  801121:	68 db 23 80 00       	push   $0x8023db
  801126:	e8 e4 04 00 00       	call   80160f <cprintf>
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	eb ad                	jmp    8010dd <_pipeisclosed+0xe>
	}
}
  801130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	57                   	push   %edi
  80113f:	56                   	push   %esi
  801140:	53                   	push   %ebx
  801141:	83 ec 28             	sub    $0x28,%esp
  801144:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801147:	56                   	push   %esi
  801148:	e8 b5 f2 ff ff       	call   800402 <fd2data>
  80114d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	bf 00 00 00 00       	mov    $0x0,%edi
  801157:	eb 4b                	jmp    8011a4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801159:	89 da                	mov    %ebx,%edx
  80115b:	89 f0                	mov    %esi,%eax
  80115d:	e8 6d ff ff ff       	call   8010cf <_pipeisclosed>
  801162:	85 c0                	test   %eax,%eax
  801164:	75 48                	jne    8011ae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801166:	e8 d4 ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80116b:	8b 43 04             	mov    0x4(%ebx),%eax
  80116e:	8b 0b                	mov    (%ebx),%ecx
  801170:	8d 51 20             	lea    0x20(%ecx),%edx
  801173:	39 d0                	cmp    %edx,%eax
  801175:	73 e2                	jae    801159 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80117e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 fa 1f             	sar    $0x1f,%edx
  801186:	89 d1                	mov    %edx,%ecx
  801188:	c1 e9 1b             	shr    $0x1b,%ecx
  80118b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80118e:	83 e2 1f             	and    $0x1f,%edx
  801191:	29 ca                	sub    %ecx,%edx
  801193:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801197:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80119b:	83 c0 01             	add    $0x1,%eax
  80119e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011a1:	83 c7 01             	add    $0x1,%edi
  8011a4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011a7:	75 c2                	jne    80116b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ac:	eb 05                	jmp    8011b3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	57                   	push   %edi
  8011bf:	56                   	push   %esi
  8011c0:	53                   	push   %ebx
  8011c1:	83 ec 18             	sub    $0x18,%esp
  8011c4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011c7:	57                   	push   %edi
  8011c8:	e8 35 f2 ff ff       	call   800402 <fd2data>
  8011cd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d7:	eb 3d                	jmp    801216 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011d9:	85 db                	test   %ebx,%ebx
  8011db:	74 04                	je     8011e1 <devpipe_read+0x26>
				return i;
  8011dd:	89 d8                	mov    %ebx,%eax
  8011df:	eb 44                	jmp    801225 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011e1:	89 f2                	mov    %esi,%edx
  8011e3:	89 f8                	mov    %edi,%eax
  8011e5:	e8 e5 fe ff ff       	call   8010cf <_pipeisclosed>
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	75 32                	jne    801220 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ee:	e8 4c ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011f3:	8b 06                	mov    (%esi),%eax
  8011f5:	3b 46 04             	cmp    0x4(%esi),%eax
  8011f8:	74 df                	je     8011d9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011fa:	99                   	cltd   
  8011fb:	c1 ea 1b             	shr    $0x1b,%edx
  8011fe:	01 d0                	add    %edx,%eax
  801200:	83 e0 1f             	and    $0x1f,%eax
  801203:	29 d0                	sub    %edx,%eax
  801205:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801210:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801213:	83 c3 01             	add    $0x1,%ebx
  801216:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801219:	75 d8                	jne    8011f3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80121b:	8b 45 10             	mov    0x10(%ebp),%eax
  80121e:	eb 05                	jmp    801225 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	e8 db f1 ff ff       	call   800419 <fd_alloc>
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	89 c2                	mov    %eax,%edx
  801243:	85 c0                	test   %eax,%eax
  801245:	0f 88 2c 01 00 00    	js     801377 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124b:	83 ec 04             	sub    $0x4,%esp
  80124e:	68 07 04 00 00       	push   $0x407
  801253:	ff 75 f4             	pushl  -0xc(%ebp)
  801256:	6a 00                	push   $0x0
  801258:	e8 01 ef ff ff       	call   80015e <sys_page_alloc>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	89 c2                	mov    %eax,%edx
  801262:	85 c0                	test   %eax,%eax
  801264:	0f 88 0d 01 00 00    	js     801377 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80126a:	83 ec 0c             	sub    $0xc,%esp
  80126d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	e8 a3 f1 ff ff       	call   800419 <fd_alloc>
  801276:	89 c3                	mov    %eax,%ebx
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 88 e2 00 00 00    	js     801365 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801283:	83 ec 04             	sub    $0x4,%esp
  801286:	68 07 04 00 00       	push   $0x407
  80128b:	ff 75 f0             	pushl  -0x10(%ebp)
  80128e:	6a 00                	push   $0x0
  801290:	e8 c9 ee ff ff       	call   80015e <sys_page_alloc>
  801295:	89 c3                	mov    %eax,%ebx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	0f 88 c3 00 00 00    	js     801365 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a8:	e8 55 f1 ff ff       	call   800402 <fd2data>
  8012ad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012af:	83 c4 0c             	add    $0xc,%esp
  8012b2:	68 07 04 00 00       	push   $0x407
  8012b7:	50                   	push   %eax
  8012b8:	6a 00                	push   $0x0
  8012ba:	e8 9f ee ff ff       	call   80015e <sys_page_alloc>
  8012bf:	89 c3                	mov    %eax,%ebx
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	0f 88 89 00 00 00    	js     801355 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012cc:	83 ec 0c             	sub    $0xc,%esp
  8012cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d2:	e8 2b f1 ff ff       	call   800402 <fd2data>
  8012d7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012de:	50                   	push   %eax
  8012df:	6a 00                	push   $0x0
  8012e1:	56                   	push   %esi
  8012e2:	6a 00                	push   $0x0
  8012e4:	e8 b8 ee ff ff       	call   8001a1 <sys_page_map>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	83 c4 20             	add    $0x20,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 55                	js     801347 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012f2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801300:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801307:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801312:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801315:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	ff 75 f4             	pushl  -0xc(%ebp)
  801322:	e8 cb f0 ff ff       	call   8003f2 <fd2num>
  801327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80132c:	83 c4 04             	add    $0x4,%esp
  80132f:	ff 75 f0             	pushl  -0x10(%ebp)
  801332:	e8 bb f0 ff ff       	call   8003f2 <fd2num>
  801337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	ba 00 00 00 00       	mov    $0x0,%edx
  801345:	eb 30                	jmp    801377 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	56                   	push   %esi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 91 ee ff ff       	call   8001e3 <sys_page_unmap>
  801352:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	ff 75 f0             	pushl  -0x10(%ebp)
  80135b:	6a 00                	push   $0x0
  80135d:	e8 81 ee ff ff       	call   8001e3 <sys_page_unmap>
  801362:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	ff 75 f4             	pushl  -0xc(%ebp)
  80136b:	6a 00                	push   $0x0
  80136d:	e8 71 ee ff ff       	call   8001e3 <sys_page_unmap>
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801377:	89 d0                	mov    %edx,%eax
  801379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 d6 f0 ff ff       	call   800468 <fd_lookup>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 18                	js     8013b1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	ff 75 f4             	pushl  -0xc(%ebp)
  80139f:	e8 5e f0 ff ff       	call   800402 <fd2data>
	return _pipeisclosed(fd, p);
  8013a4:	89 c2                	mov    %eax,%edx
  8013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a9:	e8 21 fd ff ff       	call   8010cf <_pipeisclosed>
  8013ae:	83 c4 10             	add    $0x10,%esp
}
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013c3:	68 f3 23 80 00       	push   $0x8023f3
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	e8 c4 07 00 00       	call   801b94 <strcpy>
	return 0;
}
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	57                   	push   %edi
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013e8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ee:	eb 2d                	jmp    80141d <devcons_write+0x46>
		m = n - tot;
  8013f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013f3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013f5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013f8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013fd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801400:	83 ec 04             	sub    $0x4,%esp
  801403:	53                   	push   %ebx
  801404:	03 45 0c             	add    0xc(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	57                   	push   %edi
  801409:	e8 18 09 00 00       	call   801d26 <memmove>
		sys_cputs(buf, m);
  80140e:	83 c4 08             	add    $0x8,%esp
  801411:	53                   	push   %ebx
  801412:	57                   	push   %edi
  801413:	e8 8a ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801418:	01 de                	add    %ebx,%esi
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	89 f0                	mov    %esi,%eax
  80141f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801422:	72 cc                	jb     8013f0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5f                   	pop    %edi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801437:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80143b:	74 2a                	je     801467 <devcons_read+0x3b>
  80143d:	eb 05                	jmp    801444 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80143f:	e8 fb ec ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801444:	e8 77 ec ff ff       	call   8000c0 <sys_cgetc>
  801449:	85 c0                	test   %eax,%eax
  80144b:	74 f2                	je     80143f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 16                	js     801467 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801451:	83 f8 04             	cmp    $0x4,%eax
  801454:	74 0c                	je     801462 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801456:	8b 55 0c             	mov    0xc(%ebp),%edx
  801459:	88 02                	mov    %al,(%edx)
	return 1;
  80145b:	b8 01 00 00 00       	mov    $0x1,%eax
  801460:	eb 05                	jmp    801467 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801475:	6a 01                	push   $0x1
  801477:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	e8 22 ec ff ff       	call   8000a2 <sys_cputs>
}
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <getchar>:

int
getchar(void)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80148b:	6a 01                	push   $0x1
  80148d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	6a 00                	push   $0x0
  801493:	e8 36 f2 ff ff       	call   8006ce <read>
	if (r < 0)
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 0f                	js     8014ae <getchar+0x29>
		return r;
	if (r < 1)
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	7e 06                	jle    8014a9 <getchar+0x24>
		return -E_EOF;
	return c;
  8014a3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014a7:	eb 05                	jmp    8014ae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014a9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	ff 75 08             	pushl  0x8(%ebp)
  8014bd:	e8 a6 ef ff ff       	call   800468 <fd_lookup>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 11                	js     8014da <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014d2:	39 10                	cmp    %edx,(%eax)
  8014d4:	0f 94 c0             	sete   %al
  8014d7:	0f b6 c0             	movzbl %al,%eax
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <opencons>:

int
opencons(void)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	e8 2e ef ff ff       	call   800419 <fd_alloc>
  8014eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ee:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 3e                	js     801532 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	68 07 04 00 00       	push   $0x407
  8014fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ff:	6a 00                	push   $0x0
  801501:	e8 58 ec ff ff       	call   80015e <sys_page_alloc>
  801506:	83 c4 10             	add    $0x10,%esp
		return r;
  801509:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 23                	js     801532 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80150f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801515:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801518:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	50                   	push   %eax
  801528:	e8 c5 ee ff ff       	call   8003f2 <fd2num>
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	83 c4 10             	add    $0x10,%esp
}
  801532:	89 d0                	mov    %edx,%eax
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80153b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80153e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801544:	e8 d7 eb ff ff       	call   800120 <sys_getenvid>
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	ff 75 0c             	pushl  0xc(%ebp)
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	56                   	push   %esi
  801553:	50                   	push   %eax
  801554:	68 00 24 80 00       	push   $0x802400
  801559:	e8 b1 00 00 00       	call   80160f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80155e:	83 c4 18             	add    $0x18,%esp
  801561:	53                   	push   %ebx
  801562:	ff 75 10             	pushl  0x10(%ebp)
  801565:	e8 54 00 00 00       	call   8015be <vcprintf>
	cprintf("\n");
  80156a:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801571:	e8 99 00 00 00       	call   80160f <cprintf>
  801576:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801579:	cc                   	int3   
  80157a:	eb fd                	jmp    801579 <_panic+0x43>

0080157c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	53                   	push   %ebx
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801586:	8b 13                	mov    (%ebx),%edx
  801588:	8d 42 01             	lea    0x1(%edx),%eax
  80158b:	89 03                	mov    %eax,(%ebx)
  80158d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801590:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801594:	3d ff 00 00 00       	cmp    $0xff,%eax
  801599:	75 1a                	jne    8015b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	68 ff 00 00 00       	push   $0xff
  8015a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8015a6:	50                   	push   %eax
  8015a7:	e8 f6 ea ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8015ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015ce:	00 00 00 
	b.cnt = 0;
  8015d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	ff 75 08             	pushl  0x8(%ebp)
  8015e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	68 7c 15 80 00       	push   $0x80157c
  8015ed:	e8 54 01 00 00       	call   801746 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	e8 9b ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801607:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801615:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801618:	50                   	push   %eax
  801619:	ff 75 08             	pushl  0x8(%ebp)
  80161c:	e8 9d ff ff ff       	call   8015be <vcprintf>
	va_end(ap);

	return cnt;
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	57                   	push   %edi
  801627:	56                   	push   %esi
  801628:	53                   	push   %ebx
  801629:	83 ec 1c             	sub    $0x1c,%esp
  80162c:	89 c7                	mov    %eax,%edi
  80162e:	89 d6                	mov    %edx,%esi
  801630:	8b 45 08             	mov    0x8(%ebp),%eax
  801633:	8b 55 0c             	mov    0xc(%ebp),%edx
  801636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801639:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80163c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80163f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801644:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801647:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80164a:	39 d3                	cmp    %edx,%ebx
  80164c:	72 05                	jb     801653 <printnum+0x30>
  80164e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801651:	77 45                	ja     801698 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	ff 75 18             	pushl  0x18(%ebp)
  801659:	8b 45 14             	mov    0x14(%ebp),%eax
  80165c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80165f:	53                   	push   %ebx
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	ff 75 e4             	pushl  -0x1c(%ebp)
  801669:	ff 75 e0             	pushl  -0x20(%ebp)
  80166c:	ff 75 dc             	pushl  -0x24(%ebp)
  80166f:	ff 75 d8             	pushl  -0x28(%ebp)
  801672:	e8 99 09 00 00       	call   802010 <__udivdi3>
  801677:	83 c4 18             	add    $0x18,%esp
  80167a:	52                   	push   %edx
  80167b:	50                   	push   %eax
  80167c:	89 f2                	mov    %esi,%edx
  80167e:	89 f8                	mov    %edi,%eax
  801680:	e8 9e ff ff ff       	call   801623 <printnum>
  801685:	83 c4 20             	add    $0x20,%esp
  801688:	eb 18                	jmp    8016a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	56                   	push   %esi
  80168e:	ff 75 18             	pushl  0x18(%ebp)
  801691:	ff d7                	call   *%edi
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	eb 03                	jmp    80169b <printnum+0x78>
  801698:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80169b:	83 eb 01             	sub    $0x1,%ebx
  80169e:	85 db                	test   %ebx,%ebx
  8016a0:	7f e8                	jg     80168a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	56                   	push   %esi
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8016af:	ff 75 dc             	pushl  -0x24(%ebp)
  8016b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8016b5:	e8 86 0a 00 00       	call   802140 <__umoddi3>
  8016ba:	83 c4 14             	add    $0x14,%esp
  8016bd:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8016c4:	50                   	push   %eax
  8016c5:	ff d7                	call   *%edi
}
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016d5:	83 fa 01             	cmp    $0x1,%edx
  8016d8:	7e 0e                	jle    8016e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016da:	8b 10                	mov    (%eax),%edx
  8016dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016df:	89 08                	mov    %ecx,(%eax)
  8016e1:	8b 02                	mov    (%edx),%eax
  8016e3:	8b 52 04             	mov    0x4(%edx),%edx
  8016e6:	eb 22                	jmp    80170a <getuint+0x38>
	else if (lflag)
  8016e8:	85 d2                	test   %edx,%edx
  8016ea:	74 10                	je     8016fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016ec:	8b 10                	mov    (%eax),%edx
  8016ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f1:	89 08                	mov    %ecx,(%eax)
  8016f3:	8b 02                	mov    (%edx),%eax
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	eb 0e                	jmp    80170a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016fc:	8b 10                	mov    (%eax),%edx
  8016fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  801701:	89 08                	mov    %ecx,(%eax)
  801703:	8b 02                	mov    (%edx),%eax
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801712:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801716:	8b 10                	mov    (%eax),%edx
  801718:	3b 50 04             	cmp    0x4(%eax),%edx
  80171b:	73 0a                	jae    801727 <sprintputch+0x1b>
		*b->buf++ = ch;
  80171d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801720:	89 08                	mov    %ecx,(%eax)
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	88 02                	mov    %al,(%edx)
}
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80172f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801732:	50                   	push   %eax
  801733:	ff 75 10             	pushl  0x10(%ebp)
  801736:	ff 75 0c             	pushl  0xc(%ebp)
  801739:	ff 75 08             	pushl  0x8(%ebp)
  80173c:	e8 05 00 00 00       	call   801746 <vprintfmt>
	va_end(ap);
}
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	57                   	push   %edi
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	83 ec 2c             	sub    $0x2c,%esp
  80174f:	8b 75 08             	mov    0x8(%ebp),%esi
  801752:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801755:	8b 7d 10             	mov    0x10(%ebp),%edi
  801758:	eb 12                	jmp    80176c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80175a:	85 c0                	test   %eax,%eax
  80175c:	0f 84 89 03 00 00    	je     801aeb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	53                   	push   %ebx
  801766:	50                   	push   %eax
  801767:	ff d6                	call   *%esi
  801769:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80176c:	83 c7 01             	add    $0x1,%edi
  80176f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801773:	83 f8 25             	cmp    $0x25,%eax
  801776:	75 e2                	jne    80175a <vprintfmt+0x14>
  801778:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80177c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801783:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80178a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	eb 07                	jmp    80179f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801798:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80179b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179f:	8d 47 01             	lea    0x1(%edi),%eax
  8017a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017a5:	0f b6 07             	movzbl (%edi),%eax
  8017a8:	0f b6 c8             	movzbl %al,%ecx
  8017ab:	83 e8 23             	sub    $0x23,%eax
  8017ae:	3c 55                	cmp    $0x55,%al
  8017b0:	0f 87 1a 03 00 00    	ja     801ad0 <vprintfmt+0x38a>
  8017b6:	0f b6 c0             	movzbl %al,%eax
  8017b9:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8017c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017c7:	eb d6                	jmp    80179f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017e1:	83 fa 09             	cmp    $0x9,%edx
  8017e4:	77 39                	ja     80181f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017e9:	eb e9                	jmp    8017d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8017f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017f4:	8b 00                	mov    (%eax),%eax
  8017f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017fc:	eb 27                	jmp    801825 <vprintfmt+0xdf>
  8017fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801801:	85 c0                	test   %eax,%eax
  801803:	b9 00 00 00 00       	mov    $0x0,%ecx
  801808:	0f 49 c8             	cmovns %eax,%ecx
  80180b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801811:	eb 8c                	jmp    80179f <vprintfmt+0x59>
  801813:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801816:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80181d:	eb 80                	jmp    80179f <vprintfmt+0x59>
  80181f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801822:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801825:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801829:	0f 89 70 ff ff ff    	jns    80179f <vprintfmt+0x59>
				width = precision, precision = -1;
  80182f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801832:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801835:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80183c:	e9 5e ff ff ff       	jmp    80179f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801841:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801844:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801847:	e9 53 ff ff ff       	jmp    80179f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80184c:	8b 45 14             	mov    0x14(%ebp),%eax
  80184f:	8d 50 04             	lea    0x4(%eax),%edx
  801852:	89 55 14             	mov    %edx,0x14(%ebp)
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	53                   	push   %ebx
  801859:	ff 30                	pushl  (%eax)
  80185b:	ff d6                	call   *%esi
			break;
  80185d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801860:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801863:	e9 04 ff ff ff       	jmp    80176c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801868:	8b 45 14             	mov    0x14(%ebp),%eax
  80186b:	8d 50 04             	lea    0x4(%eax),%edx
  80186e:	89 55 14             	mov    %edx,0x14(%ebp)
  801871:	8b 00                	mov    (%eax),%eax
  801873:	99                   	cltd   
  801874:	31 d0                	xor    %edx,%eax
  801876:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801878:	83 f8 0f             	cmp    $0xf,%eax
  80187b:	7f 0b                	jg     801888 <vprintfmt+0x142>
  80187d:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801884:	85 d2                	test   %edx,%edx
  801886:	75 18                	jne    8018a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801888:	50                   	push   %eax
  801889:	68 3b 24 80 00       	push   $0x80243b
  80188e:	53                   	push   %ebx
  80188f:	56                   	push   %esi
  801890:	e8 94 fe ff ff       	call   801729 <printfmt>
  801895:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80189b:	e9 cc fe ff ff       	jmp    80176c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018a0:	52                   	push   %edx
  8018a1:	68 81 23 80 00       	push   $0x802381
  8018a6:	53                   	push   %ebx
  8018a7:	56                   	push   %esi
  8018a8:	e8 7c fe ff ff       	call   801729 <printfmt>
  8018ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b3:	e9 b4 fe ff ff       	jmp    80176c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bb:	8d 50 04             	lea    0x4(%eax),%edx
  8018be:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018c3:	85 ff                	test   %edi,%edi
  8018c5:	b8 34 24 80 00       	mov    $0x802434,%eax
  8018ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018d1:	0f 8e 94 00 00 00    	jle    80196b <vprintfmt+0x225>
  8018d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018db:	0f 84 98 00 00 00    	je     801979 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8018e7:	57                   	push   %edi
  8018e8:	e8 86 02 00 00       	call   801b73 <strnlen>
  8018ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018f0:	29 c1                	sub    %eax,%ecx
  8018f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801902:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801904:	eb 0f                	jmp    801915 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	53                   	push   %ebx
  80190a:	ff 75 e0             	pushl  -0x20(%ebp)
  80190d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80190f:	83 ef 01             	sub    $0x1,%edi
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	85 ff                	test   %edi,%edi
  801917:	7f ed                	jg     801906 <vprintfmt+0x1c0>
  801919:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80191c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80191f:	85 c9                	test   %ecx,%ecx
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
  801926:	0f 49 c1             	cmovns %ecx,%eax
  801929:	29 c1                	sub    %eax,%ecx
  80192b:	89 75 08             	mov    %esi,0x8(%ebp)
  80192e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801931:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801934:	89 cb                	mov    %ecx,%ebx
  801936:	eb 4d                	jmp    801985 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801938:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80193c:	74 1b                	je     801959 <vprintfmt+0x213>
  80193e:	0f be c0             	movsbl %al,%eax
  801941:	83 e8 20             	sub    $0x20,%eax
  801944:	83 f8 5e             	cmp    $0x5e,%eax
  801947:	76 10                	jbe    801959 <vprintfmt+0x213>
					putch('?', putdat);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	6a 3f                	push   $0x3f
  801951:	ff 55 08             	call   *0x8(%ebp)
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	eb 0d                	jmp    801966 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	ff 75 0c             	pushl  0xc(%ebp)
  80195f:	52                   	push   %edx
  801960:	ff 55 08             	call   *0x8(%ebp)
  801963:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801966:	83 eb 01             	sub    $0x1,%ebx
  801969:	eb 1a                	jmp    801985 <vprintfmt+0x23f>
  80196b:	89 75 08             	mov    %esi,0x8(%ebp)
  80196e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801971:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801974:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801977:	eb 0c                	jmp    801985 <vprintfmt+0x23f>
  801979:	89 75 08             	mov    %esi,0x8(%ebp)
  80197c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80197f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801982:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801985:	83 c7 01             	add    $0x1,%edi
  801988:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80198c:	0f be d0             	movsbl %al,%edx
  80198f:	85 d2                	test   %edx,%edx
  801991:	74 23                	je     8019b6 <vprintfmt+0x270>
  801993:	85 f6                	test   %esi,%esi
  801995:	78 a1                	js     801938 <vprintfmt+0x1f2>
  801997:	83 ee 01             	sub    $0x1,%esi
  80199a:	79 9c                	jns    801938 <vprintfmt+0x1f2>
  80199c:	89 df                	mov    %ebx,%edi
  80199e:	8b 75 08             	mov    0x8(%ebp),%esi
  8019a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019a4:	eb 18                	jmp    8019be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	53                   	push   %ebx
  8019aa:	6a 20                	push   $0x20
  8019ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019ae:	83 ef 01             	sub    $0x1,%edi
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	eb 08                	jmp    8019be <vprintfmt+0x278>
  8019b6:	89 df                	mov    %ebx,%edi
  8019b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8019bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019be:	85 ff                	test   %edi,%edi
  8019c0:	7f e4                	jg     8019a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019c5:	e9 a2 fd ff ff       	jmp    80176c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019ca:	83 fa 01             	cmp    $0x1,%edx
  8019cd:	7e 16                	jle    8019e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d2:	8d 50 08             	lea    0x8(%eax),%edx
  8019d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d8:	8b 50 04             	mov    0x4(%eax),%edx
  8019db:	8b 00                	mov    (%eax),%eax
  8019dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019e3:	eb 32                	jmp    801a17 <vprintfmt+0x2d1>
	else if (lflag)
  8019e5:	85 d2                	test   %edx,%edx
  8019e7:	74 18                	je     801a01 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ec:	8d 50 04             	lea    0x4(%eax),%edx
  8019ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8019f2:	8b 00                	mov    (%eax),%eax
  8019f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019f7:	89 c1                	mov    %eax,%ecx
  8019f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8019fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019ff:	eb 16                	jmp    801a17 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a01:	8b 45 14             	mov    0x14(%ebp),%eax
  801a04:	8d 50 04             	lea    0x4(%eax),%edx
  801a07:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0a:	8b 00                	mov    (%eax),%eax
  801a0c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a0f:	89 c1                	mov    %eax,%ecx
  801a11:	c1 f9 1f             	sar    $0x1f,%ecx
  801a14:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a17:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a1d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a22:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a26:	79 74                	jns    801a9c <vprintfmt+0x356>
				putch('-', putdat);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	53                   	push   %ebx
  801a2c:	6a 2d                	push   $0x2d
  801a2e:	ff d6                	call   *%esi
				num = -(long long) num;
  801a30:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a33:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a36:	f7 d8                	neg    %eax
  801a38:	83 d2 00             	adc    $0x0,%edx
  801a3b:	f7 da                	neg    %edx
  801a3d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a40:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a45:	eb 55                	jmp    801a9c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a47:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4a:	e8 83 fc ff ff       	call   8016d2 <getuint>
			base = 10;
  801a4f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a54:	eb 46                	jmp    801a9c <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a56:	8d 45 14             	lea    0x14(%ebp),%eax
  801a59:	e8 74 fc ff ff       	call   8016d2 <getuint>
			base = 8;
  801a5e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a63:	eb 37                	jmp    801a9c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	53                   	push   %ebx
  801a69:	6a 30                	push   $0x30
  801a6b:	ff d6                	call   *%esi
			putch('x', putdat);
  801a6d:	83 c4 08             	add    $0x8,%esp
  801a70:	53                   	push   %ebx
  801a71:	6a 78                	push   $0x78
  801a73:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a75:	8b 45 14             	mov    0x14(%ebp),%eax
  801a78:	8d 50 04             	lea    0x4(%eax),%edx
  801a7b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a7e:	8b 00                	mov    (%eax),%eax
  801a80:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a85:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a88:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a8d:	eb 0d                	jmp    801a9c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a8f:	8d 45 14             	lea    0x14(%ebp),%eax
  801a92:	e8 3b fc ff ff       	call   8016d2 <getuint>
			base = 16;
  801a97:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aa3:	57                   	push   %edi
  801aa4:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa7:	51                   	push   %ecx
  801aa8:	52                   	push   %edx
  801aa9:	50                   	push   %eax
  801aaa:	89 da                	mov    %ebx,%edx
  801aac:	89 f0                	mov    %esi,%eax
  801aae:	e8 70 fb ff ff       	call   801623 <printnum>
			break;
  801ab3:	83 c4 20             	add    $0x20,%esp
  801ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ab9:	e9 ae fc ff ff       	jmp    80176c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	53                   	push   %ebx
  801ac2:	51                   	push   %ecx
  801ac3:	ff d6                	call   *%esi
			break;
  801ac5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801acb:	e9 9c fc ff ff       	jmp    80176c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ad0:	83 ec 08             	sub    $0x8,%esp
  801ad3:	53                   	push   %ebx
  801ad4:	6a 25                	push   $0x25
  801ad6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	eb 03                	jmp    801ae0 <vprintfmt+0x39a>
  801add:	83 ef 01             	sub    $0x1,%edi
  801ae0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ae4:	75 f7                	jne    801add <vprintfmt+0x397>
  801ae6:	e9 81 fc ff ff       	jmp    80176c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5f                   	pop    %edi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 18             	sub    $0x18,%esp
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b02:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b06:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b10:	85 c0                	test   %eax,%eax
  801b12:	74 26                	je     801b3a <vsnprintf+0x47>
  801b14:	85 d2                	test   %edx,%edx
  801b16:	7e 22                	jle    801b3a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b18:	ff 75 14             	pushl  0x14(%ebp)
  801b1b:	ff 75 10             	pushl  0x10(%ebp)
  801b1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b21:	50                   	push   %eax
  801b22:	68 0c 17 80 00       	push   $0x80170c
  801b27:	e8 1a fc ff ff       	call   801746 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b2f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	eb 05                	jmp    801b3f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b47:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b4a:	50                   	push   %eax
  801b4b:	ff 75 10             	pushl  0x10(%ebp)
  801b4e:	ff 75 0c             	pushl  0xc(%ebp)
  801b51:	ff 75 08             	pushl  0x8(%ebp)
  801b54:	e8 9a ff ff ff       	call   801af3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
  801b66:	eb 03                	jmp    801b6b <strlen+0x10>
		n++;
  801b68:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b6b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b6f:	75 f7                	jne    801b68 <strlen+0xd>
		n++;
	return n;
}
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b79:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b81:	eb 03                	jmp    801b86 <strnlen+0x13>
		n++;
  801b83:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b86:	39 c2                	cmp    %eax,%edx
  801b88:	74 08                	je     801b92 <strnlen+0x1f>
  801b8a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b8e:	75 f3                	jne    801b83 <strnlen+0x10>
  801b90:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	53                   	push   %ebx
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	83 c2 01             	add    $0x1,%edx
  801ba3:	83 c1 01             	add    $0x1,%ecx
  801ba6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801baa:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bad:	84 db                	test   %bl,%bl
  801baf:	75 ef                	jne    801ba0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bb1:	5b                   	pop    %ebx
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	53                   	push   %ebx
  801bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bbb:	53                   	push   %ebx
  801bbc:	e8 9a ff ff ff       	call   801b5b <strlen>
  801bc1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	01 d8                	add    %ebx,%eax
  801bc9:	50                   	push   %eax
  801bca:	e8 c5 ff ff ff       	call   801b94 <strcpy>
	return dst;
}
  801bcf:	89 d8                	mov    %ebx,%eax
  801bd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be1:	89 f3                	mov    %esi,%ebx
  801be3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801be6:	89 f2                	mov    %esi,%edx
  801be8:	eb 0f                	jmp    801bf9 <strncpy+0x23>
		*dst++ = *src;
  801bea:	83 c2 01             	add    $0x1,%edx
  801bed:	0f b6 01             	movzbl (%ecx),%eax
  801bf0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bf3:	80 39 01             	cmpb   $0x1,(%ecx)
  801bf6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bf9:	39 da                	cmp    %ebx,%edx
  801bfb:	75 ed                	jne    801bea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bfd:	89 f0                	mov    %esi,%eax
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0e:	8b 55 10             	mov    0x10(%ebp),%edx
  801c11:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c13:	85 d2                	test   %edx,%edx
  801c15:	74 21                	je     801c38 <strlcpy+0x35>
  801c17:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	eb 09                	jmp    801c28 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c1f:	83 c2 01             	add    $0x1,%edx
  801c22:	83 c1 01             	add    $0x1,%ecx
  801c25:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c28:	39 c2                	cmp    %eax,%edx
  801c2a:	74 09                	je     801c35 <strlcpy+0x32>
  801c2c:	0f b6 19             	movzbl (%ecx),%ebx
  801c2f:	84 db                	test   %bl,%bl
  801c31:	75 ec                	jne    801c1f <strlcpy+0x1c>
  801c33:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c35:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c38:	29 f0                	sub    %esi,%eax
}
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c44:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c47:	eb 06                	jmp    801c4f <strcmp+0x11>
		p++, q++;
  801c49:	83 c1 01             	add    $0x1,%ecx
  801c4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c4f:	0f b6 01             	movzbl (%ecx),%eax
  801c52:	84 c0                	test   %al,%al
  801c54:	74 04                	je     801c5a <strcmp+0x1c>
  801c56:	3a 02                	cmp    (%edx),%al
  801c58:	74 ef                	je     801c49 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c5a:	0f b6 c0             	movzbl %al,%eax
  801c5d:	0f b6 12             	movzbl (%edx),%edx
  801c60:	29 d0                	sub    %edx,%eax
}
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	53                   	push   %ebx
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6e:	89 c3                	mov    %eax,%ebx
  801c70:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c73:	eb 06                	jmp    801c7b <strncmp+0x17>
		n--, p++, q++;
  801c75:	83 c0 01             	add    $0x1,%eax
  801c78:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c7b:	39 d8                	cmp    %ebx,%eax
  801c7d:	74 15                	je     801c94 <strncmp+0x30>
  801c7f:	0f b6 08             	movzbl (%eax),%ecx
  801c82:	84 c9                	test   %cl,%cl
  801c84:	74 04                	je     801c8a <strncmp+0x26>
  801c86:	3a 0a                	cmp    (%edx),%cl
  801c88:	74 eb                	je     801c75 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c8a:	0f b6 00             	movzbl (%eax),%eax
  801c8d:	0f b6 12             	movzbl (%edx),%edx
  801c90:	29 d0                	sub    %edx,%eax
  801c92:	eb 05                	jmp    801c99 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c99:	5b                   	pop    %ebx
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca6:	eb 07                	jmp    801caf <strchr+0x13>
		if (*s == c)
  801ca8:	38 ca                	cmp    %cl,%dl
  801caa:	74 0f                	je     801cbb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cac:	83 c0 01             	add    $0x1,%eax
  801caf:	0f b6 10             	movzbl (%eax),%edx
  801cb2:	84 d2                	test   %dl,%dl
  801cb4:	75 f2                	jne    801ca8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc7:	eb 03                	jmp    801ccc <strfind+0xf>
  801cc9:	83 c0 01             	add    $0x1,%eax
  801ccc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ccf:	38 ca                	cmp    %cl,%dl
  801cd1:	74 04                	je     801cd7 <strfind+0x1a>
  801cd3:	84 d2                	test   %dl,%dl
  801cd5:	75 f2                	jne    801cc9 <strfind+0xc>
			break;
	return (char *) s;
}
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	57                   	push   %edi
  801cdd:	56                   	push   %esi
  801cde:	53                   	push   %ebx
  801cdf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ce2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ce5:	85 c9                	test   %ecx,%ecx
  801ce7:	74 36                	je     801d1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ce9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cef:	75 28                	jne    801d19 <memset+0x40>
  801cf1:	f6 c1 03             	test   $0x3,%cl
  801cf4:	75 23                	jne    801d19 <memset+0x40>
		c &= 0xFF;
  801cf6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cfa:	89 d3                	mov    %edx,%ebx
  801cfc:	c1 e3 08             	shl    $0x8,%ebx
  801cff:	89 d6                	mov    %edx,%esi
  801d01:	c1 e6 18             	shl    $0x18,%esi
  801d04:	89 d0                	mov    %edx,%eax
  801d06:	c1 e0 10             	shl    $0x10,%eax
  801d09:	09 f0                	or     %esi,%eax
  801d0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d0d:	89 d8                	mov    %ebx,%eax
  801d0f:	09 d0                	or     %edx,%eax
  801d11:	c1 e9 02             	shr    $0x2,%ecx
  801d14:	fc                   	cld    
  801d15:	f3 ab                	rep stos %eax,%es:(%edi)
  801d17:	eb 06                	jmp    801d1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1c:	fc                   	cld    
  801d1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d1f:	89 f8                	mov    %edi,%eax
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	57                   	push   %edi
  801d2a:	56                   	push   %esi
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d34:	39 c6                	cmp    %eax,%esi
  801d36:	73 35                	jae    801d6d <memmove+0x47>
  801d38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d3b:	39 d0                	cmp    %edx,%eax
  801d3d:	73 2e                	jae    801d6d <memmove+0x47>
		s += n;
		d += n;
  801d3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d42:	89 d6                	mov    %edx,%esi
  801d44:	09 fe                	or     %edi,%esi
  801d46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d4c:	75 13                	jne    801d61 <memmove+0x3b>
  801d4e:	f6 c1 03             	test   $0x3,%cl
  801d51:	75 0e                	jne    801d61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d53:	83 ef 04             	sub    $0x4,%edi
  801d56:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d59:	c1 e9 02             	shr    $0x2,%ecx
  801d5c:	fd                   	std    
  801d5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5f:	eb 09                	jmp    801d6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d61:	83 ef 01             	sub    $0x1,%edi
  801d64:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d67:	fd                   	std    
  801d68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d6a:	fc                   	cld    
  801d6b:	eb 1d                	jmp    801d8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d6d:	89 f2                	mov    %esi,%edx
  801d6f:	09 c2                	or     %eax,%edx
  801d71:	f6 c2 03             	test   $0x3,%dl
  801d74:	75 0f                	jne    801d85 <memmove+0x5f>
  801d76:	f6 c1 03             	test   $0x3,%cl
  801d79:	75 0a                	jne    801d85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d7b:	c1 e9 02             	shr    $0x2,%ecx
  801d7e:	89 c7                	mov    %eax,%edi
  801d80:	fc                   	cld    
  801d81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d83:	eb 05                	jmp    801d8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d85:	89 c7                	mov    %eax,%edi
  801d87:	fc                   	cld    
  801d88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d91:	ff 75 10             	pushl  0x10(%ebp)
  801d94:	ff 75 0c             	pushl  0xc(%ebp)
  801d97:	ff 75 08             	pushl  0x8(%ebp)
  801d9a:	e8 87 ff ff ff       	call   801d26 <memmove>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	56                   	push   %esi
  801da5:	53                   	push   %ebx
  801da6:	8b 45 08             	mov    0x8(%ebp),%eax
  801da9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dac:	89 c6                	mov    %eax,%esi
  801dae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801db1:	eb 1a                	jmp    801dcd <memcmp+0x2c>
		if (*s1 != *s2)
  801db3:	0f b6 08             	movzbl (%eax),%ecx
  801db6:	0f b6 1a             	movzbl (%edx),%ebx
  801db9:	38 d9                	cmp    %bl,%cl
  801dbb:	74 0a                	je     801dc7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dbd:	0f b6 c1             	movzbl %cl,%eax
  801dc0:	0f b6 db             	movzbl %bl,%ebx
  801dc3:	29 d8                	sub    %ebx,%eax
  801dc5:	eb 0f                	jmp    801dd6 <memcmp+0x35>
		s1++, s2++;
  801dc7:	83 c0 01             	add    $0x1,%eax
  801dca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dcd:	39 f0                	cmp    %esi,%eax
  801dcf:	75 e2                	jne    801db3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd6:	5b                   	pop    %ebx
  801dd7:	5e                   	pop    %esi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    

00801dda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	53                   	push   %ebx
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801de1:	89 c1                	mov    %eax,%ecx
  801de3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801de6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dea:	eb 0a                	jmp    801df6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dec:	0f b6 10             	movzbl (%eax),%edx
  801def:	39 da                	cmp    %ebx,%edx
  801df1:	74 07                	je     801dfa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801df3:	83 c0 01             	add    $0x1,%eax
  801df6:	39 c8                	cmp    %ecx,%eax
  801df8:	72 f2                	jb     801dec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dfa:	5b                   	pop    %ebx
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e09:	eb 03                	jmp    801e0e <strtol+0x11>
		s++;
  801e0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e0e:	0f b6 01             	movzbl (%ecx),%eax
  801e11:	3c 20                	cmp    $0x20,%al
  801e13:	74 f6                	je     801e0b <strtol+0xe>
  801e15:	3c 09                	cmp    $0x9,%al
  801e17:	74 f2                	je     801e0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e19:	3c 2b                	cmp    $0x2b,%al
  801e1b:	75 0a                	jne    801e27 <strtol+0x2a>
		s++;
  801e1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e20:	bf 00 00 00 00       	mov    $0x0,%edi
  801e25:	eb 11                	jmp    801e38 <strtol+0x3b>
  801e27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e2c:	3c 2d                	cmp    $0x2d,%al
  801e2e:	75 08                	jne    801e38 <strtol+0x3b>
		s++, neg = 1;
  801e30:	83 c1 01             	add    $0x1,%ecx
  801e33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e3e:	75 15                	jne    801e55 <strtol+0x58>
  801e40:	80 39 30             	cmpb   $0x30,(%ecx)
  801e43:	75 10                	jne    801e55 <strtol+0x58>
  801e45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e49:	75 7c                	jne    801ec7 <strtol+0xca>
		s += 2, base = 16;
  801e4b:	83 c1 02             	add    $0x2,%ecx
  801e4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e53:	eb 16                	jmp    801e6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e55:	85 db                	test   %ebx,%ebx
  801e57:	75 12                	jne    801e6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e5e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e61:	75 08                	jne    801e6b <strtol+0x6e>
		s++, base = 8;
  801e63:	83 c1 01             	add    $0x1,%ecx
  801e66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e73:	0f b6 11             	movzbl (%ecx),%edx
  801e76:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e79:	89 f3                	mov    %esi,%ebx
  801e7b:	80 fb 09             	cmp    $0x9,%bl
  801e7e:	77 08                	ja     801e88 <strtol+0x8b>
			dig = *s - '0';
  801e80:	0f be d2             	movsbl %dl,%edx
  801e83:	83 ea 30             	sub    $0x30,%edx
  801e86:	eb 22                	jmp    801eaa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e88:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e8b:	89 f3                	mov    %esi,%ebx
  801e8d:	80 fb 19             	cmp    $0x19,%bl
  801e90:	77 08                	ja     801e9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e92:	0f be d2             	movsbl %dl,%edx
  801e95:	83 ea 57             	sub    $0x57,%edx
  801e98:	eb 10                	jmp    801eaa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e9d:	89 f3                	mov    %esi,%ebx
  801e9f:	80 fb 19             	cmp    $0x19,%bl
  801ea2:	77 16                	ja     801eba <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ea4:	0f be d2             	movsbl %dl,%edx
  801ea7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eaa:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ead:	7d 0b                	jge    801eba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801eaf:	83 c1 01             	add    $0x1,%ecx
  801eb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eb8:	eb b9                	jmp    801e73 <strtol+0x76>

	if (endptr)
  801eba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ebe:	74 0d                	je     801ecd <strtol+0xd0>
		*endptr = (char *) s;
  801ec0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec3:	89 0e                	mov    %ecx,(%esi)
  801ec5:	eb 06                	jmp    801ecd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ec7:	85 db                	test   %ebx,%ebx
  801ec9:	74 98                	je     801e63 <strtol+0x66>
  801ecb:	eb 9e                	jmp    801e6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ecd:	89 c2                	mov    %eax,%edx
  801ecf:	f7 da                	neg    %edx
  801ed1:	85 ff                	test   %edi,%edi
  801ed3:	0f 45 c2             	cmovne %edx,%eax
}
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5f                   	pop    %edi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ee9:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801eeb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ef0:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ef3:	83 ec 0c             	sub    $0xc,%esp
  801ef6:	50                   	push   %eax
  801ef7:	e8 12 e4 ff ff       	call   80030e <sys_ipc_recv>

	if (from_env_store != NULL)
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 f6                	test   %esi,%esi
  801f01:	74 14                	je     801f17 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f03:	ba 00 00 00 00       	mov    $0x0,%edx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 09                	js     801f15 <ipc_recv+0x3a>
  801f0c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f12:	8b 52 74             	mov    0x74(%edx),%edx
  801f15:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f17:	85 db                	test   %ebx,%ebx
  801f19:	74 14                	je     801f2f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 09                	js     801f2d <ipc_recv+0x52>
  801f24:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f2a:	8b 52 78             	mov    0x78(%edx),%edx
  801f2d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 08                	js     801f3b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f33:	a1 08 40 80 00       	mov    0x804008,%eax
  801f38:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3e:	5b                   	pop    %ebx
  801f3f:	5e                   	pop    %esi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 0c             	sub    $0xc,%esp
  801f4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f54:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f56:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f5b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f5e:	ff 75 14             	pushl  0x14(%ebp)
  801f61:	53                   	push   %ebx
  801f62:	56                   	push   %esi
  801f63:	57                   	push   %edi
  801f64:	e8 82 e3 ff ff       	call   8002eb <sys_ipc_try_send>

		if (err < 0) {
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	79 1e                	jns    801f8e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f70:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f73:	75 07                	jne    801f7c <ipc_send+0x3a>
				sys_yield();
  801f75:	e8 c5 e1 ff ff       	call   80013f <sys_yield>
  801f7a:	eb e2                	jmp    801f5e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f7c:	50                   	push   %eax
  801f7d:	68 20 27 80 00       	push   $0x802720
  801f82:	6a 49                	push   $0x49
  801f84:	68 2d 27 80 00       	push   $0x80272d
  801f89:	e8 a8 f5 ff ff       	call   801536 <_panic>
		}

	} while (err < 0);

}
  801f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5f                   	pop    %edi
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fa4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801faa:	8b 52 50             	mov    0x50(%edx),%edx
  801fad:	39 ca                	cmp    %ecx,%edx
  801faf:	75 0d                	jne    801fbe <ipc_find_env+0x28>
			return envs[i].env_id;
  801fb1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb9:	8b 40 48             	mov    0x48(%eax),%eax
  801fbc:	eb 0f                	jmp    801fcd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fbe:	83 c0 01             	add    $0x1,%eax
  801fc1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fc6:	75 d9                	jne    801fa1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd5:	89 d0                	mov    %edx,%eax
  801fd7:	c1 e8 16             	shr    $0x16,%eax
  801fda:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe6:	f6 c1 01             	test   $0x1,%cl
  801fe9:	74 1d                	je     802008 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801feb:	c1 ea 0c             	shr    $0xc,%edx
  801fee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ff5:	f6 c2 01             	test   $0x1,%dl
  801ff8:	74 0e                	je     802008 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ffa:	c1 ea 0c             	shr    $0xc,%edx
  801ffd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802004:	ef 
  802005:	0f b7 c0             	movzwl %ax,%eax
}
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__udivdi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80201b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80201f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 f6                	test   %esi,%esi
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 ca                	mov    %ecx,%edx
  80202f:	89 f8                	mov    %edi,%eax
  802031:	75 3d                	jne    802070 <__udivdi3+0x60>
  802033:	39 cf                	cmp    %ecx,%edi
  802035:	0f 87 c5 00 00 00    	ja     802100 <__udivdi3+0xf0>
  80203b:	85 ff                	test   %edi,%edi
  80203d:	89 fd                	mov    %edi,%ebp
  80203f:	75 0b                	jne    80204c <__udivdi3+0x3c>
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	31 d2                	xor    %edx,%edx
  802048:	f7 f7                	div    %edi
  80204a:	89 c5                	mov    %eax,%ebp
  80204c:	89 c8                	mov    %ecx,%eax
  80204e:	31 d2                	xor    %edx,%edx
  802050:	f7 f5                	div    %ebp
  802052:	89 c1                	mov    %eax,%ecx
  802054:	89 d8                	mov    %ebx,%eax
  802056:	89 cf                	mov    %ecx,%edi
  802058:	f7 f5                	div    %ebp
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	39 ce                	cmp    %ecx,%esi
  802072:	77 74                	ja     8020e8 <__udivdi3+0xd8>
  802074:	0f bd fe             	bsr    %esi,%edi
  802077:	83 f7 1f             	xor    $0x1f,%edi
  80207a:	0f 84 98 00 00 00    	je     802118 <__udivdi3+0x108>
  802080:	bb 20 00 00 00       	mov    $0x20,%ebx
  802085:	89 f9                	mov    %edi,%ecx
  802087:	89 c5                	mov    %eax,%ebp
  802089:	29 fb                	sub    %edi,%ebx
  80208b:	d3 e6                	shl    %cl,%esi
  80208d:	89 d9                	mov    %ebx,%ecx
  80208f:	d3 ed                	shr    %cl,%ebp
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e0                	shl    %cl,%eax
  802095:	09 ee                	or     %ebp,%esi
  802097:	89 d9                	mov    %ebx,%ecx
  802099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209d:	89 d5                	mov    %edx,%ebp
  80209f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020a3:	d3 ed                	shr    %cl,%ebp
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e2                	shl    %cl,%edx
  8020a9:	89 d9                	mov    %ebx,%ecx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	09 c2                	or     %eax,%edx
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	89 ea                	mov    %ebp,%edx
  8020b3:	f7 f6                	div    %esi
  8020b5:	89 d5                	mov    %edx,%ebp
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	f7 64 24 0c          	mull   0xc(%esp)
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	72 10                	jb     8020d1 <__udivdi3+0xc1>
  8020c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e6                	shl    %cl,%esi
  8020c9:	39 c6                	cmp    %eax,%esi
  8020cb:	73 07                	jae    8020d4 <__udivdi3+0xc4>
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	75 03                	jne    8020d4 <__udivdi3+0xc4>
  8020d1:	83 eb 01             	sub    $0x1,%ebx
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	31 ff                	xor    %edi,%edi
  8020ea:	31 db                	xor    %ebx,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	f7 f7                	div    %edi
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 c3                	mov    %eax,%ebx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 fa                	mov    %edi,%edx
  80210c:	83 c4 1c             	add    $0x1c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	72 0c                	jb     802128 <__udivdi3+0x118>
  80211c:	31 db                	xor    %ebx,%ebx
  80211e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802122:	0f 87 34 ff ff ff    	ja     80205c <__udivdi3+0x4c>
  802128:	bb 01 00 00 00       	mov    $0x1,%ebx
  80212d:	e9 2a ff ff ff       	jmp    80205c <__udivdi3+0x4c>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80214b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80214f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 d2                	test   %edx,%edx
  802159:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f3                	mov    %esi,%ebx
  802163:	89 3c 24             	mov    %edi,(%esp)
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	75 1c                	jne    802188 <__umoddi3+0x48>
  80216c:	39 f7                	cmp    %esi,%edi
  80216e:	76 50                	jbe    8021c0 <__umoddi3+0x80>
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	f7 f7                	div    %edi
  802176:	89 d0                	mov    %edx,%eax
  802178:	31 d2                	xor    %edx,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	77 52                	ja     8021e0 <__umoddi3+0xa0>
  80218e:	0f bd ea             	bsr    %edx,%ebp
  802191:	83 f5 1f             	xor    $0x1f,%ebp
  802194:	75 5a                	jne    8021f0 <__umoddi3+0xb0>
  802196:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80219a:	0f 82 e0 00 00 00    	jb     802280 <__umoddi3+0x140>
  8021a0:	39 0c 24             	cmp    %ecx,(%esp)
  8021a3:	0f 86 d7 00 00 00    	jbe    802280 <__umoddi3+0x140>
  8021a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	89 fd                	mov    %edi,%ebp
  8021c4:	75 0b                	jne    8021d1 <__umoddi3+0x91>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f7                	div    %edi
  8021cf:	89 c5                	mov    %eax,%ebp
  8021d1:	89 f0                	mov    %esi,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f5                	div    %ebp
  8021d7:	89 c8                	mov    %ecx,%eax
  8021d9:	f7 f5                	div    %ebp
  8021db:	89 d0                	mov    %edx,%eax
  8021dd:	eb 99                	jmp    802178 <__umoddi3+0x38>
  8021df:	90                   	nop
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 1c             	add    $0x1c,%esp
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5f                   	pop    %edi
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	8b 34 24             	mov    (%esp),%esi
  8021f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	29 ef                	sub    %ebp,%edi
  8021fc:	d3 e0                	shl    %cl,%eax
  8021fe:	89 f9                	mov    %edi,%ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	d3 ea                	shr    %cl,%edx
  802204:	89 e9                	mov    %ebp,%ecx
  802206:	09 c2                	or     %eax,%edx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 14 24             	mov    %edx,(%esp)
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	d3 e2                	shl    %cl,%edx
  802211:	89 f9                	mov    %edi,%ecx
  802213:	89 54 24 04          	mov    %edx,0x4(%esp)
  802217:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	d3 e3                	shl    %cl,%ebx
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 d0                	mov    %edx,%eax
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	09 d8                	or     %ebx,%eax
  80222d:	89 d3                	mov    %edx,%ebx
  80222f:	89 f2                	mov    %esi,%edx
  802231:	f7 34 24             	divl   (%esp)
  802234:	89 d6                	mov    %edx,%esi
  802236:	d3 e3                	shl    %cl,%ebx
  802238:	f7 64 24 04          	mull   0x4(%esp)
  80223c:	39 d6                	cmp    %edx,%esi
  80223e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802242:	89 d1                	mov    %edx,%ecx
  802244:	89 c3                	mov    %eax,%ebx
  802246:	72 08                	jb     802250 <__umoddi3+0x110>
  802248:	75 11                	jne    80225b <__umoddi3+0x11b>
  80224a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80224e:	73 0b                	jae    80225b <__umoddi3+0x11b>
  802250:	2b 44 24 04          	sub    0x4(%esp),%eax
  802254:	1b 14 24             	sbb    (%esp),%edx
  802257:	89 d1                	mov    %edx,%ecx
  802259:	89 c3                	mov    %eax,%ebx
  80225b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80225f:	29 da                	sub    %ebx,%edx
  802261:	19 ce                	sbb    %ecx,%esi
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 f0                	mov    %esi,%eax
  802267:	d3 e0                	shl    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	d3 ea                	shr    %cl,%edx
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	09 d0                	or     %edx,%eax
  802273:	89 f2                	mov    %esi,%edx
  802275:	83 c4 1c             	add    $0x1c,%esp
  802278:	5b                   	pop    %ebx
  802279:	5e                   	pop    %esi
  80227a:	5f                   	pop    %edi
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	29 f9                	sub    %edi,%ecx
  802282:	19 d6                	sbb    %edx,%esi
  802284:	89 74 24 04          	mov    %esi,0x4(%esp)
  802288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228c:	e9 18 ff ff ff       	jmp    8021a9 <__umoddi3+0x69>
