
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 8a 1d 80 00       	push   $0x801d8a
  800104:	6a 23                	push   $0x23
  800106:	68 a7 1d 80 00       	push   $0x801da7
  80010b:	e8 f5 0e 00 00       	call   801005 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 8a 1d 80 00       	push   $0x801d8a
  800185:	6a 23                	push   $0x23
  800187:	68 a7 1d 80 00       	push   $0x801da7
  80018c:	e8 74 0e 00 00       	call   801005 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 8a 1d 80 00       	push   $0x801d8a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 a7 1d 80 00       	push   $0x801da7
  8001ce:	e8 32 0e 00 00       	call   801005 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 8a 1d 80 00       	push   $0x801d8a
  800209:	6a 23                	push   $0x23
  80020b:	68 a7 1d 80 00       	push   $0x801da7
  800210:	e8 f0 0d 00 00       	call   801005 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 8a 1d 80 00       	push   $0x801d8a
  80024b:	6a 23                	push   $0x23
  80024d:	68 a7 1d 80 00       	push   $0x801da7
  800252:	e8 ae 0d 00 00       	call   801005 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 8a 1d 80 00       	push   $0x801d8a
  80028d:	6a 23                	push   $0x23
  80028f:	68 a7 1d 80 00       	push   $0x801da7
  800294:	e8 6c 0d 00 00       	call   801005 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 8a 1d 80 00       	push   $0x801d8a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 a7 1d 80 00       	push   $0x801da7
  8002d6:	e8 2a 0d 00 00       	call   801005 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 8a 1d 80 00       	push   $0x801d8a
  800333:	6a 23                	push   $0x23
  800335:	68 a7 1d 80 00       	push   $0x801da7
  80033a:	e8 c6 0c 00 00       	call   801005 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 34 1e 80 00       	mov    $0x801e34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 b8 1d 80 00       	push   $0x801db8
  80044e:	e8 8b 0c 00 00       	call   8010de <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 f9 1d 80 00       	push   $0x801df9
  800678:	e8 61 0a 00 00       	call   8010de <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 15 1e 80 00       	push   $0x801e15
  80074d:	e8 8c 09 00 00       	call   8010de <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 d8 1d 80 00       	push   $0x801dd8
  800802:	e8 d7 08 00 00       	call   8010de <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 b7 01 00 00       	call   800a82 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 53 11 00 00       	call   801a65 <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 e4 10 00 00       	call   801a11 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 70 10 00 00       	call   8019aa <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 a0 0c 00 00       	call   801663 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009ec:	68 44 1e 80 00       	push   $0x801e44
  8009f1:	68 90 00 00 00       	push   $0x90
  8009f6:	68 62 1e 80 00       	push   $0x801e62
  8009fb:	e8 05 06 00 00       	call   801005 <_panic>

00800a00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a23:	e8 ce fe ff ff       	call   8008f6 <fsipc>
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	85 c0                	test   %eax,%eax
  800a2c:	78 4b                	js     800a79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a2e:	39 c6                	cmp    %eax,%esi
  800a30:	73 16                	jae    800a48 <devfile_read+0x48>
  800a32:	68 6d 1e 80 00       	push   $0x801e6d
  800a37:	68 74 1e 80 00       	push   $0x801e74
  800a3c:	6a 7c                	push   $0x7c
  800a3e:	68 62 1e 80 00       	push   $0x801e62
  800a43:	e8 bd 05 00 00       	call   801005 <_panic>
	assert(r <= PGSIZE);
  800a48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4d:	7e 16                	jle    800a65 <devfile_read+0x65>
  800a4f:	68 89 1e 80 00       	push   $0x801e89
  800a54:	68 74 1e 80 00       	push   $0x801e74
  800a59:	6a 7d                	push   $0x7d
  800a5b:	68 62 1e 80 00       	push   $0x801e62
  800a60:	e8 a0 05 00 00       	call   801005 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a65:	83 ec 04             	sub    $0x4,%esp
  800a68:	50                   	push   %eax
  800a69:	68 00 50 80 00       	push   $0x805000
  800a6e:	ff 75 0c             	pushl  0xc(%ebp)
  800a71:	e8 7f 0d 00 00       	call   8017f5 <memmove>
	return r;
  800a76:	83 c4 10             	add    $0x10,%esp
}
  800a79:	89 d8                	mov    %ebx,%eax
  800a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	83 ec 20             	sub    $0x20,%esp
  800a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8c:	53                   	push   %ebx
  800a8d:	e8 98 0b 00 00       	call   80162a <strlen>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9a:	7f 67                	jg     800b03 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa2:	50                   	push   %eax
  800aa3:	e8 c6 f8 ff ff       	call   80036e <fd_alloc>
  800aa8:	83 c4 10             	add    $0x10,%esp
		return r;
  800aab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	78 57                	js     800b08 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	53                   	push   %ebx
  800ab5:	68 00 50 80 00       	push   $0x805000
  800aba:	e8 a4 0b 00 00       	call   801663 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	e8 22 fe ff ff       	call   8008f6 <fsipc>
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	79 14                	jns    800af1 <open+0x6f>
		fd_close(fd, 0);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	6a 00                	push   $0x0
  800ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae5:	e8 7c f9 ff ff       	call   800466 <fd_close>
		return r;
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	89 da                	mov    %ebx,%edx
  800aef:	eb 17                	jmp    800b08 <open+0x86>
	}

	return fd2num(fd);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	ff 75 f4             	pushl  -0xc(%ebp)
  800af7:	e8 4b f8 ff ff       	call   800347 <fd2num>
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	eb 05                	jmp    800b08 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b08:	89 d0                	mov    %edx,%eax
  800b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1f:	e8 d2 fd ff ff       	call   8008f6 <fsipc>
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	ff 75 08             	pushl  0x8(%ebp)
  800b34:	e8 1e f8 ff ff       	call   800357 <fd2data>
  800b39:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3b:	83 c4 08             	add    $0x8,%esp
  800b3e:	68 95 1e 80 00       	push   $0x801e95
  800b43:	53                   	push   %ebx
  800b44:	e8 1a 0b 00 00       	call   801663 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b49:	8b 46 04             	mov    0x4(%esi),%eax
  800b4c:	2b 06                	sub    (%esi),%eax
  800b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b54:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5b:	00 00 00 
	stat->st_dev = &devpipe;
  800b5e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b65:	30 80 00 
	return 0;
}
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b7e:	53                   	push   %ebx
  800b7f:	6a 00                	push   $0x0
  800b81:	e8 55 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b86:	89 1c 24             	mov    %ebx,(%esp)
  800b89:	e8 c9 f7 ff ff       	call   800357 <fd2data>
  800b8e:	83 c4 08             	add    $0x8,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 00                	push   $0x0
  800b94:	e8 42 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 1c             	sub    $0x1c,%esp
  800ba7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800baa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bac:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bba:	e8 df 0e 00 00       	call   801a9e <pageref>
  800bbf:	89 c3                	mov    %eax,%ebx
  800bc1:	89 3c 24             	mov    %edi,(%esp)
  800bc4:	e8 d5 0e 00 00       	call   801a9e <pageref>
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	39 c3                	cmp    %eax,%ebx
  800bce:	0f 94 c1             	sete   %cl
  800bd1:	0f b6 c9             	movzbl %cl,%ecx
  800bd4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bd7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bdd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be0:	39 ce                	cmp    %ecx,%esi
  800be2:	74 1b                	je     800bff <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800be4:	39 c3                	cmp    %eax,%ebx
  800be6:	75 c4                	jne    800bac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be8:	8b 42 58             	mov    0x58(%edx),%eax
  800beb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bee:	50                   	push   %eax
  800bef:	56                   	push   %esi
  800bf0:	68 9c 1e 80 00       	push   $0x801e9c
  800bf5:	e8 e4 04 00 00       	call   8010de <cprintf>
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb ad                	jmp    800bac <_pipeisclosed+0xe>
	}
}
  800bff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 28             	sub    $0x28,%esp
  800c13:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c16:	56                   	push   %esi
  800c17:	e8 3b f7 ff ff       	call   800357 <fd2data>
  800c1c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
  800c26:	eb 4b                	jmp    800c73 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c28:	89 da                	mov    %ebx,%edx
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	e8 6d ff ff ff       	call   800b9e <_pipeisclosed>
  800c31:	85 c0                	test   %eax,%eax
  800c33:	75 48                	jne    800c7d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c35:	e8 fd f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c3d:	8b 0b                	mov    (%ebx),%ecx
  800c3f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c42:	39 d0                	cmp    %edx,%eax
  800c44:	73 e2                	jae    800c28 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c4d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c50:	89 c2                	mov    %eax,%edx
  800c52:	c1 fa 1f             	sar    $0x1f,%edx
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	c1 e9 1b             	shr    $0x1b,%ecx
  800c5a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c5d:	83 e2 1f             	and    $0x1f,%edx
  800c60:	29 ca                	sub    %ecx,%edx
  800c62:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6a:	83 c0 01             	add    $0x1,%eax
  800c6d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c70:	83 c7 01             	add    $0x1,%edi
  800c73:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c76:	75 c2                	jne    800c3a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	eb 05                	jmp    800c82 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 18             	sub    $0x18,%esp
  800c93:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c96:	57                   	push   %edi
  800c97:	e8 bb f6 ff ff       	call   800357 <fd2data>
  800c9c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca6:	eb 3d                	jmp    800ce5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	74 04                	je     800cb0 <devpipe_read+0x26>
				return i;
  800cac:	89 d8                	mov    %ebx,%eax
  800cae:	eb 44                	jmp    800cf4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cb0:	89 f2                	mov    %esi,%edx
  800cb2:	89 f8                	mov    %edi,%eax
  800cb4:	e8 e5 fe ff ff       	call   800b9e <_pipeisclosed>
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	75 32                	jne    800cef <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cbd:	e8 75 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc2:	8b 06                	mov    (%esi),%eax
  800cc4:	3b 46 04             	cmp    0x4(%esi),%eax
  800cc7:	74 df                	je     800ca8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cc9:	99                   	cltd   
  800cca:	c1 ea 1b             	shr    $0x1b,%edx
  800ccd:	01 d0                	add    %edx,%eax
  800ccf:	83 e0 1f             	and    $0x1f,%eax
  800cd2:	29 d0                	sub    %edx,%eax
  800cd4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cdf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce2:	83 c3 01             	add    $0x1,%ebx
  800ce5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800ce8:	75 d8                	jne    800cc2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ced:	eb 05                	jmp    800cf4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d07:	50                   	push   %eax
  800d08:	e8 61 f6 ff ff       	call   80036e <fd_alloc>
  800d0d:	83 c4 10             	add    $0x10,%esp
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	85 c0                	test   %eax,%eax
  800d14:	0f 88 2c 01 00 00    	js     800e46 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1a:	83 ec 04             	sub    $0x4,%esp
  800d1d:	68 07 04 00 00       	push   $0x407
  800d22:	ff 75 f4             	pushl  -0xc(%ebp)
  800d25:	6a 00                	push   $0x0
  800d27:	e8 2a f4 ff ff       	call   800156 <sys_page_alloc>
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	89 c2                	mov    %eax,%edx
  800d31:	85 c0                	test   %eax,%eax
  800d33:	0f 88 0d 01 00 00    	js     800e46 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3f:	50                   	push   %eax
  800d40:	e8 29 f6 ff ff       	call   80036e <fd_alloc>
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	0f 88 e2 00 00 00    	js     800e34 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	68 07 04 00 00       	push   $0x407
  800d5a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 f2 f3 ff ff       	call   800156 <sys_page_alloc>
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 c3 00 00 00    	js     800e34 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	ff 75 f4             	pushl  -0xc(%ebp)
  800d77:	e8 db f5 ff ff       	call   800357 <fd2data>
  800d7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 c4 0c             	add    $0xc,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	50                   	push   %eax
  800d87:	6a 00                	push   $0x0
  800d89:	e8 c8 f3 ff ff       	call   800156 <sys_page_alloc>
  800d8e:	89 c3                	mov    %eax,%ebx
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	85 c0                	test   %eax,%eax
  800d95:	0f 88 89 00 00 00    	js     800e24 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	ff 75 f0             	pushl  -0x10(%ebp)
  800da1:	e8 b1 f5 ff ff       	call   800357 <fd2data>
  800da6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dad:	50                   	push   %eax
  800dae:	6a 00                	push   $0x0
  800db0:	56                   	push   %esi
  800db1:	6a 00                	push   $0x0
  800db3:	e8 e1 f3 ff ff       	call   800199 <sys_page_map>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	83 c4 20             	add    $0x20,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 55                	js     800e16 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ddf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	ff 75 f4             	pushl  -0xc(%ebp)
  800df1:	e8 51 f5 ff ff       	call   800347 <fd2num>
  800df6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dfb:	83 c4 04             	add    $0x4,%esp
  800dfe:	ff 75 f0             	pushl  -0x10(%ebp)
  800e01:	e8 41 f5 ff ff       	call   800347 <fd2num>
  800e06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e09:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e14:	eb 30                	jmp    800e46 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e16:	83 ec 08             	sub    $0x8,%esp
  800e19:	56                   	push   %esi
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 ba f3 ff ff       	call   8001db <sys_page_unmap>
  800e21:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 aa f3 ff ff       	call   8001db <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 9a f3 ff ff       	call   8001db <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e46:	89 d0                	mov    %edx,%eax
  800e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e58:	50                   	push   %eax
  800e59:	ff 75 08             	pushl  0x8(%ebp)
  800e5c:	e8 5c f5 ff ff       	call   8003bd <fd_lookup>
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 18                	js     800e80 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6e:	e8 e4 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e78:	e8 21 fd ff ff       	call   800b9e <_pipeisclosed>
  800e7d:	83 c4 10             	add    $0x10,%esp
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e92:	68 b4 1e 80 00       	push   $0x801eb4
  800e97:	ff 75 0c             	pushl  0xc(%ebp)
  800e9a:	e8 c4 07 00 00       	call   801663 <strcpy>
	return 0;
}
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eb7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebd:	eb 2d                	jmp    800eec <devcons_write+0x46>
		m = n - tot;
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ec4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ec7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ecc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	53                   	push   %ebx
  800ed3:	03 45 0c             	add    0xc(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	57                   	push   %edi
  800ed8:	e8 18 09 00 00       	call   8017f5 <memmove>
		sys_cputs(buf, m);
  800edd:	83 c4 08             	add    $0x8,%esp
  800ee0:	53                   	push   %ebx
  800ee1:	57                   	push   %edi
  800ee2:	e8 b3 f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee7:	01 de                	add    %ebx,%esi
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	89 f0                	mov    %esi,%eax
  800eee:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef1:	72 cc                	jb     800ebf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0a:	74 2a                	je     800f36 <devcons_read+0x3b>
  800f0c:	eb 05                	jmp    800f13 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f0e:	e8 24 f2 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f13:	e8 a0 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	74 f2                	je     800f0e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 16                	js     800f36 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f20:	83 f8 04             	cmp    $0x4,%eax
  800f23:	74 0c                	je     800f31 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f28:	88 02                	mov    %al,(%edx)
	return 1;
  800f2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2f:	eb 05                	jmp    800f36 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f44:	6a 01                	push   $0x1
  800f46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	e8 4b f1 ff ff       	call   80009a <sys_cputs>
}
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <getchar>:

int
getchar(void)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f5a:	6a 01                	push   $0x1
  800f5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	6a 00                	push   $0x0
  800f62:	e8 bc f6 ff ff       	call   800623 <read>
	if (r < 0)
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 0f                	js     800f7d <getchar+0x29>
		return r;
	if (r < 1)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 06                	jle    800f78 <getchar+0x24>
		return -E_EOF;
	return c;
  800f72:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f76:	eb 05                	jmp    800f7d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f78:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 08             	pushl  0x8(%ebp)
  800f8c:	e8 2c f4 ff ff       	call   8003bd <fd_lookup>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 11                	js     800fa9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa1:	39 10                	cmp    %edx,(%eax)
  800fa3:	0f 94 c0             	sete   %al
  800fa6:	0f b6 c0             	movzbl %al,%eax
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <opencons>:

int
opencons(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	e8 b4 f3 ff ff       	call   80036e <fd_alloc>
  800fba:	83 c4 10             	add    $0x10,%esp
		return r;
  800fbd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 3e                	js     801001 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	68 07 04 00 00       	push   $0x407
  800fcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 81 f1 ff ff       	call   800156 <sys_page_alloc>
  800fd5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 23                	js     801001 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fde:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	e8 4b f3 ff ff       	call   800347 <fd2num>
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	83 c4 10             	add    $0x10,%esp
}
  801001:	89 d0                	mov    %edx,%eax
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801013:	e8 00 f1 ff ff       	call   800118 <sys_getenvid>
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	ff 75 0c             	pushl  0xc(%ebp)
  80101e:	ff 75 08             	pushl  0x8(%ebp)
  801021:	56                   	push   %esi
  801022:	50                   	push   %eax
  801023:	68 c0 1e 80 00       	push   $0x801ec0
  801028:	e8 b1 00 00 00       	call   8010de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102d:	83 c4 18             	add    $0x18,%esp
  801030:	53                   	push   %ebx
  801031:	ff 75 10             	pushl  0x10(%ebp)
  801034:	e8 54 00 00 00       	call   80108d <vcprintf>
	cprintf("\n");
  801039:	c7 04 24 ad 1e 80 00 	movl   $0x801ead,(%esp)
  801040:	e8 99 00 00 00       	call   8010de <cprintf>
  801045:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801048:	cc                   	int3   
  801049:	eb fd                	jmp    801048 <_panic+0x43>

0080104b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801055:	8b 13                	mov    (%ebx),%edx
  801057:	8d 42 01             	lea    0x1(%edx),%eax
  80105a:	89 03                	mov    %eax,(%ebx)
  80105c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801063:	3d ff 00 00 00       	cmp    $0xff,%eax
  801068:	75 1a                	jne    801084 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	68 ff 00 00 00       	push   $0xff
  801072:	8d 43 08             	lea    0x8(%ebx),%eax
  801075:	50                   	push   %eax
  801076:	e8 1f f0 ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80107b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801081:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801084:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801096:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109d:	00 00 00 
	b.cnt = 0;
  8010a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010aa:	ff 75 0c             	pushl  0xc(%ebp)
  8010ad:	ff 75 08             	pushl  0x8(%ebp)
  8010b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	68 4b 10 80 00       	push   $0x80104b
  8010bc:	e8 54 01 00 00       	call   801215 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d0:	50                   	push   %eax
  8010d1:	e8 c4 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8010d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e7:	50                   	push   %eax
  8010e8:	ff 75 08             	pushl  0x8(%ebp)
  8010eb:	e8 9d ff ff ff       	call   80108d <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 1c             	sub    $0x1c,%esp
  8010fb:	89 c7                	mov    %eax,%edi
  8010fd:	89 d6                	mov    %edx,%esi
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	8b 55 0c             	mov    0xc(%ebp),%edx
  801105:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801108:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801113:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801116:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801119:	39 d3                	cmp    %edx,%ebx
  80111b:	72 05                	jb     801122 <printnum+0x30>
  80111d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801120:	77 45                	ja     801167 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	ff 75 18             	pushl  0x18(%ebp)
  801128:	8b 45 14             	mov    0x14(%ebp),%eax
  80112b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112e:	53                   	push   %ebx
  80112f:	ff 75 10             	pushl  0x10(%ebp)
  801132:	83 ec 08             	sub    $0x8,%esp
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	ff 75 e0             	pushl  -0x20(%ebp)
  80113b:	ff 75 dc             	pushl  -0x24(%ebp)
  80113e:	ff 75 d8             	pushl  -0x28(%ebp)
  801141:	e8 9a 09 00 00       	call   801ae0 <__udivdi3>
  801146:	83 c4 18             	add    $0x18,%esp
  801149:	52                   	push   %edx
  80114a:	50                   	push   %eax
  80114b:	89 f2                	mov    %esi,%edx
  80114d:	89 f8                	mov    %edi,%eax
  80114f:	e8 9e ff ff ff       	call   8010f2 <printnum>
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	eb 18                	jmp    801171 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	56                   	push   %esi
  80115d:	ff 75 18             	pushl  0x18(%ebp)
  801160:	ff d7                	call   *%edi
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	eb 03                	jmp    80116a <printnum+0x78>
  801167:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80116a:	83 eb 01             	sub    $0x1,%ebx
  80116d:	85 db                	test   %ebx,%ebx
  80116f:	7f e8                	jg     801159 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	56                   	push   %esi
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117b:	ff 75 e0             	pushl  -0x20(%ebp)
  80117e:	ff 75 dc             	pushl  -0x24(%ebp)
  801181:	ff 75 d8             	pushl  -0x28(%ebp)
  801184:	e8 87 0a 00 00       	call   801c10 <__umoddi3>
  801189:	83 c4 14             	add    $0x14,%esp
  80118c:	0f be 80 e3 1e 80 00 	movsbl 0x801ee3(%eax),%eax
  801193:	50                   	push   %eax
  801194:	ff d7                	call   *%edi
}
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a4:	83 fa 01             	cmp    $0x1,%edx
  8011a7:	7e 0e                	jle    8011b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011a9:	8b 10                	mov    (%eax),%edx
  8011ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ae:	89 08                	mov    %ecx,(%eax)
  8011b0:	8b 02                	mov    (%edx),%eax
  8011b2:	8b 52 04             	mov    0x4(%edx),%edx
  8011b5:	eb 22                	jmp    8011d9 <getuint+0x38>
	else if (lflag)
  8011b7:	85 d2                	test   %edx,%edx
  8011b9:	74 10                	je     8011cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011bb:	8b 10                	mov    (%eax),%edx
  8011bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c0:	89 08                	mov    %ecx,(%eax)
  8011c2:	8b 02                	mov    (%edx),%eax
  8011c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c9:	eb 0e                	jmp    8011d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011cb:	8b 10                	mov    (%eax),%edx
  8011cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d0:	89 08                	mov    %ecx,(%eax)
  8011d2:	8b 02                	mov    (%edx),%eax
  8011d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e5:	8b 10                	mov    (%eax),%edx
  8011e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ea:	73 0a                	jae    8011f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ef:	89 08                	mov    %ecx,(%eax)
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	88 02                	mov    %al,(%edx)
}
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801201:	50                   	push   %eax
  801202:	ff 75 10             	pushl  0x10(%ebp)
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	ff 75 08             	pushl  0x8(%ebp)
  80120b:	e8 05 00 00 00       	call   801215 <vprintfmt>
	va_end(ap);
}
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 2c             	sub    $0x2c,%esp
  80121e:	8b 75 08             	mov    0x8(%ebp),%esi
  801221:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801224:	8b 7d 10             	mov    0x10(%ebp),%edi
  801227:	eb 12                	jmp    80123b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801229:	85 c0                	test   %eax,%eax
  80122b:	0f 84 89 03 00 00    	je     8015ba <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	53                   	push   %ebx
  801235:	50                   	push   %eax
  801236:	ff d6                	call   *%esi
  801238:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123b:	83 c7 01             	add    $0x1,%edi
  80123e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801242:	83 f8 25             	cmp    $0x25,%eax
  801245:	75 e2                	jne    801229 <vprintfmt+0x14>
  801247:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80124b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801252:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801259:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801260:	ba 00 00 00 00       	mov    $0x0,%edx
  801265:	eb 07                	jmp    80126e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801267:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80126a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126e:	8d 47 01             	lea    0x1(%edi),%eax
  801271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801274:	0f b6 07             	movzbl (%edi),%eax
  801277:	0f b6 c8             	movzbl %al,%ecx
  80127a:	83 e8 23             	sub    $0x23,%eax
  80127d:	3c 55                	cmp    $0x55,%al
  80127f:	0f 87 1a 03 00 00    	ja     80159f <vprintfmt+0x38a>
  801285:	0f b6 c0             	movzbl %al,%eax
  801288:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80128f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801292:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801296:	eb d6                	jmp    80126e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012aa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012ad:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012b0:	83 fa 09             	cmp    $0x9,%edx
  8012b3:	77 39                	ja     8012ee <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b8:	eb e9                	jmp    8012a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8012c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012c3:	8b 00                	mov    (%eax),%eax
  8012c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012cb:	eb 27                	jmp    8012f4 <vprintfmt+0xdf>
  8012cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d7:	0f 49 c8             	cmovns %eax,%ecx
  8012da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e0:	eb 8c                	jmp    80126e <vprintfmt+0x59>
  8012e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ec:	eb 80                	jmp    80126e <vprintfmt+0x59>
  8012ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012f8:	0f 89 70 ff ff ff    	jns    80126e <vprintfmt+0x59>
				width = precision, precision = -1;
  8012fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801301:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801304:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130b:	e9 5e ff ff ff       	jmp    80126e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801310:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801316:	e9 53 ff ff ff       	jmp    80126e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80131b:	8b 45 14             	mov    0x14(%ebp),%eax
  80131e:	8d 50 04             	lea    0x4(%eax),%edx
  801321:	89 55 14             	mov    %edx,0x14(%ebp)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	53                   	push   %ebx
  801328:	ff 30                	pushl  (%eax)
  80132a:	ff d6                	call   *%esi
			break;
  80132c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801332:	e9 04 ff ff ff       	jmp    80123b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801337:	8b 45 14             	mov    0x14(%ebp),%eax
  80133a:	8d 50 04             	lea    0x4(%eax),%edx
  80133d:	89 55 14             	mov    %edx,0x14(%ebp)
  801340:	8b 00                	mov    (%eax),%eax
  801342:	99                   	cltd   
  801343:	31 d0                	xor    %edx,%eax
  801345:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801347:	83 f8 0f             	cmp    $0xf,%eax
  80134a:	7f 0b                	jg     801357 <vprintfmt+0x142>
  80134c:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801353:	85 d2                	test   %edx,%edx
  801355:	75 18                	jne    80136f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801357:	50                   	push   %eax
  801358:	68 fb 1e 80 00       	push   $0x801efb
  80135d:	53                   	push   %ebx
  80135e:	56                   	push   %esi
  80135f:	e8 94 fe ff ff       	call   8011f8 <printfmt>
  801364:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80136a:	e9 cc fe ff ff       	jmp    80123b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80136f:	52                   	push   %edx
  801370:	68 86 1e 80 00       	push   $0x801e86
  801375:	53                   	push   %ebx
  801376:	56                   	push   %esi
  801377:	e8 7c fe ff ff       	call   8011f8 <printfmt>
  80137c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801382:	e9 b4 fe ff ff       	jmp    80123b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801387:	8b 45 14             	mov    0x14(%ebp),%eax
  80138a:	8d 50 04             	lea    0x4(%eax),%edx
  80138d:	89 55 14             	mov    %edx,0x14(%ebp)
  801390:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801392:	85 ff                	test   %edi,%edi
  801394:	b8 f4 1e 80 00       	mov    $0x801ef4,%eax
  801399:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80139c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a0:	0f 8e 94 00 00 00    	jle    80143a <vprintfmt+0x225>
  8013a6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013aa:	0f 84 98 00 00 00    	je     801448 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b6:	57                   	push   %edi
  8013b7:	e8 86 02 00 00       	call   801642 <strnlen>
  8013bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013bf:	29 c1                	sub    %eax,%ecx
  8013c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013c4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013c7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d3:	eb 0f                	jmp    8013e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	53                   	push   %ebx
  8013d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8013dc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013de:	83 ef 01             	sub    $0x1,%edi
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	85 ff                	test   %edi,%edi
  8013e6:	7f ed                	jg     8013d5 <vprintfmt+0x1c0>
  8013e8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013eb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8013ee:	85 c9                	test   %ecx,%ecx
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f5:	0f 49 c1             	cmovns %ecx,%eax
  8013f8:	29 c1                	sub    %eax,%ecx
  8013fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8013fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801400:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801403:	89 cb                	mov    %ecx,%ebx
  801405:	eb 4d                	jmp    801454 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801407:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80140b:	74 1b                	je     801428 <vprintfmt+0x213>
  80140d:	0f be c0             	movsbl %al,%eax
  801410:	83 e8 20             	sub    $0x20,%eax
  801413:	83 f8 5e             	cmp    $0x5e,%eax
  801416:	76 10                	jbe    801428 <vprintfmt+0x213>
					putch('?', putdat);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	ff 75 0c             	pushl  0xc(%ebp)
  80141e:	6a 3f                	push   $0x3f
  801420:	ff 55 08             	call   *0x8(%ebp)
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	eb 0d                	jmp    801435 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	52                   	push   %edx
  80142f:	ff 55 08             	call   *0x8(%ebp)
  801432:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801435:	83 eb 01             	sub    $0x1,%ebx
  801438:	eb 1a                	jmp    801454 <vprintfmt+0x23f>
  80143a:	89 75 08             	mov    %esi,0x8(%ebp)
  80143d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801440:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801443:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801446:	eb 0c                	jmp    801454 <vprintfmt+0x23f>
  801448:	89 75 08             	mov    %esi,0x8(%ebp)
  80144b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801451:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801454:	83 c7 01             	add    $0x1,%edi
  801457:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80145b:	0f be d0             	movsbl %al,%edx
  80145e:	85 d2                	test   %edx,%edx
  801460:	74 23                	je     801485 <vprintfmt+0x270>
  801462:	85 f6                	test   %esi,%esi
  801464:	78 a1                	js     801407 <vprintfmt+0x1f2>
  801466:	83 ee 01             	sub    $0x1,%esi
  801469:	79 9c                	jns    801407 <vprintfmt+0x1f2>
  80146b:	89 df                	mov    %ebx,%edi
  80146d:	8b 75 08             	mov    0x8(%ebp),%esi
  801470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801473:	eb 18                	jmp    80148d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	53                   	push   %ebx
  801479:	6a 20                	push   $0x20
  80147b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147d:	83 ef 01             	sub    $0x1,%edi
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	eb 08                	jmp    80148d <vprintfmt+0x278>
  801485:	89 df                	mov    %ebx,%edi
  801487:	8b 75 08             	mov    0x8(%ebp),%esi
  80148a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148d:	85 ff                	test   %edi,%edi
  80148f:	7f e4                	jg     801475 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801494:	e9 a2 fd ff ff       	jmp    80123b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801499:	83 fa 01             	cmp    $0x1,%edx
  80149c:	7e 16                	jle    8014b4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80149e:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a1:	8d 50 08             	lea    0x8(%eax),%edx
  8014a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a7:	8b 50 04             	mov    0x4(%eax),%edx
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b2:	eb 32                	jmp    8014e6 <vprintfmt+0x2d1>
	else if (lflag)
  8014b4:	85 d2                	test   %edx,%edx
  8014b6:	74 18                	je     8014d0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bb:	8d 50 04             	lea    0x4(%eax),%edx
  8014be:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c1:	8b 00                	mov    (%eax),%eax
  8014c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c6:	89 c1                	mov    %eax,%ecx
  8014c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ce:	eb 16                	jmp    8014e6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d3:	8d 50 04             	lea    0x4(%eax),%edx
  8014d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014de:	89 c1                	mov    %eax,%ecx
  8014e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014f5:	79 74                	jns    80156b <vprintfmt+0x356>
				putch('-', putdat);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	53                   	push   %ebx
  8014fb:	6a 2d                	push   $0x2d
  8014fd:	ff d6                	call   *%esi
				num = -(long long) num;
  8014ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801502:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801505:	f7 d8                	neg    %eax
  801507:	83 d2 00             	adc    $0x0,%edx
  80150a:	f7 da                	neg    %edx
  80150c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80150f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801514:	eb 55                	jmp    80156b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801516:	8d 45 14             	lea    0x14(%ebp),%eax
  801519:	e8 83 fc ff ff       	call   8011a1 <getuint>
			base = 10;
  80151e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801523:	eb 46                	jmp    80156b <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801525:	8d 45 14             	lea    0x14(%ebp),%eax
  801528:	e8 74 fc ff ff       	call   8011a1 <getuint>
			base = 8;
  80152d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801532:	eb 37                	jmp    80156b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	53                   	push   %ebx
  801538:	6a 30                	push   $0x30
  80153a:	ff d6                	call   *%esi
			putch('x', putdat);
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	53                   	push   %ebx
  801540:	6a 78                	push   $0x78
  801542:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 50 04             	lea    0x4(%eax),%edx
  80154a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80154d:	8b 00                	mov    (%eax),%eax
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801554:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801557:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80155c:	eb 0d                	jmp    80156b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80155e:	8d 45 14             	lea    0x14(%ebp),%eax
  801561:	e8 3b fc ff ff       	call   8011a1 <getuint>
			base = 16;
  801566:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80156b:	83 ec 0c             	sub    $0xc,%esp
  80156e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801572:	57                   	push   %edi
  801573:	ff 75 e0             	pushl  -0x20(%ebp)
  801576:	51                   	push   %ecx
  801577:	52                   	push   %edx
  801578:	50                   	push   %eax
  801579:	89 da                	mov    %ebx,%edx
  80157b:	89 f0                	mov    %esi,%eax
  80157d:	e8 70 fb ff ff       	call   8010f2 <printnum>
			break;
  801582:	83 c4 20             	add    $0x20,%esp
  801585:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801588:	e9 ae fc ff ff       	jmp    80123b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	51                   	push   %ecx
  801592:	ff d6                	call   *%esi
			break;
  801594:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80159a:	e9 9c fc ff ff       	jmp    80123b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	6a 25                	push   $0x25
  8015a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb 03                	jmp    8015af <vprintfmt+0x39a>
  8015ac:	83 ef 01             	sub    $0x1,%edi
  8015af:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015b3:	75 f7                	jne    8015ac <vprintfmt+0x397>
  8015b5:	e9 81 fc ff ff       	jmp    80123b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5f                   	pop    %edi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 18             	sub    $0x18,%esp
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	74 26                	je     801609 <vsnprintf+0x47>
  8015e3:	85 d2                	test   %edx,%edx
  8015e5:	7e 22                	jle    801609 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015e7:	ff 75 14             	pushl  0x14(%ebp)
  8015ea:	ff 75 10             	pushl  0x10(%ebp)
  8015ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	68 db 11 80 00       	push   $0x8011db
  8015f6:	e8 1a fc ff ff       	call   801215 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8015fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb 05                	jmp    80160e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801609:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801616:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801619:	50                   	push   %eax
  80161a:	ff 75 10             	pushl  0x10(%ebp)
  80161d:	ff 75 0c             	pushl  0xc(%ebp)
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 9a ff ff ff       	call   8015c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801630:	b8 00 00 00 00       	mov    $0x0,%eax
  801635:	eb 03                	jmp    80163a <strlen+0x10>
		n++;
  801637:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80163a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80163e:	75 f7                	jne    801637 <strlen+0xd>
		n++;
	return n;
}
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801648:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80164b:	ba 00 00 00 00       	mov    $0x0,%edx
  801650:	eb 03                	jmp    801655 <strnlen+0x13>
		n++;
  801652:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801655:	39 c2                	cmp    %eax,%edx
  801657:	74 08                	je     801661 <strnlen+0x1f>
  801659:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80165d:	75 f3                	jne    801652 <strnlen+0x10>
  80165f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	53                   	push   %ebx
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	83 c2 01             	add    $0x1,%edx
  801672:	83 c1 01             	add    $0x1,%ecx
  801675:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801679:	88 5a ff             	mov    %bl,-0x1(%edx)
  80167c:	84 db                	test   %bl,%bl
  80167e:	75 ef                	jne    80166f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801680:	5b                   	pop    %ebx
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80168a:	53                   	push   %ebx
  80168b:	e8 9a ff ff ff       	call   80162a <strlen>
  801690:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	01 d8                	add    %ebx,%eax
  801698:	50                   	push   %eax
  801699:	e8 c5 ff ff ff       	call   801663 <strcpy>
	return dst;
}
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	56                   	push   %esi
  8016a9:	53                   	push   %ebx
  8016aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b0:	89 f3                	mov    %esi,%ebx
  8016b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016b5:	89 f2                	mov    %esi,%edx
  8016b7:	eb 0f                	jmp    8016c8 <strncpy+0x23>
		*dst++ = *src;
  8016b9:	83 c2 01             	add    $0x1,%edx
  8016bc:	0f b6 01             	movzbl (%ecx),%eax
  8016bf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016c2:	80 39 01             	cmpb   $0x1,(%ecx)
  8016c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c8:	39 da                	cmp    %ebx,%edx
  8016ca:	75 ed                	jne    8016b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016cc:	89 f0                	mov    %esi,%eax
  8016ce:	5b                   	pop    %ebx
  8016cf:	5e                   	pop    %esi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8016e0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016e2:	85 d2                	test   %edx,%edx
  8016e4:	74 21                	je     801707 <strlcpy+0x35>
  8016e6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016ea:	89 f2                	mov    %esi,%edx
  8016ec:	eb 09                	jmp    8016f7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016ee:	83 c2 01             	add    $0x1,%edx
  8016f1:	83 c1 01             	add    $0x1,%ecx
  8016f4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016f7:	39 c2                	cmp    %eax,%edx
  8016f9:	74 09                	je     801704 <strlcpy+0x32>
  8016fb:	0f b6 19             	movzbl (%ecx),%ebx
  8016fe:	84 db                	test   %bl,%bl
  801700:	75 ec                	jne    8016ee <strlcpy+0x1c>
  801702:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801704:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801707:	29 f0                	sub    %esi,%eax
}
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801713:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801716:	eb 06                	jmp    80171e <strcmp+0x11>
		p++, q++;
  801718:	83 c1 01             	add    $0x1,%ecx
  80171b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80171e:	0f b6 01             	movzbl (%ecx),%eax
  801721:	84 c0                	test   %al,%al
  801723:	74 04                	je     801729 <strcmp+0x1c>
  801725:	3a 02                	cmp    (%edx),%al
  801727:	74 ef                	je     801718 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801729:	0f b6 c0             	movzbl %al,%eax
  80172c:	0f b6 12             	movzbl (%edx),%edx
  80172f:	29 d0                	sub    %edx,%eax
}
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	8b 45 08             	mov    0x8(%ebp),%eax
  80173a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801742:	eb 06                	jmp    80174a <strncmp+0x17>
		n--, p++, q++;
  801744:	83 c0 01             	add    $0x1,%eax
  801747:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80174a:	39 d8                	cmp    %ebx,%eax
  80174c:	74 15                	je     801763 <strncmp+0x30>
  80174e:	0f b6 08             	movzbl (%eax),%ecx
  801751:	84 c9                	test   %cl,%cl
  801753:	74 04                	je     801759 <strncmp+0x26>
  801755:	3a 0a                	cmp    (%edx),%cl
  801757:	74 eb                	je     801744 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801759:	0f b6 00             	movzbl (%eax),%eax
  80175c:	0f b6 12             	movzbl (%edx),%edx
  80175f:	29 d0                	sub    %edx,%eax
  801761:	eb 05                	jmp    801768 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801768:	5b                   	pop    %ebx
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801775:	eb 07                	jmp    80177e <strchr+0x13>
		if (*s == c)
  801777:	38 ca                	cmp    %cl,%dl
  801779:	74 0f                	je     80178a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80177b:	83 c0 01             	add    $0x1,%eax
  80177e:	0f b6 10             	movzbl (%eax),%edx
  801781:	84 d2                	test   %dl,%dl
  801783:	75 f2                	jne    801777 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801785:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801796:	eb 03                	jmp    80179b <strfind+0xf>
  801798:	83 c0 01             	add    $0x1,%eax
  80179b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80179e:	38 ca                	cmp    %cl,%dl
  8017a0:	74 04                	je     8017a6 <strfind+0x1a>
  8017a2:	84 d2                	test   %dl,%dl
  8017a4:	75 f2                	jne    801798 <strfind+0xc>
			break;
	return (char *) s;
}
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	57                   	push   %edi
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017b4:	85 c9                	test   %ecx,%ecx
  8017b6:	74 36                	je     8017ee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017be:	75 28                	jne    8017e8 <memset+0x40>
  8017c0:	f6 c1 03             	test   $0x3,%cl
  8017c3:	75 23                	jne    8017e8 <memset+0x40>
		c &= 0xFF;
  8017c5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017c9:	89 d3                	mov    %edx,%ebx
  8017cb:	c1 e3 08             	shl    $0x8,%ebx
  8017ce:	89 d6                	mov    %edx,%esi
  8017d0:	c1 e6 18             	shl    $0x18,%esi
  8017d3:	89 d0                	mov    %edx,%eax
  8017d5:	c1 e0 10             	shl    $0x10,%eax
  8017d8:	09 f0                	or     %esi,%eax
  8017da:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017dc:	89 d8                	mov    %ebx,%eax
  8017de:	09 d0                	or     %edx,%eax
  8017e0:	c1 e9 02             	shr    $0x2,%ecx
  8017e3:	fc                   	cld    
  8017e4:	f3 ab                	rep stos %eax,%es:(%edi)
  8017e6:	eb 06                	jmp    8017ee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017eb:	fc                   	cld    
  8017ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017ee:	89 f8                	mov    %edi,%eax
  8017f0:	5b                   	pop    %ebx
  8017f1:	5e                   	pop    %esi
  8017f2:	5f                   	pop    %edi
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	57                   	push   %edi
  8017f9:	56                   	push   %esi
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801800:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801803:	39 c6                	cmp    %eax,%esi
  801805:	73 35                	jae    80183c <memmove+0x47>
  801807:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80180a:	39 d0                	cmp    %edx,%eax
  80180c:	73 2e                	jae    80183c <memmove+0x47>
		s += n;
		d += n;
  80180e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801811:	89 d6                	mov    %edx,%esi
  801813:	09 fe                	or     %edi,%esi
  801815:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80181b:	75 13                	jne    801830 <memmove+0x3b>
  80181d:	f6 c1 03             	test   $0x3,%cl
  801820:	75 0e                	jne    801830 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801822:	83 ef 04             	sub    $0x4,%edi
  801825:	8d 72 fc             	lea    -0x4(%edx),%esi
  801828:	c1 e9 02             	shr    $0x2,%ecx
  80182b:	fd                   	std    
  80182c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80182e:	eb 09                	jmp    801839 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801830:	83 ef 01             	sub    $0x1,%edi
  801833:	8d 72 ff             	lea    -0x1(%edx),%esi
  801836:	fd                   	std    
  801837:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801839:	fc                   	cld    
  80183a:	eb 1d                	jmp    801859 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80183c:	89 f2                	mov    %esi,%edx
  80183e:	09 c2                	or     %eax,%edx
  801840:	f6 c2 03             	test   $0x3,%dl
  801843:	75 0f                	jne    801854 <memmove+0x5f>
  801845:	f6 c1 03             	test   $0x3,%cl
  801848:	75 0a                	jne    801854 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80184a:	c1 e9 02             	shr    $0x2,%ecx
  80184d:	89 c7                	mov    %eax,%edi
  80184f:	fc                   	cld    
  801850:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801852:	eb 05                	jmp    801859 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801854:	89 c7                	mov    %eax,%edi
  801856:	fc                   	cld    
  801857:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801859:	5e                   	pop    %esi
  80185a:	5f                   	pop    %edi
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801860:	ff 75 10             	pushl  0x10(%ebp)
  801863:	ff 75 0c             	pushl  0xc(%ebp)
  801866:	ff 75 08             	pushl  0x8(%ebp)
  801869:	e8 87 ff ff ff       	call   8017f5 <memmove>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187b:	89 c6                	mov    %eax,%esi
  80187d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801880:	eb 1a                	jmp    80189c <memcmp+0x2c>
		if (*s1 != *s2)
  801882:	0f b6 08             	movzbl (%eax),%ecx
  801885:	0f b6 1a             	movzbl (%edx),%ebx
  801888:	38 d9                	cmp    %bl,%cl
  80188a:	74 0a                	je     801896 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80188c:	0f b6 c1             	movzbl %cl,%eax
  80188f:	0f b6 db             	movzbl %bl,%ebx
  801892:	29 d8                	sub    %ebx,%eax
  801894:	eb 0f                	jmp    8018a5 <memcmp+0x35>
		s1++, s2++;
  801896:	83 c0 01             	add    $0x1,%eax
  801899:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80189c:	39 f0                	cmp    %esi,%eax
  80189e:	75 e2                	jne    801882 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018b0:	89 c1                	mov    %eax,%ecx
  8018b2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018b5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018b9:	eb 0a                	jmp    8018c5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018bb:	0f b6 10             	movzbl (%eax),%edx
  8018be:	39 da                	cmp    %ebx,%edx
  8018c0:	74 07                	je     8018c9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018c2:	83 c0 01             	add    $0x1,%eax
  8018c5:	39 c8                	cmp    %ecx,%eax
  8018c7:	72 f2                	jb     8018bb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	57                   	push   %edi
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018d8:	eb 03                	jmp    8018dd <strtol+0x11>
		s++;
  8018da:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018dd:	0f b6 01             	movzbl (%ecx),%eax
  8018e0:	3c 20                	cmp    $0x20,%al
  8018e2:	74 f6                	je     8018da <strtol+0xe>
  8018e4:	3c 09                	cmp    $0x9,%al
  8018e6:	74 f2                	je     8018da <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018e8:	3c 2b                	cmp    $0x2b,%al
  8018ea:	75 0a                	jne    8018f6 <strtol+0x2a>
		s++;
  8018ec:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f4:	eb 11                	jmp    801907 <strtol+0x3b>
  8018f6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8018fb:	3c 2d                	cmp    $0x2d,%al
  8018fd:	75 08                	jne    801907 <strtol+0x3b>
		s++, neg = 1;
  8018ff:	83 c1 01             	add    $0x1,%ecx
  801902:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801907:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80190d:	75 15                	jne    801924 <strtol+0x58>
  80190f:	80 39 30             	cmpb   $0x30,(%ecx)
  801912:	75 10                	jne    801924 <strtol+0x58>
  801914:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801918:	75 7c                	jne    801996 <strtol+0xca>
		s += 2, base = 16;
  80191a:	83 c1 02             	add    $0x2,%ecx
  80191d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801922:	eb 16                	jmp    80193a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801924:	85 db                	test   %ebx,%ebx
  801926:	75 12                	jne    80193a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801928:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80192d:	80 39 30             	cmpb   $0x30,(%ecx)
  801930:	75 08                	jne    80193a <strtol+0x6e>
		s++, base = 8;
  801932:	83 c1 01             	add    $0x1,%ecx
  801935:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
  80193f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801942:	0f b6 11             	movzbl (%ecx),%edx
  801945:	8d 72 d0             	lea    -0x30(%edx),%esi
  801948:	89 f3                	mov    %esi,%ebx
  80194a:	80 fb 09             	cmp    $0x9,%bl
  80194d:	77 08                	ja     801957 <strtol+0x8b>
			dig = *s - '0';
  80194f:	0f be d2             	movsbl %dl,%edx
  801952:	83 ea 30             	sub    $0x30,%edx
  801955:	eb 22                	jmp    801979 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801957:	8d 72 9f             	lea    -0x61(%edx),%esi
  80195a:	89 f3                	mov    %esi,%ebx
  80195c:	80 fb 19             	cmp    $0x19,%bl
  80195f:	77 08                	ja     801969 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801961:	0f be d2             	movsbl %dl,%edx
  801964:	83 ea 57             	sub    $0x57,%edx
  801967:	eb 10                	jmp    801979 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801969:	8d 72 bf             	lea    -0x41(%edx),%esi
  80196c:	89 f3                	mov    %esi,%ebx
  80196e:	80 fb 19             	cmp    $0x19,%bl
  801971:	77 16                	ja     801989 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801973:	0f be d2             	movsbl %dl,%edx
  801976:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801979:	3b 55 10             	cmp    0x10(%ebp),%edx
  80197c:	7d 0b                	jge    801989 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80197e:	83 c1 01             	add    $0x1,%ecx
  801981:	0f af 45 10          	imul   0x10(%ebp),%eax
  801985:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801987:	eb b9                	jmp    801942 <strtol+0x76>

	if (endptr)
  801989:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80198d:	74 0d                	je     80199c <strtol+0xd0>
		*endptr = (char *) s;
  80198f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801992:	89 0e                	mov    %ecx,(%esi)
  801994:	eb 06                	jmp    80199c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801996:	85 db                	test   %ebx,%ebx
  801998:	74 98                	je     801932 <strtol+0x66>
  80199a:	eb 9e                	jmp    80193a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80199c:	89 c2                	mov    %eax,%edx
  80199e:	f7 da                	neg    %edx
  8019a0:	85 ff                	test   %edi,%edi
  8019a2:	0f 45 c2             	cmovne %edx,%eax
}
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5f                   	pop    %edi
  8019a8:	5d                   	pop    %ebp
  8019a9:	c3                   	ret    

008019aa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
  8019af:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019b8:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019ba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019bf:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	50                   	push   %eax
  8019c6:	e8 3b e9 ff ff       	call   800306 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 f6                	test   %esi,%esi
  8019d0:	74 14                	je     8019e6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 09                	js     8019e4 <ipc_recv+0x3a>
  8019db:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e1:	8b 52 74             	mov    0x74(%edx),%edx
  8019e4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019e6:	85 db                	test   %ebx,%ebx
  8019e8:	74 14                	je     8019fe <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 09                	js     8019fc <ipc_recv+0x52>
  8019f3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019f9:	8b 52 78             	mov    0x78(%edx),%edx
  8019fc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 08                	js     801a0a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a02:	a1 04 40 80 00       	mov    0x804004,%eax
  801a07:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	57                   	push   %edi
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a23:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a25:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a2a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a2d:	ff 75 14             	pushl  0x14(%ebp)
  801a30:	53                   	push   %ebx
  801a31:	56                   	push   %esi
  801a32:	57                   	push   %edi
  801a33:	e8 ab e8 ff ff       	call   8002e3 <sys_ipc_try_send>

		if (err < 0) {
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 1e                	jns    801a5d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a3f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a42:	75 07                	jne    801a4b <ipc_send+0x3a>
				sys_yield();
  801a44:	e8 ee e6 ff ff       	call   800137 <sys_yield>
  801a49:	eb e2                	jmp    801a2d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a4b:	50                   	push   %eax
  801a4c:	68 e0 21 80 00       	push   $0x8021e0
  801a51:	6a 49                	push   $0x49
  801a53:	68 ed 21 80 00       	push   $0x8021ed
  801a58:	e8 a8 f5 ff ff       	call   801005 <_panic>
		}

	} while (err < 0);

}
  801a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5f                   	pop    %edi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a6b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a70:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a73:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a79:	8b 52 50             	mov    0x50(%edx),%edx
  801a7c:	39 ca                	cmp    %ecx,%edx
  801a7e:	75 0d                	jne    801a8d <ipc_find_env+0x28>
			return envs[i].env_id;
  801a80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a88:	8b 40 48             	mov    0x48(%eax),%eax
  801a8b:	eb 0f                	jmp    801a9c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a8d:	83 c0 01             	add    $0x1,%eax
  801a90:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a95:	75 d9                	jne    801a70 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    

00801a9e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aa4:	89 d0                	mov    %edx,%eax
  801aa6:	c1 e8 16             	shr    $0x16,%eax
  801aa9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ab0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab5:	f6 c1 01             	test   $0x1,%cl
  801ab8:	74 1d                	je     801ad7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aba:	c1 ea 0c             	shr    $0xc,%edx
  801abd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ac4:	f6 c2 01             	test   $0x1,%dl
  801ac7:	74 0e                	je     801ad7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ac9:	c1 ea 0c             	shr    $0xc,%edx
  801acc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ad3:	ef 
  801ad4:	0f b7 c0             	movzwl %ax,%eax
}
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    
  801ad9:	66 90                	xchg   %ax,%ax
  801adb:	66 90                	xchg   %ax,%ax
  801add:	66 90                	xchg   %ax,%ax
  801adf:	90                   	nop

00801ae0 <__udivdi3>:
  801ae0:	55                   	push   %ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 1c             	sub    $0x1c,%esp
  801ae7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801aeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801aef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801af3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801af7:	85 f6                	test   %esi,%esi
  801af9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801afd:	89 ca                	mov    %ecx,%edx
  801aff:	89 f8                	mov    %edi,%eax
  801b01:	75 3d                	jne    801b40 <__udivdi3+0x60>
  801b03:	39 cf                	cmp    %ecx,%edi
  801b05:	0f 87 c5 00 00 00    	ja     801bd0 <__udivdi3+0xf0>
  801b0b:	85 ff                	test   %edi,%edi
  801b0d:	89 fd                	mov    %edi,%ebp
  801b0f:	75 0b                	jne    801b1c <__udivdi3+0x3c>
  801b11:	b8 01 00 00 00       	mov    $0x1,%eax
  801b16:	31 d2                	xor    %edx,%edx
  801b18:	f7 f7                	div    %edi
  801b1a:	89 c5                	mov    %eax,%ebp
  801b1c:	89 c8                	mov    %ecx,%eax
  801b1e:	31 d2                	xor    %edx,%edx
  801b20:	f7 f5                	div    %ebp
  801b22:	89 c1                	mov    %eax,%ecx
  801b24:	89 d8                	mov    %ebx,%eax
  801b26:	89 cf                	mov    %ecx,%edi
  801b28:	f7 f5                	div    %ebp
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	89 fa                	mov    %edi,%edx
  801b30:	83 c4 1c             	add    $0x1c,%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5f                   	pop    %edi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    
  801b38:	90                   	nop
  801b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b40:	39 ce                	cmp    %ecx,%esi
  801b42:	77 74                	ja     801bb8 <__udivdi3+0xd8>
  801b44:	0f bd fe             	bsr    %esi,%edi
  801b47:	83 f7 1f             	xor    $0x1f,%edi
  801b4a:	0f 84 98 00 00 00    	je     801be8 <__udivdi3+0x108>
  801b50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b55:	89 f9                	mov    %edi,%ecx
  801b57:	89 c5                	mov    %eax,%ebp
  801b59:	29 fb                	sub    %edi,%ebx
  801b5b:	d3 e6                	shl    %cl,%esi
  801b5d:	89 d9                	mov    %ebx,%ecx
  801b5f:	d3 ed                	shr    %cl,%ebp
  801b61:	89 f9                	mov    %edi,%ecx
  801b63:	d3 e0                	shl    %cl,%eax
  801b65:	09 ee                	or     %ebp,%esi
  801b67:	89 d9                	mov    %ebx,%ecx
  801b69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b6d:	89 d5                	mov    %edx,%ebp
  801b6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b73:	d3 ed                	shr    %cl,%ebp
  801b75:	89 f9                	mov    %edi,%ecx
  801b77:	d3 e2                	shl    %cl,%edx
  801b79:	89 d9                	mov    %ebx,%ecx
  801b7b:	d3 e8                	shr    %cl,%eax
  801b7d:	09 c2                	or     %eax,%edx
  801b7f:	89 d0                	mov    %edx,%eax
  801b81:	89 ea                	mov    %ebp,%edx
  801b83:	f7 f6                	div    %esi
  801b85:	89 d5                	mov    %edx,%ebp
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	f7 64 24 0c          	mull   0xc(%esp)
  801b8d:	39 d5                	cmp    %edx,%ebp
  801b8f:	72 10                	jb     801ba1 <__udivdi3+0xc1>
  801b91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	d3 e6                	shl    %cl,%esi
  801b99:	39 c6                	cmp    %eax,%esi
  801b9b:	73 07                	jae    801ba4 <__udivdi3+0xc4>
  801b9d:	39 d5                	cmp    %edx,%ebp
  801b9f:	75 03                	jne    801ba4 <__udivdi3+0xc4>
  801ba1:	83 eb 01             	sub    $0x1,%ebx
  801ba4:	31 ff                	xor    %edi,%edi
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	89 fa                	mov    %edi,%edx
  801baa:	83 c4 1c             	add    $0x1c,%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    
  801bb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bb8:	31 ff                	xor    %edi,%edi
  801bba:	31 db                	xor    %ebx,%ebx
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	89 fa                	mov    %edi,%edx
  801bc0:	83 c4 1c             	add    $0x1c,%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    
  801bc8:	90                   	nop
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	89 d8                	mov    %ebx,%eax
  801bd2:	f7 f7                	div    %edi
  801bd4:	31 ff                	xor    %edi,%edi
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	89 d8                	mov    %ebx,%eax
  801bda:	89 fa                	mov    %edi,%edx
  801bdc:	83 c4 1c             	add    $0x1c,%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5f                   	pop    %edi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	39 ce                	cmp    %ecx,%esi
  801bea:	72 0c                	jb     801bf8 <__udivdi3+0x118>
  801bec:	31 db                	xor    %ebx,%ebx
  801bee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801bf2:	0f 87 34 ff ff ff    	ja     801b2c <__udivdi3+0x4c>
  801bf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801bfd:	e9 2a ff ff ff       	jmp    801b2c <__udivdi3+0x4c>
  801c02:	66 90                	xchg   %ax,%ax
  801c04:	66 90                	xchg   %ax,%ax
  801c06:	66 90                	xchg   %ax,%ax
  801c08:	66 90                	xchg   %ax,%ax
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__umoddi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 d2                	test   %edx,%edx
  801c29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f3                	mov    %esi,%ebx
  801c33:	89 3c 24             	mov    %edi,(%esp)
  801c36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c3a:	75 1c                	jne    801c58 <__umoddi3+0x48>
  801c3c:	39 f7                	cmp    %esi,%edi
  801c3e:	76 50                	jbe    801c90 <__umoddi3+0x80>
  801c40:	89 c8                	mov    %ecx,%eax
  801c42:	89 f2                	mov    %esi,%edx
  801c44:	f7 f7                	div    %edi
  801c46:	89 d0                	mov    %edx,%eax
  801c48:	31 d2                	xor    %edx,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	39 f2                	cmp    %esi,%edx
  801c5a:	89 d0                	mov    %edx,%eax
  801c5c:	77 52                	ja     801cb0 <__umoddi3+0xa0>
  801c5e:	0f bd ea             	bsr    %edx,%ebp
  801c61:	83 f5 1f             	xor    $0x1f,%ebp
  801c64:	75 5a                	jne    801cc0 <__umoddi3+0xb0>
  801c66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c6a:	0f 82 e0 00 00 00    	jb     801d50 <__umoddi3+0x140>
  801c70:	39 0c 24             	cmp    %ecx,(%esp)
  801c73:	0f 86 d7 00 00 00    	jbe    801d50 <__umoddi3+0x140>
  801c79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c81:	83 c4 1c             	add    $0x1c,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	85 ff                	test   %edi,%edi
  801c92:	89 fd                	mov    %edi,%ebp
  801c94:	75 0b                	jne    801ca1 <__umoddi3+0x91>
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	f7 f7                	div    %edi
  801c9f:	89 c5                	mov    %eax,%ebp
  801ca1:	89 f0                	mov    %esi,%eax
  801ca3:	31 d2                	xor    %edx,%edx
  801ca5:	f7 f5                	div    %ebp
  801ca7:	89 c8                	mov    %ecx,%eax
  801ca9:	f7 f5                	div    %ebp
  801cab:	89 d0                	mov    %edx,%eax
  801cad:	eb 99                	jmp    801c48 <__umoddi3+0x38>
  801caf:	90                   	nop
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	83 c4 1c             	add    $0x1c,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    
  801cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	8b 34 24             	mov    (%esp),%esi
  801cc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801cc8:	89 e9                	mov    %ebp,%ecx
  801cca:	29 ef                	sub    %ebp,%edi
  801ccc:	d3 e0                	shl    %cl,%eax
  801cce:	89 f9                	mov    %edi,%ecx
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	d3 ea                	shr    %cl,%edx
  801cd4:	89 e9                	mov    %ebp,%ecx
  801cd6:	09 c2                	or     %eax,%edx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 14 24             	mov    %edx,(%esp)
  801cdd:	89 f2                	mov    %esi,%edx
  801cdf:	d3 e2                	shl    %cl,%edx
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	89 e9                	mov    %ebp,%ecx
  801cef:	89 c6                	mov    %eax,%esi
  801cf1:	d3 e3                	shl    %cl,%ebx
  801cf3:	89 f9                	mov    %edi,%ecx
  801cf5:	89 d0                	mov    %edx,%eax
  801cf7:	d3 e8                	shr    %cl,%eax
  801cf9:	89 e9                	mov    %ebp,%ecx
  801cfb:	09 d8                	or     %ebx,%eax
  801cfd:	89 d3                	mov    %edx,%ebx
  801cff:	89 f2                	mov    %esi,%edx
  801d01:	f7 34 24             	divl   (%esp)
  801d04:	89 d6                	mov    %edx,%esi
  801d06:	d3 e3                	shl    %cl,%ebx
  801d08:	f7 64 24 04          	mull   0x4(%esp)
  801d0c:	39 d6                	cmp    %edx,%esi
  801d0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d12:	89 d1                	mov    %edx,%ecx
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	72 08                	jb     801d20 <__umoddi3+0x110>
  801d18:	75 11                	jne    801d2b <__umoddi3+0x11b>
  801d1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d1e:	73 0b                	jae    801d2b <__umoddi3+0x11b>
  801d20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d24:	1b 14 24             	sbb    (%esp),%edx
  801d27:	89 d1                	mov    %edx,%ecx
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d2f:	29 da                	sub    %ebx,%edx
  801d31:	19 ce                	sbb    %ecx,%esi
  801d33:	89 f9                	mov    %edi,%ecx
  801d35:	89 f0                	mov    %esi,%eax
  801d37:	d3 e0                	shl    %cl,%eax
  801d39:	89 e9                	mov    %ebp,%ecx
  801d3b:	d3 ea                	shr    %cl,%edx
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	d3 ee                	shr    %cl,%esi
  801d41:	09 d0                	or     %edx,%eax
  801d43:	89 f2                	mov    %esi,%edx
  801d45:	83 c4 1c             	add    $0x1c,%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5f                   	pop    %edi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    
  801d4d:	8d 76 00             	lea    0x0(%esi),%esi
  801d50:	29 f9                	sub    %edi,%ecx
  801d52:	19 d6                	sbb    %edx,%esi
  801d54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d5c:	e9 18 ff ff ff       	jmp    801c79 <__umoddi3+0x69>
