
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 40 23 80 00       	push   $0x802340
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 43 23 80 00       	push   $0x802343
  80008f:	6a 01                	push   $0x1
  800091:	e8 2e 0b 00 00       	call   800bc4 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 12 0b 00 00       	call   800bc4 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 90 24 80 00       	push   $0x802490
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 f1 0a 00 00       	call   800bc4 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 4e 04 00 00       	call   80053c <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 aa 08 00 00       	call   8009d9 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c2 03 00 00       	call   8004fb <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ec:	89 d1                	mov    %edx,%ecx
  8004ee:	89 d3                	mov    %edx,%ebx
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
  800509:	b8 03 00 00 00       	mov    $0x3,%eax
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800519:	85 c0                	test   %eax,%eax
  80051b:	7e 17                	jle    800534 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	50                   	push   %eax
  800521:	6a 03                	push   $0x3
  800523:	68 4f 23 80 00       	push   $0x80234f
  800528:	6a 23                	push   $0x23
  80052a:	68 6c 23 80 00       	push   $0x80236c
  80052f:	e8 1e 14 00 00       	call   801952 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	b8 02 00 00 00       	mov    $0x2,%eax
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 d3                	mov    %edx,%ebx
  800550:	89 d7                	mov    %edx,%edi
  800552:	89 d6                	mov    %edx,%esi
  800554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5f                   	pop    %edi
  800559:	5d                   	pop    %ebp
  80055a:	c3                   	ret    

0080055b <sys_yield>:

void
sys_yield(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 d3                	mov    %edx,%ebx
  80056f:	89 d7                	mov    %edx,%edi
  800571:	89 d6                	mov    %edx,%esi
  800573:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800583:	be 00 00 00 00       	mov    $0x0,%esi
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800590:	8b 55 08             	mov    0x8(%ebp),%edx
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	89 f7                	mov    %esi,%edi
  800598:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80059a:	85 c0                	test   %eax,%eax
  80059c:	7e 17                	jle    8005b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	50                   	push   %eax
  8005a2:	6a 04                	push   $0x4
  8005a4:	68 4f 23 80 00       	push   $0x80234f
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 6c 23 80 00       	push   $0x80236c
  8005b0:	e8 9d 13 00 00       	call   801952 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	7e 17                	jle    8005f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	50                   	push   %eax
  8005e4:	6a 05                	push   $0x5
  8005e6:	68 4f 23 80 00       	push   $0x80234f
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 6c 23 80 00       	push   $0x80236c
  8005f2:	e8 5b 13 00 00       	call   801952 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 17                	jle    800639 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	50                   	push   %eax
  800626:	6a 06                	push   $0x6
  800628:	68 4f 23 80 00       	push   $0x80234f
  80062d:	6a 23                	push   $0x23
  80062f:	68 6c 23 80 00       	push   $0x80236c
  800634:	e8 19 13 00 00       	call   801952 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	57                   	push   %edi
  800645:	56                   	push   %esi
  800646:	53                   	push   %ebx
  800647:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	89 de                	mov    %ebx,%esi
  80065e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800660:	85 c0                	test   %eax,%eax
  800662:	7e 17                	jle    80067b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	50                   	push   %eax
  800668:	6a 08                	push   $0x8
  80066a:	68 4f 23 80 00       	push   $0x80234f
  80066f:	6a 23                	push   $0x23
  800671:	68 6c 23 80 00       	push   $0x80236c
  800676:	e8 d7 12 00 00       	call   801952 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800699:	8b 55 08             	mov    0x8(%ebp),%edx
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	7e 17                	jle    8006bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	50                   	push   %eax
  8006aa:	6a 09                	push   $0x9
  8006ac:	68 4f 23 80 00       	push   $0x80234f
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 6c 23 80 00       	push   $0x80236c
  8006b8:	e8 95 12 00 00       	call   801952 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	89 de                	mov    %ebx,%esi
  8006e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	7e 17                	jle    8006ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	50                   	push   %eax
  8006ec:	6a 0a                	push   $0xa
  8006ee:	68 4f 23 80 00       	push   $0x80234f
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 6c 23 80 00       	push   $0x80236c
  8006fa:	e8 53 12 00 00       	call   801952 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80070d:	be 00 00 00 00       	mov    $0x0,%esi
  800712:	b8 0c 00 00 00       	mov    $0xc,%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800720:	8b 7d 14             	mov    0x14(%ebp),%edi
  800723:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 cb                	mov    %ecx,%ebx
  800742:	89 cf                	mov    %ecx,%edi
  800744:	89 ce                	mov    %ecx,%esi
  800746:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800748:	85 c0                	test   %eax,%eax
  80074a:	7e 17                	jle    800763 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	6a 0d                	push   $0xd
  800752:	68 4f 23 80 00       	push   $0x80234f
  800757:	6a 23                	push   $0x23
  800759:	68 6c 23 80 00       	push   $0x80236c
  80075e:	e8 ef 11 00 00       	call   801952 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	57                   	push   %edi
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800771:	ba 00 00 00 00       	mov    $0x0,%edx
  800776:	b8 0e 00 00 00       	mov    $0xe,%eax
  80077b:	89 d1                	mov    %edx,%ecx
  80077d:	89 d3                	mov    %edx,%ebx
  80077f:	89 d7                	mov    %edx,%edi
  800781:	89 d6                	mov    %edx,%esi
  800783:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5f                   	pop    %edi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	57                   	push   %edi
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800793:	bb 00 00 00 00       	mov    $0x0,%ebx
  800798:	b8 0f 00 00 00       	mov    $0xf,%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a3:	89 df                	mov    %ebx,%edi
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	7e 17                	jle    8007c4 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	50                   	push   %eax
  8007b1:	6a 0f                	push   $0xf
  8007b3:	68 4f 23 80 00       	push   $0x80234f
  8007b8:	6a 23                	push   $0x23
  8007ba:	68 6c 23 80 00       	push   $0x80236c
  8007bf:	e8 8e 11 00 00       	call   801952 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8007c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5f                   	pop    %edi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	57                   	push   %edi
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007da:	b8 10 00 00 00       	mov    $0x10,%eax
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e5:	89 df                	mov    %ebx,%edi
  8007e7:	89 de                	mov    %ebx,%esi
  8007e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	7e 17                	jle    800806 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007ef:	83 ec 0c             	sub    $0xc,%esp
  8007f2:	50                   	push   %eax
  8007f3:	6a 10                	push   $0x10
  8007f5:	68 4f 23 80 00       	push   $0x80234f
  8007fa:	6a 23                	push   $0x23
  8007fc:	68 6c 23 80 00       	push   $0x80236c
  800801:	e8 4c 11 00 00       	call   801952 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5f                   	pop    %edi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	05 00 00 00 30       	add    $0x30000000,%eax
  800819:	c1 e8 0c             	shr    $0xc,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	05 00 00 00 30       	add    $0x30000000,%eax
  800829:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80082e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800840:	89 c2                	mov    %eax,%edx
  800842:	c1 ea 16             	shr    $0x16,%edx
  800845:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80084c:	f6 c2 01             	test   $0x1,%dl
  80084f:	74 11                	je     800862 <fd_alloc+0x2d>
  800851:	89 c2                	mov    %eax,%edx
  800853:	c1 ea 0c             	shr    $0xc,%edx
  800856:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80085d:	f6 c2 01             	test   $0x1,%dl
  800860:	75 09                	jne    80086b <fd_alloc+0x36>
			*fd_store = fd;
  800862:	89 01                	mov    %eax,(%ecx)
			return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	eb 17                	jmp    800882 <fd_alloc+0x4d>
  80086b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800870:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800875:	75 c9                	jne    800840 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800877:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80087d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80088a:	83 f8 1f             	cmp    $0x1f,%eax
  80088d:	77 36                	ja     8008c5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80088f:	c1 e0 0c             	shl    $0xc,%eax
  800892:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800897:	89 c2                	mov    %eax,%edx
  800899:	c1 ea 16             	shr    $0x16,%edx
  80089c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008a3:	f6 c2 01             	test   $0x1,%dl
  8008a6:	74 24                	je     8008cc <fd_lookup+0x48>
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	c1 ea 0c             	shr    $0xc,%edx
  8008ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008b4:	f6 c2 01             	test   $0x1,%dl
  8008b7:	74 1a                	je     8008d3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 02                	mov    %eax,(%edx)
	return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	eb 13                	jmp    8008d8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ca:	eb 0c                	jmp    8008d8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d1:	eb 05                	jmp    8008d8 <fd_lookup+0x54>
  8008d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e3:	ba f8 23 80 00       	mov    $0x8023f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8008e8:	eb 13                	jmp    8008fd <dev_lookup+0x23>
  8008ea:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8008ed:	39 08                	cmp    %ecx,(%eax)
  8008ef:	75 0c                	jne    8008fd <dev_lookup+0x23>
			*dev = devtab[i];
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb 2e                	jmp    80092b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008fd:	8b 02                	mov    (%edx),%eax
  8008ff:	85 c0                	test   %eax,%eax
  800901:	75 e7                	jne    8008ea <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800903:	a1 08 40 80 00       	mov    0x804008,%eax
  800908:	8b 40 48             	mov    0x48(%eax),%eax
  80090b:	83 ec 04             	sub    $0x4,%esp
  80090e:	51                   	push   %ecx
  80090f:	50                   	push   %eax
  800910:	68 7c 23 80 00       	push   $0x80237c
  800915:	e8 11 11 00 00       	call   801a2b <cprintf>
	*dev = 0;
  80091a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    

0080092d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	56                   	push   %esi
  800931:	53                   	push   %ebx
  800932:	83 ec 10             	sub    $0x10,%esp
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80093b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093e:	50                   	push   %eax
  80093f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800945:	c1 e8 0c             	shr    $0xc,%eax
  800948:	50                   	push   %eax
  800949:	e8 36 ff ff ff       	call   800884 <fd_lookup>
  80094e:	83 c4 08             	add    $0x8,%esp
  800951:	85 c0                	test   %eax,%eax
  800953:	78 05                	js     80095a <fd_close+0x2d>
	    || fd != fd2)
  800955:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800958:	74 0c                	je     800966 <fd_close+0x39>
		return (must_exist ? r : 0);
  80095a:	84 db                	test   %bl,%bl
  80095c:	ba 00 00 00 00       	mov    $0x0,%edx
  800961:	0f 44 c2             	cmove  %edx,%eax
  800964:	eb 41                	jmp    8009a7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800966:	83 ec 08             	sub    $0x8,%esp
  800969:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80096c:	50                   	push   %eax
  80096d:	ff 36                	pushl  (%esi)
  80096f:	e8 66 ff ff ff       	call   8008da <dev_lookup>
  800974:	89 c3                	mov    %eax,%ebx
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	85 c0                	test   %eax,%eax
  80097b:	78 1a                	js     800997 <fd_close+0x6a>
		if (dev->dev_close)
  80097d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800980:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800983:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800988:	85 c0                	test   %eax,%eax
  80098a:	74 0b                	je     800997 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80098c:	83 ec 0c             	sub    $0xc,%esp
  80098f:	56                   	push   %esi
  800990:	ff d0                	call   *%eax
  800992:	89 c3                	mov    %eax,%ebx
  800994:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	56                   	push   %esi
  80099b:	6a 00                	push   $0x0
  80099d:	e8 5d fc ff ff       	call   8005ff <sys_page_unmap>
	return r;
  8009a2:	83 c4 10             	add    $0x10,%esp
  8009a5:	89 d8                	mov    %ebx,%eax
}
  8009a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b7:	50                   	push   %eax
  8009b8:	ff 75 08             	pushl  0x8(%ebp)
  8009bb:	e8 c4 fe ff ff       	call   800884 <fd_lookup>
  8009c0:	83 c4 08             	add    $0x8,%esp
  8009c3:	85 c0                	test   %eax,%eax
  8009c5:	78 10                	js     8009d7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	6a 01                	push   $0x1
  8009cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8009cf:	e8 59 ff ff ff       	call   80092d <fd_close>
  8009d4:	83 c4 10             	add    $0x10,%esp
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <close_all>:

void
close_all(void)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009e5:	83 ec 0c             	sub    $0xc,%esp
  8009e8:	53                   	push   %ebx
  8009e9:	e8 c0 ff ff ff       	call   8009ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ee:	83 c3 01             	add    $0x1,%ebx
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	83 fb 20             	cmp    $0x20,%ebx
  8009f7:	75 ec                	jne    8009e5 <close_all+0xc>
		close(i);
}
  8009f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	83 ec 2c             	sub    $0x2c,%esp
  800a07:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a0a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 08             	pushl  0x8(%ebp)
  800a11:	e8 6e fe ff ff       	call   800884 <fd_lookup>
  800a16:	83 c4 08             	add    $0x8,%esp
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	0f 88 c1 00 00 00    	js     800ae2 <dup+0xe4>
		return r;
	close(newfdnum);
  800a21:	83 ec 0c             	sub    $0xc,%esp
  800a24:	56                   	push   %esi
  800a25:	e8 84 ff ff ff       	call   8009ae <close>

	newfd = INDEX2FD(newfdnum);
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	c1 e3 0c             	shl    $0xc,%ebx
  800a2f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800a35:	83 c4 04             	add    $0x4,%esp
  800a38:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a3b:	e8 de fd ff ff       	call   80081e <fd2data>
  800a40:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800a42:	89 1c 24             	mov    %ebx,(%esp)
  800a45:	e8 d4 fd ff ff       	call   80081e <fd2data>
  800a4a:	83 c4 10             	add    $0x10,%esp
  800a4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a50:	89 f8                	mov    %edi,%eax
  800a52:	c1 e8 16             	shr    $0x16,%eax
  800a55:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a5c:	a8 01                	test   $0x1,%al
  800a5e:	74 37                	je     800a97 <dup+0x99>
  800a60:	89 f8                	mov    %edi,%eax
  800a62:	c1 e8 0c             	shr    $0xc,%eax
  800a65:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a6c:	f6 c2 01             	test   $0x1,%dl
  800a6f:	74 26                	je     800a97 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a78:	83 ec 0c             	sub    $0xc,%esp
  800a7b:	25 07 0e 00 00       	and    $0xe07,%eax
  800a80:	50                   	push   %eax
  800a81:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a84:	6a 00                	push   $0x0
  800a86:	57                   	push   %edi
  800a87:	6a 00                	push   $0x0
  800a89:	e8 2f fb ff ff       	call   8005bd <sys_page_map>
  800a8e:	89 c7                	mov    %eax,%edi
  800a90:	83 c4 20             	add    $0x20,%esp
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 2e                	js     800ac5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a9a:	89 d0                	mov    %edx,%eax
  800a9c:	c1 e8 0c             	shr    $0xc,%eax
  800a9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	25 07 0e 00 00       	and    $0xe07,%eax
  800aae:	50                   	push   %eax
  800aaf:	53                   	push   %ebx
  800ab0:	6a 00                	push   $0x0
  800ab2:	52                   	push   %edx
  800ab3:	6a 00                	push   $0x0
  800ab5:	e8 03 fb ff ff       	call   8005bd <sys_page_map>
  800aba:	89 c7                	mov    %eax,%edi
  800abc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800abf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ac1:	85 ff                	test   %edi,%edi
  800ac3:	79 1d                	jns    800ae2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	53                   	push   %ebx
  800ac9:	6a 00                	push   $0x0
  800acb:	e8 2f fb ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ad0:	83 c4 08             	add    $0x8,%esp
  800ad3:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ad6:	6a 00                	push   $0x0
  800ad8:	e8 22 fb ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	89 f8                	mov    %edi,%eax
}
  800ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	53                   	push   %ebx
  800aee:	83 ec 14             	sub    $0x14,%esp
  800af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800af4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800af7:	50                   	push   %eax
  800af8:	53                   	push   %ebx
  800af9:	e8 86 fd ff ff       	call   800884 <fd_lookup>
  800afe:	83 c4 08             	add    $0x8,%esp
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	85 c0                	test   %eax,%eax
  800b05:	78 6d                	js     800b74 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0d:	50                   	push   %eax
  800b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b11:	ff 30                	pushl  (%eax)
  800b13:	e8 c2 fd ff ff       	call   8008da <dev_lookup>
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	78 4c                	js     800b6b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b22:	8b 42 08             	mov    0x8(%edx),%eax
  800b25:	83 e0 03             	and    $0x3,%eax
  800b28:	83 f8 01             	cmp    $0x1,%eax
  800b2b:	75 21                	jne    800b4e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b2d:	a1 08 40 80 00       	mov    0x804008,%eax
  800b32:	8b 40 48             	mov    0x48(%eax),%eax
  800b35:	83 ec 04             	sub    $0x4,%esp
  800b38:	53                   	push   %ebx
  800b39:	50                   	push   %eax
  800b3a:	68 bd 23 80 00       	push   $0x8023bd
  800b3f:	e8 e7 0e 00 00       	call   801a2b <cprintf>
		return -E_INVAL;
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b4c:	eb 26                	jmp    800b74 <read+0x8a>
	}
	if (!dev->dev_read)
  800b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b51:	8b 40 08             	mov    0x8(%eax),%eax
  800b54:	85 c0                	test   %eax,%eax
  800b56:	74 17                	je     800b6f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b58:	83 ec 04             	sub    $0x4,%esp
  800b5b:	ff 75 10             	pushl  0x10(%ebp)
  800b5e:	ff 75 0c             	pushl  0xc(%ebp)
  800b61:	52                   	push   %edx
  800b62:	ff d0                	call   *%eax
  800b64:	89 c2                	mov    %eax,%edx
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	eb 09                	jmp    800b74 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b6b:	89 c2                	mov    %eax,%edx
  800b6d:	eb 05                	jmp    800b74 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b6f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800b74:	89 d0                	mov    %edx,%eax
  800b76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b87:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8f:	eb 21                	jmp    800bb2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b91:	83 ec 04             	sub    $0x4,%esp
  800b94:	89 f0                	mov    %esi,%eax
  800b96:	29 d8                	sub    %ebx,%eax
  800b98:	50                   	push   %eax
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	03 45 0c             	add    0xc(%ebp),%eax
  800b9e:	50                   	push   %eax
  800b9f:	57                   	push   %edi
  800ba0:	e8 45 ff ff ff       	call   800aea <read>
		if (m < 0)
  800ba5:	83 c4 10             	add    $0x10,%esp
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	78 10                	js     800bbc <readn+0x41>
			return m;
		if (m == 0)
  800bac:	85 c0                	test   %eax,%eax
  800bae:	74 0a                	je     800bba <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bb0:	01 c3                	add    %eax,%ebx
  800bb2:	39 f3                	cmp    %esi,%ebx
  800bb4:	72 db                	jb     800b91 <readn+0x16>
  800bb6:	89 d8                	mov    %ebx,%eax
  800bb8:	eb 02                	jmp    800bbc <readn+0x41>
  800bba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 14             	sub    $0x14,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bd1:	50                   	push   %eax
  800bd2:	53                   	push   %ebx
  800bd3:	e8 ac fc ff ff       	call   800884 <fd_lookup>
  800bd8:	83 c4 08             	add    $0x8,%esp
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	78 68                	js     800c49 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be1:	83 ec 08             	sub    $0x8,%esp
  800be4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be7:	50                   	push   %eax
  800be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800beb:	ff 30                	pushl  (%eax)
  800bed:	e8 e8 fc ff ff       	call   8008da <dev_lookup>
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	78 47                	js     800c40 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c00:	75 21                	jne    800c23 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c02:	a1 08 40 80 00       	mov    0x804008,%eax
  800c07:	8b 40 48             	mov    0x48(%eax),%eax
  800c0a:	83 ec 04             	sub    $0x4,%esp
  800c0d:	53                   	push   %ebx
  800c0e:	50                   	push   %eax
  800c0f:	68 d9 23 80 00       	push   $0x8023d9
  800c14:	e8 12 0e 00 00       	call   801a2b <cprintf>
		return -E_INVAL;
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c21:	eb 26                	jmp    800c49 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c26:	8b 52 0c             	mov    0xc(%edx),%edx
  800c29:	85 d2                	test   %edx,%edx
  800c2b:	74 17                	je     800c44 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c2d:	83 ec 04             	sub    $0x4,%esp
  800c30:	ff 75 10             	pushl  0x10(%ebp)
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	50                   	push   %eax
  800c37:	ff d2                	call   *%edx
  800c39:	89 c2                	mov    %eax,%edx
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	eb 09                	jmp    800c49 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	eb 05                	jmp    800c49 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c44:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800c49:	89 d0                	mov    %edx,%eax
  800c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c56:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c59:	50                   	push   %eax
  800c5a:	ff 75 08             	pushl  0x8(%ebp)
  800c5d:	e8 22 fc ff ff       	call   800884 <fd_lookup>
  800c62:	83 c4 08             	add    $0x8,%esp
  800c65:	85 c0                	test   %eax,%eax
  800c67:	78 0e                	js     800c77 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 14             	sub    $0x14,%esp
  800c80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c86:	50                   	push   %eax
  800c87:	53                   	push   %ebx
  800c88:	e8 f7 fb ff ff       	call   800884 <fd_lookup>
  800c8d:	83 c4 08             	add    $0x8,%esp
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	85 c0                	test   %eax,%eax
  800c94:	78 65                	js     800cfb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c96:	83 ec 08             	sub    $0x8,%esp
  800c99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c9c:	50                   	push   %eax
  800c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca0:	ff 30                	pushl  (%eax)
  800ca2:	e8 33 fc ff ff       	call   8008da <dev_lookup>
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	85 c0                	test   %eax,%eax
  800cac:	78 44                	js     800cf2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cb5:	75 21                	jne    800cd8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cb7:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cbc:	8b 40 48             	mov    0x48(%eax),%eax
  800cbf:	83 ec 04             	sub    $0x4,%esp
  800cc2:	53                   	push   %ebx
  800cc3:	50                   	push   %eax
  800cc4:	68 9c 23 80 00       	push   $0x80239c
  800cc9:	e8 5d 0d 00 00       	call   801a2b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800cce:	83 c4 10             	add    $0x10,%esp
  800cd1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cd6:	eb 23                	jmp    800cfb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800cd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cdb:	8b 52 18             	mov    0x18(%edx),%edx
  800cde:	85 d2                	test   %edx,%edx
  800ce0:	74 14                	je     800cf6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800ce2:	83 ec 08             	sub    $0x8,%esp
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	50                   	push   %eax
  800ce9:	ff d2                	call   *%edx
  800ceb:	89 c2                	mov    %eax,%edx
  800ced:	83 c4 10             	add    $0x10,%esp
  800cf0:	eb 09                	jmp    800cfb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cf2:	89 c2                	mov    %eax,%edx
  800cf4:	eb 05                	jmp    800cfb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800cf6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800cfb:	89 d0                	mov    %edx,%eax
  800cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	53                   	push   %ebx
  800d06:	83 ec 14             	sub    $0x14,%esp
  800d09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d0f:	50                   	push   %eax
  800d10:	ff 75 08             	pushl  0x8(%ebp)
  800d13:	e8 6c fb ff ff       	call   800884 <fd_lookup>
  800d18:	83 c4 08             	add    $0x8,%esp
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	78 58                	js     800d79 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d21:	83 ec 08             	sub    $0x8,%esp
  800d24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d27:	50                   	push   %eax
  800d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d2b:	ff 30                	pushl  (%eax)
  800d2d:	e8 a8 fb ff ff       	call   8008da <dev_lookup>
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 37                	js     800d70 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d40:	74 32                	je     800d74 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d42:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d45:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d4c:	00 00 00 
	stat->st_isdir = 0;
  800d4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d56:	00 00 00 
	stat->st_dev = dev;
  800d59:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d5f:	83 ec 08             	sub    $0x8,%esp
  800d62:	53                   	push   %ebx
  800d63:	ff 75 f0             	pushl  -0x10(%ebp)
  800d66:	ff 50 14             	call   *0x14(%eax)
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	eb 09                	jmp    800d79 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d70:	89 c2                	mov    %eax,%edx
  800d72:	eb 05                	jmp    800d79 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d74:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d85:	83 ec 08             	sub    $0x8,%esp
  800d88:	6a 00                	push   $0x0
  800d8a:	ff 75 08             	pushl  0x8(%ebp)
  800d8d:	e8 d6 01 00 00       	call   800f68 <open>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 1b                	js     800db6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d9b:	83 ec 08             	sub    $0x8,%esp
  800d9e:	ff 75 0c             	pushl  0xc(%ebp)
  800da1:	50                   	push   %eax
  800da2:	e8 5b ff ff ff       	call   800d02 <fstat>
  800da7:	89 c6                	mov    %eax,%esi
	close(fd);
  800da9:	89 1c 24             	mov    %ebx,(%esp)
  800dac:	e8 fd fb ff ff       	call   8009ae <close>
	return r;
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	89 f0                	mov    %esi,%eax
}
  800db6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	89 c6                	mov    %eax,%esi
  800dc4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800dc6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800dcd:	75 12                	jne    800de1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	6a 01                	push   $0x1
  800dd4:	e8 59 12 00 00       	call   802032 <ipc_find_env>
  800dd9:	a3 00 40 80 00       	mov    %eax,0x804000
  800dde:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800de1:	6a 07                	push   $0x7
  800de3:	68 00 50 80 00       	push   $0x805000
  800de8:	56                   	push   %esi
  800de9:	ff 35 00 40 80 00    	pushl  0x804000
  800def:	e8 ea 11 00 00       	call   801fde <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800df4:	83 c4 0c             	add    $0xc,%esp
  800df7:	6a 00                	push   $0x0
  800df9:	53                   	push   %ebx
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 76 11 00 00       	call   801f77 <ipc_recv>
}
  800e01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 40 0c             	mov    0xc(%eax),%eax
  800e14:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e21:	ba 00 00 00 00       	mov    $0x0,%edx
  800e26:	b8 02 00 00 00       	mov    $0x2,%eax
  800e2b:	e8 8d ff ff ff       	call   800dbd <fsipc>
}
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800e3e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	b8 06 00 00 00       	mov    $0x6,%eax
  800e4d:	e8 6b ff ff ff       	call   800dbd <fsipc>
}
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	53                   	push   %ebx
  800e58:	83 ec 04             	sub    $0x4,%esp
  800e5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	8b 40 0c             	mov    0xc(%eax),%eax
  800e64:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e73:	e8 45 ff ff ff       	call   800dbd <fsipc>
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	78 2c                	js     800ea8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	68 00 50 80 00       	push   $0x805000
  800e84:	53                   	push   %ebx
  800e85:	e8 ed f2 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e8a:	a1 80 50 80 00       	mov    0x805080,%eax
  800e8f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e95:	a1 84 50 80 00       	mov    0x805084,%eax
  800e9a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	8b 52 0c             	mov    0xc(%edx),%edx
  800ebc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800ec2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ec7:	50                   	push   %eax
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	68 08 50 80 00       	push   $0x805008
  800ed0:	e8 34 f4 ff ff       	call   800309 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800ed5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eda:	b8 04 00 00 00       	mov    $0x4,%eax
  800edf:	e8 d9 fe ff ff       	call   800dbd <fsipc>

}
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ef4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ef9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eff:	ba 00 00 00 00       	mov    $0x0,%edx
  800f04:	b8 03 00 00 00       	mov    $0x3,%eax
  800f09:	e8 af fe ff ff       	call   800dbd <fsipc>
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	85 c0                	test   %eax,%eax
  800f12:	78 4b                	js     800f5f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800f14:	39 c6                	cmp    %eax,%esi
  800f16:	73 16                	jae    800f2e <devfile_read+0x48>
  800f18:	68 0c 24 80 00       	push   $0x80240c
  800f1d:	68 13 24 80 00       	push   $0x802413
  800f22:	6a 7c                	push   $0x7c
  800f24:	68 28 24 80 00       	push   $0x802428
  800f29:	e8 24 0a 00 00       	call   801952 <_panic>
	assert(r <= PGSIZE);
  800f2e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f33:	7e 16                	jle    800f4b <devfile_read+0x65>
  800f35:	68 33 24 80 00       	push   $0x802433
  800f3a:	68 13 24 80 00       	push   $0x802413
  800f3f:	6a 7d                	push   $0x7d
  800f41:	68 28 24 80 00       	push   $0x802428
  800f46:	e8 07 0a 00 00       	call   801952 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	50                   	push   %eax
  800f4f:	68 00 50 80 00       	push   $0x805000
  800f54:	ff 75 0c             	pushl  0xc(%ebp)
  800f57:	e8 ad f3 ff ff       	call   800309 <memmove>
	return r;
  800f5c:	83 c4 10             	add    $0x10,%esp
}
  800f5f:	89 d8                	mov    %ebx,%eax
  800f61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 20             	sub    $0x20,%esp
  800f6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f72:	53                   	push   %ebx
  800f73:	e8 c6 f1 ff ff       	call   80013e <strlen>
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f80:	7f 67                	jg     800fe9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	e8 a7 f8 ff ff       	call   800835 <fd_alloc>
  800f8e:	83 c4 10             	add    $0x10,%esp
		return r;
  800f91:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 57                	js     800fee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f97:	83 ec 08             	sub    $0x8,%esp
  800f9a:	53                   	push   %ebx
  800f9b:	68 00 50 80 00       	push   $0x805000
  800fa0:	e8 d2 f1 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800fad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb5:	e8 03 fe ff ff       	call   800dbd <fsipc>
  800fba:	89 c3                	mov    %eax,%ebx
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	79 14                	jns    800fd7 <open+0x6f>
		fd_close(fd, 0);
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	6a 00                	push   $0x0
  800fc8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcb:	e8 5d f9 ff ff       	call   80092d <fd_close>
		return r;
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	89 da                	mov    %ebx,%edx
  800fd5:	eb 17                	jmp    800fee <open+0x86>
	}

	return fd2num(fd);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdd:	e8 2c f8 ff ff       	call   80080e <fd2num>
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	eb 05                	jmp    800fee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800fe9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800fee:	89 d0                	mov    %edx,%eax
  800ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ffb:	ba 00 00 00 00       	mov    $0x0,%edx
  801000:	b8 08 00 00 00       	mov    $0x8,%eax
  801005:	e8 b3 fd ff ff       	call   800dbd <fsipc>
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801012:	68 3f 24 80 00       	push   $0x80243f
  801017:	ff 75 0c             	pushl  0xc(%ebp)
  80101a:	e8 58 f1 ff ff       	call   800177 <strcpy>
	return 0;
}
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 10             	sub    $0x10,%esp
  80102d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801030:	53                   	push   %ebx
  801031:	e8 35 10 00 00       	call   80206b <pageref>
  801036:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80103e:	83 f8 01             	cmp    $0x1,%eax
  801041:	75 10                	jne    801053 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 73 0c             	pushl  0xc(%ebx)
  801049:	e8 c0 02 00 00       	call   80130e <nsipc_close>
  80104e:	89 c2                	mov    %eax,%edx
  801050:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801053:	89 d0                	mov    %edx,%eax
  801055:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801060:	6a 00                	push   $0x0
  801062:	ff 75 10             	pushl  0x10(%ebp)
  801065:	ff 75 0c             	pushl  0xc(%ebp)
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	ff 70 0c             	pushl  0xc(%eax)
  80106e:	e8 78 03 00 00       	call   8013eb <nsipc_send>
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80107b:	6a 00                	push   $0x0
  80107d:	ff 75 10             	pushl  0x10(%ebp)
  801080:	ff 75 0c             	pushl  0xc(%ebp)
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	ff 70 0c             	pushl  0xc(%eax)
  801089:	e8 f1 02 00 00       	call   80137f <nsipc_recv>
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801096:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801099:	52                   	push   %edx
  80109a:	50                   	push   %eax
  80109b:	e8 e4 f7 ff ff       	call   800884 <fd_lookup>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 17                	js     8010be <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8010a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010aa:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8010b0:	39 08                	cmp    %ecx,(%eax)
  8010b2:	75 05                	jne    8010b9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8010b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8010b7:	eb 05                	jmp    8010be <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8010b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 1c             	sub    $0x1c,%esp
  8010c8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8010ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cd:	50                   	push   %eax
  8010ce:	e8 62 f7 ff ff       	call   800835 <fd_alloc>
  8010d3:	89 c3                	mov    %eax,%ebx
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 1b                	js     8010f7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	68 07 04 00 00       	push   $0x407
  8010e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8010e7:	6a 00                	push   $0x0
  8010e9:	e8 8c f4 ff ff       	call   80057a <sys_page_alloc>
  8010ee:	89 c3                	mov    %eax,%ebx
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 10                	jns    801107 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	56                   	push   %esi
  8010fb:	e8 0e 02 00 00       	call   80130e <nsipc_close>
		return r;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	89 d8                	mov    %ebx,%eax
  801105:	eb 24                	jmp    80112b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801107:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80110d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801110:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801115:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80111c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	50                   	push   %eax
  801123:	e8 e6 f6 ff ff       	call   80080e <fd2num>
  801128:	83 c4 10             	add    $0x10,%esp
}
  80112b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	e8 50 ff ff ff       	call   801090 <fd2sockid>
		return r;
  801140:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801142:	85 c0                	test   %eax,%eax
  801144:	78 1f                	js     801165 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	ff 75 10             	pushl  0x10(%ebp)
  80114c:	ff 75 0c             	pushl  0xc(%ebp)
  80114f:	50                   	push   %eax
  801150:	e8 12 01 00 00       	call   801267 <nsipc_accept>
  801155:	83 c4 10             	add    $0x10,%esp
		return r;
  801158:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 07                	js     801165 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80115e:	e8 5d ff ff ff       	call   8010c0 <alloc_sockfd>
  801163:	89 c1                	mov    %eax,%ecx
}
  801165:	89 c8                	mov    %ecx,%eax
  801167:	c9                   	leave  
  801168:	c3                   	ret    

00801169 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	e8 19 ff ff ff       	call   801090 <fd2sockid>
  801177:	85 c0                	test   %eax,%eax
  801179:	78 12                	js     80118d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	ff 75 10             	pushl  0x10(%ebp)
  801181:	ff 75 0c             	pushl  0xc(%ebp)
  801184:	50                   	push   %eax
  801185:	e8 2d 01 00 00       	call   8012b7 <nsipc_bind>
  80118a:	83 c4 10             	add    $0x10,%esp
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <shutdown>:

int
shutdown(int s, int how)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801195:	8b 45 08             	mov    0x8(%ebp),%eax
  801198:	e8 f3 fe ff ff       	call   801090 <fd2sockid>
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 0f                	js     8011b0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	ff 75 0c             	pushl  0xc(%ebp)
  8011a7:	50                   	push   %eax
  8011a8:	e8 3f 01 00 00       	call   8012ec <nsipc_shutdown>
  8011ad:	83 c4 10             	add    $0x10,%esp
}
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bb:	e8 d0 fe ff ff       	call   801090 <fd2sockid>
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 12                	js     8011d6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	ff 75 10             	pushl  0x10(%ebp)
  8011ca:	ff 75 0c             	pushl  0xc(%ebp)
  8011cd:	50                   	push   %eax
  8011ce:	e8 55 01 00 00       	call   801328 <nsipc_connect>
  8011d3:	83 c4 10             	add    $0x10,%esp
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <listen>:

int
listen(int s, int backlog)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	e8 aa fe ff ff       	call   801090 <fd2sockid>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 0f                	js     8011f9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	ff 75 0c             	pushl  0xc(%ebp)
  8011f0:	50                   	push   %eax
  8011f1:	e8 67 01 00 00       	call   80135d <nsipc_listen>
  8011f6:	83 c4 10             	add    $0x10,%esp
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801201:	ff 75 10             	pushl  0x10(%ebp)
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	ff 75 08             	pushl  0x8(%ebp)
  80120a:	e8 3a 02 00 00       	call   801449 <nsipc_socket>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 05                	js     80121b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801216:	e8 a5 fe ff ff       	call   8010c0 <alloc_sockfd>
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	53                   	push   %ebx
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801226:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80122d:	75 12                	jne    801241 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80122f:	83 ec 0c             	sub    $0xc,%esp
  801232:	6a 02                	push   $0x2
  801234:	e8 f9 0d 00 00       	call   802032 <ipc_find_env>
  801239:	a3 04 40 80 00       	mov    %eax,0x804004
  80123e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801241:	6a 07                	push   $0x7
  801243:	68 00 60 80 00       	push   $0x806000
  801248:	53                   	push   %ebx
  801249:	ff 35 04 40 80 00    	pushl  0x804004
  80124f:	e8 8a 0d 00 00       	call   801fde <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801254:	83 c4 0c             	add    $0xc,%esp
  801257:	6a 00                	push   $0x0
  801259:	6a 00                	push   $0x0
  80125b:	6a 00                	push   $0x0
  80125d:	e8 15 0d 00 00       	call   801f77 <ipc_recv>
}
  801262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	56                   	push   %esi
  80126b:	53                   	push   %ebx
  80126c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
  801272:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801277:	8b 06                	mov    (%esi),%eax
  801279:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80127e:	b8 01 00 00 00       	mov    $0x1,%eax
  801283:	e8 95 ff ff ff       	call   80121d <nsipc>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 20                	js     8012ae <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	ff 35 10 60 80 00    	pushl  0x806010
  801297:	68 00 60 80 00       	push   $0x806000
  80129c:	ff 75 0c             	pushl  0xc(%ebp)
  80129f:	e8 65 f0 ff ff       	call   800309 <memmove>
		*addrlen = ret->ret_addrlen;
  8012a4:	a1 10 60 80 00       	mov    0x806010,%eax
  8012a9:	89 06                	mov    %eax,(%esi)
  8012ab:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8012ae:	89 d8                	mov    %ebx,%eax
  8012b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8012c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8012c9:	53                   	push   %ebx
  8012ca:	ff 75 0c             	pushl  0xc(%ebp)
  8012cd:	68 04 60 80 00       	push   $0x806004
  8012d2:	e8 32 f0 ff ff       	call   800309 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8012d7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8012dd:	b8 02 00 00 00       	mov    $0x2,%eax
  8012e2:	e8 36 ff ff ff       	call   80121d <nsipc>
}
  8012e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8012f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8012fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801302:	b8 03 00 00 00       	mov    $0x3,%eax
  801307:	e8 11 ff ff ff       	call   80121d <nsipc>
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <nsipc_close>:

int
nsipc_close(int s)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80131c:	b8 04 00 00 00       	mov    $0x4,%eax
  801321:	e8 f7 fe ff ff       	call   80121d <nsipc>
}
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
  801335:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80133a:	53                   	push   %ebx
  80133b:	ff 75 0c             	pushl  0xc(%ebp)
  80133e:	68 04 60 80 00       	push   $0x806004
  801343:	e8 c1 ef ff ff       	call   800309 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801348:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80134e:	b8 05 00 00 00       	mov    $0x5,%eax
  801353:	e8 c5 fe ff ff       	call   80121d <nsipc>
}
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80136b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801373:	b8 06 00 00 00       	mov    $0x6,%eax
  801378:	e8 a0 fe ff ff       	call   80121d <nsipc>
}
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80138f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801395:	8b 45 14             	mov    0x14(%ebp),%eax
  801398:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80139d:	b8 07 00 00 00       	mov    $0x7,%eax
  8013a2:	e8 76 fe ff ff       	call   80121d <nsipc>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 35                	js     8013e2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8013ad:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8013b2:	7f 04                	jg     8013b8 <nsipc_recv+0x39>
  8013b4:	39 c6                	cmp    %eax,%esi
  8013b6:	7d 16                	jge    8013ce <nsipc_recv+0x4f>
  8013b8:	68 4b 24 80 00       	push   $0x80244b
  8013bd:	68 13 24 80 00       	push   $0x802413
  8013c2:	6a 62                	push   $0x62
  8013c4:	68 60 24 80 00       	push   $0x802460
  8013c9:	e8 84 05 00 00       	call   801952 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	50                   	push   %eax
  8013d2:	68 00 60 80 00       	push   $0x806000
  8013d7:	ff 75 0c             	pushl  0xc(%ebp)
  8013da:	e8 2a ef ff ff       	call   800309 <memmove>
  8013df:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8013e2:	89 d8                	mov    %ebx,%eax
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 04             	sub    $0x4,%esp
  8013f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013fd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801403:	7e 16                	jle    80141b <nsipc_send+0x30>
  801405:	68 6c 24 80 00       	push   $0x80246c
  80140a:	68 13 24 80 00       	push   $0x802413
  80140f:	6a 6d                	push   $0x6d
  801411:	68 60 24 80 00       	push   $0x802460
  801416:	e8 37 05 00 00       	call   801952 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	53                   	push   %ebx
  80141f:	ff 75 0c             	pushl  0xc(%ebp)
  801422:	68 0c 60 80 00       	push   $0x80600c
  801427:	e8 dd ee ff ff       	call   800309 <memmove>
	nsipcbuf.send.req_size = size;
  80142c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801432:	8b 45 14             	mov    0x14(%ebp),%eax
  801435:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80143a:	b8 08 00 00 00       	mov    $0x8,%eax
  80143f:	e8 d9 fd ff ff       	call   80121d <nsipc>
}
  801444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80145f:	8b 45 10             	mov    0x10(%ebp),%eax
  801462:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801467:	b8 09 00 00 00       	mov    $0x9,%eax
  80146c:	e8 ac fd ff ff       	call   80121d <nsipc>
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80147b:	83 ec 0c             	sub    $0xc,%esp
  80147e:	ff 75 08             	pushl  0x8(%ebp)
  801481:	e8 98 f3 ff ff       	call   80081e <fd2data>
  801486:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	68 78 24 80 00       	push   $0x802478
  801490:	53                   	push   %ebx
  801491:	e8 e1 ec ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801496:	8b 46 04             	mov    0x4(%esi),%eax
  801499:	2b 06                	sub    (%esi),%eax
  80149b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8014a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014a8:	00 00 00 
	stat->st_dev = &devpipe;
  8014ab:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8014b2:	30 80 00 
	return 0;
}
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5e                   	pop    %esi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8014cb:	53                   	push   %ebx
  8014cc:	6a 00                	push   $0x0
  8014ce:	e8 2c f1 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8014d3:	89 1c 24             	mov    %ebx,(%esp)
  8014d6:	e8 43 f3 ff ff       	call   80081e <fd2data>
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	50                   	push   %eax
  8014df:	6a 00                	push   $0x0
  8014e1:	e8 19 f1 ff ff       	call   8005ff <sys_page_unmap>
}
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 1c             	sub    $0x1c,%esp
  8014f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014f7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8014f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8014fe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	ff 75 e0             	pushl  -0x20(%ebp)
  801507:	e8 5f 0b 00 00       	call   80206b <pageref>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	89 3c 24             	mov    %edi,(%esp)
  801511:	e8 55 0b 00 00       	call   80206b <pageref>
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	39 c3                	cmp    %eax,%ebx
  80151b:	0f 94 c1             	sete   %cl
  80151e:	0f b6 c9             	movzbl %cl,%ecx
  801521:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801524:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80152a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80152d:	39 ce                	cmp    %ecx,%esi
  80152f:	74 1b                	je     80154c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801531:	39 c3                	cmp    %eax,%ebx
  801533:	75 c4                	jne    8014f9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801535:	8b 42 58             	mov    0x58(%edx),%eax
  801538:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153b:	50                   	push   %eax
  80153c:	56                   	push   %esi
  80153d:	68 7f 24 80 00       	push   $0x80247f
  801542:	e8 e4 04 00 00       	call   801a2b <cprintf>
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	eb ad                	jmp    8014f9 <_pipeisclosed+0xe>
	}
}
  80154c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80154f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 28             	sub    $0x28,%esp
  801560:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801563:	56                   	push   %esi
  801564:	e8 b5 f2 ff ff       	call   80081e <fd2data>
  801569:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	bf 00 00 00 00       	mov    $0x0,%edi
  801573:	eb 4b                	jmp    8015c0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801575:	89 da                	mov    %ebx,%edx
  801577:	89 f0                	mov    %esi,%eax
  801579:	e8 6d ff ff ff       	call   8014eb <_pipeisclosed>
  80157e:	85 c0                	test   %eax,%eax
  801580:	75 48                	jne    8015ca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801582:	e8 d4 ef ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801587:	8b 43 04             	mov    0x4(%ebx),%eax
  80158a:	8b 0b                	mov    (%ebx),%ecx
  80158c:	8d 51 20             	lea    0x20(%ecx),%edx
  80158f:	39 d0                	cmp    %edx,%eax
  801591:	73 e2                	jae    801575 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801593:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801596:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80159a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	c1 fa 1f             	sar    $0x1f,%edx
  8015a2:	89 d1                	mov    %edx,%ecx
  8015a4:	c1 e9 1b             	shr    $0x1b,%ecx
  8015a7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8015aa:	83 e2 1f             	and    $0x1f,%edx
  8015ad:	29 ca                	sub    %ecx,%edx
  8015af:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8015b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015b7:	83 c0 01             	add    $0x1,%eax
  8015ba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015bd:	83 c7 01             	add    $0x1,%edi
  8015c0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015c3:	75 c2                	jne    801587 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8015c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c8:	eb 05                	jmp    8015cf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8015ca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 18             	sub    $0x18,%esp
  8015e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8015e3:	57                   	push   %edi
  8015e4:	e8 35 f2 ff ff       	call   80081e <fd2data>
  8015e9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f3:	eb 3d                	jmp    801632 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8015f5:	85 db                	test   %ebx,%ebx
  8015f7:	74 04                	je     8015fd <devpipe_read+0x26>
				return i;
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	eb 44                	jmp    801641 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8015fd:	89 f2                	mov    %esi,%edx
  8015ff:	89 f8                	mov    %edi,%eax
  801601:	e8 e5 fe ff ff       	call   8014eb <_pipeisclosed>
  801606:	85 c0                	test   %eax,%eax
  801608:	75 32                	jne    80163c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80160a:	e8 4c ef ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80160f:	8b 06                	mov    (%esi),%eax
  801611:	3b 46 04             	cmp    0x4(%esi),%eax
  801614:	74 df                	je     8015f5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801616:	99                   	cltd   
  801617:	c1 ea 1b             	shr    $0x1b,%edx
  80161a:	01 d0                	add    %edx,%eax
  80161c:	83 e0 1f             	and    $0x1f,%eax
  80161f:	29 d0                	sub    %edx,%eax
  801621:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801626:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801629:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80162c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162f:	83 c3 01             	add    $0x1,%ebx
  801632:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801635:	75 d8                	jne    80160f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801637:	8b 45 10             	mov    0x10(%ebp),%eax
  80163a:	eb 05                	jmp    801641 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5f                   	pop    %edi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	e8 db f1 ff ff       	call   800835 <fd_alloc>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	0f 88 2c 01 00 00    	js     801793 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801667:	83 ec 04             	sub    $0x4,%esp
  80166a:	68 07 04 00 00       	push   $0x407
  80166f:	ff 75 f4             	pushl  -0xc(%ebp)
  801672:	6a 00                	push   $0x0
  801674:	e8 01 ef ff ff       	call   80057a <sys_page_alloc>
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	85 c0                	test   %eax,%eax
  801680:	0f 88 0d 01 00 00    	js     801793 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	e8 a3 f1 ff ff       	call   800835 <fd_alloc>
  801692:	89 c3                	mov    %eax,%ebx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	0f 88 e2 00 00 00    	js     801781 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	68 07 04 00 00       	push   $0x407
  8016a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8016aa:	6a 00                	push   $0x0
  8016ac:	e8 c9 ee ff ff       	call   80057a <sys_page_alloc>
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	0f 88 c3 00 00 00    	js     801781 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c4:	e8 55 f1 ff ff       	call   80081e <fd2data>
  8016c9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016cb:	83 c4 0c             	add    $0xc,%esp
  8016ce:	68 07 04 00 00       	push   $0x407
  8016d3:	50                   	push   %eax
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 9f ee ff ff       	call   80057a <sys_page_alloc>
  8016db:	89 c3                	mov    %eax,%ebx
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	0f 88 89 00 00 00    	js     801771 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ee:	e8 2b f1 ff ff       	call   80081e <fd2data>
  8016f3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8016fa:	50                   	push   %eax
  8016fb:	6a 00                	push   $0x0
  8016fd:	56                   	push   %esi
  8016fe:	6a 00                	push   $0x0
  801700:	e8 b8 ee ff ff       	call   8005bd <sys_page_map>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	83 c4 20             	add    $0x20,%esp
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 55                	js     801763 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80170e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801717:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801723:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80172e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801731:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801738:	83 ec 0c             	sub    $0xc,%esp
  80173b:	ff 75 f4             	pushl  -0xc(%ebp)
  80173e:	e8 cb f0 ff ff       	call   80080e <fd2num>
  801743:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801746:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801748:	83 c4 04             	add    $0x4,%esp
  80174b:	ff 75 f0             	pushl  -0x10(%ebp)
  80174e:	e8 bb f0 ff ff       	call   80080e <fd2num>
  801753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801756:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	ba 00 00 00 00       	mov    $0x0,%edx
  801761:	eb 30                	jmp    801793 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	56                   	push   %esi
  801767:	6a 00                	push   $0x0
  801769:	e8 91 ee ff ff       	call   8005ff <sys_page_unmap>
  80176e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	ff 75 f0             	pushl  -0x10(%ebp)
  801777:	6a 00                	push   $0x0
  801779:	e8 81 ee ff ff       	call   8005ff <sys_page_unmap>
  80177e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801781:	83 ec 08             	sub    $0x8,%esp
  801784:	ff 75 f4             	pushl  -0xc(%ebp)
  801787:	6a 00                	push   $0x0
  801789:	e8 71 ee ff ff       	call   8005ff <sys_page_unmap>
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801793:	89 d0                	mov    %edx,%eax
  801795:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	ff 75 08             	pushl  0x8(%ebp)
  8017a9:	e8 d6 f0 ff ff       	call   800884 <fd_lookup>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 18                	js     8017cd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bb:	e8 5e f0 ff ff       	call   80081e <fd2data>
	return _pipeisclosed(fd, p);
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c5:	e8 21 fd ff ff       	call   8014eb <_pipeisclosed>
  8017ca:	83 c4 10             	add    $0x10,%esp
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8017d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8017df:	68 97 24 80 00       	push   $0x802497
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	e8 8b e9 ff ff       	call   800177 <strcpy>
	return 0;
}
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	57                   	push   %edi
  8017f7:	56                   	push   %esi
  8017f8:	53                   	push   %ebx
  8017f9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017ff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801804:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80180a:	eb 2d                	jmp    801839 <devcons_write+0x46>
		m = n - tot;
  80180c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80180f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801811:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801814:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801819:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	53                   	push   %ebx
  801820:	03 45 0c             	add    0xc(%ebp),%eax
  801823:	50                   	push   %eax
  801824:	57                   	push   %edi
  801825:	e8 df ea ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  80182a:	83 c4 08             	add    $0x8,%esp
  80182d:	53                   	push   %ebx
  80182e:	57                   	push   %edi
  80182f:	e8 8a ec ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801834:	01 de                	add    %ebx,%esi
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	89 f0                	mov    %esi,%eax
  80183b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80183e:	72 cc                	jb     80180c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801840:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5f                   	pop    %edi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801853:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801857:	74 2a                	je     801883 <devcons_read+0x3b>
  801859:	eb 05                	jmp    801860 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80185b:	e8 fb ec ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801860:	e8 77 ec ff ff       	call   8004dc <sys_cgetc>
  801865:	85 c0                	test   %eax,%eax
  801867:	74 f2                	je     80185b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 16                	js     801883 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80186d:	83 f8 04             	cmp    $0x4,%eax
  801870:	74 0c                	je     80187e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801872:	8b 55 0c             	mov    0xc(%ebp),%edx
  801875:	88 02                	mov    %al,(%edx)
	return 1;
  801877:	b8 01 00 00 00       	mov    $0x1,%eax
  80187c:	eb 05                	jmp    801883 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80187e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801891:	6a 01                	push   $0x1
  801893:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801896:	50                   	push   %eax
  801897:	e8 22 ec ff ff       	call   8004be <sys_cputs>
}
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <getchar>:

int
getchar(void)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8018a7:	6a 01                	push   $0x1
  8018a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	6a 00                	push   $0x0
  8018af:	e8 36 f2 ff ff       	call   800aea <read>
	if (r < 0)
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 0f                	js     8018ca <getchar+0x29>
		return r;
	if (r < 1)
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	7e 06                	jle    8018c5 <getchar+0x24>
		return -E_EOF;
	return c;
  8018bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8018c3:	eb 05                	jmp    8018ca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8018c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	ff 75 08             	pushl  0x8(%ebp)
  8018d9:	e8 a6 ef ff ff       	call   800884 <fd_lookup>
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 11                	js     8018f6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018ee:	39 10                	cmp    %edx,(%eax)
  8018f0:	0f 94 c0             	sete   %al
  8018f3:	0f b6 c0             	movzbl %al,%eax
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <opencons>:

int
opencons(void)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8018fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801901:	50                   	push   %eax
  801902:	e8 2e ef ff ff       	call   800835 <fd_alloc>
  801907:	83 c4 10             	add    $0x10,%esp
		return r;
  80190a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 3e                	js     80194e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801910:	83 ec 04             	sub    $0x4,%esp
  801913:	68 07 04 00 00       	push   $0x407
  801918:	ff 75 f4             	pushl  -0xc(%ebp)
  80191b:	6a 00                	push   $0x0
  80191d:	e8 58 ec ff ff       	call   80057a <sys_page_alloc>
  801922:	83 c4 10             	add    $0x10,%esp
		return r;
  801925:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801927:	85 c0                	test   %eax,%eax
  801929:	78 23                	js     80194e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80192b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801934:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801939:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801940:	83 ec 0c             	sub    $0xc,%esp
  801943:	50                   	push   %eax
  801944:	e8 c5 ee ff ff       	call   80080e <fd2num>
  801949:	89 c2                	mov    %eax,%edx
  80194b:	83 c4 10             	add    $0x10,%esp
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801957:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80195a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801960:	e8 d7 eb ff ff       	call   80053c <sys_getenvid>
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	ff 75 0c             	pushl  0xc(%ebp)
  80196b:	ff 75 08             	pushl  0x8(%ebp)
  80196e:	56                   	push   %esi
  80196f:	50                   	push   %eax
  801970:	68 a4 24 80 00       	push   $0x8024a4
  801975:	e8 b1 00 00 00       	call   801a2b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80197a:	83 c4 18             	add    $0x18,%esp
  80197d:	53                   	push   %ebx
  80197e:	ff 75 10             	pushl  0x10(%ebp)
  801981:	e8 54 00 00 00       	call   8019da <vcprintf>
	cprintf("\n");
  801986:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  80198d:	e8 99 00 00 00       	call   801a2b <cprintf>
  801992:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801995:	cc                   	int3   
  801996:	eb fd                	jmp    801995 <_panic+0x43>

00801998 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	53                   	push   %ebx
  80199c:	83 ec 04             	sub    $0x4,%esp
  80199f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019a2:	8b 13                	mov    (%ebx),%edx
  8019a4:	8d 42 01             	lea    0x1(%edx),%eax
  8019a7:	89 03                	mov    %eax,(%ebx)
  8019a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019b5:	75 1a                	jne    8019d1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	68 ff 00 00 00       	push   $0xff
  8019bf:	8d 43 08             	lea    0x8(%ebx),%eax
  8019c2:	50                   	push   %eax
  8019c3:	e8 f6 ea ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  8019c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019ce:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8019d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8019d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8019e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019ea:	00 00 00 
	b.cnt = 0;
  8019ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8019f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a03:	50                   	push   %eax
  801a04:	68 98 19 80 00       	push   $0x801998
  801a09:	e8 54 01 00 00       	call   801b62 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a0e:	83 c4 08             	add    $0x8,%esp
  801a11:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a17:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	e8 9b ea ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  801a23:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a31:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a34:	50                   	push   %eax
  801a35:	ff 75 08             	pushl  0x8(%ebp)
  801a38:	e8 9d ff ff ff       	call   8019da <vcprintf>
	va_end(ap);

	return cnt;
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
  801a48:	89 c7                	mov    %eax,%edi
  801a4a:	89 d6                	mov    %edx,%esi
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a55:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a60:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a63:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a66:	39 d3                	cmp    %edx,%ebx
  801a68:	72 05                	jb     801a6f <printnum+0x30>
  801a6a:	39 45 10             	cmp    %eax,0x10(%ebp)
  801a6d:	77 45                	ja     801ab4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	ff 75 18             	pushl  0x18(%ebp)
  801a75:	8b 45 14             	mov    0x14(%ebp),%eax
  801a78:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801a7b:	53                   	push   %ebx
  801a7c:	ff 75 10             	pushl  0x10(%ebp)
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a85:	ff 75 e0             	pushl  -0x20(%ebp)
  801a88:	ff 75 dc             	pushl  -0x24(%ebp)
  801a8b:	ff 75 d8             	pushl  -0x28(%ebp)
  801a8e:	e8 1d 06 00 00       	call   8020b0 <__udivdi3>
  801a93:	83 c4 18             	add    $0x18,%esp
  801a96:	52                   	push   %edx
  801a97:	50                   	push   %eax
  801a98:	89 f2                	mov    %esi,%edx
  801a9a:	89 f8                	mov    %edi,%eax
  801a9c:	e8 9e ff ff ff       	call   801a3f <printnum>
  801aa1:	83 c4 20             	add    $0x20,%esp
  801aa4:	eb 18                	jmp    801abe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	56                   	push   %esi
  801aaa:	ff 75 18             	pushl  0x18(%ebp)
  801aad:	ff d7                	call   *%edi
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	eb 03                	jmp    801ab7 <printnum+0x78>
  801ab4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801ab7:	83 eb 01             	sub    $0x1,%ebx
  801aba:	85 db                	test   %ebx,%ebx
  801abc:	7f e8                	jg     801aa6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	56                   	push   %esi
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac8:	ff 75 e0             	pushl  -0x20(%ebp)
  801acb:	ff 75 dc             	pushl  -0x24(%ebp)
  801ace:	ff 75 d8             	pushl  -0x28(%ebp)
  801ad1:	e8 0a 07 00 00       	call   8021e0 <__umoddi3>
  801ad6:	83 c4 14             	add    $0x14,%esp
  801ad9:	0f be 80 c7 24 80 00 	movsbl 0x8024c7(%eax),%eax
  801ae0:	50                   	push   %eax
  801ae1:	ff d7                	call   *%edi
}
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801af1:	83 fa 01             	cmp    $0x1,%edx
  801af4:	7e 0e                	jle    801b04 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801af6:	8b 10                	mov    (%eax),%edx
  801af8:	8d 4a 08             	lea    0x8(%edx),%ecx
  801afb:	89 08                	mov    %ecx,(%eax)
  801afd:	8b 02                	mov    (%edx),%eax
  801aff:	8b 52 04             	mov    0x4(%edx),%edx
  801b02:	eb 22                	jmp    801b26 <getuint+0x38>
	else if (lflag)
  801b04:	85 d2                	test   %edx,%edx
  801b06:	74 10                	je     801b18 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b08:	8b 10                	mov    (%eax),%edx
  801b0a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b0d:	89 08                	mov    %ecx,(%eax)
  801b0f:	8b 02                	mov    (%edx),%eax
  801b11:	ba 00 00 00 00       	mov    $0x0,%edx
  801b16:	eb 0e                	jmp    801b26 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b18:	8b 10                	mov    (%eax),%edx
  801b1a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b1d:	89 08                	mov    %ecx,(%eax)
  801b1f:	8b 02                	mov    (%edx),%eax
  801b21:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b2e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b32:	8b 10                	mov    (%eax),%edx
  801b34:	3b 50 04             	cmp    0x4(%eax),%edx
  801b37:	73 0a                	jae    801b43 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b39:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b3c:	89 08                	mov    %ecx,(%eax)
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	88 02                	mov    %al,(%edx)
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b4b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b4e:	50                   	push   %eax
  801b4f:	ff 75 10             	pushl  0x10(%ebp)
  801b52:	ff 75 0c             	pushl  0xc(%ebp)
  801b55:	ff 75 08             	pushl  0x8(%ebp)
  801b58:	e8 05 00 00 00       	call   801b62 <vprintfmt>
	va_end(ap);
}
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 2c             	sub    $0x2c,%esp
  801b6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b71:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b74:	eb 12                	jmp    801b88 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 84 89 03 00 00    	je     801f07 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801b7e:	83 ec 08             	sub    $0x8,%esp
  801b81:	53                   	push   %ebx
  801b82:	50                   	push   %eax
  801b83:	ff d6                	call   *%esi
  801b85:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b88:	83 c7 01             	add    $0x1,%edi
  801b8b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b8f:	83 f8 25             	cmp    $0x25,%eax
  801b92:	75 e2                	jne    801b76 <vprintfmt+0x14>
  801b94:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b98:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b9f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ba6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801bad:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb2:	eb 07                	jmp    801bbb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801bb7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bbb:	8d 47 01             	lea    0x1(%edi),%eax
  801bbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bc1:	0f b6 07             	movzbl (%edi),%eax
  801bc4:	0f b6 c8             	movzbl %al,%ecx
  801bc7:	83 e8 23             	sub    $0x23,%eax
  801bca:	3c 55                	cmp    $0x55,%al
  801bcc:	0f 87 1a 03 00 00    	ja     801eec <vprintfmt+0x38a>
  801bd2:	0f b6 c0             	movzbl %al,%eax
  801bd5:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  801bdc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801bdf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801be3:	eb d6                	jmp    801bbb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801bf0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801bf3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801bf7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801bfa:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801bfd:	83 fa 09             	cmp    $0x9,%edx
  801c00:	77 39                	ja     801c3b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c02:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c05:	eb e9                	jmp    801bf0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c07:	8b 45 14             	mov    0x14(%ebp),%eax
  801c0a:	8d 48 04             	lea    0x4(%eax),%ecx
  801c0d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c10:	8b 00                	mov    (%eax),%eax
  801c12:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c18:	eb 27                	jmp    801c41 <vprintfmt+0xdf>
  801c1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c24:	0f 49 c8             	cmovns %eax,%ecx
  801c27:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c2d:	eb 8c                	jmp    801bbb <vprintfmt+0x59>
  801c2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c32:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c39:	eb 80                	jmp    801bbb <vprintfmt+0x59>
  801c3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c3e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c45:	0f 89 70 ff ff ff    	jns    801bbb <vprintfmt+0x59>
				width = precision, precision = -1;
  801c4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c51:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c58:	e9 5e ff ff ff       	jmp    801bbb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c5d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c63:	e9 53 ff ff ff       	jmp    801bbb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c68:	8b 45 14             	mov    0x14(%ebp),%eax
  801c6b:	8d 50 04             	lea    0x4(%eax),%edx
  801c6e:	89 55 14             	mov    %edx,0x14(%ebp)
  801c71:	83 ec 08             	sub    $0x8,%esp
  801c74:	53                   	push   %ebx
  801c75:	ff 30                	pushl  (%eax)
  801c77:	ff d6                	call   *%esi
			break;
  801c79:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c7f:	e9 04 ff ff ff       	jmp    801b88 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c84:	8b 45 14             	mov    0x14(%ebp),%eax
  801c87:	8d 50 04             	lea    0x4(%eax),%edx
  801c8a:	89 55 14             	mov    %edx,0x14(%ebp)
  801c8d:	8b 00                	mov    (%eax),%eax
  801c8f:	99                   	cltd   
  801c90:	31 d0                	xor    %edx,%eax
  801c92:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c94:	83 f8 0f             	cmp    $0xf,%eax
  801c97:	7f 0b                	jg     801ca4 <vprintfmt+0x142>
  801c99:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  801ca0:	85 d2                	test   %edx,%edx
  801ca2:	75 18                	jne    801cbc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801ca4:	50                   	push   %eax
  801ca5:	68 df 24 80 00       	push   $0x8024df
  801caa:	53                   	push   %ebx
  801cab:	56                   	push   %esi
  801cac:	e8 94 fe ff ff       	call   801b45 <printfmt>
  801cb1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cb7:	e9 cc fe ff ff       	jmp    801b88 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cbc:	52                   	push   %edx
  801cbd:	68 25 24 80 00       	push   $0x802425
  801cc2:	53                   	push   %ebx
  801cc3:	56                   	push   %esi
  801cc4:	e8 7c fe ff ff       	call   801b45 <printfmt>
  801cc9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ccc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ccf:	e9 b4 fe ff ff       	jmp    801b88 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801cd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd7:	8d 50 04             	lea    0x4(%eax),%edx
  801cda:	89 55 14             	mov    %edx,0x14(%ebp)
  801cdd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801cdf:	85 ff                	test   %edi,%edi
  801ce1:	b8 d8 24 80 00       	mov    $0x8024d8,%eax
  801ce6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ce9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ced:	0f 8e 94 00 00 00    	jle    801d87 <vprintfmt+0x225>
  801cf3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801cf7:	0f 84 98 00 00 00    	je     801d95 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801cfd:	83 ec 08             	sub    $0x8,%esp
  801d00:	ff 75 d0             	pushl  -0x30(%ebp)
  801d03:	57                   	push   %edi
  801d04:	e8 4d e4 ff ff       	call   800156 <strnlen>
  801d09:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d0c:	29 c1                	sub    %eax,%ecx
  801d0e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d11:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d14:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d1b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d1e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d20:	eb 0f                	jmp    801d31 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d22:	83 ec 08             	sub    $0x8,%esp
  801d25:	53                   	push   %ebx
  801d26:	ff 75 e0             	pushl  -0x20(%ebp)
  801d29:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d2b:	83 ef 01             	sub    $0x1,%edi
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 ff                	test   %edi,%edi
  801d33:	7f ed                	jg     801d22 <vprintfmt+0x1c0>
  801d35:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d38:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d3b:	85 c9                	test   %ecx,%ecx
  801d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d42:	0f 49 c1             	cmovns %ecx,%eax
  801d45:	29 c1                	sub    %eax,%ecx
  801d47:	89 75 08             	mov    %esi,0x8(%ebp)
  801d4a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d4d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d50:	89 cb                	mov    %ecx,%ebx
  801d52:	eb 4d                	jmp    801da1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d54:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d58:	74 1b                	je     801d75 <vprintfmt+0x213>
  801d5a:	0f be c0             	movsbl %al,%eax
  801d5d:	83 e8 20             	sub    $0x20,%eax
  801d60:	83 f8 5e             	cmp    $0x5e,%eax
  801d63:	76 10                	jbe    801d75 <vprintfmt+0x213>
					putch('?', putdat);
  801d65:	83 ec 08             	sub    $0x8,%esp
  801d68:	ff 75 0c             	pushl  0xc(%ebp)
  801d6b:	6a 3f                	push   $0x3f
  801d6d:	ff 55 08             	call   *0x8(%ebp)
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	eb 0d                	jmp    801d82 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801d75:	83 ec 08             	sub    $0x8,%esp
  801d78:	ff 75 0c             	pushl  0xc(%ebp)
  801d7b:	52                   	push   %edx
  801d7c:	ff 55 08             	call   *0x8(%ebp)
  801d7f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d82:	83 eb 01             	sub    $0x1,%ebx
  801d85:	eb 1a                	jmp    801da1 <vprintfmt+0x23f>
  801d87:	89 75 08             	mov    %esi,0x8(%ebp)
  801d8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d90:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d93:	eb 0c                	jmp    801da1 <vprintfmt+0x23f>
  801d95:	89 75 08             	mov    %esi,0x8(%ebp)
  801d98:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d9b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d9e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801da1:	83 c7 01             	add    $0x1,%edi
  801da4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801da8:	0f be d0             	movsbl %al,%edx
  801dab:	85 d2                	test   %edx,%edx
  801dad:	74 23                	je     801dd2 <vprintfmt+0x270>
  801daf:	85 f6                	test   %esi,%esi
  801db1:	78 a1                	js     801d54 <vprintfmt+0x1f2>
  801db3:	83 ee 01             	sub    $0x1,%esi
  801db6:	79 9c                	jns    801d54 <vprintfmt+0x1f2>
  801db8:	89 df                	mov    %ebx,%edi
  801dba:	8b 75 08             	mov    0x8(%ebp),%esi
  801dbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dc0:	eb 18                	jmp    801dda <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801dc2:	83 ec 08             	sub    $0x8,%esp
  801dc5:	53                   	push   %ebx
  801dc6:	6a 20                	push   $0x20
  801dc8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801dca:	83 ef 01             	sub    $0x1,%edi
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	eb 08                	jmp    801dda <vprintfmt+0x278>
  801dd2:	89 df                	mov    %ebx,%edi
  801dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dda:	85 ff                	test   %edi,%edi
  801ddc:	7f e4                	jg     801dc2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801de1:	e9 a2 fd ff ff       	jmp    801b88 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801de6:	83 fa 01             	cmp    $0x1,%edx
  801de9:	7e 16                	jle    801e01 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801deb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dee:	8d 50 08             	lea    0x8(%eax),%edx
  801df1:	89 55 14             	mov    %edx,0x14(%ebp)
  801df4:	8b 50 04             	mov    0x4(%eax),%edx
  801df7:	8b 00                	mov    (%eax),%eax
  801df9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dfc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801dff:	eb 32                	jmp    801e33 <vprintfmt+0x2d1>
	else if (lflag)
  801e01:	85 d2                	test   %edx,%edx
  801e03:	74 18                	je     801e1d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e05:	8b 45 14             	mov    0x14(%ebp),%eax
  801e08:	8d 50 04             	lea    0x4(%eax),%edx
  801e0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e0e:	8b 00                	mov    (%eax),%eax
  801e10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e13:	89 c1                	mov    %eax,%ecx
  801e15:	c1 f9 1f             	sar    $0x1f,%ecx
  801e18:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e1b:	eb 16                	jmp    801e33 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e20:	8d 50 04             	lea    0x4(%eax),%edx
  801e23:	89 55 14             	mov    %edx,0x14(%ebp)
  801e26:	8b 00                	mov    (%eax),%eax
  801e28:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e2b:	89 c1                	mov    %eax,%ecx
  801e2d:	c1 f9 1f             	sar    $0x1f,%ecx
  801e30:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e36:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e39:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e42:	79 74                	jns    801eb8 <vprintfmt+0x356>
				putch('-', putdat);
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	53                   	push   %ebx
  801e48:	6a 2d                	push   $0x2d
  801e4a:	ff d6                	call   *%esi
				num = -(long long) num;
  801e4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e52:	f7 d8                	neg    %eax
  801e54:	83 d2 00             	adc    $0x0,%edx
  801e57:	f7 da                	neg    %edx
  801e59:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e5c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e61:	eb 55                	jmp    801eb8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e63:	8d 45 14             	lea    0x14(%ebp),%eax
  801e66:	e8 83 fc ff ff       	call   801aee <getuint>
			base = 10;
  801e6b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801e70:	eb 46                	jmp    801eb8 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801e72:	8d 45 14             	lea    0x14(%ebp),%eax
  801e75:	e8 74 fc ff ff       	call   801aee <getuint>
			base = 8;
  801e7a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801e7f:	eb 37                	jmp    801eb8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801e81:	83 ec 08             	sub    $0x8,%esp
  801e84:	53                   	push   %ebx
  801e85:	6a 30                	push   $0x30
  801e87:	ff d6                	call   *%esi
			putch('x', putdat);
  801e89:	83 c4 08             	add    $0x8,%esp
  801e8c:	53                   	push   %ebx
  801e8d:	6a 78                	push   $0x78
  801e8f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801e91:	8b 45 14             	mov    0x14(%ebp),%eax
  801e94:	8d 50 04             	lea    0x4(%eax),%edx
  801e97:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801e9a:	8b 00                	mov    (%eax),%eax
  801e9c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ea1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ea4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ea9:	eb 0d                	jmp    801eb8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801eab:	8d 45 14             	lea    0x14(%ebp),%eax
  801eae:	e8 3b fc ff ff       	call   801aee <getuint>
			base = 16;
  801eb3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801eb8:	83 ec 0c             	sub    $0xc,%esp
  801ebb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ebf:	57                   	push   %edi
  801ec0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ec3:	51                   	push   %ecx
  801ec4:	52                   	push   %edx
  801ec5:	50                   	push   %eax
  801ec6:	89 da                	mov    %ebx,%edx
  801ec8:	89 f0                	mov    %esi,%eax
  801eca:	e8 70 fb ff ff       	call   801a3f <printnum>
			break;
  801ecf:	83 c4 20             	add    $0x20,%esp
  801ed2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ed5:	e9 ae fc ff ff       	jmp    801b88 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801eda:	83 ec 08             	sub    $0x8,%esp
  801edd:	53                   	push   %ebx
  801ede:	51                   	push   %ecx
  801edf:	ff d6                	call   *%esi
			break;
  801ee1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ee4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ee7:	e9 9c fc ff ff       	jmp    801b88 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801eec:	83 ec 08             	sub    $0x8,%esp
  801eef:	53                   	push   %ebx
  801ef0:	6a 25                	push   $0x25
  801ef2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	eb 03                	jmp    801efc <vprintfmt+0x39a>
  801ef9:	83 ef 01             	sub    $0x1,%edi
  801efc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f00:	75 f7                	jne    801ef9 <vprintfmt+0x397>
  801f02:	e9 81 fc ff ff       	jmp    801b88 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 18             	sub    $0x18,%esp
  801f15:	8b 45 08             	mov    0x8(%ebp),%eax
  801f18:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f1e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f22:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	74 26                	je     801f56 <vsnprintf+0x47>
  801f30:	85 d2                	test   %edx,%edx
  801f32:	7e 22                	jle    801f56 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f34:	ff 75 14             	pushl  0x14(%ebp)
  801f37:	ff 75 10             	pushl  0x10(%ebp)
  801f3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f3d:	50                   	push   %eax
  801f3e:	68 28 1b 80 00       	push   $0x801b28
  801f43:	e8 1a fc ff ff       	call   801b62 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	eb 05                	jmp    801f5b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f63:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f66:	50                   	push   %eax
  801f67:	ff 75 10             	pushl  0x10(%ebp)
  801f6a:	ff 75 0c             	pushl  0xc(%ebp)
  801f6d:	ff 75 08             	pushl  0x8(%ebp)
  801f70:	e8 9a ff ff ff       	call   801f0f <vsnprintf>
	va_end(ap);

	return rc;
}
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	56                   	push   %esi
  801f7b:	53                   	push   %ebx
  801f7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f85:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f87:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f8c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f8f:	83 ec 0c             	sub    $0xc,%esp
  801f92:	50                   	push   %eax
  801f93:	e8 92 e7 ff ff       	call   80072a <sys_ipc_recv>

	if (from_env_store != NULL)
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 f6                	test   %esi,%esi
  801f9d:	74 14                	je     801fb3 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 09                	js     801fb1 <ipc_recv+0x3a>
  801fa8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fae:	8b 52 74             	mov    0x74(%edx),%edx
  801fb1:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801fb3:	85 db                	test   %ebx,%ebx
  801fb5:	74 14                	je     801fcb <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 09                	js     801fc9 <ipc_recv+0x52>
  801fc0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fc6:	8b 52 78             	mov    0x78(%edx),%edx
  801fc9:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	78 08                	js     801fd7 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801fcf:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fda:	5b                   	pop    %ebx
  801fdb:	5e                   	pop    %esi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fea:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801ff0:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ff2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff7:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ffa:	ff 75 14             	pushl  0x14(%ebp)
  801ffd:	53                   	push   %ebx
  801ffe:	56                   	push   %esi
  801fff:	57                   	push   %edi
  802000:	e8 02 e7 ff ff       	call   800707 <sys_ipc_try_send>

		if (err < 0) {
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	79 1e                	jns    80202a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80200c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200f:	75 07                	jne    802018 <ipc_send+0x3a>
				sys_yield();
  802011:	e8 45 e5 ff ff       	call   80055b <sys_yield>
  802016:	eb e2                	jmp    801ffa <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802018:	50                   	push   %eax
  802019:	68 c0 27 80 00       	push   $0x8027c0
  80201e:	6a 49                	push   $0x49
  802020:	68 cd 27 80 00       	push   $0x8027cd
  802025:	e8 28 f9 ff ff       	call   801952 <_panic>
		}

	} while (err < 0);

}
  80202a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802040:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802046:	8b 52 50             	mov    0x50(%edx),%edx
  802049:	39 ca                	cmp    %ecx,%edx
  80204b:	75 0d                	jne    80205a <ipc_find_env+0x28>
			return envs[i].env_id;
  80204d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802050:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802055:	8b 40 48             	mov    0x48(%eax),%eax
  802058:	eb 0f                	jmp    802069 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205a:	83 c0 01             	add    $0x1,%eax
  80205d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802062:	75 d9                	jne    80203d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802064:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802071:	89 d0                	mov    %edx,%eax
  802073:	c1 e8 16             	shr    $0x16,%eax
  802076:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802082:	f6 c1 01             	test   $0x1,%cl
  802085:	74 1d                	je     8020a4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802087:	c1 ea 0c             	shr    $0xc,%edx
  80208a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802091:	f6 c2 01             	test   $0x1,%dl
  802094:	74 0e                	je     8020a4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802096:	c1 ea 0c             	shr    $0xc,%edx
  802099:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a0:	ef 
  8020a1:	0f b7 c0             	movzwl %ax,%eax
}
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
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
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
