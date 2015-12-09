function [bFun, b0Fun, derFun] = conAffPoint2PlaneSimpleOLS(prm, cst, obs)

% ------------------------------------------------------------------------------

bFun = @(obs) bFunNested(obs);

    function bBlock = bFunNested(obs)
       
        bBlock = obs.dp;
        
    end

% ------------------------------------------------------------------------------

b0Fun = @(prm, cst) b0FunNested(prm, cst);
    
    function b0Block = b0FunNested(prm, cst)
        
        % Affine matrices
        A1 = [prm.a111 prm.a121 prm.a131
              prm.a211 prm.a221 prm.a231
              prm.a311 prm.a321 prm.a331];
        
        A2 = [prm.a112 prm.a122 prm.a132
              prm.a212 prm.a222 prm.a232
              prm.a312 prm.a322 prm.a332];
        
        % Homogeneous transformation matrix
        H1 = homotrafo(1, A1, [prm.tx1 prm.ty1 prm.tz1]);
        H2 = homotrafo(1, A2, [prm.tx2 prm.ty2 prm.tz2]);
        
        % Coordinates
        X1 = [cst.x1 cst.y1 cst.z1];
        X2 = [cst.x2 cst.y2 cst.z2];

        % Normal vector
        n1 = [cst.nx1 cst.ny1 cst.nz1];
        
        % Transformation from cartesian coord. to homogeneous coord.
        X1_h = homocoord(X1);
        X2_h = homocoord(X2);
               
        b0Block = dot((homocoord((H1 * X1_h')') - homocoord((H2 * X2_h')'))', n1')';
        
    end

% Derivatives ------------------------------------------------------------------

derFun.prm.a111 = @(prm, cst) derFunNested(prm, cst, 'prm_a111');
derFun.prm.a121 = @(prm, cst) derFunNested(prm, cst, 'prm_a121');
derFun.prm.a131 = @(prm, cst) derFunNested(prm, cst, 'prm_a131');
derFun.prm.a211 = @(prm, cst) derFunNested(prm, cst, 'prm_a211');
derFun.prm.a221 = @(prm, cst) derFunNested(prm, cst, 'prm_a221');
derFun.prm.a231 = @(prm, cst) derFunNested(prm, cst, 'prm_a231');
derFun.prm.a311 = @(prm, cst) derFunNested(prm, cst, 'prm_a311');
derFun.prm.a321 = @(prm, cst) derFunNested(prm, cst, 'prm_a321');
derFun.prm.a331 = @(prm, cst) derFunNested(prm, cst, 'prm_a331');
derFun.prm.tx1  = @(prm, cst) derFunNested(prm, cst, 'prm_tx1');
derFun.prm.ty1  = @(prm, cst) derFunNested(prm, cst, 'prm_ty1');
derFun.prm.tz1  = @(prm, cst) derFunNested(prm, cst, 'prm_tz1');
                                                               
derFun.prm.a112 = @(prm, cst) derFunNested(prm, cst, 'prm_a112');
derFun.prm.a122 = @(prm, cst) derFunNested(prm, cst, 'prm_a122');
derFun.prm.a132 = @(prm, cst) derFunNested(prm, cst, 'prm_a132');
derFun.prm.a212 = @(prm, cst) derFunNested(prm, cst, 'prm_a212');
derFun.prm.a222 = @(prm, cst) derFunNested(prm, cst, 'prm_a222');
derFun.prm.a232 = @(prm, cst) derFunNested(prm, cst, 'prm_a232');
derFun.prm.a312 = @(prm, cst) derFunNested(prm, cst, 'prm_a312');
derFun.prm.a322 = @(prm, cst) derFunNested(prm, cst, 'prm_a322');
derFun.prm.a332 = @(prm, cst) derFunNested(prm, cst, 'prm_a332');
derFun.prm.tx2  = @(prm, cst) derFunNested(prm, cst, 'prm_tx2');
derFun.prm.ty2  = @(prm, cst) derFunNested(prm, cst, 'prm_ty2');
derFun.prm.tz2  = @(prm, cst) derFunNested(prm, cst, 'prm_tz2');

    function derFunBlock = derFunNested(prm, cst, var)
        
        switch var
            
            % ------------------------------------------------------------------
            
            case 'prm_a111'
                
                derFunBlock =   cst.x1 .* cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a121'
                
                derFunBlock =   cst.y1 .* cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a131'
                
                derFunBlock =   cst.z1 .* cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a211'
                
                derFunBlock =   cst.x1 .* cst.ny1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a221'
                
                derFunBlock =   cst.y1 .* cst.ny1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a231'
                
                derFunBlock =   cst.z1 .* cst.ny1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a311'
                
                derFunBlock =   cst.x1 .* cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a321'
                
                derFunBlock =   cst.y1 .* cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a331'
                
                derFunBlock =   cst.z1.* cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a112'
                
                derFunBlock = - cst.x2 .* cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a122'
                
                derFunBlock = - cst.y2 .* cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a132'
                
                derFunBlock = - cst.z2 .* cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a212'
                
                derFunBlock = - cst.x2 .* cst.ny1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a222'
                
                derFunBlock = - cst.y2 .* cst.ny1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a232'
                
                derFunBlock = - cst.z2 .* cst.ny1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a312'
                
                derFunBlock = - cst.x2 .* cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a322'
                
                derFunBlock = - cst.y2 .* cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_a332'
                
                derFunBlock = - cst.z2.* cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_tx1'

                derFunBlock =   cst.nx1;
        
            % ------------------------------------------------------------------
            
            case 'prm_tx2'

                derFunBlock = - cst.nx1;
                
            % ------------------------------------------------------------------
            
            case 'prm_ty1'

                derFunBlock =   cst.ny1;
                
            % ------------------------------------------------------------------
            
            case 'prm_ty2'

                derFunBlock = - cst.ny1;
                
            % ------------------------------------------------------------------
            
            case 'prm_tz1'

                derFunBlock =   cst.nz1;
                
            % ------------------------------------------------------------------
            
            case 'prm_tz2'

                derFunBlock = - cst.nz1;
                                        
        end
        
    end

end
