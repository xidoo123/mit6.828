
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
  80008e:	e8 a6 04 00 00       	call   800539 <close_all>
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
  800107:	68 2a 22 80 00       	push   $0x80222a
  80010c:	6a 23                	push   $0x23
  80010e:	68 47 22 80 00       	push   $0x802247
  800113:	e8 9a 13 00 00       	call   8014b2 <_panic>

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
  800188:	68 2a 22 80 00       	push   $0x80222a
  80018d:	6a 23                	push   $0x23
  80018f:	68 47 22 80 00       	push   $0x802247
  800194:	e8 19 13 00 00       	call   8014b2 <_panic>

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
  8001ca:	68 2a 22 80 00       	push   $0x80222a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 47 22 80 00       	push   $0x802247
  8001d6:	e8 d7 12 00 00       	call   8014b2 <_panic>

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
  80020c:	68 2a 22 80 00       	push   $0x80222a
  800211:	6a 23                	push   $0x23
  800213:	68 47 22 80 00       	push   $0x802247
  800218:	e8 95 12 00 00       	call   8014b2 <_panic>

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
  80024e:	68 2a 22 80 00       	push   $0x80222a
  800253:	6a 23                	push   $0x23
  800255:	68 47 22 80 00       	push   $0x802247
  80025a:	e8 53 12 00 00       	call   8014b2 <_panic>

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
  800290:	68 2a 22 80 00       	push   $0x80222a
  800295:	6a 23                	push   $0x23
  800297:	68 47 22 80 00       	push   $0x802247
  80029c:	e8 11 12 00 00       	call   8014b2 <_panic>

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
  8002d2:	68 2a 22 80 00       	push   $0x80222a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 47 22 80 00       	push   $0x802247
  8002de:	e8 cf 11 00 00       	call   8014b2 <_panic>

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
  800336:	68 2a 22 80 00       	push   $0x80222a
  80033b:	6a 23                	push   $0x23
  80033d:	68 47 22 80 00       	push   $0x802247
  800342:	e8 6b 11 00 00       	call   8014b2 <_panic>

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

0080036e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	05 00 00 00 30       	add    $0x30000000,%eax
  800379:	c1 e8 0c             	shr    $0xc,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	05 00 00 00 30       	add    $0x30000000,%eax
  800389:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 16             	shr    $0x16,%edx
  8003a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 11                	je     8003c2 <fd_alloc+0x2d>
  8003b1:	89 c2                	mov    %eax,%edx
  8003b3:	c1 ea 0c             	shr    $0xc,%edx
  8003b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bd:	f6 c2 01             	test   $0x1,%dl
  8003c0:	75 09                	jne    8003cb <fd_alloc+0x36>
			*fd_store = fd;
  8003c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	eb 17                	jmp    8003e2 <fd_alloc+0x4d>
  8003cb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d5:	75 c9                	jne    8003a0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ea:	83 f8 1f             	cmp    $0x1f,%eax
  8003ed:	77 36                	ja     800425 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ef:	c1 e0 0c             	shl    $0xc,%eax
  8003f2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f7:	89 c2                	mov    %eax,%edx
  8003f9:	c1 ea 16             	shr    $0x16,%edx
  8003fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800403:	f6 c2 01             	test   $0x1,%dl
  800406:	74 24                	je     80042c <fd_lookup+0x48>
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 ea 0c             	shr    $0xc,%edx
  80040d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800414:	f6 c2 01             	test   $0x1,%dl
  800417:	74 1a                	je     800433 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 02                	mov    %eax,(%edx)
	return 0;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	eb 13                	jmp    800438 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042a:	eb 0c                	jmp    800438 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800431:	eb 05                	jmp    800438 <fd_lookup+0x54>
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800443:	ba d4 22 80 00       	mov    $0x8022d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800448:	eb 13                	jmp    80045d <dev_lookup+0x23>
  80044a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80044d:	39 08                	cmp    %ecx,(%eax)
  80044f:	75 0c                	jne    80045d <dev_lookup+0x23>
			*dev = devtab[i];
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	89 01                	mov    %eax,(%ecx)
			return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	eb 2e                	jmp    80048b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 e7                	jne    80044a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800463:	a1 08 40 80 00       	mov    0x804008,%eax
  800468:	8b 40 48             	mov    0x48(%eax),%eax
  80046b:	83 ec 04             	sub    $0x4,%esp
  80046e:	51                   	push   %ecx
  80046f:	50                   	push   %eax
  800470:	68 58 22 80 00       	push   $0x802258
  800475:	e8 11 11 00 00       	call   80158b <cprintf>
	*dev = 0;
  80047a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    

0080048d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 10             	sub    $0x10,%esp
  800495:	8b 75 08             	mov    0x8(%ebp),%esi
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049e:	50                   	push   %eax
  80049f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a5:	c1 e8 0c             	shr    $0xc,%eax
  8004a8:	50                   	push   %eax
  8004a9:	e8 36 ff ff ff       	call   8003e4 <fd_lookup>
  8004ae:	83 c4 08             	add    $0x8,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 05                	js     8004ba <fd_close+0x2d>
	    || fd != fd2)
  8004b5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b8:	74 0c                	je     8004c6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004ba:	84 db                	test   %bl,%bl
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	0f 44 c2             	cmove  %edx,%eax
  8004c4:	eb 41                	jmp    800507 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	ff 36                	pushl  (%esi)
  8004cf:	e8 66 ff ff ff       	call   80043a <dev_lookup>
  8004d4:	89 c3                	mov    %eax,%ebx
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	78 1a                	js     8004f7 <fd_close+0x6a>
		if (dev->dev_close)
  8004dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	74 0b                	je     8004f7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	56                   	push   %esi
  8004f0:	ff d0                	call   *%eax
  8004f2:	89 c3                	mov    %eax,%ebx
  8004f4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	56                   	push   %esi
  8004fb:	6a 00                	push   $0x0
  8004fd:	e8 e1 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	89 d8                	mov    %ebx,%eax
}
  800507:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050a:	5b                   	pop    %ebx
  80050b:	5e                   	pop    %esi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800517:	50                   	push   %eax
  800518:	ff 75 08             	pushl  0x8(%ebp)
  80051b:	e8 c4 fe ff ff       	call   8003e4 <fd_lookup>
  800520:	83 c4 08             	add    $0x8,%esp
  800523:	85 c0                	test   %eax,%eax
  800525:	78 10                	js     800537 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	6a 01                	push   $0x1
  80052c:	ff 75 f4             	pushl  -0xc(%ebp)
  80052f:	e8 59 ff ff ff       	call   80048d <fd_close>
  800534:	83 c4 10             	add    $0x10,%esp
}
  800537:	c9                   	leave  
  800538:	c3                   	ret    

00800539 <close_all>:

void
close_all(void)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	53                   	push   %ebx
  80053d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800540:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800545:	83 ec 0c             	sub    $0xc,%esp
  800548:	53                   	push   %ebx
  800549:	e8 c0 ff ff ff       	call   80050e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054e:	83 c3 01             	add    $0x1,%ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	83 fb 20             	cmp    $0x20,%ebx
  800557:	75 ec                	jne    800545 <close_all+0xc>
		close(i);
}
  800559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	57                   	push   %edi
  800562:	56                   	push   %esi
  800563:	53                   	push   %ebx
  800564:	83 ec 2c             	sub    $0x2c,%esp
  800567:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056d:	50                   	push   %eax
  80056e:	ff 75 08             	pushl  0x8(%ebp)
  800571:	e8 6e fe ff ff       	call   8003e4 <fd_lookup>
  800576:	83 c4 08             	add    $0x8,%esp
  800579:	85 c0                	test   %eax,%eax
  80057b:	0f 88 c1 00 00 00    	js     800642 <dup+0xe4>
		return r;
	close(newfdnum);
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	56                   	push   %esi
  800585:	e8 84 ff ff ff       	call   80050e <close>

	newfd = INDEX2FD(newfdnum);
  80058a:	89 f3                	mov    %esi,%ebx
  80058c:	c1 e3 0c             	shl    $0xc,%ebx
  80058f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800595:	83 c4 04             	add    $0x4,%esp
  800598:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059b:	e8 de fd ff ff       	call   80037e <fd2data>
  8005a0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a2:	89 1c 24             	mov    %ebx,(%esp)
  8005a5:	e8 d4 fd ff ff       	call   80037e <fd2data>
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b0:	89 f8                	mov    %edi,%eax
  8005b2:	c1 e8 16             	shr    $0x16,%eax
  8005b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bc:	a8 01                	test   $0x1,%al
  8005be:	74 37                	je     8005f7 <dup+0x99>
  8005c0:	89 f8                	mov    %edi,%eax
  8005c2:	c1 e8 0c             	shr    $0xc,%eax
  8005c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cc:	f6 c2 01             	test   $0x1,%dl
  8005cf:	74 26                	je     8005f7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e0:	50                   	push   %eax
  8005e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e4:	6a 00                	push   $0x0
  8005e6:	57                   	push   %edi
  8005e7:	6a 00                	push   $0x0
  8005e9:	e8 b3 fb ff ff       	call   8001a1 <sys_page_map>
  8005ee:	89 c7                	mov    %eax,%edi
  8005f0:	83 c4 20             	add    $0x20,%esp
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	78 2e                	js     800625 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fa:	89 d0                	mov    %edx,%eax
  8005fc:	c1 e8 0c             	shr    $0xc,%eax
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	53                   	push   %ebx
  800610:	6a 00                	push   $0x0
  800612:	52                   	push   %edx
  800613:	6a 00                	push   $0x0
  800615:	e8 87 fb ff ff       	call   8001a1 <sys_page_map>
  80061a:	89 c7                	mov    %eax,%edi
  80061c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800621:	85 ff                	test   %edi,%edi
  800623:	79 1d                	jns    800642 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	e8 b3 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	ff 75 d4             	pushl  -0x2c(%ebp)
  800636:	6a 00                	push   $0x0
  800638:	e8 a6 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	89 f8                	mov    %edi,%eax
}
  800642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800645:	5b                   	pop    %ebx
  800646:	5e                   	pop    %esi
  800647:	5f                   	pop    %edi
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	53                   	push   %ebx
  80064e:	83 ec 14             	sub    $0x14,%esp
  800651:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800654:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	53                   	push   %ebx
  800659:	e8 86 fd ff ff       	call   8003e4 <fd_lookup>
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	89 c2                	mov    %eax,%edx
  800663:	85 c0                	test   %eax,%eax
  800665:	78 6d                	js     8006d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800671:	ff 30                	pushl  (%eax)
  800673:	e8 c2 fd ff ff       	call   80043a <dev_lookup>
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	85 c0                	test   %eax,%eax
  80067d:	78 4c                	js     8006cb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800682:	8b 42 08             	mov    0x8(%edx),%eax
  800685:	83 e0 03             	and    $0x3,%eax
  800688:	83 f8 01             	cmp    $0x1,%eax
  80068b:	75 21                	jne    8006ae <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 08 40 80 00       	mov    0x804008,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 99 22 80 00       	push   $0x802299
  80069f:	e8 e7 0e 00 00       	call   80158b <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ac:	eb 26                	jmp    8006d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	8b 40 08             	mov    0x8(%eax),%eax
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 17                	je     8006cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff d0                	call   *%eax
  8006c4:	89 c2                	mov    %eax,%edx
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb 09                	jmp    8006d4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cb:	89 c2                	mov    %eax,%edx
  8006cd:	eb 05                	jmp    8006d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d4:	89 d0                	mov    %edx,%eax
  8006d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	57                   	push   %edi
  8006df:	56                   	push   %esi
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 0c             	sub    $0xc,%esp
  8006e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ef:	eb 21                	jmp    800712 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f1:	83 ec 04             	sub    $0x4,%esp
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	29 d8                	sub    %ebx,%eax
  8006f8:	50                   	push   %eax
  8006f9:	89 d8                	mov    %ebx,%eax
  8006fb:	03 45 0c             	add    0xc(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	57                   	push   %edi
  800700:	e8 45 ff ff ff       	call   80064a <read>
		if (m < 0)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 10                	js     80071c <readn+0x41>
			return m;
		if (m == 0)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 0a                	je     80071a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800710:	01 c3                	add    %eax,%ebx
  800712:	39 f3                	cmp    %esi,%ebx
  800714:	72 db                	jb     8006f1 <readn+0x16>
  800716:	89 d8                	mov    %ebx,%eax
  800718:	eb 02                	jmp    80071c <readn+0x41>
  80071a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80071c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5f                   	pop    %edi
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	53                   	push   %ebx
  800728:	83 ec 14             	sub    $0x14,%esp
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	53                   	push   %ebx
  800733:	e8 ac fc ff ff       	call   8003e4 <fd_lookup>
  800738:	83 c4 08             	add    $0x8,%esp
  80073b:	89 c2                	mov    %eax,%edx
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 68                	js     8007a9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074b:	ff 30                	pushl  (%eax)
  80074d:	e8 e8 fc ff ff       	call   80043a <dev_lookup>
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	85 c0                	test   %eax,%eax
  800757:	78 47                	js     8007a0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800760:	75 21                	jne    800783 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800762:	a1 08 40 80 00       	mov    0x804008,%eax
  800767:	8b 40 48             	mov    0x48(%eax),%eax
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	53                   	push   %ebx
  80076e:	50                   	push   %eax
  80076f:	68 b5 22 80 00       	push   $0x8022b5
  800774:	e8 12 0e 00 00       	call   80158b <cprintf>
		return -E_INVAL;
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800781:	eb 26                	jmp    8007a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800783:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800786:	8b 52 0c             	mov    0xc(%edx),%edx
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 17                	je     8007a4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	50                   	push   %eax
  800797:	ff d2                	call   *%edx
  800799:	89 c2                	mov    %eax,%edx
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	eb 09                	jmp    8007a9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	eb 05                	jmp    8007a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a9:	89 d0                	mov    %edx,%eax
  8007ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 22 fc ff ff       	call   8003e4 <fd_lookup>
  8007c2:	83 c4 08             	add    $0x8,%esp
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	78 0e                	js     8007d7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 14             	sub    $0x14,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e6:	50                   	push   %eax
  8007e7:	53                   	push   %ebx
  8007e8:	e8 f7 fb ff ff       	call   8003e4 <fd_lookup>
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	89 c2                	mov    %eax,%edx
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	78 65                	js     80085b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800800:	ff 30                	pushl  (%eax)
  800802:	e8 33 fc ff ff       	call   80043a <dev_lookup>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 44                	js     800852 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800811:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800815:	75 21                	jne    800838 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800817:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80081c:	8b 40 48             	mov    0x48(%eax),%eax
  80081f:	83 ec 04             	sub    $0x4,%esp
  800822:	53                   	push   %ebx
  800823:	50                   	push   %eax
  800824:	68 78 22 80 00       	push   $0x802278
  800829:	e8 5d 0d 00 00       	call   80158b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800836:	eb 23                	jmp    80085b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800838:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083b:	8b 52 18             	mov    0x18(%edx),%edx
  80083e:	85 d2                	test   %edx,%edx
  800840:	74 14                	je     800856 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	50                   	push   %eax
  800849:	ff d2                	call   *%edx
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	eb 09                	jmp    80085b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800852:	89 c2                	mov    %eax,%edx
  800854:	eb 05                	jmp    80085b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800856:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	83 ec 14             	sub    $0x14,%esp
  800869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086f:	50                   	push   %eax
  800870:	ff 75 08             	pushl  0x8(%ebp)
  800873:	e8 6c fb ff ff       	call   8003e4 <fd_lookup>
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 58                	js     8008d9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	ff 30                	pushl  (%eax)
  80088d:	e8 a8 fb ff ff       	call   80043a <dev_lookup>
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 c0                	test   %eax,%eax
  800897:	78 37                	js     8008d0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a0:	74 32                	je     8008d4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ac:	00 00 00 
	stat->st_isdir = 0;
  8008af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b6:	00 00 00 
	stat->st_dev = dev;
  8008b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c6:	ff 50 14             	call   *0x14(%eax)
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 09                	jmp    8008d9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	eb 05                	jmp    8008d9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d9:	89 d0                	mov    %edx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	6a 00                	push   $0x0
  8008ea:	ff 75 08             	pushl  0x8(%ebp)
  8008ed:	e8 d6 01 00 00       	call   800ac8 <open>
  8008f2:	89 c3                	mov    %eax,%ebx
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	85 c0                	test   %eax,%eax
  8008f9:	78 1b                	js     800916 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	50                   	push   %eax
  800902:	e8 5b ff ff ff       	call   800862 <fstat>
  800907:	89 c6                	mov    %eax,%esi
	close(fd);
  800909:	89 1c 24             	mov    %ebx,(%esp)
  80090c:	e8 fd fb ff ff       	call   80050e <close>
	return r;
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	89 f0                	mov    %esi,%eax
}
  800916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	89 c6                	mov    %eax,%esi
  800924:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800926:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80092d:	75 12                	jne    800941 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092f:	83 ec 0c             	sub    $0xc,%esp
  800932:	6a 01                	push   $0x1
  800934:	e8 d9 15 00 00       	call   801f12 <ipc_find_env>
  800939:	a3 00 40 80 00       	mov    %eax,0x804000
  80093e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800941:	6a 07                	push   $0x7
  800943:	68 00 50 80 00       	push   $0x805000
  800948:	56                   	push   %esi
  800949:	ff 35 00 40 80 00    	pushl  0x804000
  80094f:	e8 6a 15 00 00       	call   801ebe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800954:	83 c4 0c             	add    $0xc,%esp
  800957:	6a 00                	push   $0x0
  800959:	53                   	push   %ebx
  80095a:	6a 00                	push   $0x0
  80095c:	e8 f6 14 00 00       	call   801e57 <ipc_recv>
}
  800961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 40 0c             	mov    0xc(%eax),%eax
  800974:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	b8 02 00 00 00       	mov    $0x2,%eax
  80098b:	e8 8d ff ff ff       	call   80091d <fsipc>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 40 0c             	mov    0xc(%eax),%eax
  80099e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ad:	e8 6b ff ff ff       	call   80091d <fsipc>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	83 ec 04             	sub    $0x4,%esp
  8009bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d3:	e8 45 ff ff ff       	call   80091d <fsipc>
  8009d8:	85 c0                	test   %eax,%eax
  8009da:	78 2c                	js     800a08 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	68 00 50 80 00       	push   $0x805000
  8009e4:	53                   	push   %ebx
  8009e5:	e8 26 11 00 00       	call   801b10 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 0c             	sub    $0xc,%esp
  800a13:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a16:	8b 55 08             	mov    0x8(%ebp),%edx
  800a19:	8b 52 0c             	mov    0xc(%edx),%edx
  800a1c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a22:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a27:	50                   	push   %eax
  800a28:	ff 75 0c             	pushl  0xc(%ebp)
  800a2b:	68 08 50 80 00       	push   $0x805008
  800a30:	e8 6d 12 00 00       	call   801ca2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3f:	e8 d9 fe ff ff       	call   80091d <fsipc>

}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 40 0c             	mov    0xc(%eax),%eax
  800a54:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a59:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a64:	b8 03 00 00 00       	mov    $0x3,%eax
  800a69:	e8 af fe ff ff       	call   80091d <fsipc>
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	85 c0                	test   %eax,%eax
  800a72:	78 4b                	js     800abf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a74:	39 c6                	cmp    %eax,%esi
  800a76:	73 16                	jae    800a8e <devfile_read+0x48>
  800a78:	68 e8 22 80 00       	push   $0x8022e8
  800a7d:	68 ef 22 80 00       	push   $0x8022ef
  800a82:	6a 7c                	push   $0x7c
  800a84:	68 04 23 80 00       	push   $0x802304
  800a89:	e8 24 0a 00 00       	call   8014b2 <_panic>
	assert(r <= PGSIZE);
  800a8e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a93:	7e 16                	jle    800aab <devfile_read+0x65>
  800a95:	68 0f 23 80 00       	push   $0x80230f
  800a9a:	68 ef 22 80 00       	push   $0x8022ef
  800a9f:	6a 7d                	push   $0x7d
  800aa1:	68 04 23 80 00       	push   $0x802304
  800aa6:	e8 07 0a 00 00       	call   8014b2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aab:	83 ec 04             	sub    $0x4,%esp
  800aae:	50                   	push   %eax
  800aaf:	68 00 50 80 00       	push   $0x805000
  800ab4:	ff 75 0c             	pushl  0xc(%ebp)
  800ab7:	e8 e6 11 00 00       	call   801ca2 <memmove>
	return r;
  800abc:	83 c4 10             	add    $0x10,%esp
}
  800abf:	89 d8                	mov    %ebx,%eax
  800ac1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	53                   	push   %ebx
  800acc:	83 ec 20             	sub    $0x20,%esp
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ad2:	53                   	push   %ebx
  800ad3:	e8 ff 0f 00 00       	call   801ad7 <strlen>
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae0:	7f 67                	jg     800b49 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae8:	50                   	push   %eax
  800ae9:	e8 a7 f8 ff ff       	call   800395 <fd_alloc>
  800aee:	83 c4 10             	add    $0x10,%esp
		return r;
  800af1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	78 57                	js     800b4e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af7:	83 ec 08             	sub    $0x8,%esp
  800afa:	53                   	push   %ebx
  800afb:	68 00 50 80 00       	push   $0x805000
  800b00:	e8 0b 10 00 00       	call   801b10 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b10:	b8 01 00 00 00       	mov    $0x1,%eax
  800b15:	e8 03 fe ff ff       	call   80091d <fsipc>
  800b1a:	89 c3                	mov    %eax,%ebx
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	79 14                	jns    800b37 <open+0x6f>
		fd_close(fd, 0);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	6a 00                	push   $0x0
  800b28:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2b:	e8 5d f9 ff ff       	call   80048d <fd_close>
		return r;
  800b30:	83 c4 10             	add    $0x10,%esp
  800b33:	89 da                	mov    %ebx,%edx
  800b35:	eb 17                	jmp    800b4e <open+0x86>
	}

	return fd2num(fd);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3d:	e8 2c f8 ff ff       	call   80036e <fd2num>
  800b42:	89 c2                	mov    %eax,%edx
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	eb 05                	jmp    800b4e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b49:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b4e:	89 d0                	mov    %edx,%eax
  800b50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 08 00 00 00       	mov    $0x8,%eax
  800b65:	e8 b3 fd ff ff       	call   80091d <fsipc>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b72:	68 1b 23 80 00       	push   $0x80231b
  800b77:	ff 75 0c             	pushl  0xc(%ebp)
  800b7a:	e8 91 0f 00 00       	call   801b10 <strcpy>
	return 0;
}
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 10             	sub    $0x10,%esp
  800b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b90:	53                   	push   %ebx
  800b91:	e8 b5 13 00 00       	call   801f4b <pageref>
  800b96:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800b9e:	83 f8 01             	cmp    $0x1,%eax
  800ba1:	75 10                	jne    800bb3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	ff 73 0c             	pushl  0xc(%ebx)
  800ba9:	e8 c0 02 00 00       	call   800e6e <nsipc_close>
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bb3:	89 d0                	mov    %edx,%eax
  800bb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 10             	pushl  0x10(%ebp)
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	ff 70 0c             	pushl  0xc(%eax)
  800bce:	e8 78 03 00 00       	call   800f4b <nsipc_send>
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bdb:	6a 00                	push   $0x0
  800bdd:	ff 75 10             	pushl  0x10(%ebp)
  800be0:	ff 75 0c             	pushl  0xc(%ebp)
  800be3:	8b 45 08             	mov    0x8(%ebp),%eax
  800be6:	ff 70 0c             	pushl  0xc(%eax)
  800be9:	e8 f1 02 00 00       	call   800edf <nsipc_recv>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bf6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bf9:	52                   	push   %edx
  800bfa:	50                   	push   %eax
  800bfb:	e8 e4 f7 ff ff       	call   8003e4 <fd_lookup>
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	85 c0                	test   %eax,%eax
  800c05:	78 17                	js     800c1e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c10:	39 08                	cmp    %ecx,(%eax)
  800c12:	75 05                	jne    800c19 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c14:	8b 40 0c             	mov    0xc(%eax),%eax
  800c17:	eb 05                	jmp    800c1e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 1c             	sub    $0x1c,%esp
  800c28:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c2d:	50                   	push   %eax
  800c2e:	e8 62 f7 ff ff       	call   800395 <fd_alloc>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	83 c4 10             	add    $0x10,%esp
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	78 1b                	js     800c57 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c3c:	83 ec 04             	sub    $0x4,%esp
  800c3f:	68 07 04 00 00       	push   $0x407
  800c44:	ff 75 f4             	pushl  -0xc(%ebp)
  800c47:	6a 00                	push   $0x0
  800c49:	e8 10 f5 ff ff       	call   80015e <sys_page_alloc>
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	85 c0                	test   %eax,%eax
  800c55:	79 10                	jns    800c67 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	56                   	push   %esi
  800c5b:	e8 0e 02 00 00       	call   800e6e <nsipc_close>
		return r;
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	89 d8                	mov    %ebx,%eax
  800c65:	eb 24                	jmp    800c8b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c70:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c7c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	e8 e6 f6 ff ff       	call   80036e <fd2num>
  800c88:	83 c4 10             	add    $0x10,%esp
}
  800c8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	e8 50 ff ff ff       	call   800bf0 <fd2sockid>
		return r;
  800ca0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	78 1f                	js     800cc5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ca6:	83 ec 04             	sub    $0x4,%esp
  800ca9:	ff 75 10             	pushl  0x10(%ebp)
  800cac:	ff 75 0c             	pushl  0xc(%ebp)
  800caf:	50                   	push   %eax
  800cb0:	e8 12 01 00 00       	call   800dc7 <nsipc_accept>
  800cb5:	83 c4 10             	add    $0x10,%esp
		return r;
  800cb8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	78 07                	js     800cc5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cbe:	e8 5d ff ff ff       	call   800c20 <alloc_sockfd>
  800cc3:	89 c1                	mov    %eax,%ecx
}
  800cc5:	89 c8                	mov    %ecx,%eax
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	e8 19 ff ff ff       	call   800bf0 <fd2sockid>
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	78 12                	js     800ced <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800cdb:	83 ec 04             	sub    $0x4,%esp
  800cde:	ff 75 10             	pushl  0x10(%ebp)
  800ce1:	ff 75 0c             	pushl  0xc(%ebp)
  800ce4:	50                   	push   %eax
  800ce5:	e8 2d 01 00 00       	call   800e17 <nsipc_bind>
  800cea:	83 c4 10             	add    $0x10,%esp
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <shutdown>:

int
shutdown(int s, int how)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	e8 f3 fe ff ff       	call   800bf0 <fd2sockid>
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	78 0f                	js     800d10 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d01:	83 ec 08             	sub    $0x8,%esp
  800d04:	ff 75 0c             	pushl  0xc(%ebp)
  800d07:	50                   	push   %eax
  800d08:	e8 3f 01 00 00       	call   800e4c <nsipc_shutdown>
  800d0d:	83 c4 10             	add    $0x10,%esp
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	e8 d0 fe ff ff       	call   800bf0 <fd2sockid>
  800d20:	85 c0                	test   %eax,%eax
  800d22:	78 12                	js     800d36 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d24:	83 ec 04             	sub    $0x4,%esp
  800d27:	ff 75 10             	pushl  0x10(%ebp)
  800d2a:	ff 75 0c             	pushl  0xc(%ebp)
  800d2d:	50                   	push   %eax
  800d2e:	e8 55 01 00 00       	call   800e88 <nsipc_connect>
  800d33:	83 c4 10             	add    $0x10,%esp
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <listen>:

int
listen(int s, int backlog)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	e8 aa fe ff ff       	call   800bf0 <fd2sockid>
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 0f                	js     800d59 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	ff 75 0c             	pushl  0xc(%ebp)
  800d50:	50                   	push   %eax
  800d51:	e8 67 01 00 00       	call   800ebd <nsipc_listen>
  800d56:	83 c4 10             	add    $0x10,%esp
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d61:	ff 75 10             	pushl  0x10(%ebp)
  800d64:	ff 75 0c             	pushl  0xc(%ebp)
  800d67:	ff 75 08             	pushl  0x8(%ebp)
  800d6a:	e8 3a 02 00 00       	call   800fa9 <nsipc_socket>
  800d6f:	83 c4 10             	add    $0x10,%esp
  800d72:	85 c0                	test   %eax,%eax
  800d74:	78 05                	js     800d7b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d76:	e8 a5 fe ff ff       	call   800c20 <alloc_sockfd>
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	53                   	push   %ebx
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d86:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d8d:	75 12                	jne    800da1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	6a 02                	push   $0x2
  800d94:	e8 79 11 00 00       	call   801f12 <ipc_find_env>
  800d99:	a3 04 40 80 00       	mov    %eax,0x804004
  800d9e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800da1:	6a 07                	push   $0x7
  800da3:	68 00 60 80 00       	push   $0x806000
  800da8:	53                   	push   %ebx
  800da9:	ff 35 04 40 80 00    	pushl  0x804004
  800daf:	e8 0a 11 00 00       	call   801ebe <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800db4:	83 c4 0c             	add    $0xc,%esp
  800db7:	6a 00                	push   $0x0
  800db9:	6a 00                	push   $0x0
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 95 10 00 00       	call   801e57 <ipc_recv>
}
  800dc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dd7:	8b 06                	mov    (%esi),%eax
  800dd9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dde:	b8 01 00 00 00       	mov    $0x1,%eax
  800de3:	e8 95 ff ff ff       	call   800d7d <nsipc>
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 20                	js     800e0e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	ff 35 10 60 80 00    	pushl  0x806010
  800df7:	68 00 60 80 00       	push   $0x806000
  800dfc:	ff 75 0c             	pushl  0xc(%ebp)
  800dff:	e8 9e 0e 00 00       	call   801ca2 <memmove>
		*addrlen = ret->ret_addrlen;
  800e04:	a1 10 60 80 00       	mov    0x806010,%eax
  800e09:	89 06                	mov    %eax,(%esi)
  800e0b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e0e:	89 d8                	mov    %ebx,%eax
  800e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	53                   	push   %ebx
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e29:	53                   	push   %ebx
  800e2a:	ff 75 0c             	pushl  0xc(%ebp)
  800e2d:	68 04 60 80 00       	push   $0x806004
  800e32:	e8 6b 0e 00 00       	call   801ca2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e37:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e42:	e8 36 ff ff ff       	call   800d7d <nsipc>
}
  800e47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e62:	b8 03 00 00 00       	mov    $0x3,%eax
  800e67:	e8 11 ff ff ff       	call   800d7d <nsipc>
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <nsipc_close>:

int
nsipc_close(int s)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e81:	e8 f7 fe ff ff       	call   800d7d <nsipc>
}
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 08             	sub    $0x8,%esp
  800e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800e9a:	53                   	push   %ebx
  800e9b:	ff 75 0c             	pushl  0xc(%ebp)
  800e9e:	68 04 60 80 00       	push   $0x806004
  800ea3:	e8 fa 0d 00 00       	call   801ca2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ea8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eae:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb3:	e8 c5 fe ff ff       	call   800d7d <nsipc>
}
  800eb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ece:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ed3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed8:	e8 a0 fe ff ff       	call   800d7d <nsipc>
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800eef:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800ef5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800efd:	b8 07 00 00 00       	mov    $0x7,%eax
  800f02:	e8 76 fe ff ff       	call   800d7d <nsipc>
  800f07:	89 c3                	mov    %eax,%ebx
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	78 35                	js     800f42 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f0d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f12:	7f 04                	jg     800f18 <nsipc_recv+0x39>
  800f14:	39 c6                	cmp    %eax,%esi
  800f16:	7d 16                	jge    800f2e <nsipc_recv+0x4f>
  800f18:	68 27 23 80 00       	push   $0x802327
  800f1d:	68 ef 22 80 00       	push   $0x8022ef
  800f22:	6a 62                	push   $0x62
  800f24:	68 3c 23 80 00       	push   $0x80233c
  800f29:	e8 84 05 00 00       	call   8014b2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	50                   	push   %eax
  800f32:	68 00 60 80 00       	push   $0x806000
  800f37:	ff 75 0c             	pushl  0xc(%ebp)
  800f3a:	e8 63 0d 00 00       	call   801ca2 <memmove>
  800f3f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f42:	89 d8                	mov    %ebx,%eax
  800f44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
  800f58:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f5d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f63:	7e 16                	jle    800f7b <nsipc_send+0x30>
  800f65:	68 48 23 80 00       	push   $0x802348
  800f6a:	68 ef 22 80 00       	push   $0x8022ef
  800f6f:	6a 6d                	push   $0x6d
  800f71:	68 3c 23 80 00       	push   $0x80233c
  800f76:	e8 37 05 00 00       	call   8014b2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f7b:	83 ec 04             	sub    $0x4,%esp
  800f7e:	53                   	push   %ebx
  800f7f:	ff 75 0c             	pushl  0xc(%ebp)
  800f82:	68 0c 60 80 00       	push   $0x80600c
  800f87:	e8 16 0d 00 00       	call   801ca2 <memmove>
	nsipcbuf.send.req_size = size;
  800f8c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f92:	8b 45 14             	mov    0x14(%ebp),%eax
  800f95:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800f9a:	b8 08 00 00 00       	mov    $0x8,%eax
  800f9f:	e8 d9 fd ff ff       	call   800d7d <nsipc>
}
  800fa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fba:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fc7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fcc:	e8 ac fd ff ff       	call   800d7d <nsipc>
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	ff 75 08             	pushl  0x8(%ebp)
  800fe1:	e8 98 f3 ff ff       	call   80037e <fd2data>
  800fe6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	68 54 23 80 00       	push   $0x802354
  800ff0:	53                   	push   %ebx
  800ff1:	e8 1a 0b 00 00       	call   801b10 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ff6:	8b 46 04             	mov    0x4(%esi),%eax
  800ff9:	2b 06                	sub    (%esi),%eax
  800ffb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801001:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801008:	00 00 00 
	stat->st_dev = &devpipe;
  80100b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801012:	30 80 00 
	return 0;
}
  801015:	b8 00 00 00 00       	mov    $0x0,%eax
  80101a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	53                   	push   %ebx
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80102b:	53                   	push   %ebx
  80102c:	6a 00                	push   $0x0
  80102e:	e8 b0 f1 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801033:	89 1c 24             	mov    %ebx,(%esp)
  801036:	e8 43 f3 ff ff       	call   80037e <fd2data>
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	50                   	push   %eax
  80103f:	6a 00                	push   $0x0
  801041:	e8 9d f1 ff ff       	call   8001e3 <sys_page_unmap>
}
  801046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 1c             	sub    $0x1c,%esp
  801054:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801057:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801059:	a1 08 40 80 00       	mov    0x804008,%eax
  80105e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	ff 75 e0             	pushl  -0x20(%ebp)
  801067:	e8 df 0e 00 00       	call   801f4b <pageref>
  80106c:	89 c3                	mov    %eax,%ebx
  80106e:	89 3c 24             	mov    %edi,(%esp)
  801071:	e8 d5 0e 00 00       	call   801f4b <pageref>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	39 c3                	cmp    %eax,%ebx
  80107b:	0f 94 c1             	sete   %cl
  80107e:	0f b6 c9             	movzbl %cl,%ecx
  801081:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801084:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80108a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80108d:	39 ce                	cmp    %ecx,%esi
  80108f:	74 1b                	je     8010ac <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801091:	39 c3                	cmp    %eax,%ebx
  801093:	75 c4                	jne    801059 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801095:	8b 42 58             	mov    0x58(%edx),%eax
  801098:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109b:	50                   	push   %eax
  80109c:	56                   	push   %esi
  80109d:	68 5b 23 80 00       	push   $0x80235b
  8010a2:	e8 e4 04 00 00       	call   80158b <cprintf>
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	eb ad                	jmp    801059 <_pipeisclosed+0xe>
	}
}
  8010ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b2:	5b                   	pop    %ebx
  8010b3:	5e                   	pop    %esi
  8010b4:	5f                   	pop    %edi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 28             	sub    $0x28,%esp
  8010c0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010c3:	56                   	push   %esi
  8010c4:	e8 b5 f2 ff ff       	call   80037e <fd2data>
  8010c9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d3:	eb 4b                	jmp    801120 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010d5:	89 da                	mov    %ebx,%edx
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	e8 6d ff ff ff       	call   80104b <_pipeisclosed>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	75 48                	jne    80112a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010e2:	e8 58 f0 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010e7:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ea:	8b 0b                	mov    (%ebx),%ecx
  8010ec:	8d 51 20             	lea    0x20(%ecx),%edx
  8010ef:	39 d0                	cmp    %edx,%eax
  8010f1:	73 e2                	jae    8010d5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010fa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010fd:	89 c2                	mov    %eax,%edx
  8010ff:	c1 fa 1f             	sar    $0x1f,%edx
  801102:	89 d1                	mov    %edx,%ecx
  801104:	c1 e9 1b             	shr    $0x1b,%ecx
  801107:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80110a:	83 e2 1f             	and    $0x1f,%edx
  80110d:	29 ca                	sub    %ecx,%edx
  80110f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801117:	83 c0 01             	add    $0x1,%eax
  80111a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80111d:	83 c7 01             	add    $0x1,%edi
  801120:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801123:	75 c2                	jne    8010e7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801125:	8b 45 10             	mov    0x10(%ebp),%eax
  801128:	eb 05                	jmp    80112f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80112a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 18             	sub    $0x18,%esp
  801140:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801143:	57                   	push   %edi
  801144:	e8 35 f2 ff ff       	call   80037e <fd2data>
  801149:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	eb 3d                	jmp    801192 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801155:	85 db                	test   %ebx,%ebx
  801157:	74 04                	je     80115d <devpipe_read+0x26>
				return i;
  801159:	89 d8                	mov    %ebx,%eax
  80115b:	eb 44                	jmp    8011a1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80115d:	89 f2                	mov    %esi,%edx
  80115f:	89 f8                	mov    %edi,%eax
  801161:	e8 e5 fe ff ff       	call   80104b <_pipeisclosed>
  801166:	85 c0                	test   %eax,%eax
  801168:	75 32                	jne    80119c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80116a:	e8 d0 ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80116f:	8b 06                	mov    (%esi),%eax
  801171:	3b 46 04             	cmp    0x4(%esi),%eax
  801174:	74 df                	je     801155 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801176:	99                   	cltd   
  801177:	c1 ea 1b             	shr    $0x1b,%edx
  80117a:	01 d0                	add    %edx,%eax
  80117c:	83 e0 1f             	and    $0x1f,%eax
  80117f:	29 d0                	sub    %edx,%eax
  801181:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801189:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80118c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118f:	83 c3 01             	add    $0x1,%ebx
  801192:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801195:	75 d8                	jne    80116f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801197:	8b 45 10             	mov    0x10(%ebp),%eax
  80119a:	eb 05                	jmp    8011a1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	e8 db f1 ff ff       	call   800395 <fd_alloc>
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	0f 88 2c 01 00 00    	js     8012f3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	68 07 04 00 00       	push   $0x407
  8011cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 85 ef ff ff       	call   80015e <sys_page_alloc>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	0f 88 0d 01 00 00    	js     8012f3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	e8 a3 f1 ff ff       	call   800395 <fd_alloc>
  8011f2:	89 c3                	mov    %eax,%ebx
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	0f 88 e2 00 00 00    	js     8012e1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	68 07 04 00 00       	push   $0x407
  801207:	ff 75 f0             	pushl  -0x10(%ebp)
  80120a:	6a 00                	push   $0x0
  80120c:	e8 4d ef ff ff       	call   80015e <sys_page_alloc>
  801211:	89 c3                	mov    %eax,%ebx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	0f 88 c3 00 00 00    	js     8012e1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	ff 75 f4             	pushl  -0xc(%ebp)
  801224:	e8 55 f1 ff ff       	call   80037e <fd2data>
  801229:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122b:	83 c4 0c             	add    $0xc,%esp
  80122e:	68 07 04 00 00       	push   $0x407
  801233:	50                   	push   %eax
  801234:	6a 00                	push   $0x0
  801236:	e8 23 ef ff ff       	call   80015e <sys_page_alloc>
  80123b:	89 c3                	mov    %eax,%ebx
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	0f 88 89 00 00 00    	js     8012d1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	ff 75 f0             	pushl  -0x10(%ebp)
  80124e:	e8 2b f1 ff ff       	call   80037e <fd2data>
  801253:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80125a:	50                   	push   %eax
  80125b:	6a 00                	push   $0x0
  80125d:	56                   	push   %esi
  80125e:	6a 00                	push   $0x0
  801260:	e8 3c ef ff ff       	call   8001a1 <sys_page_map>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 20             	add    $0x20,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 55                	js     8012c3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80126e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801274:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801277:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801283:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	ff 75 f4             	pushl  -0xc(%ebp)
  80129e:	e8 cb f0 ff ff       	call   80036e <fd2num>
  8012a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012a8:	83 c4 04             	add    $0x4,%esp
  8012ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ae:	e8 bb f0 ff ff       	call   80036e <fd2num>
  8012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c1:	eb 30                	jmp    8012f3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	56                   	push   %esi
  8012c7:	6a 00                	push   $0x0
  8012c9:	e8 15 ef ff ff       	call   8001e3 <sys_page_unmap>
  8012ce:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 05 ef ff ff       	call   8001e3 <sys_page_unmap>
  8012de:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 f5 ee ff ff       	call   8001e3 <sys_page_unmap>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012f3:	89 d0                	mov    %edx,%eax
  8012f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801302:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 d6 f0 ff ff       	call   8003e4 <fd_lookup>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 18                	js     80132d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801315:	83 ec 0c             	sub    $0xc,%esp
  801318:	ff 75 f4             	pushl  -0xc(%ebp)
  80131b:	e8 5e f0 ff ff       	call   80037e <fd2data>
	return _pipeisclosed(fd, p);
  801320:	89 c2                	mov    %eax,%edx
  801322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801325:	e8 21 fd ff ff       	call   80104b <_pipeisclosed>
  80132a:	83 c4 10             	add    $0x10,%esp
}
  80132d:	c9                   	leave  
  80132e:	c3                   	ret    

0080132f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801332:	b8 00 00 00 00       	mov    $0x0,%eax
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80133f:	68 73 23 80 00       	push   $0x802373
  801344:	ff 75 0c             	pushl  0xc(%ebp)
  801347:	e8 c4 07 00 00       	call   801b10 <strcpy>
	return 0;
}
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	57                   	push   %edi
  801357:	56                   	push   %esi
  801358:	53                   	push   %ebx
  801359:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80135f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801364:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80136a:	eb 2d                	jmp    801399 <devcons_write+0x46>
		m = n - tot;
  80136c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80136f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801371:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801374:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801379:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	53                   	push   %ebx
  801380:	03 45 0c             	add    0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	57                   	push   %edi
  801385:	e8 18 09 00 00       	call   801ca2 <memmove>
		sys_cputs(buf, m);
  80138a:	83 c4 08             	add    $0x8,%esp
  80138d:	53                   	push   %ebx
  80138e:	57                   	push   %edi
  80138f:	e8 0e ed ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801394:	01 de                	add    %ebx,%esi
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	89 f0                	mov    %esi,%eax
  80139b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80139e:	72 cc                	jb     80136c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5f                   	pop    %edi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013b7:	74 2a                	je     8013e3 <devcons_read+0x3b>
  8013b9:	eb 05                	jmp    8013c0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013bb:	e8 7f ed ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013c0:	e8 fb ec ff ff       	call   8000c0 <sys_cgetc>
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	74 f2                	je     8013bb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 16                	js     8013e3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013cd:	83 f8 04             	cmp    $0x4,%eax
  8013d0:	74 0c                	je     8013de <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d5:	88 02                	mov    %al,(%edx)
	return 1;
  8013d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8013dc:	eb 05                	jmp    8013e3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013f1:	6a 01                	push   $0x1
  8013f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013f6:	50                   	push   %eax
  8013f7:	e8 a6 ec ff ff       	call   8000a2 <sys_cputs>
}
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <getchar>:

int
getchar(void)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801407:	6a 01                	push   $0x1
  801409:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	6a 00                	push   $0x0
  80140f:	e8 36 f2 ff ff       	call   80064a <read>
	if (r < 0)
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 0f                	js     80142a <getchar+0x29>
		return r;
	if (r < 1)
  80141b:	85 c0                	test   %eax,%eax
  80141d:	7e 06                	jle    801425 <getchar+0x24>
		return -E_EOF;
	return c;
  80141f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801423:	eb 05                	jmp    80142a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801425:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	ff 75 08             	pushl  0x8(%ebp)
  801439:	e8 a6 ef ff ff       	call   8003e4 <fd_lookup>
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	85 c0                	test   %eax,%eax
  801443:	78 11                	js     801456 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801445:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801448:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80144e:	39 10                	cmp    %edx,(%eax)
  801450:	0f 94 c0             	sete   %al
  801453:	0f b6 c0             	movzbl %al,%eax
}
  801456:	c9                   	leave  
  801457:	c3                   	ret    

00801458 <opencons>:

int
opencons(void)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80145e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	e8 2e ef ff ff       	call   800395 <fd_alloc>
  801467:	83 c4 10             	add    $0x10,%esp
		return r;
  80146a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 3e                	js     8014ae <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	68 07 04 00 00       	push   $0x407
  801478:	ff 75 f4             	pushl  -0xc(%ebp)
  80147b:	6a 00                	push   $0x0
  80147d:	e8 dc ec ff ff       	call   80015e <sys_page_alloc>
  801482:	83 c4 10             	add    $0x10,%esp
		return r;
  801485:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801487:	85 c0                	test   %eax,%eax
  801489:	78 23                	js     8014ae <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80148b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801494:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801499:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a0:	83 ec 0c             	sub    $0xc,%esp
  8014a3:	50                   	push   %eax
  8014a4:	e8 c5 ee ff ff       	call   80036e <fd2num>
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	83 c4 10             	add    $0x10,%esp
}
  8014ae:	89 d0                	mov    %edx,%eax
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	56                   	push   %esi
  8014b6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c0:	e8 5b ec ff ff       	call   800120 <sys_getenvid>
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	ff 75 08             	pushl  0x8(%ebp)
  8014ce:	56                   	push   %esi
  8014cf:	50                   	push   %eax
  8014d0:	68 80 23 80 00       	push   $0x802380
  8014d5:	e8 b1 00 00 00       	call   80158b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014da:	83 c4 18             	add    $0x18,%esp
  8014dd:	53                   	push   %ebx
  8014de:	ff 75 10             	pushl  0x10(%ebp)
  8014e1:	e8 54 00 00 00       	call   80153a <vcprintf>
	cprintf("\n");
  8014e6:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014ed:	e8 99 00 00 00       	call   80158b <cprintf>
  8014f2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f5:	cc                   	int3   
  8014f6:	eb fd                	jmp    8014f5 <_panic+0x43>

008014f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801502:	8b 13                	mov    (%ebx),%edx
  801504:	8d 42 01             	lea    0x1(%edx),%eax
  801507:	89 03                	mov    %eax,(%ebx)
  801509:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801510:	3d ff 00 00 00       	cmp    $0xff,%eax
  801515:	75 1a                	jne    801531 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	68 ff 00 00 00       	push   $0xff
  80151f:	8d 43 08             	lea    0x8(%ebx),%eax
  801522:	50                   	push   %eax
  801523:	e8 7a eb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  801528:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80152e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801531:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801543:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154a:	00 00 00 
	b.cnt = 0;
  80154d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801554:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801557:	ff 75 0c             	pushl  0xc(%ebp)
  80155a:	ff 75 08             	pushl  0x8(%ebp)
  80155d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	68 f8 14 80 00       	push   $0x8014f8
  801569:	e8 54 01 00 00       	call   8016c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801577:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	e8 1f eb ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801583:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801591:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801594:	50                   	push   %eax
  801595:	ff 75 08             	pushl  0x8(%ebp)
  801598:	e8 9d ff ff ff       	call   80153a <vcprintf>
	va_end(ap);

	return cnt;
}
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	57                   	push   %edi
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 1c             	sub    $0x1c,%esp
  8015a8:	89 c7                	mov    %eax,%edi
  8015aa:	89 d6                	mov    %edx,%esi
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015c3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015c6:	39 d3                	cmp    %edx,%ebx
  8015c8:	72 05                	jb     8015cf <printnum+0x30>
  8015ca:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015cd:	77 45                	ja     801614 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	ff 75 18             	pushl  0x18(%ebp)
  8015d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015db:	53                   	push   %ebx
  8015dc:	ff 75 10             	pushl  0x10(%ebp)
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8015eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ee:	e8 9d 09 00 00       	call   801f90 <__udivdi3>
  8015f3:	83 c4 18             	add    $0x18,%esp
  8015f6:	52                   	push   %edx
  8015f7:	50                   	push   %eax
  8015f8:	89 f2                	mov    %esi,%edx
  8015fa:	89 f8                	mov    %edi,%eax
  8015fc:	e8 9e ff ff ff       	call   80159f <printnum>
  801601:	83 c4 20             	add    $0x20,%esp
  801604:	eb 18                	jmp    80161e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	56                   	push   %esi
  80160a:	ff 75 18             	pushl  0x18(%ebp)
  80160d:	ff d7                	call   *%edi
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb 03                	jmp    801617 <printnum+0x78>
  801614:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801617:	83 eb 01             	sub    $0x1,%ebx
  80161a:	85 db                	test   %ebx,%ebx
  80161c:	7f e8                	jg     801606 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	56                   	push   %esi
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	ff 75 e4             	pushl  -0x1c(%ebp)
  801628:	ff 75 e0             	pushl  -0x20(%ebp)
  80162b:	ff 75 dc             	pushl  -0x24(%ebp)
  80162e:	ff 75 d8             	pushl  -0x28(%ebp)
  801631:	e8 8a 0a 00 00       	call   8020c0 <__umoddi3>
  801636:	83 c4 14             	add    $0x14,%esp
  801639:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801640:	50                   	push   %eax
  801641:	ff d7                	call   *%edi
}
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801651:	83 fa 01             	cmp    $0x1,%edx
  801654:	7e 0e                	jle    801664 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801656:	8b 10                	mov    (%eax),%edx
  801658:	8d 4a 08             	lea    0x8(%edx),%ecx
  80165b:	89 08                	mov    %ecx,(%eax)
  80165d:	8b 02                	mov    (%edx),%eax
  80165f:	8b 52 04             	mov    0x4(%edx),%edx
  801662:	eb 22                	jmp    801686 <getuint+0x38>
	else if (lflag)
  801664:	85 d2                	test   %edx,%edx
  801666:	74 10                	je     801678 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801668:	8b 10                	mov    (%eax),%edx
  80166a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80166d:	89 08                	mov    %ecx,(%eax)
  80166f:	8b 02                	mov    (%edx),%eax
  801671:	ba 00 00 00 00       	mov    $0x0,%edx
  801676:	eb 0e                	jmp    801686 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801678:	8b 10                	mov    (%eax),%edx
  80167a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80167d:	89 08                	mov    %ecx,(%eax)
  80167f:	8b 02                	mov    (%edx),%eax
  801681:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80168e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801692:	8b 10                	mov    (%eax),%edx
  801694:	3b 50 04             	cmp    0x4(%eax),%edx
  801697:	73 0a                	jae    8016a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  801699:	8d 4a 01             	lea    0x1(%edx),%ecx
  80169c:	89 08                	mov    %ecx,(%eax)
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	88 02                	mov    %al,(%edx)
}
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ae:	50                   	push   %eax
  8016af:	ff 75 10             	pushl  0x10(%ebp)
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	ff 75 08             	pushl  0x8(%ebp)
  8016b8:	e8 05 00 00 00       	call   8016c2 <vprintfmt>
	va_end(ap);
}
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	57                   	push   %edi
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 2c             	sub    $0x2c,%esp
  8016cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016d4:	eb 12                	jmp    8016e8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	0f 84 89 03 00 00    	je     801a67 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	50                   	push   %eax
  8016e3:	ff d6                	call   *%esi
  8016e5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e8:	83 c7 01             	add    $0x1,%edi
  8016eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ef:	83 f8 25             	cmp    $0x25,%eax
  8016f2:	75 e2                	jne    8016d6 <vprintfmt+0x14>
  8016f4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801706:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
  801712:	eb 07                	jmp    80171b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801714:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801717:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171b:	8d 47 01             	lea    0x1(%edi),%eax
  80171e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801721:	0f b6 07             	movzbl (%edi),%eax
  801724:	0f b6 c8             	movzbl %al,%ecx
  801727:	83 e8 23             	sub    $0x23,%eax
  80172a:	3c 55                	cmp    $0x55,%al
  80172c:	0f 87 1a 03 00 00    	ja     801a4c <vprintfmt+0x38a>
  801732:	0f b6 c0             	movzbl %al,%eax
  801735:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  80173c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80173f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801743:	eb d6                	jmp    80171b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801748:	b8 00 00 00 00       	mov    $0x0,%eax
  80174d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801750:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801753:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801757:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80175a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80175d:	83 fa 09             	cmp    $0x9,%edx
  801760:	77 39                	ja     80179b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801762:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801765:	eb e9                	jmp    801750 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801767:	8b 45 14             	mov    0x14(%ebp),%eax
  80176a:	8d 48 04             	lea    0x4(%eax),%ecx
  80176d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801770:	8b 00                	mov    (%eax),%eax
  801772:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801778:	eb 27                	jmp    8017a1 <vprintfmt+0xdf>
  80177a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80177d:	85 c0                	test   %eax,%eax
  80177f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801784:	0f 49 c8             	cmovns %eax,%ecx
  801787:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178d:	eb 8c                	jmp    80171b <vprintfmt+0x59>
  80178f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801792:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801799:	eb 80                	jmp    80171b <vprintfmt+0x59>
  80179b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80179e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017a5:	0f 89 70 ff ff ff    	jns    80171b <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b8:	e9 5e ff ff ff       	jmp    80171b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017bd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017c3:	e9 53 ff ff ff       	jmp    80171b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017cb:	8d 50 04             	lea    0x4(%eax),%edx
  8017ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	53                   	push   %ebx
  8017d5:	ff 30                	pushl  (%eax)
  8017d7:	ff d6                	call   *%esi
			break;
  8017d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017df:	e9 04 ff ff ff       	jmp    8016e8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e7:	8d 50 04             	lea    0x4(%eax),%edx
  8017ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ed:	8b 00                	mov    (%eax),%eax
  8017ef:	99                   	cltd   
  8017f0:	31 d0                	xor    %edx,%eax
  8017f2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f4:	83 f8 0f             	cmp    $0xf,%eax
  8017f7:	7f 0b                	jg     801804 <vprintfmt+0x142>
  8017f9:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  801800:	85 d2                	test   %edx,%edx
  801802:	75 18                	jne    80181c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801804:	50                   	push   %eax
  801805:	68 bb 23 80 00       	push   $0x8023bb
  80180a:	53                   	push   %ebx
  80180b:	56                   	push   %esi
  80180c:	e8 94 fe ff ff       	call   8016a5 <printfmt>
  801811:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801814:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801817:	e9 cc fe ff ff       	jmp    8016e8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80181c:	52                   	push   %edx
  80181d:	68 01 23 80 00       	push   $0x802301
  801822:	53                   	push   %ebx
  801823:	56                   	push   %esi
  801824:	e8 7c fe ff ff       	call   8016a5 <printfmt>
  801829:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80182f:	e9 b4 fe ff ff       	jmp    8016e8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801834:	8b 45 14             	mov    0x14(%ebp),%eax
  801837:	8d 50 04             	lea    0x4(%eax),%edx
  80183a:	89 55 14             	mov    %edx,0x14(%ebp)
  80183d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80183f:	85 ff                	test   %edi,%edi
  801841:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801846:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801849:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80184d:	0f 8e 94 00 00 00    	jle    8018e7 <vprintfmt+0x225>
  801853:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801857:	0f 84 98 00 00 00    	je     8018f5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	ff 75 d0             	pushl  -0x30(%ebp)
  801863:	57                   	push   %edi
  801864:	e8 86 02 00 00       	call   801aef <strnlen>
  801869:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80186c:	29 c1                	sub    %eax,%ecx
  80186e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801871:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801874:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801878:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80187b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80187e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801880:	eb 0f                	jmp    801891 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	53                   	push   %ebx
  801886:	ff 75 e0             	pushl  -0x20(%ebp)
  801889:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80188b:	83 ef 01             	sub    $0x1,%edi
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	85 ff                	test   %edi,%edi
  801893:	7f ed                	jg     801882 <vprintfmt+0x1c0>
  801895:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801898:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80189b:	85 c9                	test   %ecx,%ecx
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a2:	0f 49 c1             	cmovns %ecx,%eax
  8018a5:	29 c1                	sub    %eax,%ecx
  8018a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8018aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018b0:	89 cb                	mov    %ecx,%ebx
  8018b2:	eb 4d                	jmp    801901 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b8:	74 1b                	je     8018d5 <vprintfmt+0x213>
  8018ba:	0f be c0             	movsbl %al,%eax
  8018bd:	83 e8 20             	sub    $0x20,%eax
  8018c0:	83 f8 5e             	cmp    $0x5e,%eax
  8018c3:	76 10                	jbe    8018d5 <vprintfmt+0x213>
					putch('?', putdat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	6a 3f                	push   $0x3f
  8018cd:	ff 55 08             	call   *0x8(%ebp)
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	eb 0d                	jmp    8018e2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	52                   	push   %edx
  8018dc:	ff 55 08             	call   *0x8(%ebp)
  8018df:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018e2:	83 eb 01             	sub    $0x1,%ebx
  8018e5:	eb 1a                	jmp    801901 <vprintfmt+0x23f>
  8018e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f3:	eb 0c                	jmp    801901 <vprintfmt+0x23f>
  8018f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801901:	83 c7 01             	add    $0x1,%edi
  801904:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801908:	0f be d0             	movsbl %al,%edx
  80190b:	85 d2                	test   %edx,%edx
  80190d:	74 23                	je     801932 <vprintfmt+0x270>
  80190f:	85 f6                	test   %esi,%esi
  801911:	78 a1                	js     8018b4 <vprintfmt+0x1f2>
  801913:	83 ee 01             	sub    $0x1,%esi
  801916:	79 9c                	jns    8018b4 <vprintfmt+0x1f2>
  801918:	89 df                	mov    %ebx,%edi
  80191a:	8b 75 08             	mov    0x8(%ebp),%esi
  80191d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801920:	eb 18                	jmp    80193a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	53                   	push   %ebx
  801926:	6a 20                	push   $0x20
  801928:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80192a:	83 ef 01             	sub    $0x1,%edi
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	eb 08                	jmp    80193a <vprintfmt+0x278>
  801932:	89 df                	mov    %ebx,%edi
  801934:	8b 75 08             	mov    0x8(%ebp),%esi
  801937:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80193a:	85 ff                	test   %edi,%edi
  80193c:	7f e4                	jg     801922 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801941:	e9 a2 fd ff ff       	jmp    8016e8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801946:	83 fa 01             	cmp    $0x1,%edx
  801949:	7e 16                	jle    801961 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80194b:	8b 45 14             	mov    0x14(%ebp),%eax
  80194e:	8d 50 08             	lea    0x8(%eax),%edx
  801951:	89 55 14             	mov    %edx,0x14(%ebp)
  801954:	8b 50 04             	mov    0x4(%eax),%edx
  801957:	8b 00                	mov    (%eax),%eax
  801959:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195f:	eb 32                	jmp    801993 <vprintfmt+0x2d1>
	else if (lflag)
  801961:	85 d2                	test   %edx,%edx
  801963:	74 18                	je     80197d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801965:	8b 45 14             	mov    0x14(%ebp),%eax
  801968:	8d 50 04             	lea    0x4(%eax),%edx
  80196b:	89 55 14             	mov    %edx,0x14(%ebp)
  80196e:	8b 00                	mov    (%eax),%eax
  801970:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801973:	89 c1                	mov    %eax,%ecx
  801975:	c1 f9 1f             	sar    $0x1f,%ecx
  801978:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80197b:	eb 16                	jmp    801993 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80197d:	8b 45 14             	mov    0x14(%ebp),%eax
  801980:	8d 50 04             	lea    0x4(%eax),%edx
  801983:	89 55 14             	mov    %edx,0x14(%ebp)
  801986:	8b 00                	mov    (%eax),%eax
  801988:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198b:	89 c1                	mov    %eax,%ecx
  80198d:	c1 f9 1f             	sar    $0x1f,%ecx
  801990:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801993:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801996:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801999:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80199e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019a2:	79 74                	jns    801a18 <vprintfmt+0x356>
				putch('-', putdat);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	53                   	push   %ebx
  8019a8:	6a 2d                	push   $0x2d
  8019aa:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019af:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019b2:	f7 d8                	neg    %eax
  8019b4:	83 d2 00             	adc    $0x0,%edx
  8019b7:	f7 da                	neg    %edx
  8019b9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019c1:	eb 55                	jmp    801a18 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c6:	e8 83 fc ff ff       	call   80164e <getuint>
			base = 10;
  8019cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019d0:	eb 46                	jmp    801a18 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8019d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8019d5:	e8 74 fc ff ff       	call   80164e <getuint>
			base = 8;
  8019da:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019df:	eb 37                	jmp    801a18 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	53                   	push   %ebx
  8019e5:	6a 30                	push   $0x30
  8019e7:	ff d6                	call   *%esi
			putch('x', putdat);
  8019e9:	83 c4 08             	add    $0x8,%esp
  8019ec:	53                   	push   %ebx
  8019ed:	6a 78                	push   $0x78
  8019ef:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	8d 50 04             	lea    0x4(%eax),%edx
  8019f7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019fa:	8b 00                	mov    (%eax),%eax
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a01:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a04:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a09:	eb 0d                	jmp    801a18 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a0b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0e:	e8 3b fc ff ff       	call   80164e <getuint>
			base = 16;
  801a13:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a1f:	57                   	push   %edi
  801a20:	ff 75 e0             	pushl  -0x20(%ebp)
  801a23:	51                   	push   %ecx
  801a24:	52                   	push   %edx
  801a25:	50                   	push   %eax
  801a26:	89 da                	mov    %ebx,%edx
  801a28:	89 f0                	mov    %esi,%eax
  801a2a:	e8 70 fb ff ff       	call   80159f <printnum>
			break;
  801a2f:	83 c4 20             	add    $0x20,%esp
  801a32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a35:	e9 ae fc ff ff       	jmp    8016e8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	53                   	push   %ebx
  801a3e:	51                   	push   %ecx
  801a3f:	ff d6                	call   *%esi
			break;
  801a41:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a47:	e9 9c fc ff ff       	jmp    8016e8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a4c:	83 ec 08             	sub    $0x8,%esp
  801a4f:	53                   	push   %ebx
  801a50:	6a 25                	push   $0x25
  801a52:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	eb 03                	jmp    801a5c <vprintfmt+0x39a>
  801a59:	83 ef 01             	sub    $0x1,%edi
  801a5c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a60:	75 f7                	jne    801a59 <vprintfmt+0x397>
  801a62:	e9 81 fc ff ff       	jmp    8016e8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 18             	sub    $0x18,%esp
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a7e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a82:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	74 26                	je     801ab6 <vsnprintf+0x47>
  801a90:	85 d2                	test   %edx,%edx
  801a92:	7e 22                	jle    801ab6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a94:	ff 75 14             	pushl  0x14(%ebp)
  801a97:	ff 75 10             	pushl  0x10(%ebp)
  801a9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a9d:	50                   	push   %eax
  801a9e:	68 88 16 80 00       	push   $0x801688
  801aa3:	e8 1a fc ff ff       	call   8016c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	eb 05                	jmp    801abb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ab6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ac3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ac6:	50                   	push   %eax
  801ac7:	ff 75 10             	pushl  0x10(%ebp)
  801aca:	ff 75 0c             	pushl  0xc(%ebp)
  801acd:	ff 75 08             	pushl  0x8(%ebp)
  801ad0:	e8 9a ff ff ff       	call   801a6f <vsnprintf>
	va_end(ap);

	return rc;
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801add:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae2:	eb 03                	jmp    801ae7 <strlen+0x10>
		n++;
  801ae4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ae7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801aeb:	75 f7                	jne    801ae4 <strlen+0xd>
		n++;
	return n;
}
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801af8:	ba 00 00 00 00       	mov    $0x0,%edx
  801afd:	eb 03                	jmp    801b02 <strnlen+0x13>
		n++;
  801aff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b02:	39 c2                	cmp    %eax,%edx
  801b04:	74 08                	je     801b0e <strnlen+0x1f>
  801b06:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b0a:	75 f3                	jne    801aff <strnlen+0x10>
  801b0c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	53                   	push   %ebx
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b1a:	89 c2                	mov    %eax,%edx
  801b1c:	83 c2 01             	add    $0x1,%edx
  801b1f:	83 c1 01             	add    $0x1,%ecx
  801b22:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b26:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b29:	84 db                	test   %bl,%bl
  801b2b:	75 ef                	jne    801b1c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b2d:	5b                   	pop    %ebx
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	53                   	push   %ebx
  801b34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b37:	53                   	push   %ebx
  801b38:	e8 9a ff ff ff       	call   801ad7 <strlen>
  801b3d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b40:	ff 75 0c             	pushl  0xc(%ebp)
  801b43:	01 d8                	add    %ebx,%eax
  801b45:	50                   	push   %eax
  801b46:	e8 c5 ff ff ff       	call   801b10 <strcpy>
	return dst;
}
  801b4b:	89 d8                	mov    %ebx,%eax
  801b4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
  801b57:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5d:	89 f3                	mov    %esi,%ebx
  801b5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b62:	89 f2                	mov    %esi,%edx
  801b64:	eb 0f                	jmp    801b75 <strncpy+0x23>
		*dst++ = *src;
  801b66:	83 c2 01             	add    $0x1,%edx
  801b69:	0f b6 01             	movzbl (%ecx),%eax
  801b6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b6f:	80 39 01             	cmpb   $0x1,(%ecx)
  801b72:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b75:	39 da                	cmp    %ebx,%edx
  801b77:	75 ed                	jne    801b66 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b79:	89 f0                	mov    %esi,%eax
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	8b 75 08             	mov    0x8(%ebp),%esi
  801b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8a:	8b 55 10             	mov    0x10(%ebp),%edx
  801b8d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b8f:	85 d2                	test   %edx,%edx
  801b91:	74 21                	je     801bb4 <strlcpy+0x35>
  801b93:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	eb 09                	jmp    801ba4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b9b:	83 c2 01             	add    $0x1,%edx
  801b9e:	83 c1 01             	add    $0x1,%ecx
  801ba1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ba4:	39 c2                	cmp    %eax,%edx
  801ba6:	74 09                	je     801bb1 <strlcpy+0x32>
  801ba8:	0f b6 19             	movzbl (%ecx),%ebx
  801bab:	84 db                	test   %bl,%bl
  801bad:	75 ec                	jne    801b9b <strlcpy+0x1c>
  801baf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bb1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bb4:	29 f0                	sub    %esi,%eax
}
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bc3:	eb 06                	jmp    801bcb <strcmp+0x11>
		p++, q++;
  801bc5:	83 c1 01             	add    $0x1,%ecx
  801bc8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bcb:	0f b6 01             	movzbl (%ecx),%eax
  801bce:	84 c0                	test   %al,%al
  801bd0:	74 04                	je     801bd6 <strcmp+0x1c>
  801bd2:	3a 02                	cmp    (%edx),%al
  801bd4:	74 ef                	je     801bc5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bd6:	0f b6 c0             	movzbl %al,%eax
  801bd9:	0f b6 12             	movzbl (%edx),%edx
  801bdc:	29 d0                	sub    %edx,%eax
}
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	53                   	push   %ebx
  801be4:	8b 45 08             	mov    0x8(%ebp),%eax
  801be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801bef:	eb 06                	jmp    801bf7 <strncmp+0x17>
		n--, p++, q++;
  801bf1:	83 c0 01             	add    $0x1,%eax
  801bf4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bf7:	39 d8                	cmp    %ebx,%eax
  801bf9:	74 15                	je     801c10 <strncmp+0x30>
  801bfb:	0f b6 08             	movzbl (%eax),%ecx
  801bfe:	84 c9                	test   %cl,%cl
  801c00:	74 04                	je     801c06 <strncmp+0x26>
  801c02:	3a 0a                	cmp    (%edx),%cl
  801c04:	74 eb                	je     801bf1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c06:	0f b6 00             	movzbl (%eax),%eax
  801c09:	0f b6 12             	movzbl (%edx),%edx
  801c0c:	29 d0                	sub    %edx,%eax
  801c0e:	eb 05                	jmp    801c15 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c15:	5b                   	pop    %ebx
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c22:	eb 07                	jmp    801c2b <strchr+0x13>
		if (*s == c)
  801c24:	38 ca                	cmp    %cl,%dl
  801c26:	74 0f                	je     801c37 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c28:	83 c0 01             	add    $0x1,%eax
  801c2b:	0f b6 10             	movzbl (%eax),%edx
  801c2e:	84 d2                	test   %dl,%dl
  801c30:	75 f2                	jne    801c24 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c43:	eb 03                	jmp    801c48 <strfind+0xf>
  801c45:	83 c0 01             	add    $0x1,%eax
  801c48:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c4b:	38 ca                	cmp    %cl,%dl
  801c4d:	74 04                	je     801c53 <strfind+0x1a>
  801c4f:	84 d2                	test   %dl,%dl
  801c51:	75 f2                	jne    801c45 <strfind+0xc>
			break;
	return (char *) s;
}
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	57                   	push   %edi
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c61:	85 c9                	test   %ecx,%ecx
  801c63:	74 36                	je     801c9b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c65:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c6b:	75 28                	jne    801c95 <memset+0x40>
  801c6d:	f6 c1 03             	test   $0x3,%cl
  801c70:	75 23                	jne    801c95 <memset+0x40>
		c &= 0xFF;
  801c72:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c76:	89 d3                	mov    %edx,%ebx
  801c78:	c1 e3 08             	shl    $0x8,%ebx
  801c7b:	89 d6                	mov    %edx,%esi
  801c7d:	c1 e6 18             	shl    $0x18,%esi
  801c80:	89 d0                	mov    %edx,%eax
  801c82:	c1 e0 10             	shl    $0x10,%eax
  801c85:	09 f0                	or     %esi,%eax
  801c87:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801c89:	89 d8                	mov    %ebx,%eax
  801c8b:	09 d0                	or     %edx,%eax
  801c8d:	c1 e9 02             	shr    $0x2,%ecx
  801c90:	fc                   	cld    
  801c91:	f3 ab                	rep stos %eax,%es:(%edi)
  801c93:	eb 06                	jmp    801c9b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c98:	fc                   	cld    
  801c99:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c9b:	89 f8                	mov    %edi,%eax
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cb0:	39 c6                	cmp    %eax,%esi
  801cb2:	73 35                	jae    801ce9 <memmove+0x47>
  801cb4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cb7:	39 d0                	cmp    %edx,%eax
  801cb9:	73 2e                	jae    801ce9 <memmove+0x47>
		s += n;
		d += n;
  801cbb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cbe:	89 d6                	mov    %edx,%esi
  801cc0:	09 fe                	or     %edi,%esi
  801cc2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cc8:	75 13                	jne    801cdd <memmove+0x3b>
  801cca:	f6 c1 03             	test   $0x3,%cl
  801ccd:	75 0e                	jne    801cdd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ccf:	83 ef 04             	sub    $0x4,%edi
  801cd2:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cd5:	c1 e9 02             	shr    $0x2,%ecx
  801cd8:	fd                   	std    
  801cd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cdb:	eb 09                	jmp    801ce6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cdd:	83 ef 01             	sub    $0x1,%edi
  801ce0:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ce3:	fd                   	std    
  801ce4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ce6:	fc                   	cld    
  801ce7:	eb 1d                	jmp    801d06 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce9:	89 f2                	mov    %esi,%edx
  801ceb:	09 c2                	or     %eax,%edx
  801ced:	f6 c2 03             	test   $0x3,%dl
  801cf0:	75 0f                	jne    801d01 <memmove+0x5f>
  801cf2:	f6 c1 03             	test   $0x3,%cl
  801cf5:	75 0a                	jne    801d01 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801cf7:	c1 e9 02             	shr    $0x2,%ecx
  801cfa:	89 c7                	mov    %eax,%edi
  801cfc:	fc                   	cld    
  801cfd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801cff:	eb 05                	jmp    801d06 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d01:	89 c7                	mov    %eax,%edi
  801d03:	fc                   	cld    
  801d04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d06:	5e                   	pop    %esi
  801d07:	5f                   	pop    %edi
  801d08:	5d                   	pop    %ebp
  801d09:	c3                   	ret    

00801d0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d0d:	ff 75 10             	pushl  0x10(%ebp)
  801d10:	ff 75 0c             	pushl  0xc(%ebp)
  801d13:	ff 75 08             	pushl  0x8(%ebp)
  801d16:	e8 87 ff ff ff       	call   801ca2 <memmove>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d28:	89 c6                	mov    %eax,%esi
  801d2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d2d:	eb 1a                	jmp    801d49 <memcmp+0x2c>
		if (*s1 != *s2)
  801d2f:	0f b6 08             	movzbl (%eax),%ecx
  801d32:	0f b6 1a             	movzbl (%edx),%ebx
  801d35:	38 d9                	cmp    %bl,%cl
  801d37:	74 0a                	je     801d43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d39:	0f b6 c1             	movzbl %cl,%eax
  801d3c:	0f b6 db             	movzbl %bl,%ebx
  801d3f:	29 d8                	sub    %ebx,%eax
  801d41:	eb 0f                	jmp    801d52 <memcmp+0x35>
		s1++, s2++;
  801d43:	83 c0 01             	add    $0x1,%eax
  801d46:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d49:	39 f0                	cmp    %esi,%eax
  801d4b:	75 e2                	jne    801d2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	53                   	push   %ebx
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d5d:	89 c1                	mov    %eax,%ecx
  801d5f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d62:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d66:	eb 0a                	jmp    801d72 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d68:	0f b6 10             	movzbl (%eax),%edx
  801d6b:	39 da                	cmp    %ebx,%edx
  801d6d:	74 07                	je     801d76 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d6f:	83 c0 01             	add    $0x1,%eax
  801d72:	39 c8                	cmp    %ecx,%eax
  801d74:	72 f2                	jb     801d68 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d76:	5b                   	pop    %ebx
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	57                   	push   %edi
  801d7d:	56                   	push   %esi
  801d7e:	53                   	push   %ebx
  801d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d85:	eb 03                	jmp    801d8a <strtol+0x11>
		s++;
  801d87:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d8a:	0f b6 01             	movzbl (%ecx),%eax
  801d8d:	3c 20                	cmp    $0x20,%al
  801d8f:	74 f6                	je     801d87 <strtol+0xe>
  801d91:	3c 09                	cmp    $0x9,%al
  801d93:	74 f2                	je     801d87 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d95:	3c 2b                	cmp    $0x2b,%al
  801d97:	75 0a                	jne    801da3 <strtol+0x2a>
		s++;
  801d99:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801d9c:	bf 00 00 00 00       	mov    $0x0,%edi
  801da1:	eb 11                	jmp    801db4 <strtol+0x3b>
  801da3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801da8:	3c 2d                	cmp    $0x2d,%al
  801daa:	75 08                	jne    801db4 <strtol+0x3b>
		s++, neg = 1;
  801dac:	83 c1 01             	add    $0x1,%ecx
  801daf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801db4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dba:	75 15                	jne    801dd1 <strtol+0x58>
  801dbc:	80 39 30             	cmpb   $0x30,(%ecx)
  801dbf:	75 10                	jne    801dd1 <strtol+0x58>
  801dc1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dc5:	75 7c                	jne    801e43 <strtol+0xca>
		s += 2, base = 16;
  801dc7:	83 c1 02             	add    $0x2,%ecx
  801dca:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dcf:	eb 16                	jmp    801de7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dd1:	85 db                	test   %ebx,%ebx
  801dd3:	75 12                	jne    801de7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801dd5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dda:	80 39 30             	cmpb   $0x30,(%ecx)
  801ddd:	75 08                	jne    801de7 <strtol+0x6e>
		s++, base = 8;
  801ddf:	83 c1 01             	add    $0x1,%ecx
  801de2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801de7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801def:	0f b6 11             	movzbl (%ecx),%edx
  801df2:	8d 72 d0             	lea    -0x30(%edx),%esi
  801df5:	89 f3                	mov    %esi,%ebx
  801df7:	80 fb 09             	cmp    $0x9,%bl
  801dfa:	77 08                	ja     801e04 <strtol+0x8b>
			dig = *s - '0';
  801dfc:	0f be d2             	movsbl %dl,%edx
  801dff:	83 ea 30             	sub    $0x30,%edx
  801e02:	eb 22                	jmp    801e26 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e04:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e07:	89 f3                	mov    %esi,%ebx
  801e09:	80 fb 19             	cmp    $0x19,%bl
  801e0c:	77 08                	ja     801e16 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e0e:	0f be d2             	movsbl %dl,%edx
  801e11:	83 ea 57             	sub    $0x57,%edx
  801e14:	eb 10                	jmp    801e26 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e16:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e19:	89 f3                	mov    %esi,%ebx
  801e1b:	80 fb 19             	cmp    $0x19,%bl
  801e1e:	77 16                	ja     801e36 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e20:	0f be d2             	movsbl %dl,%edx
  801e23:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e26:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e29:	7d 0b                	jge    801e36 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e2b:	83 c1 01             	add    $0x1,%ecx
  801e2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e32:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e34:	eb b9                	jmp    801def <strtol+0x76>

	if (endptr)
  801e36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e3a:	74 0d                	je     801e49 <strtol+0xd0>
		*endptr = (char *) s;
  801e3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e3f:	89 0e                	mov    %ecx,(%esi)
  801e41:	eb 06                	jmp    801e49 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e43:	85 db                	test   %ebx,%ebx
  801e45:	74 98                	je     801ddf <strtol+0x66>
  801e47:	eb 9e                	jmp    801de7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e49:	89 c2                	mov    %eax,%edx
  801e4b:	f7 da                	neg    %edx
  801e4d:	85 ff                	test   %edi,%edi
  801e4f:	0f 45 c2             	cmovne %edx,%eax
}
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	56                   	push   %esi
  801e5b:	53                   	push   %ebx
  801e5c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e65:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e67:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e6c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	50                   	push   %eax
  801e73:	e8 96 e4 ff ff       	call   80030e <sys_ipc_recv>

	if (from_env_store != NULL)
  801e78:	83 c4 10             	add    $0x10,%esp
  801e7b:	85 f6                	test   %esi,%esi
  801e7d:	74 14                	je     801e93 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 09                	js     801e91 <ipc_recv+0x3a>
  801e88:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e8e:	8b 52 74             	mov    0x74(%edx),%edx
  801e91:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e93:	85 db                	test   %ebx,%ebx
  801e95:	74 14                	je     801eab <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e97:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 09                	js     801ea9 <ipc_recv+0x52>
  801ea0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ea6:	8b 52 78             	mov    0x78(%edx),%edx
  801ea9:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eab:	85 c0                	test   %eax,%eax
  801ead:	78 08                	js     801eb7 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801eaf:	a1 08 40 80 00       	mov    0x804008,%eax
  801eb4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eca:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ed0:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ed2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ed7:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801eda:	ff 75 14             	pushl  0x14(%ebp)
  801edd:	53                   	push   %ebx
  801ede:	56                   	push   %esi
  801edf:	57                   	push   %edi
  801ee0:	e8 06 e4 ff ff       	call   8002eb <sys_ipc_try_send>

		if (err < 0) {
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	79 1e                	jns    801f0a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801eec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eef:	75 07                	jne    801ef8 <ipc_send+0x3a>
				sys_yield();
  801ef1:	e8 49 e2 ff ff       	call   80013f <sys_yield>
  801ef6:	eb e2                	jmp    801eda <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801ef8:	50                   	push   %eax
  801ef9:	68 a0 26 80 00       	push   $0x8026a0
  801efe:	6a 49                	push   $0x49
  801f00:	68 ad 26 80 00       	push   $0x8026ad
  801f05:	e8 a8 f5 ff ff       	call   8014b2 <_panic>
		}

	} while (err < 0);

}
  801f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f18:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f1d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f20:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f26:	8b 52 50             	mov    0x50(%edx),%edx
  801f29:	39 ca                	cmp    %ecx,%edx
  801f2b:	75 0d                	jne    801f3a <ipc_find_env+0x28>
			return envs[i].env_id;
  801f2d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f30:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f35:	8b 40 48             	mov    0x48(%eax),%eax
  801f38:	eb 0f                	jmp    801f49 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3a:	83 c0 01             	add    $0x1,%eax
  801f3d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f42:	75 d9                	jne    801f1d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f51:	89 d0                	mov    %edx,%eax
  801f53:	c1 e8 16             	shr    $0x16,%eax
  801f56:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f62:	f6 c1 01             	test   $0x1,%cl
  801f65:	74 1d                	je     801f84 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f67:	c1 ea 0c             	shr    $0xc,%edx
  801f6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f71:	f6 c2 01             	test   $0x1,%dl
  801f74:	74 0e                	je     801f84 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f76:	c1 ea 0c             	shr    $0xc,%edx
  801f79:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f80:	ef 
  801f81:	0f b7 c0             	movzwl %ax,%eax
}
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
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
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
