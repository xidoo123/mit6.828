
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
  800107:	68 aa 1d 80 00       	push   $0x801daa
  80010c:	6a 23                	push   $0x23
  80010e:	68 c7 1d 80 00       	push   $0x801dc7
  800113:	e8 14 0f 00 00       	call   80102c <_panic>

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
  800188:	68 aa 1d 80 00       	push   $0x801daa
  80018d:	6a 23                	push   $0x23
  80018f:	68 c7 1d 80 00       	push   $0x801dc7
  800194:	e8 93 0e 00 00       	call   80102c <_panic>

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
  8001ca:	68 aa 1d 80 00       	push   $0x801daa
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 c7 1d 80 00       	push   $0x801dc7
  8001d6:	e8 51 0e 00 00       	call   80102c <_panic>

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
  80020c:	68 aa 1d 80 00       	push   $0x801daa
  800211:	6a 23                	push   $0x23
  800213:	68 c7 1d 80 00       	push   $0x801dc7
  800218:	e8 0f 0e 00 00       	call   80102c <_panic>

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
  80024e:	68 aa 1d 80 00       	push   $0x801daa
  800253:	6a 23                	push   $0x23
  800255:	68 c7 1d 80 00       	push   $0x801dc7
  80025a:	e8 cd 0d 00 00       	call   80102c <_panic>

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
  800290:	68 aa 1d 80 00       	push   $0x801daa
  800295:	6a 23                	push   $0x23
  800297:	68 c7 1d 80 00       	push   $0x801dc7
  80029c:	e8 8b 0d 00 00       	call   80102c <_panic>

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
  8002d2:	68 aa 1d 80 00       	push   $0x801daa
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 c7 1d 80 00       	push   $0x801dc7
  8002de:	e8 49 0d 00 00       	call   80102c <_panic>

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
  800336:	68 aa 1d 80 00       	push   $0x801daa
  80033b:	6a 23                	push   $0x23
  80033d:	68 c7 1d 80 00       	push   $0x801dc7
  800342:	e8 e5 0c 00 00       	call   80102c <_panic>

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
  800424:	ba 54 1e 80 00       	mov    $0x801e54,%edx
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
  800451:	68 d8 1d 80 00       	push   $0x801dd8
  800456:	e8 aa 0c 00 00       	call   801105 <cprintf>
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
  80067b:	68 19 1e 80 00       	push   $0x801e19
  800680:	e8 80 0a 00 00       	call   801105 <cprintf>
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
  800750:	68 35 1e 80 00       	push   $0x801e35
  800755:	e8 ab 09 00 00       	call   801105 <cprintf>
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
  800805:	68 f8 1d 80 00       	push   $0x801df8
  80080a:	e8 f6 08 00 00       	call   801105 <cprintf>
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
  8008ce:	e8 d6 01 00 00       	call   800aa9 <open>
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
  800915:	e8 72 11 00 00       	call   801a8c <ipc_find_env>
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
  800930:	e8 03 11 00 00       	call   801a38 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 8f 10 00 00       	call   8019d1 <ipc_recv>
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
  8009c6:	e8 bf 0c 00 00       	call   80168a <strcpy>
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
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8009fd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a03:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a08:	50                   	push   %eax
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	68 08 50 80 00       	push   $0x805008
  800a11:	e8 06 0e 00 00       	call   80181c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a16:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a20:	e8 d9 fe ff ff       	call   8008fe <fsipc>

}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 40 0c             	mov    0xc(%eax),%eax
  800a35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4a:	e8 af fe ff ff       	call   8008fe <fsipc>
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	85 c0                	test   %eax,%eax
  800a53:	78 4b                	js     800aa0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a55:	39 c6                	cmp    %eax,%esi
  800a57:	73 16                	jae    800a6f <devfile_read+0x48>
  800a59:	68 64 1e 80 00       	push   $0x801e64
  800a5e:	68 6b 1e 80 00       	push   $0x801e6b
  800a63:	6a 7c                	push   $0x7c
  800a65:	68 80 1e 80 00       	push   $0x801e80
  800a6a:	e8 bd 05 00 00       	call   80102c <_panic>
	assert(r <= PGSIZE);
  800a6f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a74:	7e 16                	jle    800a8c <devfile_read+0x65>
  800a76:	68 8b 1e 80 00       	push   $0x801e8b
  800a7b:	68 6b 1e 80 00       	push   $0x801e6b
  800a80:	6a 7d                	push   $0x7d
  800a82:	68 80 1e 80 00       	push   $0x801e80
  800a87:	e8 a0 05 00 00       	call   80102c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a8c:	83 ec 04             	sub    $0x4,%esp
  800a8f:	50                   	push   %eax
  800a90:	68 00 50 80 00       	push   $0x805000
  800a95:	ff 75 0c             	pushl  0xc(%ebp)
  800a98:	e8 7f 0d 00 00       	call   80181c <memmove>
	return r;
  800a9d:	83 c4 10             	add    $0x10,%esp
}
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	53                   	push   %ebx
  800aad:	83 ec 20             	sub    $0x20,%esp
  800ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab3:	53                   	push   %ebx
  800ab4:	e8 98 0b 00 00       	call   801651 <strlen>
  800ab9:	83 c4 10             	add    $0x10,%esp
  800abc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac1:	7f 67                	jg     800b2a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac3:	83 ec 0c             	sub    $0xc,%esp
  800ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac9:	50                   	push   %eax
  800aca:	e8 a7 f8 ff ff       	call   800376 <fd_alloc>
  800acf:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad4:	85 c0                	test   %eax,%eax
  800ad6:	78 57                	js     800b2f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ad8:	83 ec 08             	sub    $0x8,%esp
  800adb:	53                   	push   %ebx
  800adc:	68 00 50 80 00       	push   $0x805000
  800ae1:	e8 a4 0b 00 00       	call   80168a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af1:	b8 01 00 00 00       	mov    $0x1,%eax
  800af6:	e8 03 fe ff ff       	call   8008fe <fsipc>
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	85 c0                	test   %eax,%eax
  800b02:	79 14                	jns    800b18 <open+0x6f>
		fd_close(fd, 0);
  800b04:	83 ec 08             	sub    $0x8,%esp
  800b07:	6a 00                	push   $0x0
  800b09:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0c:	e8 5d f9 ff ff       	call   80046e <fd_close>
		return r;
  800b11:	83 c4 10             	add    $0x10,%esp
  800b14:	89 da                	mov    %ebx,%edx
  800b16:	eb 17                	jmp    800b2f <open+0x86>
	}

	return fd2num(fd);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1e:	e8 2c f8 ff ff       	call   80034f <fd2num>
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	83 c4 10             	add    $0x10,%esp
  800b28:	eb 05                	jmp    800b2f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b2f:	89 d0                	mov    %edx,%eax
  800b31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 08 00 00 00       	mov    $0x8,%eax
  800b46:	e8 b3 fd ff ff       	call   8008fe <fsipc>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	ff 75 08             	pushl  0x8(%ebp)
  800b5b:	e8 ff f7 ff ff       	call   80035f <fd2data>
  800b60:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b62:	83 c4 08             	add    $0x8,%esp
  800b65:	68 97 1e 80 00       	push   $0x801e97
  800b6a:	53                   	push   %ebx
  800b6b:	e8 1a 0b 00 00       	call   80168a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b70:	8b 46 04             	mov    0x4(%esi),%eax
  800b73:	2b 06                	sub    (%esi),%eax
  800b75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b82:	00 00 00 
	stat->st_dev = &devpipe;
  800b85:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b8c:	30 80 00 
	return 0;
}
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba5:	53                   	push   %ebx
  800ba6:	6a 00                	push   $0x0
  800ba8:	e8 36 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bad:	89 1c 24             	mov    %ebx,(%esp)
  800bb0:	e8 aa f7 ff ff       	call   80035f <fd2data>
  800bb5:	83 c4 08             	add    $0x8,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 00                	push   $0x0
  800bbb:	e8 23 f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 1c             	sub    $0x1c,%esp
  800bce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd3:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	ff 75 e0             	pushl  -0x20(%ebp)
  800be1:	e8 df 0e 00 00       	call   801ac5 <pageref>
  800be6:	89 c3                	mov    %eax,%ebx
  800be8:	89 3c 24             	mov    %edi,(%esp)
  800beb:	e8 d5 0e 00 00       	call   801ac5 <pageref>
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	39 c3                	cmp    %eax,%ebx
  800bf5:	0f 94 c1             	sete   %cl
  800bf8:	0f b6 c9             	movzbl %cl,%ecx
  800bfb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bfe:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c07:	39 ce                	cmp    %ecx,%esi
  800c09:	74 1b                	je     800c26 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c0b:	39 c3                	cmp    %eax,%ebx
  800c0d:	75 c4                	jne    800bd3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c0f:	8b 42 58             	mov    0x58(%edx),%eax
  800c12:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c15:	50                   	push   %eax
  800c16:	56                   	push   %esi
  800c17:	68 9e 1e 80 00       	push   $0x801e9e
  800c1c:	e8 e4 04 00 00       	call   801105 <cprintf>
  800c21:	83 c4 10             	add    $0x10,%esp
  800c24:	eb ad                	jmp    800bd3 <_pipeisclosed+0xe>
	}
}
  800c26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 28             	sub    $0x28,%esp
  800c3a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c3d:	56                   	push   %esi
  800c3e:	e8 1c f7 ff ff       	call   80035f <fd2data>
  800c43:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4d:	eb 4b                	jmp    800c9a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c4f:	89 da                	mov    %ebx,%edx
  800c51:	89 f0                	mov    %esi,%eax
  800c53:	e8 6d ff ff ff       	call   800bc5 <_pipeisclosed>
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	75 48                	jne    800ca4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c5c:	e8 de f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c61:	8b 43 04             	mov    0x4(%ebx),%eax
  800c64:	8b 0b                	mov    (%ebx),%ecx
  800c66:	8d 51 20             	lea    0x20(%ecx),%edx
  800c69:	39 d0                	cmp    %edx,%eax
  800c6b:	73 e2                	jae    800c4f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c77:	89 c2                	mov    %eax,%edx
  800c79:	c1 fa 1f             	sar    $0x1f,%edx
  800c7c:	89 d1                	mov    %edx,%ecx
  800c7e:	c1 e9 1b             	shr    $0x1b,%ecx
  800c81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c84:	83 e2 1f             	and    $0x1f,%edx
  800c87:	29 ca                	sub    %ecx,%edx
  800c89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c91:	83 c0 01             	add    $0x1,%eax
  800c94:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c97:	83 c7 01             	add    $0x1,%edi
  800c9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c9d:	75 c2                	jne    800c61 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca2:	eb 05                	jmp    800ca9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 18             	sub    $0x18,%esp
  800cba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cbd:	57                   	push   %edi
  800cbe:	e8 9c f6 ff ff       	call   80035f <fd2data>
  800cc3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc5:	83 c4 10             	add    $0x10,%esp
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	eb 3d                	jmp    800d0c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ccf:	85 db                	test   %ebx,%ebx
  800cd1:	74 04                	je     800cd7 <devpipe_read+0x26>
				return i;
  800cd3:	89 d8                	mov    %ebx,%eax
  800cd5:	eb 44                	jmp    800d1b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cd7:	89 f2                	mov    %esi,%edx
  800cd9:	89 f8                	mov    %edi,%eax
  800cdb:	e8 e5 fe ff ff       	call   800bc5 <_pipeisclosed>
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	75 32                	jne    800d16 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce4:	e8 56 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ce9:	8b 06                	mov    (%esi),%eax
  800ceb:	3b 46 04             	cmp    0x4(%esi),%eax
  800cee:	74 df                	je     800ccf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf0:	99                   	cltd   
  800cf1:	c1 ea 1b             	shr    $0x1b,%edx
  800cf4:	01 d0                	add    %edx,%eax
  800cf6:	83 e0 1f             	and    $0x1f,%eax
  800cf9:	29 d0                	sub    %edx,%eax
  800cfb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d06:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d09:	83 c3 01             	add    $0x1,%ebx
  800d0c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d0f:	75 d8                	jne    800ce9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d11:	8b 45 10             	mov    0x10(%ebp),%eax
  800d14:	eb 05                	jmp    800d1b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d16:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d2e:	50                   	push   %eax
  800d2f:	e8 42 f6 ff ff       	call   800376 <fd_alloc>
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	89 c2                	mov    %eax,%edx
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	0f 88 2c 01 00 00    	js     800e6d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	68 07 04 00 00       	push   $0x407
  800d49:	ff 75 f4             	pushl  -0xc(%ebp)
  800d4c:	6a 00                	push   $0x0
  800d4e:	e8 0b f4 ff ff       	call   80015e <sys_page_alloc>
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	89 c2                	mov    %eax,%edx
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	0f 88 0d 01 00 00    	js     800e6d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d66:	50                   	push   %eax
  800d67:	e8 0a f6 ff ff       	call   800376 <fd_alloc>
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 e2 00 00 00    	js     800e5b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d79:	83 ec 04             	sub    $0x4,%esp
  800d7c:	68 07 04 00 00       	push   $0x407
  800d81:	ff 75 f0             	pushl  -0x10(%ebp)
  800d84:	6a 00                	push   $0x0
  800d86:	e8 d3 f3 ff ff       	call   80015e <sys_page_alloc>
  800d8b:	89 c3                	mov    %eax,%ebx
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	85 c0                	test   %eax,%eax
  800d92:	0f 88 c3 00 00 00    	js     800e5b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9e:	e8 bc f5 ff ff       	call   80035f <fd2data>
  800da3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da5:	83 c4 0c             	add    $0xc,%esp
  800da8:	68 07 04 00 00       	push   $0x407
  800dad:	50                   	push   %eax
  800dae:	6a 00                	push   $0x0
  800db0:	e8 a9 f3 ff ff       	call   80015e <sys_page_alloc>
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	0f 88 89 00 00 00    	js     800e4b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc8:	e8 92 f5 ff ff       	call   80035f <fd2data>
  800dcd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd4:	50                   	push   %eax
  800dd5:	6a 00                	push   $0x0
  800dd7:	56                   	push   %esi
  800dd8:	6a 00                	push   $0x0
  800dda:	e8 c2 f3 ff ff       	call   8001a1 <sys_page_map>
  800ddf:	89 c3                	mov    %eax,%ebx
  800de1:	83 c4 20             	add    $0x20,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	78 55                	js     800e3d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800de8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	ff 75 f4             	pushl  -0xc(%ebp)
  800e18:	e8 32 f5 ff ff       	call   80034f <fd2num>
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e22:	83 c4 04             	add    $0x4,%esp
  800e25:	ff 75 f0             	pushl  -0x10(%ebp)
  800e28:	e8 22 f5 ff ff       	call   80034f <fd2num>
  800e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3b:	eb 30                	jmp    800e6d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	56                   	push   %esi
  800e41:	6a 00                	push   $0x0
  800e43:	e8 9b f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e48:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e51:	6a 00                	push   $0x0
  800e53:	e8 8b f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e58:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e61:	6a 00                	push   $0x0
  800e63:	e8 7b f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e6d:	89 d0                	mov    %edx,%eax
  800e6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7f:	50                   	push   %eax
  800e80:	ff 75 08             	pushl  0x8(%ebp)
  800e83:	e8 3d f5 ff ff       	call   8003c5 <fd_lookup>
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	78 18                	js     800ea7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	ff 75 f4             	pushl  -0xc(%ebp)
  800e95:	e8 c5 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e9f:	e8 21 fd ff ff       	call   800bc5 <_pipeisclosed>
  800ea4:	83 c4 10             	add    $0x10,%esp
}
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eb9:	68 b6 1e 80 00       	push   $0x801eb6
  800ebe:	ff 75 0c             	pushl  0xc(%ebp)
  800ec1:	e8 c4 07 00 00       	call   80168a <strcpy>
	return 0;
}
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ede:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee4:	eb 2d                	jmp    800f13 <devcons_write+0x46>
		m = n - tot;
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800eeb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eee:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	53                   	push   %ebx
  800efa:	03 45 0c             	add    0xc(%ebp),%eax
  800efd:	50                   	push   %eax
  800efe:	57                   	push   %edi
  800eff:	e8 18 09 00 00       	call   80181c <memmove>
		sys_cputs(buf, m);
  800f04:	83 c4 08             	add    $0x8,%esp
  800f07:	53                   	push   %ebx
  800f08:	57                   	push   %edi
  800f09:	e8 94 f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0e:	01 de                	add    %ebx,%esi
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f18:	72 cc                	jb     800ee6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f31:	74 2a                	je     800f5d <devcons_read+0x3b>
  800f33:	eb 05                	jmp    800f3a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f35:	e8 05 f2 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3a:	e8 81 f1 ff ff       	call   8000c0 <sys_cgetc>
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	74 f2                	je     800f35 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 16                	js     800f5d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f47:	83 f8 04             	cmp    $0x4,%eax
  800f4a:	74 0c                	je     800f58 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4f:	88 02                	mov    %al,(%edx)
	return 1;
  800f51:	b8 01 00 00 00       	mov    $0x1,%eax
  800f56:	eb 05                	jmp    800f5d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6b:	6a 01                	push   $0x1
  800f6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f70:	50                   	push   %eax
  800f71:	e8 2c f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <getchar>:

int
getchar(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f81:	6a 01                	push   $0x1
  800f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	6a 00                	push   $0x0
  800f89:	e8 9d f6 ff ff       	call   80062b <read>
	if (r < 0)
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 0f                	js     800fa4 <getchar+0x29>
		return r;
	if (r < 1)
  800f95:	85 c0                	test   %eax,%eax
  800f97:	7e 06                	jle    800f9f <getchar+0x24>
		return -E_EOF;
	return c;
  800f99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f9d:	eb 05                	jmp    800fa4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	ff 75 08             	pushl  0x8(%ebp)
  800fb3:	e8 0d f4 ff ff       	call   8003c5 <fd_lookup>
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 11                	js     800fd0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc8:	39 10                	cmp    %edx,(%eax)
  800fca:	0f 94 c0             	sete   %al
  800fcd:	0f b6 c0             	movzbl %al,%eax
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <opencons>:

int
opencons(void)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	e8 95 f3 ff ff       	call   800376 <fd_alloc>
  800fe1:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 3e                	js     801028 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 07 04 00 00       	push   $0x407
  800ff2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 62 f1 ff ff       	call   80015e <sys_page_alloc>
  800ffc:	83 c4 10             	add    $0x10,%esp
		return r;
  800fff:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	78 23                	js     801028 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801005:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	50                   	push   %eax
  80101e:	e8 2c f3 ff ff       	call   80034f <fd2num>
  801023:	89 c2                	mov    %eax,%edx
  801025:	83 c4 10             	add    $0x10,%esp
}
  801028:	89 d0                	mov    %edx,%eax
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801031:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801034:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103a:	e8 e1 f0 ff ff       	call   800120 <sys_getenvid>
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	ff 75 0c             	pushl  0xc(%ebp)
  801045:	ff 75 08             	pushl  0x8(%ebp)
  801048:	56                   	push   %esi
  801049:	50                   	push   %eax
  80104a:	68 c4 1e 80 00       	push   $0x801ec4
  80104f:	e8 b1 00 00 00       	call   801105 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801054:	83 c4 18             	add    $0x18,%esp
  801057:	53                   	push   %ebx
  801058:	ff 75 10             	pushl  0x10(%ebp)
  80105b:	e8 54 00 00 00       	call   8010b4 <vcprintf>
	cprintf("\n");
  801060:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801067:	e8 99 00 00 00       	call   801105 <cprintf>
  80106c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80106f:	cc                   	int3   
  801070:	eb fd                	jmp    80106f <_panic+0x43>

00801072 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	53                   	push   %ebx
  801076:	83 ec 04             	sub    $0x4,%esp
  801079:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80107c:	8b 13                	mov    (%ebx),%edx
  80107e:	8d 42 01             	lea    0x1(%edx),%eax
  801081:	89 03                	mov    %eax,(%ebx)
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80108f:	75 1a                	jne    8010ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	68 ff 00 00 00       	push   $0xff
  801099:	8d 43 08             	lea    0x8(%ebx),%eax
  80109c:	50                   	push   %eax
  80109d:	e8 00 f0 ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c4:	00 00 00 
	b.cnt = 0;
  8010c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d1:	ff 75 0c             	pushl  0xc(%ebp)
  8010d4:	ff 75 08             	pushl  0x8(%ebp)
  8010d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	68 72 10 80 00       	push   $0x801072
  8010e3:	e8 54 01 00 00       	call   80123c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010e8:	83 c4 08             	add    $0x8,%esp
  8010eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	e8 a5 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8010fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80110e:	50                   	push   %eax
  80110f:	ff 75 08             	pushl  0x8(%ebp)
  801112:	e8 9d ff ff ff       	call   8010b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 1c             	sub    $0x1c,%esp
  801122:	89 c7                	mov    %eax,%edi
  801124:	89 d6                	mov    %edx,%esi
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80112f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801132:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801135:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80113d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801140:	39 d3                	cmp    %edx,%ebx
  801142:	72 05                	jb     801149 <printnum+0x30>
  801144:	39 45 10             	cmp    %eax,0x10(%ebp)
  801147:	77 45                	ja     80118e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801149:	83 ec 0c             	sub    $0xc,%esp
  80114c:	ff 75 18             	pushl  0x18(%ebp)
  80114f:	8b 45 14             	mov    0x14(%ebp),%eax
  801152:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801155:	53                   	push   %ebx
  801156:	ff 75 10             	pushl  0x10(%ebp)
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115f:	ff 75 e0             	pushl  -0x20(%ebp)
  801162:	ff 75 dc             	pushl  -0x24(%ebp)
  801165:	ff 75 d8             	pushl  -0x28(%ebp)
  801168:	e8 93 09 00 00       	call   801b00 <__udivdi3>
  80116d:	83 c4 18             	add    $0x18,%esp
  801170:	52                   	push   %edx
  801171:	50                   	push   %eax
  801172:	89 f2                	mov    %esi,%edx
  801174:	89 f8                	mov    %edi,%eax
  801176:	e8 9e ff ff ff       	call   801119 <printnum>
  80117b:	83 c4 20             	add    $0x20,%esp
  80117e:	eb 18                	jmp    801198 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	56                   	push   %esi
  801184:	ff 75 18             	pushl  0x18(%ebp)
  801187:	ff d7                	call   *%edi
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	eb 03                	jmp    801191 <printnum+0x78>
  80118e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801191:	83 eb 01             	sub    $0x1,%ebx
  801194:	85 db                	test   %ebx,%ebx
  801196:	7f e8                	jg     801180 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	56                   	push   %esi
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ab:	e8 80 0a 00 00       	call   801c30 <__umoddi3>
  8011b0:	83 c4 14             	add    $0x14,%esp
  8011b3:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  8011ba:	50                   	push   %eax
  8011bb:	ff d7                	call   *%edi
}
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011cb:	83 fa 01             	cmp    $0x1,%edx
  8011ce:	7e 0e                	jle    8011de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d0:	8b 10                	mov    (%eax),%edx
  8011d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d5:	89 08                	mov    %ecx,(%eax)
  8011d7:	8b 02                	mov    (%edx),%eax
  8011d9:	8b 52 04             	mov    0x4(%edx),%edx
  8011dc:	eb 22                	jmp    801200 <getuint+0x38>
	else if (lflag)
  8011de:	85 d2                	test   %edx,%edx
  8011e0:	74 10                	je     8011f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e2:	8b 10                	mov    (%eax),%edx
  8011e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e7:	89 08                	mov    %ecx,(%eax)
  8011e9:	8b 02                	mov    (%edx),%eax
  8011eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f0:	eb 0e                	jmp    801200 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f2:	8b 10                	mov    (%eax),%edx
  8011f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f7:	89 08                	mov    %ecx,(%eax)
  8011f9:	8b 02                	mov    (%edx),%eax
  8011fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801208:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80120c:	8b 10                	mov    (%eax),%edx
  80120e:	3b 50 04             	cmp    0x4(%eax),%edx
  801211:	73 0a                	jae    80121d <sprintputch+0x1b>
		*b->buf++ = ch;
  801213:	8d 4a 01             	lea    0x1(%edx),%ecx
  801216:	89 08                	mov    %ecx,(%eax)
  801218:	8b 45 08             	mov    0x8(%ebp),%eax
  80121b:	88 02                	mov    %al,(%edx)
}
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801225:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801228:	50                   	push   %eax
  801229:	ff 75 10             	pushl  0x10(%ebp)
  80122c:	ff 75 0c             	pushl  0xc(%ebp)
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 05 00 00 00       	call   80123c <vprintfmt>
	va_end(ap);
}
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 2c             	sub    $0x2c,%esp
  801245:	8b 75 08             	mov    0x8(%ebp),%esi
  801248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80124b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80124e:	eb 12                	jmp    801262 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801250:	85 c0                	test   %eax,%eax
  801252:	0f 84 89 03 00 00    	je     8015e1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	53                   	push   %ebx
  80125c:	50                   	push   %eax
  80125d:	ff d6                	call   *%esi
  80125f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801262:	83 c7 01             	add    $0x1,%edi
  801265:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801269:	83 f8 25             	cmp    $0x25,%eax
  80126c:	75 e2                	jne    801250 <vprintfmt+0x14>
  80126e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801272:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801279:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801280:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801287:	ba 00 00 00 00       	mov    $0x0,%edx
  80128c:	eb 07                	jmp    801295 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801291:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801295:	8d 47 01             	lea    0x1(%edi),%eax
  801298:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129b:	0f b6 07             	movzbl (%edi),%eax
  80129e:	0f b6 c8             	movzbl %al,%ecx
  8012a1:	83 e8 23             	sub    $0x23,%eax
  8012a4:	3c 55                	cmp    $0x55,%al
  8012a6:	0f 87 1a 03 00 00    	ja     8015c6 <vprintfmt+0x38a>
  8012ac:	0f b6 c0             	movzbl %al,%eax
  8012af:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  8012b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012bd:	eb d6                	jmp    801295 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012d7:	83 fa 09             	cmp    $0x9,%edx
  8012da:	77 39                	ja     801315 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012df:	eb e9                	jmp    8012ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8012e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012ea:	8b 00                	mov    (%eax),%eax
  8012ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f2:	eb 27                	jmp    80131b <vprintfmt+0xdf>
  8012f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012fe:	0f 49 c8             	cmovns %eax,%ecx
  801301:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801307:	eb 8c                	jmp    801295 <vprintfmt+0x59>
  801309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80130c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801313:	eb 80                	jmp    801295 <vprintfmt+0x59>
  801315:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801318:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80131b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80131f:	0f 89 70 ff ff ff    	jns    801295 <vprintfmt+0x59>
				width = precision, precision = -1;
  801325:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801328:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80132b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801332:	e9 5e ff ff ff       	jmp    801295 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801337:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80133d:	e9 53 ff ff ff       	jmp    801295 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801342:	8b 45 14             	mov    0x14(%ebp),%eax
  801345:	8d 50 04             	lea    0x4(%eax),%edx
  801348:	89 55 14             	mov    %edx,0x14(%ebp)
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	53                   	push   %ebx
  80134f:	ff 30                	pushl  (%eax)
  801351:	ff d6                	call   *%esi
			break;
  801353:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801359:	e9 04 ff ff ff       	jmp    801262 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135e:	8b 45 14             	mov    0x14(%ebp),%eax
  801361:	8d 50 04             	lea    0x4(%eax),%edx
  801364:	89 55 14             	mov    %edx,0x14(%ebp)
  801367:	8b 00                	mov    (%eax),%eax
  801369:	99                   	cltd   
  80136a:	31 d0                	xor    %edx,%eax
  80136c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80136e:	83 f8 0f             	cmp    $0xf,%eax
  801371:	7f 0b                	jg     80137e <vprintfmt+0x142>
  801373:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80137a:	85 d2                	test   %edx,%edx
  80137c:	75 18                	jne    801396 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80137e:	50                   	push   %eax
  80137f:	68 ff 1e 80 00       	push   $0x801eff
  801384:	53                   	push   %ebx
  801385:	56                   	push   %esi
  801386:	e8 94 fe ff ff       	call   80121f <printfmt>
  80138b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801391:	e9 cc fe ff ff       	jmp    801262 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801396:	52                   	push   %edx
  801397:	68 7d 1e 80 00       	push   $0x801e7d
  80139c:	53                   	push   %ebx
  80139d:	56                   	push   %esi
  80139e:	e8 7c fe ff ff       	call   80121f <printfmt>
  8013a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a9:	e9 b4 fe ff ff       	jmp    801262 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b1:	8d 50 04             	lea    0x4(%eax),%edx
  8013b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013b9:	85 ff                	test   %edi,%edi
  8013bb:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  8013c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013c7:	0f 8e 94 00 00 00    	jle    801461 <vprintfmt+0x225>
  8013cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d1:	0f 84 98 00 00 00    	je     80146f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	ff 75 d0             	pushl  -0x30(%ebp)
  8013dd:	57                   	push   %edi
  8013de:	e8 86 02 00 00       	call   801669 <strnlen>
  8013e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e6:	29 c1                	sub    %eax,%ecx
  8013e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fa:	eb 0f                	jmp    80140b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	53                   	push   %ebx
  801400:	ff 75 e0             	pushl  -0x20(%ebp)
  801403:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801405:	83 ef 01             	sub    $0x1,%edi
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 ff                	test   %edi,%edi
  80140d:	7f ed                	jg     8013fc <vprintfmt+0x1c0>
  80140f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801412:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801415:	85 c9                	test   %ecx,%ecx
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
  80141c:	0f 49 c1             	cmovns %ecx,%eax
  80141f:	29 c1                	sub    %eax,%ecx
  801421:	89 75 08             	mov    %esi,0x8(%ebp)
  801424:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801427:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80142a:	89 cb                	mov    %ecx,%ebx
  80142c:	eb 4d                	jmp    80147b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80142e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801432:	74 1b                	je     80144f <vprintfmt+0x213>
  801434:	0f be c0             	movsbl %al,%eax
  801437:	83 e8 20             	sub    $0x20,%eax
  80143a:	83 f8 5e             	cmp    $0x5e,%eax
  80143d:	76 10                	jbe    80144f <vprintfmt+0x213>
					putch('?', putdat);
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	ff 75 0c             	pushl  0xc(%ebp)
  801445:	6a 3f                	push   $0x3f
  801447:	ff 55 08             	call   *0x8(%ebp)
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	eb 0d                	jmp    80145c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	ff 75 0c             	pushl  0xc(%ebp)
  801455:	52                   	push   %edx
  801456:	ff 55 08             	call   *0x8(%ebp)
  801459:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80145c:	83 eb 01             	sub    $0x1,%ebx
  80145f:	eb 1a                	jmp    80147b <vprintfmt+0x23f>
  801461:	89 75 08             	mov    %esi,0x8(%ebp)
  801464:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801467:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80146d:	eb 0c                	jmp    80147b <vprintfmt+0x23f>
  80146f:	89 75 08             	mov    %esi,0x8(%ebp)
  801472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801478:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147b:	83 c7 01             	add    $0x1,%edi
  80147e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801482:	0f be d0             	movsbl %al,%edx
  801485:	85 d2                	test   %edx,%edx
  801487:	74 23                	je     8014ac <vprintfmt+0x270>
  801489:	85 f6                	test   %esi,%esi
  80148b:	78 a1                	js     80142e <vprintfmt+0x1f2>
  80148d:	83 ee 01             	sub    $0x1,%esi
  801490:	79 9c                	jns    80142e <vprintfmt+0x1f2>
  801492:	89 df                	mov    %ebx,%edi
  801494:	8b 75 08             	mov    0x8(%ebp),%esi
  801497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149a:	eb 18                	jmp    8014b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	53                   	push   %ebx
  8014a0:	6a 20                	push   $0x20
  8014a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a4:	83 ef 01             	sub    $0x1,%edi
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb 08                	jmp    8014b4 <vprintfmt+0x278>
  8014ac:	89 df                	mov    %ebx,%edi
  8014ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b4:	85 ff                	test   %edi,%edi
  8014b6:	7f e4                	jg     80149c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014bb:	e9 a2 fd ff ff       	jmp    801262 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c0:	83 fa 01             	cmp    $0x1,%edx
  8014c3:	7e 16                	jle    8014db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c8:	8d 50 08             	lea    0x8(%eax),%edx
  8014cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ce:	8b 50 04             	mov    0x4(%eax),%edx
  8014d1:	8b 00                	mov    (%eax),%eax
  8014d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014d9:	eb 32                	jmp    80150d <vprintfmt+0x2d1>
	else if (lflag)
  8014db:	85 d2                	test   %edx,%edx
  8014dd:	74 18                	je     8014f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014df:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e2:	8d 50 04             	lea    0x4(%eax),%edx
  8014e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e8:	8b 00                	mov    (%eax),%eax
  8014ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ed:	89 c1                	mov    %eax,%ecx
  8014ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f5:	eb 16                	jmp    80150d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8d 50 04             	lea    0x4(%eax),%edx
  8014fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801500:	8b 00                	mov    (%eax),%eax
  801502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801505:	89 c1                	mov    %eax,%ecx
  801507:	c1 f9 1f             	sar    $0x1f,%ecx
  80150a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80150d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801510:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801513:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801518:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80151c:	79 74                	jns    801592 <vprintfmt+0x356>
				putch('-', putdat);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	53                   	push   %ebx
  801522:	6a 2d                	push   $0x2d
  801524:	ff d6                	call   *%esi
				num = -(long long) num;
  801526:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801529:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80152c:	f7 d8                	neg    %eax
  80152e:	83 d2 00             	adc    $0x0,%edx
  801531:	f7 da                	neg    %edx
  801533:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801536:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80153b:	eb 55                	jmp    801592 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80153d:	8d 45 14             	lea    0x14(%ebp),%eax
  801540:	e8 83 fc ff ff       	call   8011c8 <getuint>
			base = 10;
  801545:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80154a:	eb 46                	jmp    801592 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80154c:	8d 45 14             	lea    0x14(%ebp),%eax
  80154f:	e8 74 fc ff ff       	call   8011c8 <getuint>
			base = 8;
  801554:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801559:	eb 37                	jmp    801592 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	53                   	push   %ebx
  80155f:	6a 30                	push   $0x30
  801561:	ff d6                	call   *%esi
			putch('x', putdat);
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	53                   	push   %ebx
  801567:	6a 78                	push   $0x78
  801569:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80156b:	8b 45 14             	mov    0x14(%ebp),%eax
  80156e:	8d 50 04             	lea    0x4(%eax),%edx
  801571:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801574:	8b 00                	mov    (%eax),%eax
  801576:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80157b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80157e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801583:	eb 0d                	jmp    801592 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801585:	8d 45 14             	lea    0x14(%ebp),%eax
  801588:	e8 3b fc ff ff       	call   8011c8 <getuint>
			base = 16;
  80158d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801599:	57                   	push   %edi
  80159a:	ff 75 e0             	pushl  -0x20(%ebp)
  80159d:	51                   	push   %ecx
  80159e:	52                   	push   %edx
  80159f:	50                   	push   %eax
  8015a0:	89 da                	mov    %ebx,%edx
  8015a2:	89 f0                	mov    %esi,%eax
  8015a4:	e8 70 fb ff ff       	call   801119 <printnum>
			break;
  8015a9:	83 c4 20             	add    $0x20,%esp
  8015ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015af:	e9 ae fc ff ff       	jmp    801262 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	51                   	push   %ecx
  8015b9:	ff d6                	call   *%esi
			break;
  8015bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015c1:	e9 9c fc ff ff       	jmp    801262 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	6a 25                	push   $0x25
  8015cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	eb 03                	jmp    8015d6 <vprintfmt+0x39a>
  8015d3:	83 ef 01             	sub    $0x1,%edi
  8015d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015da:	75 f7                	jne    8015d3 <vprintfmt+0x397>
  8015dc:	e9 81 fc ff ff       	jmp    801262 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e4:	5b                   	pop    %ebx
  8015e5:	5e                   	pop    %esi
  8015e6:	5f                   	pop    %edi
  8015e7:	5d                   	pop    %ebp
  8015e8:	c3                   	ret    

008015e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	83 ec 18             	sub    $0x18,%esp
  8015ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801606:	85 c0                	test   %eax,%eax
  801608:	74 26                	je     801630 <vsnprintf+0x47>
  80160a:	85 d2                	test   %edx,%edx
  80160c:	7e 22                	jle    801630 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80160e:	ff 75 14             	pushl  0x14(%ebp)
  801611:	ff 75 10             	pushl  0x10(%ebp)
  801614:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	68 02 12 80 00       	push   $0x801202
  80161d:	e8 1a fc ff ff       	call   80123c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801622:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801625:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 05                	jmp    801635 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801630:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801640:	50                   	push   %eax
  801641:	ff 75 10             	pushl  0x10(%ebp)
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	ff 75 08             	pushl  0x8(%ebp)
  80164a:	e8 9a ff ff ff       	call   8015e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
  80165c:	eb 03                	jmp    801661 <strlen+0x10>
		n++;
  80165e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801661:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801665:	75 f7                	jne    80165e <strlen+0xd>
		n++;
	return n;
}
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80166f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801672:	ba 00 00 00 00       	mov    $0x0,%edx
  801677:	eb 03                	jmp    80167c <strnlen+0x13>
		n++;
  801679:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167c:	39 c2                	cmp    %eax,%edx
  80167e:	74 08                	je     801688 <strnlen+0x1f>
  801680:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801684:	75 f3                	jne    801679 <strnlen+0x10>
  801686:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	53                   	push   %ebx
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801694:	89 c2                	mov    %eax,%edx
  801696:	83 c2 01             	add    $0x1,%edx
  801699:	83 c1 01             	add    $0x1,%ecx
  80169c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016a3:	84 db                	test   %bl,%bl
  8016a5:	75 ef                	jne    801696 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016a7:	5b                   	pop    %ebx
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016b1:	53                   	push   %ebx
  8016b2:	e8 9a ff ff ff       	call   801651 <strlen>
  8016b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ba:	ff 75 0c             	pushl  0xc(%ebp)
  8016bd:	01 d8                	add    %ebx,%eax
  8016bf:	50                   	push   %eax
  8016c0:	e8 c5 ff ff ff       	call   80168a <strcpy>
	return dst;
}
  8016c5:	89 d8                	mov    %ebx,%eax
  8016c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d7:	89 f3                	mov    %esi,%ebx
  8016d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016dc:	89 f2                	mov    %esi,%edx
  8016de:	eb 0f                	jmp    8016ef <strncpy+0x23>
		*dst++ = *src;
  8016e0:	83 c2 01             	add    $0x1,%edx
  8016e3:	0f b6 01             	movzbl (%ecx),%eax
  8016e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8016ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016ef:	39 da                	cmp    %ebx,%edx
  8016f1:	75 ed                	jne    8016e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016f3:	89 f0                	mov    %esi,%eax
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801704:	8b 55 10             	mov    0x10(%ebp),%edx
  801707:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801709:	85 d2                	test   %edx,%edx
  80170b:	74 21                	je     80172e <strlcpy+0x35>
  80170d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801711:	89 f2                	mov    %esi,%edx
  801713:	eb 09                	jmp    80171e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801715:	83 c2 01             	add    $0x1,%edx
  801718:	83 c1 01             	add    $0x1,%ecx
  80171b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80171e:	39 c2                	cmp    %eax,%edx
  801720:	74 09                	je     80172b <strlcpy+0x32>
  801722:	0f b6 19             	movzbl (%ecx),%ebx
  801725:	84 db                	test   %bl,%bl
  801727:	75 ec                	jne    801715 <strlcpy+0x1c>
  801729:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80172b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80172e:	29 f0                	sub    %esi,%eax
}
  801730:	5b                   	pop    %ebx
  801731:	5e                   	pop    %esi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80173a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80173d:	eb 06                	jmp    801745 <strcmp+0x11>
		p++, q++;
  80173f:	83 c1 01             	add    $0x1,%ecx
  801742:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801745:	0f b6 01             	movzbl (%ecx),%eax
  801748:	84 c0                	test   %al,%al
  80174a:	74 04                	je     801750 <strcmp+0x1c>
  80174c:	3a 02                	cmp    (%edx),%al
  80174e:	74 ef                	je     80173f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801750:	0f b6 c0             	movzbl %al,%eax
  801753:	0f b6 12             	movzbl (%edx),%edx
  801756:	29 d0                	sub    %edx,%eax
}
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	8b 45 08             	mov    0x8(%ebp),%eax
  801761:	8b 55 0c             	mov    0xc(%ebp),%edx
  801764:	89 c3                	mov    %eax,%ebx
  801766:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801769:	eb 06                	jmp    801771 <strncmp+0x17>
		n--, p++, q++;
  80176b:	83 c0 01             	add    $0x1,%eax
  80176e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801771:	39 d8                	cmp    %ebx,%eax
  801773:	74 15                	je     80178a <strncmp+0x30>
  801775:	0f b6 08             	movzbl (%eax),%ecx
  801778:	84 c9                	test   %cl,%cl
  80177a:	74 04                	je     801780 <strncmp+0x26>
  80177c:	3a 0a                	cmp    (%edx),%cl
  80177e:	74 eb                	je     80176b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801780:	0f b6 00             	movzbl (%eax),%eax
  801783:	0f b6 12             	movzbl (%edx),%edx
  801786:	29 d0                	sub    %edx,%eax
  801788:	eb 05                	jmp    80178f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80178f:	5b                   	pop    %ebx
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80179c:	eb 07                	jmp    8017a5 <strchr+0x13>
		if (*s == c)
  80179e:	38 ca                	cmp    %cl,%dl
  8017a0:	74 0f                	je     8017b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017a2:	83 c0 01             	add    $0x1,%eax
  8017a5:	0f b6 10             	movzbl (%eax),%edx
  8017a8:	84 d2                	test   %dl,%dl
  8017aa:	75 f2                	jne    80179e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017bd:	eb 03                	jmp    8017c2 <strfind+0xf>
  8017bf:	83 c0 01             	add    $0x1,%eax
  8017c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017c5:	38 ca                	cmp    %cl,%dl
  8017c7:	74 04                	je     8017cd <strfind+0x1a>
  8017c9:	84 d2                	test   %dl,%dl
  8017cb:	75 f2                	jne    8017bf <strfind+0xc>
			break;
	return (char *) s;
}
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	57                   	push   %edi
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017db:	85 c9                	test   %ecx,%ecx
  8017dd:	74 36                	je     801815 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017e5:	75 28                	jne    80180f <memset+0x40>
  8017e7:	f6 c1 03             	test   $0x3,%cl
  8017ea:	75 23                	jne    80180f <memset+0x40>
		c &= 0xFF;
  8017ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017f0:	89 d3                	mov    %edx,%ebx
  8017f2:	c1 e3 08             	shl    $0x8,%ebx
  8017f5:	89 d6                	mov    %edx,%esi
  8017f7:	c1 e6 18             	shl    $0x18,%esi
  8017fa:	89 d0                	mov    %edx,%eax
  8017fc:	c1 e0 10             	shl    $0x10,%eax
  8017ff:	09 f0                	or     %esi,%eax
  801801:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801803:	89 d8                	mov    %ebx,%eax
  801805:	09 d0                	or     %edx,%eax
  801807:	c1 e9 02             	shr    $0x2,%ecx
  80180a:	fc                   	cld    
  80180b:	f3 ab                	rep stos %eax,%es:(%edi)
  80180d:	eb 06                	jmp    801815 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80180f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801812:	fc                   	cld    
  801813:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801815:	89 f8                	mov    %edi,%eax
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5f                   	pop    %edi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	8b 75 0c             	mov    0xc(%ebp),%esi
  801827:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80182a:	39 c6                	cmp    %eax,%esi
  80182c:	73 35                	jae    801863 <memmove+0x47>
  80182e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801831:	39 d0                	cmp    %edx,%eax
  801833:	73 2e                	jae    801863 <memmove+0x47>
		s += n;
		d += n;
  801835:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801838:	89 d6                	mov    %edx,%esi
  80183a:	09 fe                	or     %edi,%esi
  80183c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801842:	75 13                	jne    801857 <memmove+0x3b>
  801844:	f6 c1 03             	test   $0x3,%cl
  801847:	75 0e                	jne    801857 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801849:	83 ef 04             	sub    $0x4,%edi
  80184c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80184f:	c1 e9 02             	shr    $0x2,%ecx
  801852:	fd                   	std    
  801853:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801855:	eb 09                	jmp    801860 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801857:	83 ef 01             	sub    $0x1,%edi
  80185a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80185d:	fd                   	std    
  80185e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801860:	fc                   	cld    
  801861:	eb 1d                	jmp    801880 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801863:	89 f2                	mov    %esi,%edx
  801865:	09 c2                	or     %eax,%edx
  801867:	f6 c2 03             	test   $0x3,%dl
  80186a:	75 0f                	jne    80187b <memmove+0x5f>
  80186c:	f6 c1 03             	test   $0x3,%cl
  80186f:	75 0a                	jne    80187b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801871:	c1 e9 02             	shr    $0x2,%ecx
  801874:	89 c7                	mov    %eax,%edi
  801876:	fc                   	cld    
  801877:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801879:	eb 05                	jmp    801880 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80187b:	89 c7                	mov    %eax,%edi
  80187d:	fc                   	cld    
  80187e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801880:	5e                   	pop    %esi
  801881:	5f                   	pop    %edi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801887:	ff 75 10             	pushl  0x10(%ebp)
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	ff 75 08             	pushl  0x8(%ebp)
  801890:	e8 87 ff ff ff       	call   80181c <memmove>
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a2:	89 c6                	mov    %eax,%esi
  8018a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a7:	eb 1a                	jmp    8018c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8018a9:	0f b6 08             	movzbl (%eax),%ecx
  8018ac:	0f b6 1a             	movzbl (%edx),%ebx
  8018af:	38 d9                	cmp    %bl,%cl
  8018b1:	74 0a                	je     8018bd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018b3:	0f b6 c1             	movzbl %cl,%eax
  8018b6:	0f b6 db             	movzbl %bl,%ebx
  8018b9:	29 d8                	sub    %ebx,%eax
  8018bb:	eb 0f                	jmp    8018cc <memcmp+0x35>
		s1++, s2++;
  8018bd:	83 c0 01             	add    $0x1,%eax
  8018c0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c3:	39 f0                	cmp    %esi,%eax
  8018c5:	75 e2                	jne    8018a9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018d7:	89 c1                	mov    %eax,%ecx
  8018d9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018dc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e0:	eb 0a                	jmp    8018ec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018e2:	0f b6 10             	movzbl (%eax),%edx
  8018e5:	39 da                	cmp    %ebx,%edx
  8018e7:	74 07                	je     8018f0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018e9:	83 c0 01             	add    $0x1,%eax
  8018ec:	39 c8                	cmp    %ecx,%eax
  8018ee:	72 f2                	jb     8018e2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018f0:	5b                   	pop    %ebx
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	57                   	push   %edi
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ff:	eb 03                	jmp    801904 <strtol+0x11>
		s++;
  801901:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801904:	0f b6 01             	movzbl (%ecx),%eax
  801907:	3c 20                	cmp    $0x20,%al
  801909:	74 f6                	je     801901 <strtol+0xe>
  80190b:	3c 09                	cmp    $0x9,%al
  80190d:	74 f2                	je     801901 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80190f:	3c 2b                	cmp    $0x2b,%al
  801911:	75 0a                	jne    80191d <strtol+0x2a>
		s++;
  801913:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801916:	bf 00 00 00 00       	mov    $0x0,%edi
  80191b:	eb 11                	jmp    80192e <strtol+0x3b>
  80191d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801922:	3c 2d                	cmp    $0x2d,%al
  801924:	75 08                	jne    80192e <strtol+0x3b>
		s++, neg = 1;
  801926:	83 c1 01             	add    $0x1,%ecx
  801929:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80192e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801934:	75 15                	jne    80194b <strtol+0x58>
  801936:	80 39 30             	cmpb   $0x30,(%ecx)
  801939:	75 10                	jne    80194b <strtol+0x58>
  80193b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80193f:	75 7c                	jne    8019bd <strtol+0xca>
		s += 2, base = 16;
  801941:	83 c1 02             	add    $0x2,%ecx
  801944:	bb 10 00 00 00       	mov    $0x10,%ebx
  801949:	eb 16                	jmp    801961 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80194b:	85 db                	test   %ebx,%ebx
  80194d:	75 12                	jne    801961 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80194f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801954:	80 39 30             	cmpb   $0x30,(%ecx)
  801957:	75 08                	jne    801961 <strtol+0x6e>
		s++, base = 8;
  801959:	83 c1 01             	add    $0x1,%ecx
  80195c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
  801966:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801969:	0f b6 11             	movzbl (%ecx),%edx
  80196c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80196f:	89 f3                	mov    %esi,%ebx
  801971:	80 fb 09             	cmp    $0x9,%bl
  801974:	77 08                	ja     80197e <strtol+0x8b>
			dig = *s - '0';
  801976:	0f be d2             	movsbl %dl,%edx
  801979:	83 ea 30             	sub    $0x30,%edx
  80197c:	eb 22                	jmp    8019a0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80197e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801981:	89 f3                	mov    %esi,%ebx
  801983:	80 fb 19             	cmp    $0x19,%bl
  801986:	77 08                	ja     801990 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801988:	0f be d2             	movsbl %dl,%edx
  80198b:	83 ea 57             	sub    $0x57,%edx
  80198e:	eb 10                	jmp    8019a0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801990:	8d 72 bf             	lea    -0x41(%edx),%esi
  801993:	89 f3                	mov    %esi,%ebx
  801995:	80 fb 19             	cmp    $0x19,%bl
  801998:	77 16                	ja     8019b0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80199a:	0f be d2             	movsbl %dl,%edx
  80199d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019a0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019a3:	7d 0b                	jge    8019b0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019a5:	83 c1 01             	add    $0x1,%ecx
  8019a8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ae:	eb b9                	jmp    801969 <strtol+0x76>

	if (endptr)
  8019b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019b4:	74 0d                	je     8019c3 <strtol+0xd0>
		*endptr = (char *) s;
  8019b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b9:	89 0e                	mov    %ecx,(%esi)
  8019bb:	eb 06                	jmp    8019c3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019bd:	85 db                	test   %ebx,%ebx
  8019bf:	74 98                	je     801959 <strtol+0x66>
  8019c1:	eb 9e                	jmp    801961 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019c3:	89 c2                	mov    %eax,%edx
  8019c5:	f7 da                	neg    %edx
  8019c7:	85 ff                	test   %edi,%edi
  8019c9:	0f 45 c2             	cmovne %edx,%eax
}
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5f                   	pop    %edi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019df:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019e1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019e6:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	50                   	push   %eax
  8019ed:	e8 1c e9 ff ff       	call   80030e <sys_ipc_recv>

	if (from_env_store != NULL)
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	85 f6                	test   %esi,%esi
  8019f7:	74 14                	je     801a0d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 09                	js     801a0b <ipc_recv+0x3a>
  801a02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a08:	8b 52 74             	mov    0x74(%edx),%edx
  801a0b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a0d:	85 db                	test   %ebx,%ebx
  801a0f:	74 14                	je     801a25 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a11:	ba 00 00 00 00       	mov    $0x0,%edx
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 09                	js     801a23 <ipc_recv+0x52>
  801a1a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a20:	8b 52 78             	mov    0x78(%edx),%edx
  801a23:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 08                	js     801a31 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a29:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	57                   	push   %edi
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a4a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a4c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a51:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a54:	ff 75 14             	pushl  0x14(%ebp)
  801a57:	53                   	push   %ebx
  801a58:	56                   	push   %esi
  801a59:	57                   	push   %edi
  801a5a:	e8 8c e8 ff ff       	call   8002eb <sys_ipc_try_send>

		if (err < 0) {
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	85 c0                	test   %eax,%eax
  801a64:	79 1e                	jns    801a84 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a66:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a69:	75 07                	jne    801a72 <ipc_send+0x3a>
				sys_yield();
  801a6b:	e8 cf e6 ff ff       	call   80013f <sys_yield>
  801a70:	eb e2                	jmp    801a54 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a72:	50                   	push   %eax
  801a73:	68 e0 21 80 00       	push   $0x8021e0
  801a78:	6a 49                	push   $0x49
  801a7a:	68 ed 21 80 00       	push   $0x8021ed
  801a7f:	e8 a8 f5 ff ff       	call   80102c <_panic>
		}

	} while (err < 0);

}
  801a84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a92:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a97:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a9a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa0:	8b 52 50             	mov    0x50(%edx),%edx
  801aa3:	39 ca                	cmp    %ecx,%edx
  801aa5:	75 0d                	jne    801ab4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aa7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aaa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aaf:	8b 40 48             	mov    0x48(%eax),%eax
  801ab2:	eb 0f                	jmp    801ac3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab4:	83 c0 01             	add    $0x1,%eax
  801ab7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801abc:	75 d9                	jne    801a97 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801acb:	89 d0                	mov    %edx,%eax
  801acd:	c1 e8 16             	shr    $0x16,%eax
  801ad0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801adc:	f6 c1 01             	test   $0x1,%cl
  801adf:	74 1d                	je     801afe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae1:	c1 ea 0c             	shr    $0xc,%edx
  801ae4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801aeb:	f6 c2 01             	test   $0x1,%dl
  801aee:	74 0e                	je     801afe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af0:	c1 ea 0c             	shr    $0xc,%edx
  801af3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801afa:	ef 
  801afb:	0f b7 c0             	movzwl %ax,%eax
}
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <__udivdi3>:
  801b00:	55                   	push   %ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b17:	85 f6                	test   %esi,%esi
  801b19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b1d:	89 ca                	mov    %ecx,%edx
  801b1f:	89 f8                	mov    %edi,%eax
  801b21:	75 3d                	jne    801b60 <__udivdi3+0x60>
  801b23:	39 cf                	cmp    %ecx,%edi
  801b25:	0f 87 c5 00 00 00    	ja     801bf0 <__udivdi3+0xf0>
  801b2b:	85 ff                	test   %edi,%edi
  801b2d:	89 fd                	mov    %edi,%ebp
  801b2f:	75 0b                	jne    801b3c <__udivdi3+0x3c>
  801b31:	b8 01 00 00 00       	mov    $0x1,%eax
  801b36:	31 d2                	xor    %edx,%edx
  801b38:	f7 f7                	div    %edi
  801b3a:	89 c5                	mov    %eax,%ebp
  801b3c:	89 c8                	mov    %ecx,%eax
  801b3e:	31 d2                	xor    %edx,%edx
  801b40:	f7 f5                	div    %ebp
  801b42:	89 c1                	mov    %eax,%ecx
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	89 cf                	mov    %ecx,%edi
  801b48:	f7 f5                	div    %ebp
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	89 d8                	mov    %ebx,%eax
  801b4e:	89 fa                	mov    %edi,%edx
  801b50:	83 c4 1c             	add    $0x1c,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
  801b58:	90                   	nop
  801b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b60:	39 ce                	cmp    %ecx,%esi
  801b62:	77 74                	ja     801bd8 <__udivdi3+0xd8>
  801b64:	0f bd fe             	bsr    %esi,%edi
  801b67:	83 f7 1f             	xor    $0x1f,%edi
  801b6a:	0f 84 98 00 00 00    	je     801c08 <__udivdi3+0x108>
  801b70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b75:	89 f9                	mov    %edi,%ecx
  801b77:	89 c5                	mov    %eax,%ebp
  801b79:	29 fb                	sub    %edi,%ebx
  801b7b:	d3 e6                	shl    %cl,%esi
  801b7d:	89 d9                	mov    %ebx,%ecx
  801b7f:	d3 ed                	shr    %cl,%ebp
  801b81:	89 f9                	mov    %edi,%ecx
  801b83:	d3 e0                	shl    %cl,%eax
  801b85:	09 ee                	or     %ebp,%esi
  801b87:	89 d9                	mov    %ebx,%ecx
  801b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8d:	89 d5                	mov    %edx,%ebp
  801b8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b93:	d3 ed                	shr    %cl,%ebp
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	d3 e2                	shl    %cl,%edx
  801b99:	89 d9                	mov    %ebx,%ecx
  801b9b:	d3 e8                	shr    %cl,%eax
  801b9d:	09 c2                	or     %eax,%edx
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	89 ea                	mov    %ebp,%edx
  801ba3:	f7 f6                	div    %esi
  801ba5:	89 d5                	mov    %edx,%ebp
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	f7 64 24 0c          	mull   0xc(%esp)
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	72 10                	jb     801bc1 <__udivdi3+0xc1>
  801bb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	d3 e6                	shl    %cl,%esi
  801bb9:	39 c6                	cmp    %eax,%esi
  801bbb:	73 07                	jae    801bc4 <__udivdi3+0xc4>
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	75 03                	jne    801bc4 <__udivdi3+0xc4>
  801bc1:	83 eb 01             	sub    $0x1,%ebx
  801bc4:	31 ff                	xor    %edi,%edi
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	89 fa                	mov    %edi,%edx
  801bca:	83 c4 1c             	add    $0x1c,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    
  801bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bd8:	31 ff                	xor    %edi,%edi
  801bda:	31 db                	xor    %ebx,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	f7 f7                	div    %edi
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	89 fa                	mov    %edi,%edx
  801bfc:	83 c4 1c             	add    $0x1c,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	39 ce                	cmp    %ecx,%esi
  801c0a:	72 0c                	jb     801c18 <__udivdi3+0x118>
  801c0c:	31 db                	xor    %ebx,%ebx
  801c0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c12:	0f 87 34 ff ff ff    	ja     801b4c <__udivdi3+0x4c>
  801c18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c1d:	e9 2a ff ff ff       	jmp    801b4c <__udivdi3+0x4c>
  801c22:	66 90                	xchg   %ax,%ax
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__umoddi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 d2                	test   %edx,%edx
  801c49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f3                	mov    %esi,%ebx
  801c53:	89 3c 24             	mov    %edi,(%esp)
  801c56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5a:	75 1c                	jne    801c78 <__umoddi3+0x48>
  801c5c:	39 f7                	cmp    %esi,%edi
  801c5e:	76 50                	jbe    801cb0 <__umoddi3+0x80>
  801c60:	89 c8                	mov    %ecx,%eax
  801c62:	89 f2                	mov    %esi,%edx
  801c64:	f7 f7                	div    %edi
  801c66:	89 d0                	mov    %edx,%eax
  801c68:	31 d2                	xor    %edx,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	89 d0                	mov    %edx,%eax
  801c7c:	77 52                	ja     801cd0 <__umoddi3+0xa0>
  801c7e:	0f bd ea             	bsr    %edx,%ebp
  801c81:	83 f5 1f             	xor    $0x1f,%ebp
  801c84:	75 5a                	jne    801ce0 <__umoddi3+0xb0>
  801c86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c8a:	0f 82 e0 00 00 00    	jb     801d70 <__umoddi3+0x140>
  801c90:	39 0c 24             	cmp    %ecx,(%esp)
  801c93:	0f 86 d7 00 00 00    	jbe    801d70 <__umoddi3+0x140>
  801c99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ca1:	83 c4 1c             	add    $0x1c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	85 ff                	test   %edi,%edi
  801cb2:	89 fd                	mov    %edi,%ebp
  801cb4:	75 0b                	jne    801cc1 <__umoddi3+0x91>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f7                	div    %edi
  801cbf:	89 c5                	mov    %eax,%ebp
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  801cc5:	f7 f5                	div    %ebp
  801cc7:	89 c8                	mov    %ecx,%eax
  801cc9:	f7 f5                	div    %ebp
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	eb 99                	jmp    801c68 <__umoddi3+0x38>
  801ccf:	90                   	nop
  801cd0:	89 c8                	mov    %ecx,%eax
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	83 c4 1c             	add    $0x1c,%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    
  801cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	8b 34 24             	mov    (%esp),%esi
  801ce3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ce8:	89 e9                	mov    %ebp,%ecx
  801cea:	29 ef                	sub    %ebp,%edi
  801cec:	d3 e0                	shl    %cl,%eax
  801cee:	89 f9                	mov    %edi,%ecx
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	d3 ea                	shr    %cl,%edx
  801cf4:	89 e9                	mov    %ebp,%ecx
  801cf6:	09 c2                	or     %eax,%edx
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	89 14 24             	mov    %edx,(%esp)
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	d3 e2                	shl    %cl,%edx
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d0b:	d3 e8                	shr    %cl,%eax
  801d0d:	89 e9                	mov    %ebp,%ecx
  801d0f:	89 c6                	mov    %eax,%esi
  801d11:	d3 e3                	shl    %cl,%ebx
  801d13:	89 f9                	mov    %edi,%ecx
  801d15:	89 d0                	mov    %edx,%eax
  801d17:	d3 e8                	shr    %cl,%eax
  801d19:	89 e9                	mov    %ebp,%ecx
  801d1b:	09 d8                	or     %ebx,%eax
  801d1d:	89 d3                	mov    %edx,%ebx
  801d1f:	89 f2                	mov    %esi,%edx
  801d21:	f7 34 24             	divl   (%esp)
  801d24:	89 d6                	mov    %edx,%esi
  801d26:	d3 e3                	shl    %cl,%ebx
  801d28:	f7 64 24 04          	mull   0x4(%esp)
  801d2c:	39 d6                	cmp    %edx,%esi
  801d2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	72 08                	jb     801d40 <__umoddi3+0x110>
  801d38:	75 11                	jne    801d4b <__umoddi3+0x11b>
  801d3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d3e:	73 0b                	jae    801d4b <__umoddi3+0x11b>
  801d40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d44:	1b 14 24             	sbb    (%esp),%edx
  801d47:	89 d1                	mov    %edx,%ecx
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d4f:	29 da                	sub    %ebx,%edx
  801d51:	19 ce                	sbb    %ecx,%esi
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	d3 e0                	shl    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 ea                	shr    %cl,%edx
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	d3 ee                	shr    %cl,%esi
  801d61:	09 d0                	or     %edx,%eax
  801d63:	89 f2                	mov    %esi,%edx
  801d65:	83 c4 1c             	add    $0x1c,%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	29 f9                	sub    %edi,%ecx
  801d72:	19 d6                	sbb    %edx,%esi
  801d74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d7c:	e9 18 ff ff ff       	jmp    801c99 <__umoddi3+0x69>
