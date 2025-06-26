      SUBROUTINE BU_NEW_NAMES(BU, NAME, FNAME)
      IMPLICIT INTEGER(A - P, R - Z)
      IMPLICIT LOGICAL(Q)
C using real virtual memory allocation
      COMMON/MEMORY/ME_MEM(0:0)
C dynamic memory
      INTEGER ME_MEM
C string buffer
      BYTE ST_BUFFER(0:0)
C text buffer
      BYTE TX_TEXT(0:0)
      EQUIVALENCE(ME_MEM, ST_BUFFER), (ME_MEM, TX_TEXT)
      COMMON/SESSION/SE_SAVE, SE_RESTORE, SE_MACROS, SE_BUFFERS, SE_CURR
     *ENT_WINDOW, SE_PAGES, SE_CURRENT_PAGE, SE_COMMAND_COUNT, SE_COUNT,
     * SE_DEFAULT_CASE, SE_INDENT, SE_SEARCH_STRING, SE_SEARCH_MASK, SE_
     *SEARCH_LENGTH, SE_ERROR_OCCURRED, SE_INTERRUPT_ENABLED, SE_IN_PROM
     *PT, SE_CROSS_LINES, SE_RECOVER, SE_WORD_DEFINITION( - 128:127, 0:1
     *0)
      LOGICAL*1SE_ERROR_OCCURRED, SE_INTERRUPT_ENABLED, SE_IN_PROMPT, SE
     *_CROSS_LINES, SE_RECOVER
      BYTE SE_WORD_DEFINITION
      BYTE NAME(1), FNAME(1), NUM(14), HO_CLOWER
      OLD = ME_MEM(2 + BU)
      ME_MEM(2 + BU) = 0
      CALL ST_DEALLOCATE(ME_MEM(3 + BU))
      IF (NAME(1) .NE. 0) THEN
        ST = ST_ALLOCATE(HO_LENGTH(NAME) + 1)
        CALL HO_SCOPY(NAME, 1, ST_BUFFER(ST), 1)
        I = ST
        DO WHILE (ST_BUFFER(I) .NE. 0)
          ST_BUFFER(I) = HO_CLOWER(ST_BUFFER(I))
2300      I = I + 1
        END DO
      ELSE
        ST = BU_MAKE_NAME(FNAME)
      END IF
      IF (FNAME(1) .NE. 0) THEN
        ME_MEM(3 + BU) = ST_ALLOCATE(HO_LENGTH(FNAME) + 1)
        CALL HO_SCOPY(FNAME, 1, ST_BUFFER(ME_MEM(3 + BU)), 1)
      ELSE
        ME_MEM(3 + BU) = 0
      END IF
      SL = ST_LENGTH(ST)
      N = 2
      DO WHILE (BU_FIND_BY_NAME(ST_BUFFER(ST)) .NE. 0)
        NL = HO_ITOC(N, NUM(2), 12)
        NUM(1) = '<'
        NUM(2 + NL) = '>'
        NUM(3 + NL) = 0
        ST2 = ST_ALLOCATE(3 + NL + SL)
        CALL ST_SCOPY(ST, ST2)
        CALL HO_SCOPY(NUM, 1, ST_BUFFER(ST2 + SL), 1)
        CALL ST_DEALLOCATE(ST)
        ST = ST2
2330    N = N + 1
      END DO
      ME_MEM(2 + BU) = ST
      IF (OLD .NE. 0) THEN
C update old pointers
        PA = SE_PAGES
        DO WHILE (PA .NE. 0)
          WI = ME_MEM(2 + PA)
          DO WHILE (WI .NE. 0)
            IF (ME_MEM(6+WI) .EQ. OLD) THEN
              ME_MEM(6 + WI) = ME_MEM(2 + BU)
              ME_MEM(7 + WI) = 1
            END IF
2390        WI = ME_MEM(WI)
          END DO
2360      PA = ME_MEM(PA)
        END DO
        CALL ST_DEALLOCATE(OLD)
      END IF
      CALL MP_SET_MAPPINGS(BU, 0)
      RETURN
      END
