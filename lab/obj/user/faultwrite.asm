
obj/user/faultwrite.debug:     file format elf32-i386


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
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
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
  80008e:	e8 e8 04 00 00       	call   80057b <close_all>
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
  800107:	68 6a 22 80 00       	push   $0x80226a
  80010c:	6a 23                	push   $0x23
  80010e:	68 87 22 80 00       	push   $0x802287
  800113:	e8 dc 13 00 00       	call   8014f4 <_panic>

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
  800188:	68 6a 22 80 00       	push   $0x80226a
  80018d:	6a 23                	push   $0x23
  80018f:	68 87 22 80 00       	push   $0x802287
  800194:	e8 5b 13 00 00       	call   8014f4 <_panic>

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
  8001ca:	68 6a 22 80 00       	push   $0x80226a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 87 22 80 00       	push   $0x802287
  8001d6:	e8 19 13 00 00       	call   8014f4 <_panic>

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
  80020c:	68 6a 22 80 00       	push   $0x80226a
  800211:	6a 23                	push   $0x23
  800213:	68 87 22 80 00       	push   $0x802287
  800218:	e8 d7 12 00 00       	call   8014f4 <_panic>

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
  80024e:	68 6a 22 80 00       	push   $0x80226a
  800253:	6a 23                	push   $0x23
  800255:	68 87 22 80 00       	push   $0x802287
  80025a:	e8 95 12 00 00       	call   8014f4 <_panic>

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
  800290:	68 6a 22 80 00       	push   $0x80226a
  800295:	6a 23                	push   $0x23
  800297:	68 87 22 80 00       	push   $0x802287
  80029c:	e8 53 12 00 00       	call   8014f4 <_panic>

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
  8002d2:	68 6a 22 80 00       	push   $0x80226a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 87 22 80 00       	push   $0x802287
  8002de:	e8 11 12 00 00       	call   8014f4 <_panic>

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
  800336:	68 6a 22 80 00       	push   $0x80226a
  80033b:	6a 23                	push   $0x23
  80033d:	68 87 22 80 00       	push   $0x802287
  800342:	e8 ad 11 00 00       	call   8014f4 <_panic>

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
  800397:	68 6a 22 80 00       	push   $0x80226a
  80039c:	6a 23                	push   $0x23
  80039e:	68 87 22 80 00       	push   $0x802287
  8003a3:	e8 4c 11 00 00       	call   8014f4 <_panic>

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

008003b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003dd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e2:	89 c2                	mov    %eax,%edx
  8003e4:	c1 ea 16             	shr    $0x16,%edx
  8003e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ee:	f6 c2 01             	test   $0x1,%dl
  8003f1:	74 11                	je     800404 <fd_alloc+0x2d>
  8003f3:	89 c2                	mov    %eax,%edx
  8003f5:	c1 ea 0c             	shr    $0xc,%edx
  8003f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ff:	f6 c2 01             	test   $0x1,%dl
  800402:	75 09                	jne    80040d <fd_alloc+0x36>
			*fd_store = fd;
  800404:	89 01                	mov    %eax,(%ecx)
			return 0;
  800406:	b8 00 00 00 00       	mov    $0x0,%eax
  80040b:	eb 17                	jmp    800424 <fd_alloc+0x4d>
  80040d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800412:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800417:	75 c9                	jne    8003e2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800419:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80041f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80042c:	83 f8 1f             	cmp    $0x1f,%eax
  80042f:	77 36                	ja     800467 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800431:	c1 e0 0c             	shl    $0xc,%eax
  800434:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800439:	89 c2                	mov    %eax,%edx
  80043b:	c1 ea 16             	shr    $0x16,%edx
  80043e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800445:	f6 c2 01             	test   $0x1,%dl
  800448:	74 24                	je     80046e <fd_lookup+0x48>
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	c1 ea 0c             	shr    $0xc,%edx
  80044f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800456:	f6 c2 01             	test   $0x1,%dl
  800459:	74 1a                	je     800475 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80045b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045e:	89 02                	mov    %eax,(%edx)
	return 0;
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
  800465:	eb 13                	jmp    80047a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046c:	eb 0c                	jmp    80047a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80046e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800473:	eb 05                	jmp    80047a <fd_lookup+0x54>
  800475:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80047a:	5d                   	pop    %ebp
  80047b:	c3                   	ret    

0080047c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800485:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048a:	eb 13                	jmp    80049f <dev_lookup+0x23>
  80048c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80048f:	39 08                	cmp    %ecx,(%eax)
  800491:	75 0c                	jne    80049f <dev_lookup+0x23>
			*dev = devtab[i];
  800493:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800496:	89 01                	mov    %eax,(%ecx)
			return 0;
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	eb 2e                	jmp    8004cd <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	85 c0                	test   %eax,%eax
  8004a3:	75 e7                	jne    80048c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8004aa:	8b 40 48             	mov    0x48(%eax),%eax
  8004ad:	83 ec 04             	sub    $0x4,%esp
  8004b0:	51                   	push   %ecx
  8004b1:	50                   	push   %eax
  8004b2:	68 98 22 80 00       	push   $0x802298
  8004b7:	e8 11 11 00 00       	call   8015cd <cprintf>
	*dev = 0;
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004cd:	c9                   	leave  
  8004ce:	c3                   	ret    

008004cf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	56                   	push   %esi
  8004d3:	53                   	push   %ebx
  8004d4:	83 ec 10             	sub    $0x10,%esp
  8004d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e0:	50                   	push   %eax
  8004e1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e7:	c1 e8 0c             	shr    $0xc,%eax
  8004ea:	50                   	push   %eax
  8004eb:	e8 36 ff ff ff       	call   800426 <fd_lookup>
  8004f0:	83 c4 08             	add    $0x8,%esp
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	78 05                	js     8004fc <fd_close+0x2d>
	    || fd != fd2)
  8004f7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004fa:	74 0c                	je     800508 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004fc:	84 db                	test   %bl,%bl
  8004fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800503:	0f 44 c2             	cmove  %edx,%eax
  800506:	eb 41                	jmp    800549 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	ff 36                	pushl  (%esi)
  800511:	e8 66 ff ff ff       	call   80047c <dev_lookup>
  800516:	89 c3                	mov    %eax,%ebx
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 1a                	js     800539 <fd_close+0x6a>
		if (dev->dev_close)
  80051f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800522:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800525:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80052a:	85 c0                	test   %eax,%eax
  80052c:	74 0b                	je     800539 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	56                   	push   %esi
  800532:	ff d0                	call   *%eax
  800534:	89 c3                	mov    %eax,%ebx
  800536:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	56                   	push   %esi
  80053d:	6a 00                	push   $0x0
  80053f:	e8 9f fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	89 d8                	mov    %ebx,%eax
}
  800549:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80054c:	5b                   	pop    %ebx
  80054d:	5e                   	pop    %esi
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800556:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800559:	50                   	push   %eax
  80055a:	ff 75 08             	pushl  0x8(%ebp)
  80055d:	e8 c4 fe ff ff       	call   800426 <fd_lookup>
  800562:	83 c4 08             	add    $0x8,%esp
  800565:	85 c0                	test   %eax,%eax
  800567:	78 10                	js     800579 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	6a 01                	push   $0x1
  80056e:	ff 75 f4             	pushl  -0xc(%ebp)
  800571:	e8 59 ff ff ff       	call   8004cf <fd_close>
  800576:	83 c4 10             	add    $0x10,%esp
}
  800579:	c9                   	leave  
  80057a:	c3                   	ret    

0080057b <close_all>:

void
close_all(void)
{
  80057b:	55                   	push   %ebp
  80057c:	89 e5                	mov    %esp,%ebp
  80057e:	53                   	push   %ebx
  80057f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800582:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800587:	83 ec 0c             	sub    $0xc,%esp
  80058a:	53                   	push   %ebx
  80058b:	e8 c0 ff ff ff       	call   800550 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800590:	83 c3 01             	add    $0x1,%ebx
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 fb 20             	cmp    $0x20,%ebx
  800599:	75 ec                	jne    800587 <close_all+0xc>
		close(i);
}
  80059b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059e:	c9                   	leave  
  80059f:	c3                   	ret    

008005a0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	57                   	push   %edi
  8005a4:	56                   	push   %esi
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 2c             	sub    $0x2c,%esp
  8005a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	ff 75 08             	pushl  0x8(%ebp)
  8005b3:	e8 6e fe ff ff       	call   800426 <fd_lookup>
  8005b8:	83 c4 08             	add    $0x8,%esp
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	0f 88 c1 00 00 00    	js     800684 <dup+0xe4>
		return r;
	close(newfdnum);
  8005c3:	83 ec 0c             	sub    $0xc,%esp
  8005c6:	56                   	push   %esi
  8005c7:	e8 84 ff ff ff       	call   800550 <close>

	newfd = INDEX2FD(newfdnum);
  8005cc:	89 f3                	mov    %esi,%ebx
  8005ce:	c1 e3 0c             	shl    $0xc,%ebx
  8005d1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005d7:	83 c4 04             	add    $0x4,%esp
  8005da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005dd:	e8 de fd ff ff       	call   8003c0 <fd2data>
  8005e2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005e4:	89 1c 24             	mov    %ebx,(%esp)
  8005e7:	e8 d4 fd ff ff       	call   8003c0 <fd2data>
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f2:	89 f8                	mov    %edi,%eax
  8005f4:	c1 e8 16             	shr    $0x16,%eax
  8005f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005fe:	a8 01                	test   $0x1,%al
  800600:	74 37                	je     800639 <dup+0x99>
  800602:	89 f8                	mov    %edi,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80060e:	f6 c2 01             	test   $0x1,%dl
  800611:	74 26                	je     800639 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800613:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	25 07 0e 00 00       	and    $0xe07,%eax
  800622:	50                   	push   %eax
  800623:	ff 75 d4             	pushl  -0x2c(%ebp)
  800626:	6a 00                	push   $0x0
  800628:	57                   	push   %edi
  800629:	6a 00                	push   $0x0
  80062b:	e8 71 fb ff ff       	call   8001a1 <sys_page_map>
  800630:	89 c7                	mov    %eax,%edi
  800632:	83 c4 20             	add    $0x20,%esp
  800635:	85 c0                	test   %eax,%eax
  800637:	78 2e                	js     800667 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800639:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063c:	89 d0                	mov    %edx,%eax
  80063e:	c1 e8 0c             	shr    $0xc,%eax
  800641:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	25 07 0e 00 00       	and    $0xe07,%eax
  800650:	50                   	push   %eax
  800651:	53                   	push   %ebx
  800652:	6a 00                	push   $0x0
  800654:	52                   	push   %edx
  800655:	6a 00                	push   $0x0
  800657:	e8 45 fb ff ff       	call   8001a1 <sys_page_map>
  80065c:	89 c7                	mov    %eax,%edi
  80065e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800661:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800663:	85 ff                	test   %edi,%edi
  800665:	79 1d                	jns    800684 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 00                	push   $0x0
  80066d:	e8 71 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	ff 75 d4             	pushl  -0x2c(%ebp)
  800678:	6a 00                	push   $0x0
  80067a:	e8 64 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	89 f8                	mov    %edi,%eax
}
  800684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800687:	5b                   	pop    %ebx
  800688:	5e                   	pop    %esi
  800689:	5f                   	pop    %edi
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	53                   	push   %ebx
  800690:	83 ec 14             	sub    $0x14,%esp
  800693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	53                   	push   %ebx
  80069b:	e8 86 fd ff ff       	call   800426 <fd_lookup>
  8006a0:	83 c4 08             	add    $0x8,%esp
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	78 6d                	js     800716 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006af:	50                   	push   %eax
  8006b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b3:	ff 30                	pushl  (%eax)
  8006b5:	e8 c2 fd ff ff       	call   80047c <dev_lookup>
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	78 4c                	js     80070d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006c4:	8b 42 08             	mov    0x8(%edx),%eax
  8006c7:	83 e0 03             	and    $0x3,%eax
  8006ca:	83 f8 01             	cmp    $0x1,%eax
  8006cd:	75 21                	jne    8006f0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8006d4:	8b 40 48             	mov    0x48(%eax),%eax
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	53                   	push   %ebx
  8006db:	50                   	push   %eax
  8006dc:	68 d9 22 80 00       	push   $0x8022d9
  8006e1:	e8 e7 0e 00 00       	call   8015cd <cprintf>
		return -E_INVAL;
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ee:	eb 26                	jmp    800716 <read+0x8a>
	}
	if (!dev->dev_read)
  8006f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f3:	8b 40 08             	mov    0x8(%eax),%eax
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 17                	je     800711 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006fa:	83 ec 04             	sub    $0x4,%esp
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	52                   	push   %edx
  800704:	ff d0                	call   *%eax
  800706:	89 c2                	mov    %eax,%edx
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 09                	jmp    800716 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070d:	89 c2                	mov    %eax,%edx
  80070f:	eb 05                	jmp    800716 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800716:	89 d0                	mov    %edx,%eax
  800718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    

0080071d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	57                   	push   %edi
  800721:	56                   	push   %esi
  800722:	53                   	push   %ebx
  800723:	83 ec 0c             	sub    $0xc,%esp
  800726:	8b 7d 08             	mov    0x8(%ebp),%edi
  800729:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800731:	eb 21                	jmp    800754 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800733:	83 ec 04             	sub    $0x4,%esp
  800736:	89 f0                	mov    %esi,%eax
  800738:	29 d8                	sub    %ebx,%eax
  80073a:	50                   	push   %eax
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	03 45 0c             	add    0xc(%ebp),%eax
  800740:	50                   	push   %eax
  800741:	57                   	push   %edi
  800742:	e8 45 ff ff ff       	call   80068c <read>
		if (m < 0)
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	85 c0                	test   %eax,%eax
  80074c:	78 10                	js     80075e <readn+0x41>
			return m;
		if (m == 0)
  80074e:	85 c0                	test   %eax,%eax
  800750:	74 0a                	je     80075c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800752:	01 c3                	add    %eax,%ebx
  800754:	39 f3                	cmp    %esi,%ebx
  800756:	72 db                	jb     800733 <readn+0x16>
  800758:	89 d8                	mov    %ebx,%eax
  80075a:	eb 02                	jmp    80075e <readn+0x41>
  80075c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80075e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	83 ec 14             	sub    $0x14,%esp
  80076d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800770:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800773:	50                   	push   %eax
  800774:	53                   	push   %ebx
  800775:	e8 ac fc ff ff       	call   800426 <fd_lookup>
  80077a:	83 c4 08             	add    $0x8,%esp
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	85 c0                	test   %eax,%eax
  800781:	78 68                	js     8007eb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078d:	ff 30                	pushl  (%eax)
  80078f:	e8 e8 fc ff ff       	call   80047c <dev_lookup>
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	85 c0                	test   %eax,%eax
  800799:	78 47                	js     8007e2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007a2:	75 21                	jne    8007c5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8007a9:	8b 40 48             	mov    0x48(%eax),%eax
  8007ac:	83 ec 04             	sub    $0x4,%esp
  8007af:	53                   	push   %ebx
  8007b0:	50                   	push   %eax
  8007b1:	68 f5 22 80 00       	push   $0x8022f5
  8007b6:	e8 12 0e 00 00       	call   8015cd <cprintf>
		return -E_INVAL;
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007c3:	eb 26                	jmp    8007eb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 17                	je     8007e6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007cf:	83 ec 04             	sub    $0x4,%esp
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	50                   	push   %eax
  8007d9:	ff d2                	call   *%edx
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	eb 09                	jmp    8007eb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	eb 05                	jmp    8007eb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007eb:	89 d0                	mov    %edx,%eax
  8007ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007fb:	50                   	push   %eax
  8007fc:	ff 75 08             	pushl  0x8(%ebp)
  8007ff:	e8 22 fc ff ff       	call   800426 <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	85 c0                	test   %eax,%eax
  800809:	78 0e                	js     800819 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80080b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	83 ec 14             	sub    $0x14,%esp
  800822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	53                   	push   %ebx
  80082a:	e8 f7 fb ff ff       	call   800426 <fd_lookup>
  80082f:	83 c4 08             	add    $0x8,%esp
  800832:	89 c2                	mov    %eax,%edx
  800834:	85 c0                	test   %eax,%eax
  800836:	78 65                	js     80089d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083e:	50                   	push   %eax
  80083f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800842:	ff 30                	pushl  (%eax)
  800844:	e8 33 fc ff ff       	call   80047c <dev_lookup>
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 44                	js     800894 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800853:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800857:	75 21                	jne    80087a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800859:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085e:	8b 40 48             	mov    0x48(%eax),%eax
  800861:	83 ec 04             	sub    $0x4,%esp
  800864:	53                   	push   %ebx
  800865:	50                   	push   %eax
  800866:	68 b8 22 80 00       	push   $0x8022b8
  80086b:	e8 5d 0d 00 00       	call   8015cd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800878:	eb 23                	jmp    80089d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80087a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80087d:	8b 52 18             	mov    0x18(%edx),%edx
  800880:	85 d2                	test   %edx,%edx
  800882:	74 14                	je     800898 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	ff 75 0c             	pushl  0xc(%ebp)
  80088a:	50                   	push   %eax
  80088b:	ff d2                	call   *%edx
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	eb 09                	jmp    80089d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800894:	89 c2                	mov    %eax,%edx
  800896:	eb 05                	jmp    80089d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800898:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	83 ec 14             	sub    $0x14,%esp
  8008ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b1:	50                   	push   %eax
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 6c fb ff ff       	call   800426 <fd_lookup>
  8008ba:	83 c4 08             	add    $0x8,%esp
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	78 58                	js     80091b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cd:	ff 30                	pushl  (%eax)
  8008cf:	e8 a8 fb ff ff       	call   80047c <dev_lookup>
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	78 37                	js     800912 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e2:	74 32                	je     800916 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ee:	00 00 00 
	stat->st_isdir = 0;
  8008f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f8:	00 00 00 
	stat->st_dev = dev;
  8008fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	53                   	push   %ebx
  800905:	ff 75 f0             	pushl  -0x10(%ebp)
  800908:	ff 50 14             	call   *0x14(%eax)
  80090b:	89 c2                	mov    %eax,%edx
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	eb 09                	jmp    80091b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800912:	89 c2                	mov    %eax,%edx
  800914:	eb 05                	jmp    80091b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800916:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	6a 00                	push   $0x0
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 d6 01 00 00       	call   800b0a <open>
  800934:	89 c3                	mov    %eax,%ebx
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	85 c0                	test   %eax,%eax
  80093b:	78 1b                	js     800958 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	50                   	push   %eax
  800944:	e8 5b ff ff ff       	call   8008a4 <fstat>
  800949:	89 c6                	mov    %eax,%esi
	close(fd);
  80094b:	89 1c 24             	mov    %ebx,(%esp)
  80094e:	e8 fd fb ff ff       	call   800550 <close>
	return r;
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	89 f0                	mov    %esi,%eax
}
  800958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	89 c6                	mov    %eax,%esi
  800966:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800968:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80096f:	75 12                	jne    800983 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800971:	83 ec 0c             	sub    $0xc,%esp
  800974:	6a 01                	push   $0x1
  800976:	e8 d9 15 00 00       	call   801f54 <ipc_find_env>
  80097b:	a3 00 40 80 00       	mov    %eax,0x804000
  800980:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800983:	6a 07                	push   $0x7
  800985:	68 00 50 80 00       	push   $0x805000
  80098a:	56                   	push   %esi
  80098b:	ff 35 00 40 80 00    	pushl  0x804000
  800991:	e8 6a 15 00 00       	call   801f00 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800996:	83 c4 0c             	add    $0xc,%esp
  800999:	6a 00                	push   $0x0
  80099b:	53                   	push   %ebx
  80099c:	6a 00                	push   $0x0
  80099e:	e8 f6 14 00 00       	call   801e99 <ipc_recv>
}
  8009a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8009cd:	e8 8d ff ff ff       	call   80095f <fsipc>
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ef:	e8 6b ff ff ff       	call   80095f <fsipc>
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	83 ec 04             	sub    $0x4,%esp
  8009fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 40 0c             	mov    0xc(%eax),%eax
  800a06:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a10:	b8 05 00 00 00       	mov    $0x5,%eax
  800a15:	e8 45 ff ff ff       	call   80095f <fsipc>
  800a1a:	85 c0                	test   %eax,%eax
  800a1c:	78 2c                	js     800a4a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	68 00 50 80 00       	push   $0x805000
  800a26:	53                   	push   %ebx
  800a27:	e8 26 11 00 00       	call   801b52 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a2c:	a1 80 50 80 00       	mov    0x805080,%eax
  800a31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a37:	a1 84 50 80 00       	mov    0x805084,%eax
  800a3c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a42:	83 c4 10             	add    $0x10,%esp
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	83 ec 0c             	sub    $0xc,%esp
  800a55:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	8b 52 0c             	mov    0xc(%edx),%edx
  800a5e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a64:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a69:	50                   	push   %eax
  800a6a:	ff 75 0c             	pushl  0xc(%ebp)
  800a6d:	68 08 50 80 00       	push   $0x805008
  800a72:	e8 6d 12 00 00       	call   801ce4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a81:	e8 d9 fe ff ff       	call   80095f <fsipc>

}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 40 0c             	mov    0xc(%eax),%eax
  800a96:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a9b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aab:	e8 af fe ff ff       	call   80095f <fsipc>
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	78 4b                	js     800b01 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 16                	jae    800ad0 <devfile_read+0x48>
  800aba:	68 28 23 80 00       	push   $0x802328
  800abf:	68 2f 23 80 00       	push   $0x80232f
  800ac4:	6a 7c                	push   $0x7c
  800ac6:	68 44 23 80 00       	push   $0x802344
  800acb:	e8 24 0a 00 00       	call   8014f4 <_panic>
	assert(r <= PGSIZE);
  800ad0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad5:	7e 16                	jle    800aed <devfile_read+0x65>
  800ad7:	68 4f 23 80 00       	push   $0x80234f
  800adc:	68 2f 23 80 00       	push   $0x80232f
  800ae1:	6a 7d                	push   $0x7d
  800ae3:	68 44 23 80 00       	push   $0x802344
  800ae8:	e8 07 0a 00 00       	call   8014f4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aed:	83 ec 04             	sub    $0x4,%esp
  800af0:	50                   	push   %eax
  800af1:	68 00 50 80 00       	push   $0x805000
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	e8 e6 11 00 00       	call   801ce4 <memmove>
	return r;
  800afe:	83 c4 10             	add    $0x10,%esp
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 20             	sub    $0x20,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b14:	53                   	push   %ebx
  800b15:	e8 ff 0f 00 00       	call   801b19 <strlen>
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b22:	7f 67                	jg     800b8b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	e8 a7 f8 ff ff       	call   8003d7 <fd_alloc>
  800b30:	83 c4 10             	add    $0x10,%esp
		return r;
  800b33:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	78 57                	js     800b90 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b39:	83 ec 08             	sub    $0x8,%esp
  800b3c:	53                   	push   %ebx
  800b3d:	68 00 50 80 00       	push   $0x805000
  800b42:	e8 0b 10 00 00       	call   801b52 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	e8 03 fe ff ff       	call   80095f <fsipc>
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	85 c0                	test   %eax,%eax
  800b63:	79 14                	jns    800b79 <open+0x6f>
		fd_close(fd, 0);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6d:	e8 5d f9 ff ff       	call   8004cf <fd_close>
		return r;
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	89 da                	mov    %ebx,%edx
  800b77:	eb 17                	jmp    800b90 <open+0x86>
	}

	return fd2num(fd);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7f:	e8 2c f8 ff ff       	call   8003b0 <fd2num>
  800b84:	89 c2                	mov    %eax,%edx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 05                	jmp    800b90 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b8b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b90:	89 d0                	mov    %edx,%eax
  800b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba7:	e8 b3 fd ff ff       	call   80095f <fsipc>
}
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bb4:	68 5b 23 80 00       	push   $0x80235b
  800bb9:	ff 75 0c             	pushl  0xc(%ebp)
  800bbc:	e8 91 0f 00 00       	call   801b52 <strcpy>
	return 0;
}
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 10             	sub    $0x10,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bd2:	53                   	push   %ebx
  800bd3:	e8 b5 13 00 00       	call   801f8d <pageref>
  800bd8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800be0:	83 f8 01             	cmp    $0x1,%eax
  800be3:	75 10                	jne    800bf5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	ff 73 0c             	pushl  0xc(%ebx)
  800beb:	e8 c0 02 00 00       	call   800eb0 <nsipc_close>
  800bf0:	89 c2                	mov    %eax,%edx
  800bf2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bf5:	89 d0                	mov    %edx,%eax
  800bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c02:	6a 00                	push   $0x0
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	ff 70 0c             	pushl  0xc(%eax)
  800c10:	e8 78 03 00 00       	call   800f8d <nsipc_send>
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c1d:	6a 00                	push   $0x0
  800c1f:	ff 75 10             	pushl  0x10(%ebp)
  800c22:	ff 75 0c             	pushl  0xc(%ebp)
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	ff 70 0c             	pushl  0xc(%eax)
  800c2b:	e8 f1 02 00 00       	call   800f21 <nsipc_recv>
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c38:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c3b:	52                   	push   %edx
  800c3c:	50                   	push   %eax
  800c3d:	e8 e4 f7 ff ff       	call   800426 <fd_lookup>
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	85 c0                	test   %eax,%eax
  800c47:	78 17                	js     800c60 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c52:	39 08                	cmp    %ecx,(%eax)
  800c54:	75 05                	jne    800c5b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c56:	8b 40 0c             	mov    0xc(%eax),%eax
  800c59:	eb 05                	jmp    800c60 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c5b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 1c             	sub    $0x1c,%esp
  800c6a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6f:	50                   	push   %eax
  800c70:	e8 62 f7 ff ff       	call   8003d7 <fd_alloc>
  800c75:	89 c3                	mov    %eax,%ebx
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 1b                	js     800c99 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c7e:	83 ec 04             	sub    $0x4,%esp
  800c81:	68 07 04 00 00       	push   $0x407
  800c86:	ff 75 f4             	pushl  -0xc(%ebp)
  800c89:	6a 00                	push   $0x0
  800c8b:	e8 ce f4 ff ff       	call   80015e <sys_page_alloc>
  800c90:	89 c3                	mov    %eax,%ebx
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	85 c0                	test   %eax,%eax
  800c97:	79 10                	jns    800ca9 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	56                   	push   %esi
  800c9d:	e8 0e 02 00 00       	call   800eb0 <nsipc_close>
		return r;
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	89 d8                	mov    %ebx,%eax
  800ca7:	eb 24                	jmp    800ccd <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cbe:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	e8 e6 f6 ff ff       	call   8003b0 <fd2num>
  800cca:	83 c4 10             	add    $0x10,%esp
}
  800ccd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	e8 50 ff ff ff       	call   800c32 <fd2sockid>
		return r;
  800ce2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	78 1f                	js     800d07 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	ff 75 10             	pushl  0x10(%ebp)
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	50                   	push   %eax
  800cf2:	e8 12 01 00 00       	call   800e09 <nsipc_accept>
  800cf7:	83 c4 10             	add    $0x10,%esp
		return r;
  800cfa:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 07                	js     800d07 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d00:	e8 5d ff ff ff       	call   800c62 <alloc_sockfd>
  800d05:	89 c1                	mov    %eax,%ecx
}
  800d07:	89 c8                	mov    %ecx,%eax
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	e8 19 ff ff ff       	call   800c32 <fd2sockid>
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	78 12                	js     800d2f <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d1d:	83 ec 04             	sub    $0x4,%esp
  800d20:	ff 75 10             	pushl  0x10(%ebp)
  800d23:	ff 75 0c             	pushl  0xc(%ebp)
  800d26:	50                   	push   %eax
  800d27:	e8 2d 01 00 00       	call   800e59 <nsipc_bind>
  800d2c:	83 c4 10             	add    $0x10,%esp
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <shutdown>:

int
shutdown(int s, int how)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	e8 f3 fe ff ff       	call   800c32 <fd2sockid>
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	78 0f                	js     800d52 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	ff 75 0c             	pushl  0xc(%ebp)
  800d49:	50                   	push   %eax
  800d4a:	e8 3f 01 00 00       	call   800e8e <nsipc_shutdown>
  800d4f:	83 c4 10             	add    $0x10,%esp
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	e8 d0 fe ff ff       	call   800c32 <fd2sockid>
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 12                	js     800d78 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	ff 75 10             	pushl  0x10(%ebp)
  800d6c:	ff 75 0c             	pushl  0xc(%ebp)
  800d6f:	50                   	push   %eax
  800d70:	e8 55 01 00 00       	call   800eca <nsipc_connect>
  800d75:	83 c4 10             	add    $0x10,%esp
}
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <listen>:

int
listen(int s, int backlog)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	e8 aa fe ff ff       	call   800c32 <fd2sockid>
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	78 0f                	js     800d9b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	50                   	push   %eax
  800d93:	e8 67 01 00 00       	call   800eff <nsipc_listen>
  800d98:	83 c4 10             	add    $0x10,%esp
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800da3:	ff 75 10             	pushl  0x10(%ebp)
  800da6:	ff 75 0c             	pushl  0xc(%ebp)
  800da9:	ff 75 08             	pushl  0x8(%ebp)
  800dac:	e8 3a 02 00 00       	call   800feb <nsipc_socket>
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 05                	js     800dbd <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db8:	e8 a5 fe ff ff       	call   800c62 <alloc_sockfd>
}
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 04             	sub    $0x4,%esp
  800dc6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dcf:	75 12                	jne    800de3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	6a 02                	push   $0x2
  800dd6:	e8 79 11 00 00       	call   801f54 <ipc_find_env>
  800ddb:	a3 04 40 80 00       	mov    %eax,0x804004
  800de0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800de3:	6a 07                	push   $0x7
  800de5:	68 00 60 80 00       	push   $0x806000
  800dea:	53                   	push   %ebx
  800deb:	ff 35 04 40 80 00    	pushl  0x804004
  800df1:	e8 0a 11 00 00       	call   801f00 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800df6:	83 c4 0c             	add    $0xc,%esp
  800df9:	6a 00                	push   $0x0
  800dfb:	6a 00                	push   $0x0
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 95 10 00 00       	call   801e99 <ipc_recv>
}
  800e04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e19:	8b 06                	mov    (%esi),%eax
  800e1b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e20:	b8 01 00 00 00       	mov    $0x1,%eax
  800e25:	e8 95 ff ff ff       	call   800dbf <nsipc>
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 20                	js     800e50 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	ff 35 10 60 80 00    	pushl  0x806010
  800e39:	68 00 60 80 00       	push   $0x806000
  800e3e:	ff 75 0c             	pushl  0xc(%ebp)
  800e41:	e8 9e 0e 00 00       	call   801ce4 <memmove>
		*addrlen = ret->ret_addrlen;
  800e46:	a1 10 60 80 00       	mov    0x806010,%eax
  800e4b:	89 06                	mov    %eax,(%esi)
  800e4d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e6b:	53                   	push   %ebx
  800e6c:	ff 75 0c             	pushl  0xc(%ebp)
  800e6f:	68 04 60 80 00       	push   $0x806004
  800e74:	e8 6b 0e 00 00       	call   801ce4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e79:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e7f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e84:	e8 36 ff ff ff       	call   800dbf <nsipc>
}
  800e89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea9:	e8 11 ff ff ff       	call   800dbf <nsipc>
}
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ebe:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec3:	e8 f7 fe ff ff       	call   800dbf <nsipc>
}
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    

00800eca <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800edc:	53                   	push   %ebx
  800edd:	ff 75 0c             	pushl  0xc(%ebp)
  800ee0:	68 04 60 80 00       	push   $0x806004
  800ee5:	e8 fa 0d 00 00       	call   801ce4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eea:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ef0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef5:	e8 c5 fe ff ff       	call   800dbf <nsipc>
}
  800efa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f10:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f15:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1a:	e8 a0 fe ff ff       	call   800dbf <nsipc>
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f31:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f37:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f3f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f44:	e8 76 fe ff ff       	call   800dbf <nsipc>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 35                	js     800f84 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f4f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f54:	7f 04                	jg     800f5a <nsipc_recv+0x39>
  800f56:	39 c6                	cmp    %eax,%esi
  800f58:	7d 16                	jge    800f70 <nsipc_recv+0x4f>
  800f5a:	68 67 23 80 00       	push   $0x802367
  800f5f:	68 2f 23 80 00       	push   $0x80232f
  800f64:	6a 62                	push   $0x62
  800f66:	68 7c 23 80 00       	push   $0x80237c
  800f6b:	e8 84 05 00 00       	call   8014f4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	50                   	push   %eax
  800f74:	68 00 60 80 00       	push   $0x806000
  800f79:	ff 75 0c             	pushl  0xc(%ebp)
  800f7c:	e8 63 0d 00 00       	call   801ce4 <memmove>
  800f81:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f84:	89 d8                	mov    %ebx,%eax
  800f86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	53                   	push   %ebx
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f9f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fa5:	7e 16                	jle    800fbd <nsipc_send+0x30>
  800fa7:	68 88 23 80 00       	push   $0x802388
  800fac:	68 2f 23 80 00       	push   $0x80232f
  800fb1:	6a 6d                	push   $0x6d
  800fb3:	68 7c 23 80 00       	push   $0x80237c
  800fb8:	e8 37 05 00 00       	call   8014f4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	ff 75 0c             	pushl  0xc(%ebp)
  800fc4:	68 0c 60 80 00       	push   $0x80600c
  800fc9:	e8 16 0d 00 00       	call   801ce4 <memmove>
	nsipcbuf.send.req_size = size;
  800fce:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe1:	e8 d9 fd ff ff       	call   800dbf <nsipc>
}
  800fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801001:	8b 45 10             	mov    0x10(%ebp),%eax
  801004:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801009:	b8 09 00 00 00       	mov    $0x9,%eax
  80100e:	e8 ac fd ff ff       	call   800dbf <nsipc>
}
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	ff 75 08             	pushl  0x8(%ebp)
  801023:	e8 98 f3 ff ff       	call   8003c0 <fd2data>
  801028:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80102a:	83 c4 08             	add    $0x8,%esp
  80102d:	68 94 23 80 00       	push   $0x802394
  801032:	53                   	push   %ebx
  801033:	e8 1a 0b 00 00       	call   801b52 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801038:	8b 46 04             	mov    0x4(%esi),%eax
  80103b:	2b 06                	sub    (%esi),%eax
  80103d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801043:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80104a:	00 00 00 
	stat->st_dev = &devpipe;
  80104d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801054:	30 80 00 
	return 0;
}
  801057:	b8 00 00 00 00       	mov    $0x0,%eax
  80105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80106d:	53                   	push   %ebx
  80106e:	6a 00                	push   $0x0
  801070:	e8 6e f1 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801075:	89 1c 24             	mov    %ebx,(%esp)
  801078:	e8 43 f3 ff ff       	call   8003c0 <fd2data>
  80107d:	83 c4 08             	add    $0x8,%esp
  801080:	50                   	push   %eax
  801081:	6a 00                	push   $0x0
  801083:	e8 5b f1 ff ff       	call   8001e3 <sys_page_unmap>
}
  801088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 1c             	sub    $0x1c,%esp
  801096:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801099:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80109b:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a9:	e8 df 0e 00 00       	call   801f8d <pageref>
  8010ae:	89 c3                	mov    %eax,%ebx
  8010b0:	89 3c 24             	mov    %edi,(%esp)
  8010b3:	e8 d5 0e 00 00       	call   801f8d <pageref>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	39 c3                	cmp    %eax,%ebx
  8010bd:	0f 94 c1             	sete   %cl
  8010c0:	0f b6 c9             	movzbl %cl,%ecx
  8010c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010c6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010cf:	39 ce                	cmp    %ecx,%esi
  8010d1:	74 1b                	je     8010ee <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010d3:	39 c3                	cmp    %eax,%ebx
  8010d5:	75 c4                	jne    80109b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d7:	8b 42 58             	mov    0x58(%edx),%eax
  8010da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010dd:	50                   	push   %eax
  8010de:	56                   	push   %esi
  8010df:	68 9b 23 80 00       	push   $0x80239b
  8010e4:	e8 e4 04 00 00       	call   8015cd <cprintf>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	eb ad                	jmp    80109b <_pipeisclosed+0xe>
	}
}
  8010ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 28             	sub    $0x28,%esp
  801102:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801105:	56                   	push   %esi
  801106:	e8 b5 f2 ff ff       	call   8003c0 <fd2data>
  80110b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	bf 00 00 00 00       	mov    $0x0,%edi
  801115:	eb 4b                	jmp    801162 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801117:	89 da                	mov    %ebx,%edx
  801119:	89 f0                	mov    %esi,%eax
  80111b:	e8 6d ff ff ff       	call   80108d <_pipeisclosed>
  801120:	85 c0                	test   %eax,%eax
  801122:	75 48                	jne    80116c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801124:	e8 16 f0 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801129:	8b 43 04             	mov    0x4(%ebx),%eax
  80112c:	8b 0b                	mov    (%ebx),%ecx
  80112e:	8d 51 20             	lea    0x20(%ecx),%edx
  801131:	39 d0                	cmp    %edx,%eax
  801133:	73 e2                	jae    801117 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 fa 1f             	sar    $0x1f,%edx
  801144:	89 d1                	mov    %edx,%ecx
  801146:	c1 e9 1b             	shr    $0x1b,%ecx
  801149:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114c:	83 e2 1f             	and    $0x1f,%edx
  80114f:	29 ca                	sub    %ecx,%edx
  801151:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801159:	83 c0 01             	add    $0x1,%eax
  80115c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80115f:	83 c7 01             	add    $0x1,%edi
  801162:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801165:	75 c2                	jne    801129 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801167:	8b 45 10             	mov    0x10(%ebp),%eax
  80116a:	eb 05                	jmp    801171 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80116c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801171:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5f                   	pop    %edi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 18             	sub    $0x18,%esp
  801182:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801185:	57                   	push   %edi
  801186:	e8 35 f2 ff ff       	call   8003c0 <fd2data>
  80118b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	eb 3d                	jmp    8011d4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801197:	85 db                	test   %ebx,%ebx
  801199:	74 04                	je     80119f <devpipe_read+0x26>
				return i;
  80119b:	89 d8                	mov    %ebx,%eax
  80119d:	eb 44                	jmp    8011e3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	89 f8                	mov    %edi,%eax
  8011a3:	e8 e5 fe ff ff       	call   80108d <_pipeisclosed>
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	75 32                	jne    8011de <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ac:	e8 8e ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b1:	8b 06                	mov    (%esi),%eax
  8011b3:	3b 46 04             	cmp    0x4(%esi),%eax
  8011b6:	74 df                	je     801197 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b8:	99                   	cltd   
  8011b9:	c1 ea 1b             	shr    $0x1b,%edx
  8011bc:	01 d0                	add    %edx,%eax
  8011be:	83 e0 1f             	and    $0x1f,%eax
  8011c1:	29 d0                	sub    %edx,%eax
  8011c3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011ce:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d1:	83 c3 01             	add    $0x1,%ebx
  8011d4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d7:	75 d8                	jne    8011b1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011dc:	eb 05                	jmp    8011e3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	e8 db f1 ff ff       	call   8003d7 <fd_alloc>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 2c 01 00 00    	js     801335 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	68 07 04 00 00       	push   $0x407
  801211:	ff 75 f4             	pushl  -0xc(%ebp)
  801214:	6a 00                	push   $0x0
  801216:	e8 43 ef ff ff       	call   80015e <sys_page_alloc>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 88 0d 01 00 00    	js     801335 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	e8 a3 f1 ff ff       	call   8003d7 <fd_alloc>
  801234:	89 c3                	mov    %eax,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	0f 88 e2 00 00 00    	js     801323 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	68 07 04 00 00       	push   $0x407
  801249:	ff 75 f0             	pushl  -0x10(%ebp)
  80124c:	6a 00                	push   $0x0
  80124e:	e8 0b ef ff ff       	call   80015e <sys_page_alloc>
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 88 c3 00 00 00    	js     801323 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	ff 75 f4             	pushl  -0xc(%ebp)
  801266:	e8 55 f1 ff ff       	call   8003c0 <fd2data>
  80126b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126d:	83 c4 0c             	add    $0xc,%esp
  801270:	68 07 04 00 00       	push   $0x407
  801275:	50                   	push   %eax
  801276:	6a 00                	push   $0x0
  801278:	e8 e1 ee ff ff       	call   80015e <sys_page_alloc>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 88 89 00 00 00    	js     801313 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	ff 75 f0             	pushl  -0x10(%ebp)
  801290:	e8 2b f1 ff ff       	call   8003c0 <fd2data>
  801295:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80129c:	50                   	push   %eax
  80129d:	6a 00                	push   $0x0
  80129f:	56                   	push   %esi
  8012a0:	6a 00                	push   $0x0
  8012a2:	e8 fa ee ff ff       	call   8001a1 <sys_page_map>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	83 c4 20             	add    $0x20,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 55                	js     801305 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e0:	e8 cb f0 ff ff       	call   8003b0 <fd2num>
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ea:	83 c4 04             	add    $0x4,%esp
  8012ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f0:	e8 bb f0 ff ff       	call   8003b0 <fd2num>
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801303:	eb 30                	jmp    801335 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	56                   	push   %esi
  801309:	6a 00                	push   $0x0
  80130b:	e8 d3 ee ff ff       	call   8001e3 <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 f0             	pushl  -0x10(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 c3 ee ff ff       	call   8001e3 <sys_page_unmap>
  801320:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	ff 75 f4             	pushl  -0xc(%ebp)
  801329:	6a 00                	push   $0x0
  80132b:	e8 b3 ee ff ff       	call   8001e3 <sys_page_unmap>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801335:	89 d0                	mov    %edx,%eax
  801337:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133a:	5b                   	pop    %ebx
  80133b:	5e                   	pop    %esi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 75 08             	pushl  0x8(%ebp)
  80134b:	e8 d6 f0 ff ff       	call   800426 <fd_lookup>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 18                	js     80136f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	ff 75 f4             	pushl  -0xc(%ebp)
  80135d:	e8 5e f0 ff ff       	call   8003c0 <fd2data>
	return _pipeisclosed(fd, p);
  801362:	89 c2                	mov    %eax,%edx
  801364:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801367:	e8 21 fd ff ff       	call   80108d <_pipeisclosed>
  80136c:	83 c4 10             	add    $0x10,%esp
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801374:	b8 00 00 00 00       	mov    $0x0,%eax
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801381:	68 b3 23 80 00       	push   $0x8023b3
  801386:	ff 75 0c             	pushl  0xc(%ebp)
  801389:	e8 c4 07 00 00       	call   801b52 <strcpy>
	return 0;
}
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	57                   	push   %edi
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
  80139b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ac:	eb 2d                	jmp    8013db <devcons_write+0x46>
		m = n - tot;
  8013ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013b3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013bb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013be:	83 ec 04             	sub    $0x4,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	03 45 0c             	add    0xc(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	57                   	push   %edi
  8013c7:	e8 18 09 00 00       	call   801ce4 <memmove>
		sys_cputs(buf, m);
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	53                   	push   %ebx
  8013d0:	57                   	push   %edi
  8013d1:	e8 cc ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d6:	01 de                	add    %ebx,%esi
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 f0                	mov    %esi,%eax
  8013dd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e0:	72 cc                	jb     8013ae <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5f                   	pop    %edi
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f9:	74 2a                	je     801425 <devcons_read+0x3b>
  8013fb:	eb 05                	jmp    801402 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013fd:	e8 3d ed ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801402:	e8 b9 ec ff ff       	call   8000c0 <sys_cgetc>
  801407:	85 c0                	test   %eax,%eax
  801409:	74 f2                	je     8013fd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 16                	js     801425 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80140f:	83 f8 04             	cmp    $0x4,%eax
  801412:	74 0c                	je     801420 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801414:	8b 55 0c             	mov    0xc(%ebp),%edx
  801417:	88 02                	mov    %al,(%edx)
	return 1;
  801419:	b8 01 00 00 00       	mov    $0x1,%eax
  80141e:	eb 05                	jmp    801425 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801433:	6a 01                	push   $0x1
  801435:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	e8 64 ec ff ff       	call   8000a2 <sys_cputs>
}
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <getchar>:

int
getchar(void)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801449:	6a 01                	push   $0x1
  80144b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	6a 00                	push   $0x0
  801451:	e8 36 f2 ff ff       	call   80068c <read>
	if (r < 0)
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 0f                	js     80146c <getchar+0x29>
		return r;
	if (r < 1)
  80145d:	85 c0                	test   %eax,%eax
  80145f:	7e 06                	jle    801467 <getchar+0x24>
		return -E_EOF;
	return c;
  801461:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801465:	eb 05                	jmp    80146c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801467:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	ff 75 08             	pushl  0x8(%ebp)
  80147b:	e8 a6 ef ff ff       	call   800426 <fd_lookup>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 11                	js     801498 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801490:	39 10                	cmp    %edx,(%eax)
  801492:	0f 94 c0             	sete   %al
  801495:	0f b6 c0             	movzbl %al,%eax
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <opencons>:

int
opencons(void)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	e8 2e ef ff ff       	call   8003d7 <fd_alloc>
  8014a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 3e                	js     8014f0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b2:	83 ec 04             	sub    $0x4,%esp
  8014b5:	68 07 04 00 00       	push   $0x407
  8014ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bd:	6a 00                	push   $0x0
  8014bf:	e8 9a ec ff ff       	call   80015e <sys_page_alloc>
  8014c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 23                	js     8014f0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014cd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	50                   	push   %eax
  8014e6:	e8 c5 ee ff ff       	call   8003b0 <fd2num>
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	83 c4 10             	add    $0x10,%esp
}
  8014f0:	89 d0                	mov    %edx,%eax
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801502:	e8 19 ec ff ff       	call   800120 <sys_getenvid>
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	ff 75 0c             	pushl  0xc(%ebp)
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	56                   	push   %esi
  801511:	50                   	push   %eax
  801512:	68 c0 23 80 00       	push   $0x8023c0
  801517:	e8 b1 00 00 00       	call   8015cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151c:	83 c4 18             	add    $0x18,%esp
  80151f:	53                   	push   %ebx
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	e8 54 00 00 00       	call   80157c <vcprintf>
	cprintf("\n");
  801528:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  80152f:	e8 99 00 00 00       	call   8015cd <cprintf>
  801534:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801537:	cc                   	int3   
  801538:	eb fd                	jmp    801537 <_panic+0x43>

0080153a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	53                   	push   %ebx
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801544:	8b 13                	mov    (%ebx),%edx
  801546:	8d 42 01             	lea    0x1(%edx),%eax
  801549:	89 03                	mov    %eax,(%ebx)
  80154b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801552:	3d ff 00 00 00       	cmp    $0xff,%eax
  801557:	75 1a                	jne    801573 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	68 ff 00 00 00       	push   $0xff
  801561:	8d 43 08             	lea    0x8(%ebx),%eax
  801564:	50                   	push   %eax
  801565:	e8 38 eb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  80156a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801570:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801573:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801585:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80158c:	00 00 00 
	b.cnt = 0;
  80158f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801596:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801599:	ff 75 0c             	pushl  0xc(%ebp)
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	68 3a 15 80 00       	push   $0x80153a
  8015ab:	e8 54 01 00 00       	call   801704 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	e8 dd ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8015c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d6:	50                   	push   %eax
  8015d7:	ff 75 08             	pushl  0x8(%ebp)
  8015da:	e8 9d ff ff ff       	call   80157c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	57                   	push   %edi
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 1c             	sub    $0x1c,%esp
  8015ea:	89 c7                	mov    %eax,%edi
  8015ec:	89 d6                	mov    %edx,%esi
  8015ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801602:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801605:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801608:	39 d3                	cmp    %edx,%ebx
  80160a:	72 05                	jb     801611 <printnum+0x30>
  80160c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80160f:	77 45                	ja     801656 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	ff 75 18             	pushl  0x18(%ebp)
  801617:	8b 45 14             	mov    0x14(%ebp),%eax
  80161a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80161d:	53                   	push   %ebx
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	ff 75 e4             	pushl  -0x1c(%ebp)
  801627:	ff 75 e0             	pushl  -0x20(%ebp)
  80162a:	ff 75 dc             	pushl  -0x24(%ebp)
  80162d:	ff 75 d8             	pushl  -0x28(%ebp)
  801630:	e8 9b 09 00 00       	call   801fd0 <__udivdi3>
  801635:	83 c4 18             	add    $0x18,%esp
  801638:	52                   	push   %edx
  801639:	50                   	push   %eax
  80163a:	89 f2                	mov    %esi,%edx
  80163c:	89 f8                	mov    %edi,%eax
  80163e:	e8 9e ff ff ff       	call   8015e1 <printnum>
  801643:	83 c4 20             	add    $0x20,%esp
  801646:	eb 18                	jmp    801660 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	56                   	push   %esi
  80164c:	ff 75 18             	pushl  0x18(%ebp)
  80164f:	ff d7                	call   *%edi
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb 03                	jmp    801659 <printnum+0x78>
  801656:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801659:	83 eb 01             	sub    $0x1,%ebx
  80165c:	85 db                	test   %ebx,%ebx
  80165e:	7f e8                	jg     801648 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	56                   	push   %esi
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166a:	ff 75 e0             	pushl  -0x20(%ebp)
  80166d:	ff 75 dc             	pushl  -0x24(%ebp)
  801670:	ff 75 d8             	pushl  -0x28(%ebp)
  801673:	e8 88 0a 00 00       	call   802100 <__umoddi3>
  801678:	83 c4 14             	add    $0x14,%esp
  80167b:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801682:	50                   	push   %eax
  801683:	ff d7                	call   *%edi
}
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801693:	83 fa 01             	cmp    $0x1,%edx
  801696:	7e 0e                	jle    8016a6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801698:	8b 10                	mov    (%eax),%edx
  80169a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80169d:	89 08                	mov    %ecx,(%eax)
  80169f:	8b 02                	mov    (%edx),%eax
  8016a1:	8b 52 04             	mov    0x4(%edx),%edx
  8016a4:	eb 22                	jmp    8016c8 <getuint+0x38>
	else if (lflag)
  8016a6:	85 d2                	test   %edx,%edx
  8016a8:	74 10                	je     8016ba <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016aa:	8b 10                	mov    (%eax),%edx
  8016ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016af:	89 08                	mov    %ecx,(%eax)
  8016b1:	8b 02                	mov    (%edx),%eax
  8016b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b8:	eb 0e                	jmp    8016c8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ba:	8b 10                	mov    (%eax),%edx
  8016bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016bf:	89 08                	mov    %ecx,(%eax)
  8016c1:	8b 02                	mov    (%edx),%eax
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d4:	8b 10                	mov    (%eax),%edx
  8016d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d9:	73 0a                	jae    8016e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016de:	89 08                	mov    %ecx,(%eax)
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	88 02                	mov    %al,(%edx)
}
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f0:	50                   	push   %eax
  8016f1:	ff 75 10             	pushl  0x10(%ebp)
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	ff 75 08             	pushl  0x8(%ebp)
  8016fa:	e8 05 00 00 00       	call   801704 <vprintfmt>
	va_end(ap);
}
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	57                   	push   %edi
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
  80170a:	83 ec 2c             	sub    $0x2c,%esp
  80170d:	8b 75 08             	mov    0x8(%ebp),%esi
  801710:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801713:	8b 7d 10             	mov    0x10(%ebp),%edi
  801716:	eb 12                	jmp    80172a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 84 89 03 00 00    	je     801aa9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	53                   	push   %ebx
  801724:	50                   	push   %eax
  801725:	ff d6                	call   *%esi
  801727:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80172a:	83 c7 01             	add    $0x1,%edi
  80172d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801731:	83 f8 25             	cmp    $0x25,%eax
  801734:	75 e2                	jne    801718 <vprintfmt+0x14>
  801736:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80173a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801741:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801748:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	eb 07                	jmp    80175d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801756:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801759:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175d:	8d 47 01             	lea    0x1(%edi),%eax
  801760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801763:	0f b6 07             	movzbl (%edi),%eax
  801766:	0f b6 c8             	movzbl %al,%ecx
  801769:	83 e8 23             	sub    $0x23,%eax
  80176c:	3c 55                	cmp    $0x55,%al
  80176e:	0f 87 1a 03 00 00    	ja     801a8e <vprintfmt+0x38a>
  801774:	0f b6 c0             	movzbl %al,%eax
  801777:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80177e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801781:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801785:	eb d6                	jmp    80175d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
  80178f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801792:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801795:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801799:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80179c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80179f:	83 fa 09             	cmp    $0x9,%edx
  8017a2:	77 39                	ja     8017dd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a7:	eb e9                	jmp    801792 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8017af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017b2:	8b 00                	mov    (%eax),%eax
  8017b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ba:	eb 27                	jmp    8017e3 <vprintfmt+0xdf>
  8017bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c6:	0f 49 c8             	cmovns %eax,%ecx
  8017c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017cf:	eb 8c                	jmp    80175d <vprintfmt+0x59>
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017db:	eb 80                	jmp    80175d <vprintfmt+0x59>
  8017dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e7:	0f 89 70 ff ff ff    	jns    80175d <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017fa:	e9 5e ff ff ff       	jmp    80175d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ff:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801805:	e9 53 ff ff ff       	jmp    80175d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80180a:	8b 45 14             	mov    0x14(%ebp),%eax
  80180d:	8d 50 04             	lea    0x4(%eax),%edx
  801810:	89 55 14             	mov    %edx,0x14(%ebp)
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	53                   	push   %ebx
  801817:	ff 30                	pushl  (%eax)
  801819:	ff d6                	call   *%esi
			break;
  80181b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801821:	e9 04 ff ff ff       	jmp    80172a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801826:	8b 45 14             	mov    0x14(%ebp),%eax
  801829:	8d 50 04             	lea    0x4(%eax),%edx
  80182c:	89 55 14             	mov    %edx,0x14(%ebp)
  80182f:	8b 00                	mov    (%eax),%eax
  801831:	99                   	cltd   
  801832:	31 d0                	xor    %edx,%eax
  801834:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801836:	83 f8 0f             	cmp    $0xf,%eax
  801839:	7f 0b                	jg     801846 <vprintfmt+0x142>
  80183b:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	75 18                	jne    80185e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801846:	50                   	push   %eax
  801847:	68 fb 23 80 00       	push   $0x8023fb
  80184c:	53                   	push   %ebx
  80184d:	56                   	push   %esi
  80184e:	e8 94 fe ff ff       	call   8016e7 <printfmt>
  801853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801859:	e9 cc fe ff ff       	jmp    80172a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80185e:	52                   	push   %edx
  80185f:	68 41 23 80 00       	push   $0x802341
  801864:	53                   	push   %ebx
  801865:	56                   	push   %esi
  801866:	e8 7c fe ff ff       	call   8016e7 <printfmt>
  80186b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801871:	e9 b4 fe ff ff       	jmp    80172a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801876:	8b 45 14             	mov    0x14(%ebp),%eax
  801879:	8d 50 04             	lea    0x4(%eax),%edx
  80187c:	89 55 14             	mov    %edx,0x14(%ebp)
  80187f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801881:	85 ff                	test   %edi,%edi
  801883:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801888:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80188b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80188f:	0f 8e 94 00 00 00    	jle    801929 <vprintfmt+0x225>
  801895:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801899:	0f 84 98 00 00 00    	je     801937 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8018a5:	57                   	push   %edi
  8018a6:	e8 86 02 00 00       	call   801b31 <strnlen>
  8018ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018ae:	29 c1                	sub    %eax,%ecx
  8018b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018c0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c2:	eb 0f                	jmp    8018d3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018cb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018cd:	83 ef 01             	sub    $0x1,%edi
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 ff                	test   %edi,%edi
  8018d5:	7f ed                	jg     8018c4 <vprintfmt+0x1c0>
  8018d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018dd:	85 c9                	test   %ecx,%ecx
  8018df:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e4:	0f 49 c1             	cmovns %ecx,%eax
  8018e7:	29 c1                	sub    %eax,%ecx
  8018e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f2:	89 cb                	mov    %ecx,%ebx
  8018f4:	eb 4d                	jmp    801943 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018fa:	74 1b                	je     801917 <vprintfmt+0x213>
  8018fc:	0f be c0             	movsbl %al,%eax
  8018ff:	83 e8 20             	sub    $0x20,%eax
  801902:	83 f8 5e             	cmp    $0x5e,%eax
  801905:	76 10                	jbe    801917 <vprintfmt+0x213>
					putch('?', putdat);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	6a 3f                	push   $0x3f
  80190f:	ff 55 08             	call   *0x8(%ebp)
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	eb 0d                	jmp    801924 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	ff 75 0c             	pushl  0xc(%ebp)
  80191d:	52                   	push   %edx
  80191e:	ff 55 08             	call   *0x8(%ebp)
  801921:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801924:	83 eb 01             	sub    $0x1,%ebx
  801927:	eb 1a                	jmp    801943 <vprintfmt+0x23f>
  801929:	89 75 08             	mov    %esi,0x8(%ebp)
  80192c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801932:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801935:	eb 0c                	jmp    801943 <vprintfmt+0x23f>
  801937:	89 75 08             	mov    %esi,0x8(%ebp)
  80193a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801940:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801943:	83 c7 01             	add    $0x1,%edi
  801946:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80194a:	0f be d0             	movsbl %al,%edx
  80194d:	85 d2                	test   %edx,%edx
  80194f:	74 23                	je     801974 <vprintfmt+0x270>
  801951:	85 f6                	test   %esi,%esi
  801953:	78 a1                	js     8018f6 <vprintfmt+0x1f2>
  801955:	83 ee 01             	sub    $0x1,%esi
  801958:	79 9c                	jns    8018f6 <vprintfmt+0x1f2>
  80195a:	89 df                	mov    %ebx,%edi
  80195c:	8b 75 08             	mov    0x8(%ebp),%esi
  80195f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801962:	eb 18                	jmp    80197c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	53                   	push   %ebx
  801968:	6a 20                	push   $0x20
  80196a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80196c:	83 ef 01             	sub    $0x1,%edi
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	eb 08                	jmp    80197c <vprintfmt+0x278>
  801974:	89 df                	mov    %ebx,%edi
  801976:	8b 75 08             	mov    0x8(%ebp),%esi
  801979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80197c:	85 ff                	test   %edi,%edi
  80197e:	7f e4                	jg     801964 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801980:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801983:	e9 a2 fd ff ff       	jmp    80172a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801988:	83 fa 01             	cmp    $0x1,%edx
  80198b:	7e 16                	jle    8019a3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8d 50 08             	lea    0x8(%eax),%edx
  801993:	89 55 14             	mov    %edx,0x14(%ebp)
  801996:	8b 50 04             	mov    0x4(%eax),%edx
  801999:	8b 00                	mov    (%eax),%eax
  80199b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a1:	eb 32                	jmp    8019d5 <vprintfmt+0x2d1>
	else if (lflag)
  8019a3:	85 d2                	test   %edx,%edx
  8019a5:	74 18                	je     8019bf <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019aa:	8d 50 04             	lea    0x4(%eax),%edx
  8019ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b0:	8b 00                	mov    (%eax),%eax
  8019b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b5:	89 c1                	mov    %eax,%ecx
  8019b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019bd:	eb 16                	jmp    8019d5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c2:	8d 50 04             	lea    0x4(%eax),%edx
  8019c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c8:	8b 00                	mov    (%eax),%eax
  8019ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019cd:	89 c1                	mov    %eax,%ecx
  8019cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e4:	79 74                	jns    801a5a <vprintfmt+0x356>
				putch('-', putdat);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	53                   	push   %ebx
  8019ea:	6a 2d                	push   $0x2d
  8019ec:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f4:	f7 d8                	neg    %eax
  8019f6:	83 d2 00             	adc    $0x0,%edx
  8019f9:	f7 da                	neg    %edx
  8019fb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a03:	eb 55                	jmp    801a5a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a05:	8d 45 14             	lea    0x14(%ebp),%eax
  801a08:	e8 83 fc ff ff       	call   801690 <getuint>
			base = 10;
  801a0d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a12:	eb 46                	jmp    801a5a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801a14:	8d 45 14             	lea    0x14(%ebp),%eax
  801a17:	e8 74 fc ff ff       	call   801690 <getuint>
			base = 8;
  801a1c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801a21:	eb 37                	jmp    801a5a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	53                   	push   %ebx
  801a27:	6a 30                	push   $0x30
  801a29:	ff d6                	call   *%esi
			putch('x', putdat);
  801a2b:	83 c4 08             	add    $0x8,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	6a 78                	push   $0x78
  801a31:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a33:	8b 45 14             	mov    0x14(%ebp),%eax
  801a36:	8d 50 04             	lea    0x4(%eax),%edx
  801a39:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a3c:	8b 00                	mov    (%eax),%eax
  801a3e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a43:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a46:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a4b:	eb 0d                	jmp    801a5a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a4d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a50:	e8 3b fc ff ff       	call   801690 <getuint>
			base = 16;
  801a55:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a61:	57                   	push   %edi
  801a62:	ff 75 e0             	pushl  -0x20(%ebp)
  801a65:	51                   	push   %ecx
  801a66:	52                   	push   %edx
  801a67:	50                   	push   %eax
  801a68:	89 da                	mov    %ebx,%edx
  801a6a:	89 f0                	mov    %esi,%eax
  801a6c:	e8 70 fb ff ff       	call   8015e1 <printnum>
			break;
  801a71:	83 c4 20             	add    $0x20,%esp
  801a74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a77:	e9 ae fc ff ff       	jmp    80172a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	53                   	push   %ebx
  801a80:	51                   	push   %ecx
  801a81:	ff d6                	call   *%esi
			break;
  801a83:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a89:	e9 9c fc ff ff       	jmp    80172a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	53                   	push   %ebx
  801a92:	6a 25                	push   $0x25
  801a94:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	eb 03                	jmp    801a9e <vprintfmt+0x39a>
  801a9b:	83 ef 01             	sub    $0x1,%edi
  801a9e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa2:	75 f7                	jne    801a9b <vprintfmt+0x397>
  801aa4:	e9 81 fc ff ff       	jmp    80172a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 18             	sub    $0x18,%esp
  801ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801abd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	74 26                	je     801af8 <vsnprintf+0x47>
  801ad2:	85 d2                	test   %edx,%edx
  801ad4:	7e 22                	jle    801af8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad6:	ff 75 14             	pushl  0x14(%ebp)
  801ad9:	ff 75 10             	pushl  0x10(%ebp)
  801adc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	68 ca 16 80 00       	push   $0x8016ca
  801ae5:	e8 1a fc ff ff       	call   801704 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	eb 05                	jmp    801afd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b05:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b08:	50                   	push   %eax
  801b09:	ff 75 10             	pushl  0x10(%ebp)
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	ff 75 08             	pushl  0x8(%ebp)
  801b12:	e8 9a ff ff ff       	call   801ab1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b24:	eb 03                	jmp    801b29 <strlen+0x10>
		n++;
  801b26:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b29:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b2d:	75 f7                	jne    801b26 <strlen+0xd>
		n++;
	return n;
}
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b37:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	eb 03                	jmp    801b44 <strnlen+0x13>
		n++;
  801b41:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b44:	39 c2                	cmp    %eax,%edx
  801b46:	74 08                	je     801b50 <strnlen+0x1f>
  801b48:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b4c:	75 f3                	jne    801b41 <strnlen+0x10>
  801b4e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	83 c2 01             	add    $0x1,%edx
  801b61:	83 c1 01             	add    $0x1,%ecx
  801b64:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b68:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b6b:	84 db                	test   %bl,%bl
  801b6d:	75 ef                	jne    801b5e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b6f:	5b                   	pop    %ebx
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b79:	53                   	push   %ebx
  801b7a:	e8 9a ff ff ff       	call   801b19 <strlen>
  801b7f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	01 d8                	add    %ebx,%eax
  801b87:	50                   	push   %eax
  801b88:	e8 c5 ff ff ff       	call   801b52 <strcpy>
	return dst;
}
  801b8d:	89 d8                	mov    %ebx,%eax
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9f:	89 f3                	mov    %esi,%ebx
  801ba1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba4:	89 f2                	mov    %esi,%edx
  801ba6:	eb 0f                	jmp    801bb7 <strncpy+0x23>
		*dst++ = *src;
  801ba8:	83 c2 01             	add    $0x1,%edx
  801bab:	0f b6 01             	movzbl (%ecx),%eax
  801bae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb1:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb7:	39 da                	cmp    %ebx,%edx
  801bb9:	75 ed                	jne    801ba8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bbb:	89 f0                	mov    %esi,%eax
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcc:	8b 55 10             	mov    0x10(%ebp),%edx
  801bcf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd1:	85 d2                	test   %edx,%edx
  801bd3:	74 21                	je     801bf6 <strlcpy+0x35>
  801bd5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd9:	89 f2                	mov    %esi,%edx
  801bdb:	eb 09                	jmp    801be6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bdd:	83 c2 01             	add    $0x1,%edx
  801be0:	83 c1 01             	add    $0x1,%ecx
  801be3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be6:	39 c2                	cmp    %eax,%edx
  801be8:	74 09                	je     801bf3 <strlcpy+0x32>
  801bea:	0f b6 19             	movzbl (%ecx),%ebx
  801bed:	84 db                	test   %bl,%bl
  801bef:	75 ec                	jne    801bdd <strlcpy+0x1c>
  801bf1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf6:	29 f0                	sub    %esi,%eax
}
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c05:	eb 06                	jmp    801c0d <strcmp+0x11>
		p++, q++;
  801c07:	83 c1 01             	add    $0x1,%ecx
  801c0a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c0d:	0f b6 01             	movzbl (%ecx),%eax
  801c10:	84 c0                	test   %al,%al
  801c12:	74 04                	je     801c18 <strcmp+0x1c>
  801c14:	3a 02                	cmp    (%edx),%al
  801c16:	74 ef                	je     801c07 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c18:	0f b6 c0             	movzbl %al,%eax
  801c1b:	0f b6 12             	movzbl (%edx),%edx
  801c1e:	29 d0                	sub    %edx,%eax
}
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	53                   	push   %ebx
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c31:	eb 06                	jmp    801c39 <strncmp+0x17>
		n--, p++, q++;
  801c33:	83 c0 01             	add    $0x1,%eax
  801c36:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c39:	39 d8                	cmp    %ebx,%eax
  801c3b:	74 15                	je     801c52 <strncmp+0x30>
  801c3d:	0f b6 08             	movzbl (%eax),%ecx
  801c40:	84 c9                	test   %cl,%cl
  801c42:	74 04                	je     801c48 <strncmp+0x26>
  801c44:	3a 0a                	cmp    (%edx),%cl
  801c46:	74 eb                	je     801c33 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c48:	0f b6 00             	movzbl (%eax),%eax
  801c4b:	0f b6 12             	movzbl (%edx),%edx
  801c4e:	29 d0                	sub    %edx,%eax
  801c50:	eb 05                	jmp    801c57 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c57:	5b                   	pop    %ebx
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c64:	eb 07                	jmp    801c6d <strchr+0x13>
		if (*s == c)
  801c66:	38 ca                	cmp    %cl,%dl
  801c68:	74 0f                	je     801c79 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c6a:	83 c0 01             	add    $0x1,%eax
  801c6d:	0f b6 10             	movzbl (%eax),%edx
  801c70:	84 d2                	test   %dl,%dl
  801c72:	75 f2                	jne    801c66 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c85:	eb 03                	jmp    801c8a <strfind+0xf>
  801c87:	83 c0 01             	add    $0x1,%eax
  801c8a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c8d:	38 ca                	cmp    %cl,%dl
  801c8f:	74 04                	je     801c95 <strfind+0x1a>
  801c91:	84 d2                	test   %dl,%dl
  801c93:	75 f2                	jne    801c87 <strfind+0xc>
			break;
	return (char *) s;
}
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca3:	85 c9                	test   %ecx,%ecx
  801ca5:	74 36                	je     801cdd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cad:	75 28                	jne    801cd7 <memset+0x40>
  801caf:	f6 c1 03             	test   $0x3,%cl
  801cb2:	75 23                	jne    801cd7 <memset+0x40>
		c &= 0xFF;
  801cb4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb8:	89 d3                	mov    %edx,%ebx
  801cba:	c1 e3 08             	shl    $0x8,%ebx
  801cbd:	89 d6                	mov    %edx,%esi
  801cbf:	c1 e6 18             	shl    $0x18,%esi
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	c1 e0 10             	shl    $0x10,%eax
  801cc7:	09 f0                	or     %esi,%eax
  801cc9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ccb:	89 d8                	mov    %ebx,%eax
  801ccd:	09 d0                	or     %edx,%eax
  801ccf:	c1 e9 02             	shr    $0x2,%ecx
  801cd2:	fc                   	cld    
  801cd3:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd5:	eb 06                	jmp    801cdd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	fc                   	cld    
  801cdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cdd:	89 f8                	mov    %edi,%eax
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	57                   	push   %edi
  801ce8:	56                   	push   %esi
  801ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cec:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf2:	39 c6                	cmp    %eax,%esi
  801cf4:	73 35                	jae    801d2b <memmove+0x47>
  801cf6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf9:	39 d0                	cmp    %edx,%eax
  801cfb:	73 2e                	jae    801d2b <memmove+0x47>
		s += n;
		d += n;
  801cfd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d00:	89 d6                	mov    %edx,%esi
  801d02:	09 fe                	or     %edi,%esi
  801d04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d0a:	75 13                	jne    801d1f <memmove+0x3b>
  801d0c:	f6 c1 03             	test   $0x3,%cl
  801d0f:	75 0e                	jne    801d1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d11:	83 ef 04             	sub    $0x4,%edi
  801d14:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d17:	c1 e9 02             	shr    $0x2,%ecx
  801d1a:	fd                   	std    
  801d1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d1d:	eb 09                	jmp    801d28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1f:	83 ef 01             	sub    $0x1,%edi
  801d22:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d25:	fd                   	std    
  801d26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d28:	fc                   	cld    
  801d29:	eb 1d                	jmp    801d48 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2b:	89 f2                	mov    %esi,%edx
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	f6 c2 03             	test   $0x3,%dl
  801d32:	75 0f                	jne    801d43 <memmove+0x5f>
  801d34:	f6 c1 03             	test   $0x3,%cl
  801d37:	75 0a                	jne    801d43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d39:	c1 e9 02             	shr    $0x2,%ecx
  801d3c:	89 c7                	mov    %eax,%edi
  801d3e:	fc                   	cld    
  801d3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d41:	eb 05                	jmp    801d48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d43:	89 c7                	mov    %eax,%edi
  801d45:	fc                   	cld    
  801d46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d4f:	ff 75 10             	pushl  0x10(%ebp)
  801d52:	ff 75 0c             	pushl  0xc(%ebp)
  801d55:	ff 75 08             	pushl  0x8(%ebp)
  801d58:	e8 87 ff ff ff       	call   801ce4 <memmove>
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6a:	89 c6                	mov    %eax,%esi
  801d6c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6f:	eb 1a                	jmp    801d8b <memcmp+0x2c>
		if (*s1 != *s2)
  801d71:	0f b6 08             	movzbl (%eax),%ecx
  801d74:	0f b6 1a             	movzbl (%edx),%ebx
  801d77:	38 d9                	cmp    %bl,%cl
  801d79:	74 0a                	je     801d85 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d7b:	0f b6 c1             	movzbl %cl,%eax
  801d7e:	0f b6 db             	movzbl %bl,%ebx
  801d81:	29 d8                	sub    %ebx,%eax
  801d83:	eb 0f                	jmp    801d94 <memcmp+0x35>
		s1++, s2++;
  801d85:	83 c0 01             	add    $0x1,%eax
  801d88:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8b:	39 f0                	cmp    %esi,%eax
  801d8d:	75 e2                	jne    801d71 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	53                   	push   %ebx
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da8:	eb 0a                	jmp    801db4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801daa:	0f b6 10             	movzbl (%eax),%edx
  801dad:	39 da                	cmp    %ebx,%edx
  801daf:	74 07                	je     801db8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db1:	83 c0 01             	add    $0x1,%eax
  801db4:	39 c8                	cmp    %ecx,%eax
  801db6:	72 f2                	jb     801daa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db8:	5b                   	pop    %ebx
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc7:	eb 03                	jmp    801dcc <strtol+0x11>
		s++;
  801dc9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcc:	0f b6 01             	movzbl (%ecx),%eax
  801dcf:	3c 20                	cmp    $0x20,%al
  801dd1:	74 f6                	je     801dc9 <strtol+0xe>
  801dd3:	3c 09                	cmp    $0x9,%al
  801dd5:	74 f2                	je     801dc9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd7:	3c 2b                	cmp    $0x2b,%al
  801dd9:	75 0a                	jne    801de5 <strtol+0x2a>
		s++;
  801ddb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dde:	bf 00 00 00 00       	mov    $0x0,%edi
  801de3:	eb 11                	jmp    801df6 <strtol+0x3b>
  801de5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dea:	3c 2d                	cmp    $0x2d,%al
  801dec:	75 08                	jne    801df6 <strtol+0x3b>
		s++, neg = 1;
  801dee:	83 c1 01             	add    $0x1,%ecx
  801df1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfc:	75 15                	jne    801e13 <strtol+0x58>
  801dfe:	80 39 30             	cmpb   $0x30,(%ecx)
  801e01:	75 10                	jne    801e13 <strtol+0x58>
  801e03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e07:	75 7c                	jne    801e85 <strtol+0xca>
		s += 2, base = 16;
  801e09:	83 c1 02             	add    $0x2,%ecx
  801e0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e11:	eb 16                	jmp    801e29 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e13:	85 db                	test   %ebx,%ebx
  801e15:	75 12                	jne    801e29 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e17:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1f:	75 08                	jne    801e29 <strtol+0x6e>
		s++, base = 8;
  801e21:	83 c1 01             	add    $0x1,%ecx
  801e24:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e29:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e31:	0f b6 11             	movzbl (%ecx),%edx
  801e34:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e37:	89 f3                	mov    %esi,%ebx
  801e39:	80 fb 09             	cmp    $0x9,%bl
  801e3c:	77 08                	ja     801e46 <strtol+0x8b>
			dig = *s - '0';
  801e3e:	0f be d2             	movsbl %dl,%edx
  801e41:	83 ea 30             	sub    $0x30,%edx
  801e44:	eb 22                	jmp    801e68 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e46:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e49:	89 f3                	mov    %esi,%ebx
  801e4b:	80 fb 19             	cmp    $0x19,%bl
  801e4e:	77 08                	ja     801e58 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e50:	0f be d2             	movsbl %dl,%edx
  801e53:	83 ea 57             	sub    $0x57,%edx
  801e56:	eb 10                	jmp    801e68 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e58:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e5b:	89 f3                	mov    %esi,%ebx
  801e5d:	80 fb 19             	cmp    $0x19,%bl
  801e60:	77 16                	ja     801e78 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e62:	0f be d2             	movsbl %dl,%edx
  801e65:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e68:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e6b:	7d 0b                	jge    801e78 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e6d:	83 c1 01             	add    $0x1,%ecx
  801e70:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e74:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e76:	eb b9                	jmp    801e31 <strtol+0x76>

	if (endptr)
  801e78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e7c:	74 0d                	je     801e8b <strtol+0xd0>
		*endptr = (char *) s;
  801e7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e81:	89 0e                	mov    %ecx,(%esi)
  801e83:	eb 06                	jmp    801e8b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e85:	85 db                	test   %ebx,%ebx
  801e87:	74 98                	je     801e21 <strtol+0x66>
  801e89:	eb 9e                	jmp    801e29 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e8b:	89 c2                	mov    %eax,%edx
  801e8d:	f7 da                	neg    %edx
  801e8f:	85 ff                	test   %edi,%edi
  801e91:	0f 45 c2             	cmovne %edx,%eax
}
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5f                   	pop    %edi
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ea7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ea9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eae:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	50                   	push   %eax
  801eb5:	e8 54 e4 ff ff       	call   80030e <sys_ipc_recv>

	if (from_env_store != NULL)
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	85 f6                	test   %esi,%esi
  801ebf:	74 14                	je     801ed5 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801ec1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	78 09                	js     801ed3 <ipc_recv+0x3a>
  801eca:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ed0:	8b 52 74             	mov    0x74(%edx),%edx
  801ed3:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ed5:	85 db                	test   %ebx,%ebx
  801ed7:	74 14                	je     801eed <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 09                	js     801eeb <ipc_recv+0x52>
  801ee2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ee8:	8b 52 78             	mov    0x78(%edx),%edx
  801eeb:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 08                	js     801ef9 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ef1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	83 ec 0c             	sub    $0xc,%esp
  801f09:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f12:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f14:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f19:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f1c:	ff 75 14             	pushl  0x14(%ebp)
  801f1f:	53                   	push   %ebx
  801f20:	56                   	push   %esi
  801f21:	57                   	push   %edi
  801f22:	e8 c4 e3 ff ff       	call   8002eb <sys_ipc_try_send>

		if (err < 0) {
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	79 1e                	jns    801f4c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f2e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f31:	75 07                	jne    801f3a <ipc_send+0x3a>
				sys_yield();
  801f33:	e8 07 e2 ff ff       	call   80013f <sys_yield>
  801f38:	eb e2                	jmp    801f1c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f3a:	50                   	push   %eax
  801f3b:	68 e0 26 80 00       	push   $0x8026e0
  801f40:	6a 49                	push   $0x49
  801f42:	68 ed 26 80 00       	push   $0x8026ed
  801f47:	e8 a8 f5 ff ff       	call   8014f4 <_panic>
		}

	} while (err < 0);

}
  801f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f62:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f68:	8b 52 50             	mov    0x50(%edx),%edx
  801f6b:	39 ca                	cmp    %ecx,%edx
  801f6d:	75 0d                	jne    801f7c <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f72:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f77:	8b 40 48             	mov    0x48(%eax),%eax
  801f7a:	eb 0f                	jmp    801f8b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7c:	83 c0 01             	add    $0x1,%eax
  801f7f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f84:	75 d9                	jne    801f5f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    

00801f8d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f93:	89 d0                	mov    %edx,%eax
  801f95:	c1 e8 16             	shr    $0x16,%eax
  801f98:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa4:	f6 c1 01             	test   $0x1,%cl
  801fa7:	74 1d                	je     801fc6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa9:	c1 ea 0c             	shr    $0xc,%edx
  801fac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb3:	f6 c2 01             	test   $0x1,%dl
  801fb6:	74 0e                	je     801fc6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb8:	c1 ea 0c             	shr    $0xc,%edx
  801fbb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc2:	ef 
  801fc3:	0f b7 c0             	movzwl %ax,%eax
}
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
