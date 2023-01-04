
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 8a 1d 80 00       	push   $0x801d8a
  800111:	6a 23                	push   $0x23
  800113:	68 a7 1d 80 00       	push   $0x801da7
  800118:	e8 f5 0e 00 00       	call   801012 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 8a 1d 80 00       	push   $0x801d8a
  800192:	6a 23                	push   $0x23
  800194:	68 a7 1d 80 00       	push   $0x801da7
  800199:	e8 74 0e 00 00       	call   801012 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 8a 1d 80 00       	push   $0x801d8a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 a7 1d 80 00       	push   $0x801da7
  8001db:	e8 32 0e 00 00       	call   801012 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 8a 1d 80 00       	push   $0x801d8a
  800216:	6a 23                	push   $0x23
  800218:	68 a7 1d 80 00       	push   $0x801da7
  80021d:	e8 f0 0d 00 00       	call   801012 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 8a 1d 80 00       	push   $0x801d8a
  800258:	6a 23                	push   $0x23
  80025a:	68 a7 1d 80 00       	push   $0x801da7
  80025f:	e8 ae 0d 00 00       	call   801012 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 8a 1d 80 00       	push   $0x801d8a
  80029a:	6a 23                	push   $0x23
  80029c:	68 a7 1d 80 00       	push   $0x801da7
  8002a1:	e8 6c 0d 00 00       	call   801012 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 8a 1d 80 00       	push   $0x801d8a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 a7 1d 80 00       	push   $0x801da7
  8002e3:	e8 2a 0d 00 00       	call   801012 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 8a 1d 80 00       	push   $0x801d8a
  800340:	6a 23                	push   $0x23
  800342:	68 a7 1d 80 00       	push   $0x801da7
  800347:	e8 c6 0c 00 00       	call   801012 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 34 1e 80 00       	mov    $0x801e34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 b8 1d 80 00       	push   $0x801db8
  80045b:	e8 8b 0c 00 00       	call   8010eb <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 f9 1d 80 00       	push   $0x801df9
  800685:	e8 61 0a 00 00       	call   8010eb <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 15 1e 80 00       	push   $0x801e15
  80075a:	e8 8c 09 00 00       	call   8010eb <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 d8 1d 80 00       	push   $0x801dd8
  80080f:	e8 d7 08 00 00       	call   8010eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 b7 01 00 00       	call   800a8f <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 53 11 00 00       	call   801a72 <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 e4 10 00 00       	call   801a1e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 70 10 00 00       	call   8019b7 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 a0 0c 00 00       	call   801670 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009f9:	68 44 1e 80 00       	push   $0x801e44
  8009fe:	68 90 00 00 00       	push   $0x90
  800a03:	68 62 1e 80 00       	push   $0x801e62
  800a08:	e8 05 06 00 00       	call   801012 <_panic>

00800a0d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a20:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a30:	e8 ce fe ff ff       	call   800903 <fsipc>
  800a35:	89 c3                	mov    %eax,%ebx
  800a37:	85 c0                	test   %eax,%eax
  800a39:	78 4b                	js     800a86 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a3b:	39 c6                	cmp    %eax,%esi
  800a3d:	73 16                	jae    800a55 <devfile_read+0x48>
  800a3f:	68 6d 1e 80 00       	push   $0x801e6d
  800a44:	68 74 1e 80 00       	push   $0x801e74
  800a49:	6a 7c                	push   $0x7c
  800a4b:	68 62 1e 80 00       	push   $0x801e62
  800a50:	e8 bd 05 00 00       	call   801012 <_panic>
	assert(r <= PGSIZE);
  800a55:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5a:	7e 16                	jle    800a72 <devfile_read+0x65>
  800a5c:	68 89 1e 80 00       	push   $0x801e89
  800a61:	68 74 1e 80 00       	push   $0x801e74
  800a66:	6a 7d                	push   $0x7d
  800a68:	68 62 1e 80 00       	push   $0x801e62
  800a6d:	e8 a0 05 00 00       	call   801012 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a72:	83 ec 04             	sub    $0x4,%esp
  800a75:	50                   	push   %eax
  800a76:	68 00 50 80 00       	push   $0x805000
  800a7b:	ff 75 0c             	pushl  0xc(%ebp)
  800a7e:	e8 7f 0d 00 00       	call   801802 <memmove>
	return r;
  800a83:	83 c4 10             	add    $0x10,%esp
}
  800a86:	89 d8                	mov    %ebx,%eax
  800a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	83 ec 20             	sub    $0x20,%esp
  800a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a99:	53                   	push   %ebx
  800a9a:	e8 98 0b 00 00       	call   801637 <strlen>
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa7:	7f 67                	jg     800b10 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aaf:	50                   	push   %eax
  800ab0:	e8 c6 f8 ff ff       	call   80037b <fd_alloc>
  800ab5:	83 c4 10             	add    $0x10,%esp
		return r;
  800ab8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 57                	js     800b15 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	53                   	push   %ebx
  800ac2:	68 00 50 80 00       	push   $0x805000
  800ac7:	e8 a4 0b 00 00       	call   801670 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad7:	b8 01 00 00 00       	mov    $0x1,%eax
  800adc:	e8 22 fe ff ff       	call   800903 <fsipc>
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	79 14                	jns    800afe <open+0x6f>
		fd_close(fd, 0);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	6a 00                	push   $0x0
  800aef:	ff 75 f4             	pushl  -0xc(%ebp)
  800af2:	e8 7c f9 ff ff       	call   800473 <fd_close>
		return r;
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	89 da                	mov    %ebx,%edx
  800afc:	eb 17                	jmp    800b15 <open+0x86>
	}

	return fd2num(fd);
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	ff 75 f4             	pushl  -0xc(%ebp)
  800b04:	e8 4b f8 ff ff       	call   800354 <fd2num>
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	eb 05                	jmp    800b15 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b10:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b15:	89 d0                	mov    %edx,%eax
  800b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2c:	e8 d2 fd ff ff       	call   800903 <fsipc>
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 08             	pushl  0x8(%ebp)
  800b41:	e8 1e f8 ff ff       	call   800364 <fd2data>
  800b46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b48:	83 c4 08             	add    $0x8,%esp
  800b4b:	68 95 1e 80 00       	push   $0x801e95
  800b50:	53                   	push   %ebx
  800b51:	e8 1a 0b 00 00       	call   801670 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b56:	8b 46 04             	mov    0x4(%esi),%eax
  800b59:	2b 06                	sub    (%esi),%eax
  800b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b68:	00 00 00 
	stat->st_dev = &devpipe;
  800b6b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b72:	30 80 00 
	return 0;
}
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8b:	53                   	push   %ebx
  800b8c:	6a 00                	push   $0x0
  800b8e:	e8 55 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b93:	89 1c 24             	mov    %ebx,(%esp)
  800b96:	e8 c9 f7 ff ff       	call   800364 <fd2data>
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 00                	push   $0x0
  800ba1:	e8 42 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 1c             	sub    $0x1c,%esp
  800bb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bb7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bb9:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc7:	e8 df 0e 00 00       	call   801aab <pageref>
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	89 3c 24             	mov    %edi,(%esp)
  800bd1:	e8 d5 0e 00 00       	call   801aab <pageref>
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	39 c3                	cmp    %eax,%ebx
  800bdb:	0f 94 c1             	sete   %cl
  800bde:	0f b6 c9             	movzbl %cl,%ecx
  800be1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800be4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bed:	39 ce                	cmp    %ecx,%esi
  800bef:	74 1b                	je     800c0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf1:	39 c3                	cmp    %eax,%ebx
  800bf3:	75 c4                	jne    800bb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf5:	8b 42 58             	mov    0x58(%edx),%eax
  800bf8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bfb:	50                   	push   %eax
  800bfc:	56                   	push   %esi
  800bfd:	68 9c 1e 80 00       	push   $0x801e9c
  800c02:	e8 e4 04 00 00       	call   8010eb <cprintf>
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb ad                	jmp    800bb9 <_pipeisclosed+0xe>
	}
}
  800c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 28             	sub    $0x28,%esp
  800c20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c23:	56                   	push   %esi
  800c24:	e8 3b f7 ff ff       	call   800364 <fd2data>
  800c29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c33:	eb 4b                	jmp    800c80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c35:	89 da                	mov    %ebx,%edx
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	e8 6d ff ff ff       	call   800bab <_pipeisclosed>
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	75 48                	jne    800c8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c42:	e8 fd f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c47:	8b 43 04             	mov    0x4(%ebx),%eax
  800c4a:	8b 0b                	mov    (%ebx),%ecx
  800c4c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c4f:	39 d0                	cmp    %edx,%eax
  800c51:	73 e2                	jae    800c35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c5d:	89 c2                	mov    %eax,%edx
  800c5f:	c1 fa 1f             	sar    $0x1f,%edx
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	c1 e9 1b             	shr    $0x1b,%ecx
  800c67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6a:	83 e2 1f             	and    $0x1f,%edx
  800c6d:	29 ca                	sub    %ecx,%edx
  800c6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7d:	83 c7 01             	add    $0x1,%edi
  800c80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c83:	75 c2                	jne    800c47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c85:	8b 45 10             	mov    0x10(%ebp),%eax
  800c88:	eb 05                	jmp    800c8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 18             	sub    $0x18,%esp
  800ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ca3:	57                   	push   %edi
  800ca4:	e8 bb f6 ff ff       	call   800364 <fd2data>
  800ca9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	eb 3d                	jmp    800cf2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 04                	je     800cbd <devpipe_read+0x26>
				return i;
  800cb9:	89 d8                	mov    %ebx,%eax
  800cbb:	eb 44                	jmp    800d01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cbd:	89 f2                	mov    %esi,%edx
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	e8 e5 fe ff ff       	call   800bab <_pipeisclosed>
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	75 32                	jne    800cfc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cca:	e8 75 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ccf:	8b 06                	mov    (%esi),%eax
  800cd1:	3b 46 04             	cmp    0x4(%esi),%eax
  800cd4:	74 df                	je     800cb5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd6:	99                   	cltd   
  800cd7:	c1 ea 1b             	shr    $0x1b,%edx
  800cda:	01 d0                	add    %edx,%eax
  800cdc:	83 e0 1f             	and    $0x1f,%eax
  800cdf:	29 d0                	sub    %edx,%eax
  800ce1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cef:	83 c3 01             	add    $0x1,%ebx
  800cf2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cf5:	75 d8                	jne    800ccf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfa:	eb 05                	jmp    800d01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cfc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d14:	50                   	push   %eax
  800d15:	e8 61 f6 ff ff       	call   80037b <fd_alloc>
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	0f 88 2c 01 00 00    	js     800e53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d27:	83 ec 04             	sub    $0x4,%esp
  800d2a:	68 07 04 00 00       	push   $0x407
  800d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d32:	6a 00                	push   $0x0
  800d34:	e8 2a f4 ff ff       	call   800163 <sys_page_alloc>
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	0f 88 0d 01 00 00    	js     800e53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4c:	50                   	push   %eax
  800d4d:	e8 29 f6 ff ff       	call   80037b <fd_alloc>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	0f 88 e2 00 00 00    	js     800e41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	68 07 04 00 00       	push   $0x407
  800d67:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6a:	6a 00                	push   $0x0
  800d6c:	e8 f2 f3 ff ff       	call   800163 <sys_page_alloc>
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 88 c3 00 00 00    	js     800e41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	ff 75 f4             	pushl  -0xc(%ebp)
  800d84:	e8 db f5 ff ff       	call   800364 <fd2data>
  800d89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8b:	83 c4 0c             	add    $0xc,%esp
  800d8e:	68 07 04 00 00       	push   $0x407
  800d93:	50                   	push   %eax
  800d94:	6a 00                	push   $0x0
  800d96:	e8 c8 f3 ff ff       	call   800163 <sys_page_alloc>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	0f 88 89 00 00 00    	js     800e31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	ff 75 f0             	pushl  -0x10(%ebp)
  800dae:	e8 b1 f5 ff ff       	call   800364 <fd2data>
  800db3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dba:	50                   	push   %eax
  800dbb:	6a 00                	push   $0x0
  800dbd:	56                   	push   %esi
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 e1 f3 ff ff       	call   8001a6 <sys_page_map>
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	83 c4 20             	add    $0x20,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	78 55                	js     800e23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800de3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfe:	e8 51 f5 ff ff       	call   800354 <fd2num>
  800e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e08:	83 c4 04             	add    $0x4,%esp
  800e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0e:	e8 41 f5 ff ff       	call   800354 <fd2num>
  800e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e21:	eb 30                	jmp    800e53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	56                   	push   %esi
  800e27:	6a 00                	push   $0x0
  800e29:	e8 ba f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	ff 75 f0             	pushl  -0x10(%ebp)
  800e37:	6a 00                	push   $0x0
  800e39:	e8 aa f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	ff 75 f4             	pushl  -0xc(%ebp)
  800e47:	6a 00                	push   $0x0
  800e49:	e8 9a f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e53:	89 d0                	mov    %edx,%eax
  800e55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e65:	50                   	push   %eax
  800e66:	ff 75 08             	pushl  0x8(%ebp)
  800e69:	e8 5c f5 ff ff       	call   8003ca <fd_lookup>
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 18                	js     800e8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7b:	e8 e4 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e85:	e8 21 fd ff ff       	call   800bab <_pipeisclosed>
  800e8a:	83 c4 10             	add    $0x10,%esp
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e9f:	68 b4 1e 80 00       	push   $0x801eb4
  800ea4:	ff 75 0c             	pushl  0xc(%ebp)
  800ea7:	e8 c4 07 00 00       	call   801670 <strcpy>
	return 0;
}
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eca:	eb 2d                	jmp    800ef9 <devcons_write+0x46>
		m = n - tot;
  800ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ed1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ed4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ed9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800edc:	83 ec 04             	sub    $0x4,%esp
  800edf:	53                   	push   %ebx
  800ee0:	03 45 0c             	add    0xc(%ebp),%eax
  800ee3:	50                   	push   %eax
  800ee4:	57                   	push   %edi
  800ee5:	e8 18 09 00 00       	call   801802 <memmove>
		sys_cputs(buf, m);
  800eea:	83 c4 08             	add    $0x8,%esp
  800eed:	53                   	push   %ebx
  800eee:	57                   	push   %edi
  800eef:	e8 b3 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef4:	01 de                	add    %ebx,%esi
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	3b 75 10             	cmp    0x10(%ebp),%esi
  800efe:	72 cc                	jb     800ecc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 08             	sub    $0x8,%esp
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f17:	74 2a                	je     800f43 <devcons_read+0x3b>
  800f19:	eb 05                	jmp    800f20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f1b:	e8 24 f2 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f20:	e8 a0 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f25:	85 c0                	test   %eax,%eax
  800f27:	74 f2                	je     800f1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 16                	js     800f43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f2d:	83 f8 04             	cmp    $0x4,%eax
  800f30:	74 0c                	je     800f3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f35:	88 02                	mov    %al,(%edx)
	return 1;
  800f37:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3c:	eb 05                	jmp    800f43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f51:	6a 01                	push   $0x1
  800f53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	e8 4b f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <getchar>:

int
getchar(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f67:	6a 01                	push   $0x1
  800f69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 bc f6 ff ff       	call   800630 <read>
	if (r < 0)
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 0f                	js     800f8a <getchar+0x29>
		return r;
	if (r < 1)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	7e 06                	jle    800f85 <getchar+0x24>
		return -E_EOF;
	return c;
  800f7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f83:	eb 05                	jmp    800f8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	ff 75 08             	pushl  0x8(%ebp)
  800f99:	e8 2c f4 ff ff       	call   8003ca <fd_lookup>
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 11                	js     800fb6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fae:	39 10                	cmp    %edx,(%eax)
  800fb0:	0f 94 c0             	sete   %al
  800fb3:	0f b6 c0             	movzbl %al,%eax
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <opencons>:

int
opencons(void)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	e8 b4 f3 ff ff       	call   80037b <fd_alloc>
  800fc7:	83 c4 10             	add    $0x10,%esp
		return r;
  800fca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 3e                	js     80100e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	68 07 04 00 00       	push   $0x407
  800fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 81 f1 ff ff       	call   800163 <sys_page_alloc>
  800fe2:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 23                	js     80100e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800feb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	50                   	push   %eax
  801004:	e8 4b f3 ff ff       	call   800354 <fd2num>
  801009:	89 c2                	mov    %eax,%edx
  80100b:	83 c4 10             	add    $0x10,%esp
}
  80100e:	89 d0                	mov    %edx,%eax
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801017:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801020:	e8 00 f1 ff ff       	call   800125 <sys_getenvid>
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	ff 75 0c             	pushl  0xc(%ebp)
  80102b:	ff 75 08             	pushl  0x8(%ebp)
  80102e:	56                   	push   %esi
  80102f:	50                   	push   %eax
  801030:	68 c0 1e 80 00       	push   $0x801ec0
  801035:	e8 b1 00 00 00       	call   8010eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103a:	83 c4 18             	add    $0x18,%esp
  80103d:	53                   	push   %ebx
  80103e:	ff 75 10             	pushl  0x10(%ebp)
  801041:	e8 54 00 00 00       	call   80109a <vcprintf>
	cprintf("\n");
  801046:	c7 04 24 ad 1e 80 00 	movl   $0x801ead,(%esp)
  80104d:	e8 99 00 00 00       	call   8010eb <cprintf>
  801052:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801055:	cc                   	int3   
  801056:	eb fd                	jmp    801055 <_panic+0x43>

00801058 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801062:	8b 13                	mov    (%ebx),%edx
  801064:	8d 42 01             	lea    0x1(%edx),%eax
  801067:	89 03                	mov    %eax,(%ebx)
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801070:	3d ff 00 00 00       	cmp    $0xff,%eax
  801075:	75 1a                	jne    801091 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	68 ff 00 00 00       	push   $0xff
  80107f:	8d 43 08             	lea    0x8(%ebx),%eax
  801082:	50                   	push   %eax
  801083:	e8 1f f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801088:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801091:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010aa:	00 00 00 
	b.cnt = 0;
  8010ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ba:	ff 75 08             	pushl  0x8(%ebp)
  8010bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	68 58 10 80 00       	push   $0x801058
  8010c9:	e8 54 01 00 00       	call   801222 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	e8 c4 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8010e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 08             	pushl  0x8(%ebp)
  8010f8:	e8 9d ff ff ff       	call   80109a <vcprintf>
	va_end(ap);

	return cnt;
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 1c             	sub    $0x1c,%esp
  801108:	89 c7                	mov    %eax,%edi
  80110a:	89 d6                	mov    %edx,%esi
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801112:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801115:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801118:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801120:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801123:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801126:	39 d3                	cmp    %edx,%ebx
  801128:	72 05                	jb     80112f <printnum+0x30>
  80112a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80112d:	77 45                	ja     801174 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	ff 75 18             	pushl  0x18(%ebp)
  801135:	8b 45 14             	mov    0x14(%ebp),%eax
  801138:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80113b:	53                   	push   %ebx
  80113c:	ff 75 10             	pushl  0x10(%ebp)
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	ff 75 e4             	pushl  -0x1c(%ebp)
  801145:	ff 75 e0             	pushl  -0x20(%ebp)
  801148:	ff 75 dc             	pushl  -0x24(%ebp)
  80114b:	ff 75 d8             	pushl  -0x28(%ebp)
  80114e:	e8 9d 09 00 00       	call   801af0 <__udivdi3>
  801153:	83 c4 18             	add    $0x18,%esp
  801156:	52                   	push   %edx
  801157:	50                   	push   %eax
  801158:	89 f2                	mov    %esi,%edx
  80115a:	89 f8                	mov    %edi,%eax
  80115c:	e8 9e ff ff ff       	call   8010ff <printnum>
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	eb 18                	jmp    80117e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	56                   	push   %esi
  80116a:	ff 75 18             	pushl  0x18(%ebp)
  80116d:	ff d7                	call   *%edi
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	eb 03                	jmp    801177 <printnum+0x78>
  801174:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801177:	83 eb 01             	sub    $0x1,%ebx
  80117a:	85 db                	test   %ebx,%ebx
  80117c:	7f e8                	jg     801166 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	56                   	push   %esi
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	ff 75 e4             	pushl  -0x1c(%ebp)
  801188:	ff 75 e0             	pushl  -0x20(%ebp)
  80118b:	ff 75 dc             	pushl  -0x24(%ebp)
  80118e:	ff 75 d8             	pushl  -0x28(%ebp)
  801191:	e8 8a 0a 00 00       	call   801c20 <__umoddi3>
  801196:	83 c4 14             	add    $0x14,%esp
  801199:	0f be 80 e3 1e 80 00 	movsbl 0x801ee3(%eax),%eax
  8011a0:	50                   	push   %eax
  8011a1:	ff d7                	call   *%edi
}
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b1:	83 fa 01             	cmp    $0x1,%edx
  8011b4:	7e 0e                	jle    8011c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011b6:	8b 10                	mov    (%eax),%edx
  8011b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011bb:	89 08                	mov    %ecx,(%eax)
  8011bd:	8b 02                	mov    (%edx),%eax
  8011bf:	8b 52 04             	mov    0x4(%edx),%edx
  8011c2:	eb 22                	jmp    8011e6 <getuint+0x38>
	else if (lflag)
  8011c4:	85 d2                	test   %edx,%edx
  8011c6:	74 10                	je     8011d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011c8:	8b 10                	mov    (%eax),%edx
  8011ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011cd:	89 08                	mov    %ecx,(%eax)
  8011cf:	8b 02                	mov    (%edx),%eax
  8011d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d6:	eb 0e                	jmp    8011e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011d8:	8b 10                	mov    (%eax),%edx
  8011da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011dd:	89 08                	mov    %ecx,(%eax)
  8011df:	8b 02                	mov    (%edx),%eax
  8011e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011f2:	8b 10                	mov    (%eax),%edx
  8011f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f7:	73 0a                	jae    801203 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011fc:	89 08                	mov    %ecx,(%eax)
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	88 02                	mov    %al,(%edx)
}
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80120b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80120e:	50                   	push   %eax
  80120f:	ff 75 10             	pushl  0x10(%ebp)
  801212:	ff 75 0c             	pushl  0xc(%ebp)
  801215:	ff 75 08             	pushl  0x8(%ebp)
  801218:	e8 05 00 00 00       	call   801222 <vprintfmt>
	va_end(ap);
}
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 2c             	sub    $0x2c,%esp
  80122b:	8b 75 08             	mov    0x8(%ebp),%esi
  80122e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801231:	8b 7d 10             	mov    0x10(%ebp),%edi
  801234:	eb 12                	jmp    801248 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801236:	85 c0                	test   %eax,%eax
  801238:	0f 84 89 03 00 00    	je     8015c7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	53                   	push   %ebx
  801242:	50                   	push   %eax
  801243:	ff d6                	call   *%esi
  801245:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801248:	83 c7 01             	add    $0x1,%edi
  80124b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80124f:	83 f8 25             	cmp    $0x25,%eax
  801252:	75 e2                	jne    801236 <vprintfmt+0x14>
  801254:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801258:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80125f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801266:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80126d:	ba 00 00 00 00       	mov    $0x0,%edx
  801272:	eb 07                	jmp    80127b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801274:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801277:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127b:	8d 47 01             	lea    0x1(%edi),%eax
  80127e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801281:	0f b6 07             	movzbl (%edi),%eax
  801284:	0f b6 c8             	movzbl %al,%ecx
  801287:	83 e8 23             	sub    $0x23,%eax
  80128a:	3c 55                	cmp    $0x55,%al
  80128c:	0f 87 1a 03 00 00    	ja     8015ac <vprintfmt+0x38a>
  801292:	0f b6 c0             	movzbl %al,%eax
  801295:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80129c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80129f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012a3:	eb d6                	jmp    80127b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012bd:	83 fa 09             	cmp    $0x9,%edx
  8012c0:	77 39                	ja     8012fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012c5:	eb e9                	jmp    8012b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8012cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012d0:	8b 00                	mov    (%eax),%eax
  8012d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d8:	eb 27                	jmp    801301 <vprintfmt+0xdf>
  8012da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012e4:	0f 49 c8             	cmovns %eax,%ecx
  8012e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ed:	eb 8c                	jmp    80127b <vprintfmt+0x59>
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f9:	eb 80                	jmp    80127b <vprintfmt+0x59>
  8012fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801301:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801305:	0f 89 70 ff ff ff    	jns    80127b <vprintfmt+0x59>
				width = precision, precision = -1;
  80130b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801311:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801318:	e9 5e ff ff ff       	jmp    80127b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80131d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801323:	e9 53 ff ff ff       	jmp    80127b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801328:	8b 45 14             	mov    0x14(%ebp),%eax
  80132b:	8d 50 04             	lea    0x4(%eax),%edx
  80132e:	89 55 14             	mov    %edx,0x14(%ebp)
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	ff 30                	pushl  (%eax)
  801337:	ff d6                	call   *%esi
			break;
  801339:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80133f:	e9 04 ff ff ff       	jmp    801248 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801344:	8b 45 14             	mov    0x14(%ebp),%eax
  801347:	8d 50 04             	lea    0x4(%eax),%edx
  80134a:	89 55 14             	mov    %edx,0x14(%ebp)
  80134d:	8b 00                	mov    (%eax),%eax
  80134f:	99                   	cltd   
  801350:	31 d0                	xor    %edx,%eax
  801352:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801354:	83 f8 0f             	cmp    $0xf,%eax
  801357:	7f 0b                	jg     801364 <vprintfmt+0x142>
  801359:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  801360:	85 d2                	test   %edx,%edx
  801362:	75 18                	jne    80137c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801364:	50                   	push   %eax
  801365:	68 fb 1e 80 00       	push   $0x801efb
  80136a:	53                   	push   %ebx
  80136b:	56                   	push   %esi
  80136c:	e8 94 fe ff ff       	call   801205 <printfmt>
  801371:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801377:	e9 cc fe ff ff       	jmp    801248 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80137c:	52                   	push   %edx
  80137d:	68 86 1e 80 00       	push   $0x801e86
  801382:	53                   	push   %ebx
  801383:	56                   	push   %esi
  801384:	e8 7c fe ff ff       	call   801205 <printfmt>
  801389:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80138f:	e9 b4 fe ff ff       	jmp    801248 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801394:	8b 45 14             	mov    0x14(%ebp),%eax
  801397:	8d 50 04             	lea    0x4(%eax),%edx
  80139a:	89 55 14             	mov    %edx,0x14(%ebp)
  80139d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80139f:	85 ff                	test   %edi,%edi
  8013a1:	b8 f4 1e 80 00       	mov    $0x801ef4,%eax
  8013a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ad:	0f 8e 94 00 00 00    	jle    801447 <vprintfmt+0x225>
  8013b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b7:	0f 84 98 00 00 00    	je     801455 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c3:	57                   	push   %edi
  8013c4:	e8 86 02 00 00       	call   80164f <strnlen>
  8013c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013cc:	29 c1                	sub    %eax,%ecx
  8013ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8013d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e0:	eb 0f                	jmp    8013f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	53                   	push   %ebx
  8013e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013eb:	83 ef 01             	sub    $0x1,%edi
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 ff                	test   %edi,%edi
  8013f3:	7f ed                	jg     8013e2 <vprintfmt+0x1c0>
  8013f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8013fb:	85 c9                	test   %ecx,%ecx
  8013fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801402:	0f 49 c1             	cmovns %ecx,%eax
  801405:	29 c1                	sub    %eax,%ecx
  801407:	89 75 08             	mov    %esi,0x8(%ebp)
  80140a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80140d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801410:	89 cb                	mov    %ecx,%ebx
  801412:	eb 4d                	jmp    801461 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801414:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801418:	74 1b                	je     801435 <vprintfmt+0x213>
  80141a:	0f be c0             	movsbl %al,%eax
  80141d:	83 e8 20             	sub    $0x20,%eax
  801420:	83 f8 5e             	cmp    $0x5e,%eax
  801423:	76 10                	jbe    801435 <vprintfmt+0x213>
					putch('?', putdat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	ff 75 0c             	pushl  0xc(%ebp)
  80142b:	6a 3f                	push   $0x3f
  80142d:	ff 55 08             	call   *0x8(%ebp)
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	eb 0d                	jmp    801442 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	52                   	push   %edx
  80143c:	ff 55 08             	call   *0x8(%ebp)
  80143f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801442:	83 eb 01             	sub    $0x1,%ebx
  801445:	eb 1a                	jmp    801461 <vprintfmt+0x23f>
  801447:	89 75 08             	mov    %esi,0x8(%ebp)
  80144a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801450:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801453:	eb 0c                	jmp    801461 <vprintfmt+0x23f>
  801455:	89 75 08             	mov    %esi,0x8(%ebp)
  801458:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801461:	83 c7 01             	add    $0x1,%edi
  801464:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801468:	0f be d0             	movsbl %al,%edx
  80146b:	85 d2                	test   %edx,%edx
  80146d:	74 23                	je     801492 <vprintfmt+0x270>
  80146f:	85 f6                	test   %esi,%esi
  801471:	78 a1                	js     801414 <vprintfmt+0x1f2>
  801473:	83 ee 01             	sub    $0x1,%esi
  801476:	79 9c                	jns    801414 <vprintfmt+0x1f2>
  801478:	89 df                	mov    %ebx,%edi
  80147a:	8b 75 08             	mov    0x8(%ebp),%esi
  80147d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801480:	eb 18                	jmp    80149a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	53                   	push   %ebx
  801486:	6a 20                	push   $0x20
  801488:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148a:	83 ef 01             	sub    $0x1,%edi
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	eb 08                	jmp    80149a <vprintfmt+0x278>
  801492:	89 df                	mov    %ebx,%edi
  801494:	8b 75 08             	mov    0x8(%ebp),%esi
  801497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149a:	85 ff                	test   %edi,%edi
  80149c:	7f e4                	jg     801482 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a1:	e9 a2 fd ff ff       	jmp    801248 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a6:	83 fa 01             	cmp    $0x1,%edx
  8014a9:	7e 16                	jle    8014c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ae:	8d 50 08             	lea    0x8(%eax),%edx
  8014b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b4:	8b 50 04             	mov    0x4(%eax),%edx
  8014b7:	8b 00                	mov    (%eax),%eax
  8014b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014bf:	eb 32                	jmp    8014f3 <vprintfmt+0x2d1>
	else if (lflag)
  8014c1:	85 d2                	test   %edx,%edx
  8014c3:	74 18                	je     8014dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c8:	8d 50 04             	lea    0x4(%eax),%edx
  8014cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ce:	8b 00                	mov    (%eax),%eax
  8014d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d3:	89 c1                	mov    %eax,%ecx
  8014d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014db:	eb 16                	jmp    8014f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e0:	8d 50 04             	lea    0x4(%eax),%edx
  8014e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e6:	8b 00                	mov    (%eax),%eax
  8014e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014eb:	89 c1                	mov    %eax,%ecx
  8014ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801502:	79 74                	jns    801578 <vprintfmt+0x356>
				putch('-', putdat);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	53                   	push   %ebx
  801508:	6a 2d                	push   $0x2d
  80150a:	ff d6                	call   *%esi
				num = -(long long) num;
  80150c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80150f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801512:	f7 d8                	neg    %eax
  801514:	83 d2 00             	adc    $0x0,%edx
  801517:	f7 da                	neg    %edx
  801519:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80151c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801521:	eb 55                	jmp    801578 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801523:	8d 45 14             	lea    0x14(%ebp),%eax
  801526:	e8 83 fc ff ff       	call   8011ae <getuint>
			base = 10;
  80152b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801530:	eb 46                	jmp    801578 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801532:	8d 45 14             	lea    0x14(%ebp),%eax
  801535:	e8 74 fc ff ff       	call   8011ae <getuint>
			base = 8;
  80153a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80153f:	eb 37                	jmp    801578 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	53                   	push   %ebx
  801545:	6a 30                	push   $0x30
  801547:	ff d6                	call   *%esi
			putch('x', putdat);
  801549:	83 c4 08             	add    $0x8,%esp
  80154c:	53                   	push   %ebx
  80154d:	6a 78                	push   $0x78
  80154f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801551:	8b 45 14             	mov    0x14(%ebp),%eax
  801554:	8d 50 04             	lea    0x4(%eax),%edx
  801557:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80155a:	8b 00                	mov    (%eax),%eax
  80155c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801561:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801564:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801569:	eb 0d                	jmp    801578 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80156b:	8d 45 14             	lea    0x14(%ebp),%eax
  80156e:	e8 3b fc ff ff       	call   8011ae <getuint>
			base = 16;
  801573:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80157f:	57                   	push   %edi
  801580:	ff 75 e0             	pushl  -0x20(%ebp)
  801583:	51                   	push   %ecx
  801584:	52                   	push   %edx
  801585:	50                   	push   %eax
  801586:	89 da                	mov    %ebx,%edx
  801588:	89 f0                	mov    %esi,%eax
  80158a:	e8 70 fb ff ff       	call   8010ff <printnum>
			break;
  80158f:	83 c4 20             	add    $0x20,%esp
  801592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801595:	e9 ae fc ff ff       	jmp    801248 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	53                   	push   %ebx
  80159e:	51                   	push   %ecx
  80159f:	ff d6                	call   *%esi
			break;
  8015a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015a7:	e9 9c fc ff ff       	jmp    801248 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	6a 25                	push   $0x25
  8015b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	eb 03                	jmp    8015bc <vprintfmt+0x39a>
  8015b9:	83 ef 01             	sub    $0x1,%edi
  8015bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015c0:	75 f7                	jne    8015b9 <vprintfmt+0x397>
  8015c2:	e9 81 fc ff ff       	jmp    801248 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 18             	sub    $0x18,%esp
  8015d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	74 26                	je     801616 <vsnprintf+0x47>
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	7e 22                	jle    801616 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8015f4:	ff 75 14             	pushl  0x14(%ebp)
  8015f7:	ff 75 10             	pushl  0x10(%ebp)
  8015fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	68 e8 11 80 00       	push   $0x8011e8
  801603:	e8 1a fc ff ff       	call   801222 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801608:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80160b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80160e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 05                	jmp    80161b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801616:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801623:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801626:	50                   	push   %eax
  801627:	ff 75 10             	pushl  0x10(%ebp)
  80162a:	ff 75 0c             	pushl  0xc(%ebp)
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 9a ff ff ff       	call   8015cf <vsnprintf>
	va_end(ap);

	return rc;
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80163d:	b8 00 00 00 00       	mov    $0x0,%eax
  801642:	eb 03                	jmp    801647 <strlen+0x10>
		n++;
  801644:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801647:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80164b:	75 f7                	jne    801644 <strlen+0xd>
		n++;
	return n;
}
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801655:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801658:	ba 00 00 00 00       	mov    $0x0,%edx
  80165d:	eb 03                	jmp    801662 <strnlen+0x13>
		n++;
  80165f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801662:	39 c2                	cmp    %eax,%edx
  801664:	74 08                	je     80166e <strnlen+0x1f>
  801666:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80166a:	75 f3                	jne    80165f <strnlen+0x10>
  80166c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	53                   	push   %ebx
  801674:	8b 45 08             	mov    0x8(%ebp),%eax
  801677:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	83 c2 01             	add    $0x1,%edx
  80167f:	83 c1 01             	add    $0x1,%ecx
  801682:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801686:	88 5a ff             	mov    %bl,-0x1(%edx)
  801689:	84 db                	test   %bl,%bl
  80168b:	75 ef                	jne    80167c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80168d:	5b                   	pop    %ebx
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	53                   	push   %ebx
  801694:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801697:	53                   	push   %ebx
  801698:	e8 9a ff ff ff       	call   801637 <strlen>
  80169d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016a0:	ff 75 0c             	pushl  0xc(%ebp)
  8016a3:	01 d8                	add    %ebx,%eax
  8016a5:	50                   	push   %eax
  8016a6:	e8 c5 ff ff ff       	call   801670 <strcpy>
	return dst;
}
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	56                   	push   %esi
  8016b6:	53                   	push   %ebx
  8016b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016bd:	89 f3                	mov    %esi,%ebx
  8016bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016c2:	89 f2                	mov    %esi,%edx
  8016c4:	eb 0f                	jmp    8016d5 <strncpy+0x23>
		*dst++ = *src;
  8016c6:	83 c2 01             	add    $0x1,%edx
  8016c9:	0f b6 01             	movzbl (%ecx),%eax
  8016cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8016d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016d5:	39 da                	cmp    %ebx,%edx
  8016d7:	75 ed                	jne    8016c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8016d9:	89 f0                	mov    %esi,%eax
  8016db:	5b                   	pop    %ebx
  8016dc:	5e                   	pop    %esi
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
  8016e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8016ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8016ef:	85 d2                	test   %edx,%edx
  8016f1:	74 21                	je     801714 <strlcpy+0x35>
  8016f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8016f7:	89 f2                	mov    %esi,%edx
  8016f9:	eb 09                	jmp    801704 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8016fb:	83 c2 01             	add    $0x1,%edx
  8016fe:	83 c1 01             	add    $0x1,%ecx
  801701:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801704:	39 c2                	cmp    %eax,%edx
  801706:	74 09                	je     801711 <strlcpy+0x32>
  801708:	0f b6 19             	movzbl (%ecx),%ebx
  80170b:	84 db                	test   %bl,%bl
  80170d:	75 ec                	jne    8016fb <strlcpy+0x1c>
  80170f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801711:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801714:	29 f0                	sub    %esi,%eax
}
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801720:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801723:	eb 06                	jmp    80172b <strcmp+0x11>
		p++, q++;
  801725:	83 c1 01             	add    $0x1,%ecx
  801728:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80172b:	0f b6 01             	movzbl (%ecx),%eax
  80172e:	84 c0                	test   %al,%al
  801730:	74 04                	je     801736 <strcmp+0x1c>
  801732:	3a 02                	cmp    (%edx),%al
  801734:	74 ef                	je     801725 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801736:	0f b6 c0             	movzbl %al,%eax
  801739:	0f b6 12             	movzbl (%edx),%edx
  80173c:	29 d0                	sub    %edx,%eax
}
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80174f:	eb 06                	jmp    801757 <strncmp+0x17>
		n--, p++, q++;
  801751:	83 c0 01             	add    $0x1,%eax
  801754:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801757:	39 d8                	cmp    %ebx,%eax
  801759:	74 15                	je     801770 <strncmp+0x30>
  80175b:	0f b6 08             	movzbl (%eax),%ecx
  80175e:	84 c9                	test   %cl,%cl
  801760:	74 04                	je     801766 <strncmp+0x26>
  801762:	3a 0a                	cmp    (%edx),%cl
  801764:	74 eb                	je     801751 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801766:	0f b6 00             	movzbl (%eax),%eax
  801769:	0f b6 12             	movzbl (%edx),%edx
  80176c:	29 d0                	sub    %edx,%eax
  80176e:	eb 05                	jmp    801775 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801770:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801775:	5b                   	pop    %ebx
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801782:	eb 07                	jmp    80178b <strchr+0x13>
		if (*s == c)
  801784:	38 ca                	cmp    %cl,%dl
  801786:	74 0f                	je     801797 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801788:	83 c0 01             	add    $0x1,%eax
  80178b:	0f b6 10             	movzbl (%eax),%edx
  80178e:	84 d2                	test   %dl,%dl
  801790:	75 f2                	jne    801784 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017a3:	eb 03                	jmp    8017a8 <strfind+0xf>
  8017a5:	83 c0 01             	add    $0x1,%eax
  8017a8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ab:	38 ca                	cmp    %cl,%dl
  8017ad:	74 04                	je     8017b3 <strfind+0x1a>
  8017af:	84 d2                	test   %dl,%dl
  8017b1:	75 f2                	jne    8017a5 <strfind+0xc>
			break;
	return (char *) s;
}
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	57                   	push   %edi
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017c1:	85 c9                	test   %ecx,%ecx
  8017c3:	74 36                	je     8017fb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017cb:	75 28                	jne    8017f5 <memset+0x40>
  8017cd:	f6 c1 03             	test   $0x3,%cl
  8017d0:	75 23                	jne    8017f5 <memset+0x40>
		c &= 0xFF;
  8017d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017d6:	89 d3                	mov    %edx,%ebx
  8017d8:	c1 e3 08             	shl    $0x8,%ebx
  8017db:	89 d6                	mov    %edx,%esi
  8017dd:	c1 e6 18             	shl    $0x18,%esi
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	c1 e0 10             	shl    $0x10,%eax
  8017e5:	09 f0                	or     %esi,%eax
  8017e7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8017e9:	89 d8                	mov    %ebx,%eax
  8017eb:	09 d0                	or     %edx,%eax
  8017ed:	c1 e9 02             	shr    $0x2,%ecx
  8017f0:	fc                   	cld    
  8017f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8017f3:	eb 06                	jmp    8017fb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f8:	fc                   	cld    
  8017f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017fb:	89 f8                	mov    %edi,%eax
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5f                   	pop    %edi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	57                   	push   %edi
  801806:	56                   	push   %esi
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80180d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801810:	39 c6                	cmp    %eax,%esi
  801812:	73 35                	jae    801849 <memmove+0x47>
  801814:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801817:	39 d0                	cmp    %edx,%eax
  801819:	73 2e                	jae    801849 <memmove+0x47>
		s += n;
		d += n;
  80181b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80181e:	89 d6                	mov    %edx,%esi
  801820:	09 fe                	or     %edi,%esi
  801822:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801828:	75 13                	jne    80183d <memmove+0x3b>
  80182a:	f6 c1 03             	test   $0x3,%cl
  80182d:	75 0e                	jne    80183d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80182f:	83 ef 04             	sub    $0x4,%edi
  801832:	8d 72 fc             	lea    -0x4(%edx),%esi
  801835:	c1 e9 02             	shr    $0x2,%ecx
  801838:	fd                   	std    
  801839:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80183b:	eb 09                	jmp    801846 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80183d:	83 ef 01             	sub    $0x1,%edi
  801840:	8d 72 ff             	lea    -0x1(%edx),%esi
  801843:	fd                   	std    
  801844:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801846:	fc                   	cld    
  801847:	eb 1d                	jmp    801866 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801849:	89 f2                	mov    %esi,%edx
  80184b:	09 c2                	or     %eax,%edx
  80184d:	f6 c2 03             	test   $0x3,%dl
  801850:	75 0f                	jne    801861 <memmove+0x5f>
  801852:	f6 c1 03             	test   $0x3,%cl
  801855:	75 0a                	jne    801861 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801857:	c1 e9 02             	shr    $0x2,%ecx
  80185a:	89 c7                	mov    %eax,%edi
  80185c:	fc                   	cld    
  80185d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80185f:	eb 05                	jmp    801866 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801861:	89 c7                	mov    %eax,%edi
  801863:	fc                   	cld    
  801864:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801866:	5e                   	pop    %esi
  801867:	5f                   	pop    %edi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80186d:	ff 75 10             	pushl  0x10(%ebp)
  801870:	ff 75 0c             	pushl  0xc(%ebp)
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 87 ff ff ff       	call   801802 <memmove>
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    

0080187d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 55 0c             	mov    0xc(%ebp),%edx
  801888:	89 c6                	mov    %eax,%esi
  80188a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80188d:	eb 1a                	jmp    8018a9 <memcmp+0x2c>
		if (*s1 != *s2)
  80188f:	0f b6 08             	movzbl (%eax),%ecx
  801892:	0f b6 1a             	movzbl (%edx),%ebx
  801895:	38 d9                	cmp    %bl,%cl
  801897:	74 0a                	je     8018a3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801899:	0f b6 c1             	movzbl %cl,%eax
  80189c:	0f b6 db             	movzbl %bl,%ebx
  80189f:	29 d8                	sub    %ebx,%eax
  8018a1:	eb 0f                	jmp    8018b2 <memcmp+0x35>
		s1++, s2++;
  8018a3:	83 c0 01             	add    $0x1,%eax
  8018a6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a9:	39 f0                	cmp    %esi,%eax
  8018ab:	75 e2                	jne    80188f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018bd:	89 c1                	mov    %eax,%ecx
  8018bf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8018c2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018c6:	eb 0a                	jmp    8018d2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018c8:	0f b6 10             	movzbl (%eax),%edx
  8018cb:	39 da                	cmp    %ebx,%edx
  8018cd:	74 07                	je     8018d6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8018cf:	83 c0 01             	add    $0x1,%eax
  8018d2:	39 c8                	cmp    %ecx,%eax
  8018d4:	72 f2                	jb     8018c8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8018d6:	5b                   	pop    %ebx
  8018d7:	5d                   	pop    %ebp
  8018d8:	c3                   	ret    

008018d9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	57                   	push   %edi
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018e5:	eb 03                	jmp    8018ea <strtol+0x11>
		s++;
  8018e7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8018ea:	0f b6 01             	movzbl (%ecx),%eax
  8018ed:	3c 20                	cmp    $0x20,%al
  8018ef:	74 f6                	je     8018e7 <strtol+0xe>
  8018f1:	3c 09                	cmp    $0x9,%al
  8018f3:	74 f2                	je     8018e7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8018f5:	3c 2b                	cmp    $0x2b,%al
  8018f7:	75 0a                	jne    801903 <strtol+0x2a>
		s++;
  8018f9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8018fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801901:	eb 11                	jmp    801914 <strtol+0x3b>
  801903:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801908:	3c 2d                	cmp    $0x2d,%al
  80190a:	75 08                	jne    801914 <strtol+0x3b>
		s++, neg = 1;
  80190c:	83 c1 01             	add    $0x1,%ecx
  80190f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801914:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80191a:	75 15                	jne    801931 <strtol+0x58>
  80191c:	80 39 30             	cmpb   $0x30,(%ecx)
  80191f:	75 10                	jne    801931 <strtol+0x58>
  801921:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801925:	75 7c                	jne    8019a3 <strtol+0xca>
		s += 2, base = 16;
  801927:	83 c1 02             	add    $0x2,%ecx
  80192a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80192f:	eb 16                	jmp    801947 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801931:	85 db                	test   %ebx,%ebx
  801933:	75 12                	jne    801947 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801935:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80193a:	80 39 30             	cmpb   $0x30,(%ecx)
  80193d:	75 08                	jne    801947 <strtol+0x6e>
		s++, base = 8;
  80193f:	83 c1 01             	add    $0x1,%ecx
  801942:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80194f:	0f b6 11             	movzbl (%ecx),%edx
  801952:	8d 72 d0             	lea    -0x30(%edx),%esi
  801955:	89 f3                	mov    %esi,%ebx
  801957:	80 fb 09             	cmp    $0x9,%bl
  80195a:	77 08                	ja     801964 <strtol+0x8b>
			dig = *s - '0';
  80195c:	0f be d2             	movsbl %dl,%edx
  80195f:	83 ea 30             	sub    $0x30,%edx
  801962:	eb 22                	jmp    801986 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801964:	8d 72 9f             	lea    -0x61(%edx),%esi
  801967:	89 f3                	mov    %esi,%ebx
  801969:	80 fb 19             	cmp    $0x19,%bl
  80196c:	77 08                	ja     801976 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80196e:	0f be d2             	movsbl %dl,%edx
  801971:	83 ea 57             	sub    $0x57,%edx
  801974:	eb 10                	jmp    801986 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801976:	8d 72 bf             	lea    -0x41(%edx),%esi
  801979:	89 f3                	mov    %esi,%ebx
  80197b:	80 fb 19             	cmp    $0x19,%bl
  80197e:	77 16                	ja     801996 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801980:	0f be d2             	movsbl %dl,%edx
  801983:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801986:	3b 55 10             	cmp    0x10(%ebp),%edx
  801989:	7d 0b                	jge    801996 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80198b:	83 c1 01             	add    $0x1,%ecx
  80198e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801992:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801994:	eb b9                	jmp    80194f <strtol+0x76>

	if (endptr)
  801996:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80199a:	74 0d                	je     8019a9 <strtol+0xd0>
		*endptr = (char *) s;
  80199c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80199f:	89 0e                	mov    %ecx,(%esi)
  8019a1:	eb 06                	jmp    8019a9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a3:	85 db                	test   %ebx,%ebx
  8019a5:	74 98                	je     80193f <strtol+0x66>
  8019a7:	eb 9e                	jmp    801947 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	f7 da                	neg    %edx
  8019ad:	85 ff                	test   %edi,%edi
  8019af:	0f 45 c2             	cmovne %edx,%eax
}
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5f                   	pop    %edi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8019bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019c5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019c7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019cc:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	50                   	push   %eax
  8019d3:	e8 3b e9 ff ff       	call   800313 <sys_ipc_recv>

	if (from_env_store != NULL)
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	85 f6                	test   %esi,%esi
  8019dd:	74 14                	je     8019f3 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019df:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 09                	js     8019f1 <ipc_recv+0x3a>
  8019e8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019ee:	8b 52 74             	mov    0x74(%edx),%edx
  8019f1:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8019f3:	85 db                	test   %ebx,%ebx
  8019f5:	74 14                	je     801a0b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 09                	js     801a09 <ipc_recv+0x52>
  801a00:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a06:	8b 52 78             	mov    0x78(%edx),%edx
  801a09:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 08                	js     801a17 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a0f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a14:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	57                   	push   %edi
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a30:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a32:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a37:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a3a:	ff 75 14             	pushl  0x14(%ebp)
  801a3d:	53                   	push   %ebx
  801a3e:	56                   	push   %esi
  801a3f:	57                   	push   %edi
  801a40:	e8 ab e8 ff ff       	call   8002f0 <sys_ipc_try_send>

		if (err < 0) {
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	79 1e                	jns    801a6a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a4c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a4f:	75 07                	jne    801a58 <ipc_send+0x3a>
				sys_yield();
  801a51:	e8 ee e6 ff ff       	call   800144 <sys_yield>
  801a56:	eb e2                	jmp    801a3a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a58:	50                   	push   %eax
  801a59:	68 e0 21 80 00       	push   $0x8021e0
  801a5e:	6a 49                	push   $0x49
  801a60:	68 ed 21 80 00       	push   $0x8021ed
  801a65:	e8 a8 f5 ff ff       	call   801012 <_panic>
		}

	} while (err < 0);

}
  801a6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5f                   	pop    %edi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a7d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a80:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a86:	8b 52 50             	mov    0x50(%edx),%edx
  801a89:	39 ca                	cmp    %ecx,%edx
  801a8b:	75 0d                	jne    801a9a <ipc_find_env+0x28>
			return envs[i].env_id;
  801a8d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a90:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a95:	8b 40 48             	mov    0x48(%eax),%eax
  801a98:	eb 0f                	jmp    801aa9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a9a:	83 c0 01             	add    $0x1,%eax
  801a9d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aa2:	75 d9                	jne    801a7d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab1:	89 d0                	mov    %edx,%eax
  801ab3:	c1 e8 16             	shr    $0x16,%eax
  801ab6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801abd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac2:	f6 c1 01             	test   $0x1,%cl
  801ac5:	74 1d                	je     801ae4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ac7:	c1 ea 0c             	shr    $0xc,%edx
  801aca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ad1:	f6 c2 01             	test   $0x1,%dl
  801ad4:	74 0e                	je     801ae4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ad6:	c1 ea 0c             	shr    $0xc,%edx
  801ad9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ae0:	ef 
  801ae1:	0f b7 c0             	movzwl %ax,%eax
}
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
  801ae6:	66 90                	xchg   %ax,%ax
  801ae8:	66 90                	xchg   %ax,%ax
  801aea:	66 90                	xchg   %ax,%ax
  801aec:	66 90                	xchg   %ax,%ax
  801aee:	66 90                	xchg   %ax,%ax

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
